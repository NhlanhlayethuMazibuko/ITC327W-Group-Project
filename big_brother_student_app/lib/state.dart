import 'dart:async';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config.dart';

typedef M = Map<String, dynamic>;

/// Single app-wide state. Uses Supabase when SUPABASE_ANON_KEY is supplied,
/// otherwise runs in demo mode with in-memory data.
class AppState extends ChangeNotifier {
  SupabaseClient? get sb => Config.configured ? Supabase.instance.client : null;

  M user = {};
  String? _pw;
  String? pendingEmail;
  String roomQuery = '';
  M? application;
  M? payment;
  List<M> rooms = _demoRooms();
  List<M> viewings = [], notifs = [], maint = [], announcements = [
    {'title': 'New accomodation units available!', 'message': "Don't miss out on our latest listings."}
  ];
  List<M> reviews = [
    {'student_name': 'Thabo Mufukeng', 'rating': 4, 'comment': ''},
    {'student_name': 'Zintle Belani', 'rating': 2, 'comment': ''},
  ];
  final _rnd = Random();
  final List<StreamSubscription> _subs = [];

  static const requiredDocs = {
    'id': 'ID Copy',
    'registration': 'Proof of Registration',
    'funding': 'Funding Approval / Parent Payslip',
  };

  static List<M> _demoRooms() => [
        _room('r1', '1-Bedroom Apartment'),
        _room('r2', '2-Bedroom Apartment'),
        _room('r3', 'Single with Balcony'),
      ];
  static M _room(String id, String type) => {
        'room_id': id, 'room_name': 'Unit', 'room_type': type, 'price': 4500, 'availability_status': true,
        'description': 'A private,comfortable room with a bed,study desk, storage space and an access to shared accommodation facilities',
        'wifi': true, 'laundry': true, 'security': true, 'shuttle': true, 'furniture': true, 'images': [],
      };

  void refresh() => notifyListeners();

  bool get hasSession => sb?.auth.currentSession != null;
  String get firstName => ((user['name'] ?? '') as String).trim().isEmpty ? 'Student' : (user['name'] as String).trim().split(' ').first;
  String _code(int n) => List.generate(n, (_) => 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'[_rnd.nextInt(32)]).join();
  String get _yymmdd { final d = DateTime.now(); return '${d.year % 100}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}'; }

  int get applicationStage {
    final s = (application?['status_name'] ?? '').toString().toLowerCase();
    if (application == null) return 0;
    if (s.contains('approv')) return 7;
    if (s.contains('review')) return 6;
    return 5;
  }

  List<String> get pendingDocs {
    final got = ((application?['docs'] ?? []) as List).cast<String>();
    return requiredDocs.entries.where((e) => !got.contains(e.key)).map((e) => e.value).toList();
  }

  num get amountDue => (application?['price'] ?? 4500) as num;

  // ---------------------------------------------------------------- auth
  Future<void> restore() async {
    if (hasSession) await _afterLogin();
  }

  Future<String?> register(String name, String email, String sn, String pw) async {
    try {
      await sb?.auth.signUp(email: email, password: pw, data: {'full_name': name, 'student_number': sn, 'role': 'student'});
      user = {'name': name, 'email': email, 'student_number': sn, 'phone': ''};
      _pw = pw;
      pendingEmail = email;
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<String?> verify(String code, {bool recovery = false}) async {
    if (code.length != 6) return 'Enter the 6-digit verification code.';
    try {
      if (sb != null) {
        await sb!.auth.verifyOTP(email: pendingEmail!, token: code, type: recovery ? OtpType.recovery : OtpType.signup);
        if (!recovery) await _afterLogin();
      } else if (!recovery) {
        _seed();
      }
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Invalid or expired code.';
    }
  }

  Future<void> resend({bool recovery = false}) async {
    try {
      if (sb == null || pendingEmail == null) return;
      if (recovery) {
        await sb!.auth.resetPasswordForEmail(pendingEmail!);
      } else {
        await sb!.auth.resend(type: OtpType.signup, email: pendingEmail!);
      }
    } catch (_) {}
  }

  Future<String?> login(String email, String pw) async {
    try {
      if (sb != null) {
        await sb!.auth.signInWithPassword(email: email, password: pw);
        await _afterLogin();
      } else {
        if (pw.length < 6 || (_pw != null && user['email'] == email && pw != _pw)) return 'Incorrect Password';
        if (user['email'] != email) user = {'name': email.split('@').first, 'email': email, 'student_number': '', 'phone': ''};
        _seed();
      }
      notifyListeners();
      return null;
    } on AuthException catch (e) {
      return e.message.toLowerCase().contains('invalid') ? 'Incorrect Password' : e.message;
    } catch (_) {
      return 'Could not log in. Check your connection.';
    }
  }

  Future<String?> sendReset(String email) async {
    try {
      pendingEmail = email;
      await sb?.auth.resetPasswordForEmail(email);
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not send reset code.';
    }
  }

  Future<String?> setNewPassword(String pw) async {
    try {
      if (sb != null) {
        await sb!.auth.updateUser(UserAttributes(password: pw));
        await sb!.auth.signOut();
      }
      _pw = pw;
      return null;
    } on AuthException catch (e) {
      return e.message;
    } catch (_) {
      return 'Could not update password.';
    }
  }

  Future<void> logout() async {
    for (final s in _subs) { await s.cancel(); }
    _subs.clear();
    try { await sb?.auth.signOut(); } catch (_) {}
    application = null; payment = null; viewings = []; notifs = []; maint = []; user = {};
    notifyListeners();
  }

  // ---------------------------------------------------------------- loading
  Future<void> _afterLogin() async {
    final u = sb!.auth.currentUser!;
    user = {'name': u.userMetadata?['full_name'] ?? '', 'email': u.email ?? '', 'student_number': u.userMetadata?['student_number'] ?? '', 'phone': ''};
    try {
      final s = await sb!.from('student').select().eq('user_id', u.id).maybeSingle();
      if (s != null) {
        user = {...user, 'student_id': s['student_id'], 'name': s['full_name'] ?? user['name'], 'phone': s['phone_number'] ?? '', 'student_number': s['student_number'] ?? user['student_number']};
      }
    } catch (e) { debugPrint('profile: $e'); }
    await loadAll();
    _listen();
  }

  Future<void> loadAll() async {
    if (sb == null) return;
    try {
      final rs = await sb!.from('room').select('*, room_image(image_path)').order('price');
      rooms = rs.map<M>((r) {
        final m = M.from(r);
        m['images'] = ((r['room_image'] ?? []) as List).map((i) => sb!.storage.from('room-images').getPublicUrl(i['image_path'])).toList();
        return m;
      }).toList();
      final an = await sb!.from('announcement').select().order('created_at', ascending: false).limit(5);
      if (an.isNotEmpty) announcements = List<M>.from(an);
      final rv = await sb!.from('review').select('*, student(full_name)').order('created_at', ascending: false).limit(20);
      reviews = rv.map<M>((r) => {...M.from(r), 'student_name': r['student']?['full_name'] ?? 'Student'}).toList();
      final sid = user['student_id'];
      if (sid != null) {
        final a = await sb!.from('application').select('*, application_status(status_name), room(room_name, price)').eq('student_id', sid).order('application_date', ascending: false).limit(1);
        if (a.isEmpty) {
          application = null;
        } else {
          final docs = await sb!.from('document').select('document_type').eq('application_id', a.first['application_id']);
          application = {...M.from(a.first), 'status_name': a.first['application_status']?['status_name'] ?? 'Submitted', 'room_name': a.first['room']?['room_name'], 'price': a.first['room']?['price'] ?? 4500, 'docs': docs.map((d) => d['document_type']).toList()};
        }
        viewings = List<M>.from(await sb!.from('booking').select().eq('student_id', sid).order('created_at', ascending: false));
        notifs = List<M>.from(await sb!.from('notification').select().eq('student_id', sid).order('created_at', ascending: false));
        maint = List<M>.from(await sb!.from('maintenance_requests').select().eq('student_id', sid).order('created_at', ascending: false));
      }
    } catch (e) { debugPrint('loadAll: $e'); }
    notifyListeners();
  }

  /// Real-time: management actions in ASP.NET appear instantly here.
  void _listen() {
    final sid = user['student_id'];
    if (sb == null || sid == null) return;
    for (final t in ['application', 'booking', 'notification', 'maintenance_requests']) {
      try {
        _subs.add(sb!.from(t).stream(primaryKey: [t == 'application' ? 'application_id' : t == 'booking' ? 'booking_id' : t == 'notification' ? 'notification_id' : 'request_id']).eq('student_id', sid).listen((_) => loadAll()));
      } catch (e) { debugPrint('stream $t: $e'); }
    }
  }

  void _seed() {
    if (notifs.isNotEmpty) return;
    notifs = [
      {'notification_id': 'n1', 'title': 'Secure Your Space Today!', 'message': 'Apply for accommodation using our easy online application process.', 'is_read': true, 'created_at': DateTime(2026, 10, 2).toIso8601String()},
      {'notification_id': 'n2', 'title': 'New Units Available!', 'message': 'Hurry Up! New units are available. Check the Rooms Available tab.', 'is_read': true, 'created_at': DateTime(2026, 10, 2).toIso8601String()},
    ];
  }

  void _notify(String title, String msg) {
    if (sb == null) notifs.insert(0, {'notification_id': _code(6), 'title': title, 'message': msg, 'is_read': false, 'created_at': DateTime.now().toIso8601String()});
  }

  // ---------------------------------------------------------------- actions
  Future<String?> uploadFile(String bucket, String path, PlatformFile f) async {
    if (sb == null || f.bytes == null) return f.name;
    await sb!.storage.from(bucket).uploadBinary(path, f.bytes!, fileOptions: const FileOptions(upsert: true));
    return path;
  }

  Future<String?> submitApplication(M f, Map<String, PlatformFile> docs, M? room) async {
    final number = 'BB-APP-2026-${(_rnd.nextInt(9000) + 1000)}';
    try {
      if (sb != null) {
        final sid = user['student_id'];
        await sb!.from('student').update({
          'full_name': f['name'], 'phone_number': f['phone'], 'date_of_birth': f['dob'], 'institution': f['institution'],
          'year_of_study': f['year'], 'nsfas_funded': f['nsfas'], 'guardian_name': f['g_name'], 'guardian_email': f['g_email'],
          'guardian_contact': f['g_phone'], 'relationship': f['g_rel'],
        }).eq('student_id', sid);
        final st = await sb!.from('application_status').select('status_id').eq('status_name', 'Submitted').single();
        final ins = await sb!.from('application').insert({
          'student_id': sid, 'room_id': room?['room_id'], 'status_id': st['status_id'],
          'application_number': number, 'application_date': ymdNow(),
        }).select().single();
        for (final e in docs.entries) {
          final p = await uploadFile('documents', '$sid/${ins['application_id']}/${e.key}_${e.value.name}', e.value);
          await sb!.from('document').insert({'application_id': ins['application_id'], 'document_type': e.key, 'file_path': p});
        }
        user = {...user, 'name': f['name'], 'phone': f['phone']};
        await loadAll();
      } else {
        user = {...user, 'name': f['name'], 'phone': f['phone']};
        application = {'application_number': number, 'status_name': 'Submitted', 'room_name': room?['room_name'], 'price': room?['price'] ?? 4500, 'docs': docs.keys.toList(), 'room_id': room?['room_id']};
        _notify('Application Submitted', 'Your application $number has been received and is awaiting review.');
      }
      notifyListeners();
      return null;
    } catch (e) {
      return 'Could not submit application: $e';
    }
  }

  String ymdNow() { final d = DateTime.now(); return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}'; }

  Future<String?> bookViewing(M v) async {
    final ref = 'BB-VW-$_yymmdd-${_code(4)}';
    final d = v['date'] as DateTime;
    final row = {
      'reference_code': ref, 'booking_date': '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
      'preferred_time': v['preferred_time'], 'alternative_time': v['alternative_time'], 'room_type': v['room_type'], 'booking_status': 'Pending',
    };
    try {
      if (sb != null) {
        await sb!.from('booking').insert({...row, 'student_id': user['student_id']});
        await loadAll();
      } else {
        viewings.insert(0, row);
      }
      notifyListeners();
      return ref;
    } catch (_) {
      return null;
    }
  }

  Future<String?> submitMaintenance(M m, PlatformFile? photo) async {
    final ref = 'BB-MNT-2026-${(maint.length + 1).toString().padLeft(3, '0')}';
    try {
      String? path;
      final row = {'reference_code': ref, 'category': m['category'], 'priority': m['priority'], 'request_type': m['type'], 'description': m['description'], 'status': 'Pending'};
      if (sb != null) {
        if (photo != null) path = await uploadFile('maintenance', '${user['student_id']}/$ref-${photo.name}', photo);
        await sb!.from('maintenance_requests').insert({...row, 'student_id': user['student_id'], 'photo_path': path});
        await loadAll();
      } else {
        maint.insert(0, {...row, 'photo_path': photo?.name, 'created_at': DateTime.now().toIso8601String()});
      }
      notifyListeners();
      return ref;
    } catch (_) {
      return null;
    }
  }

  Future<bool> submitReview(int rating, String comment) async {
    try {
      if (sb != null) {
        await sb!.from('review').insert({'student_id': user['student_id'], 'rating': rating, 'comment': comment});
        await loadAll();
      } else {
        reviews.insert(0, {'student_name': user['name'] ?? 'You', 'rating': rating, 'comment': comment});
      }
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> submitPayment(String method, PlatformFile proof) async {
    final appNo = (application?['application_number'] ?? 'BB-APP-2026-0000') as String;
    try {
      String? path;
      if (sb != null) {
        path = await uploadFile('payments', '${user['student_id']}/$appNo-${proof.name}', proof);
        await sb!.from('payment').insert({'application_id': application?['application_id'], 'amount': amountDue, 'payment_method': method, 'payment_status': 'Pending Verification', 'payment_date': ymdNow(), 'payment_reference': appNo, 'proof_of_payment': path});
      }
      payment = {'amount': amountDue, 'payment_method': method, 'payment_reference': appNo, 'reference_code': 'BB-PAY-${appNo.split('-').last}', 'payment_status': 'Pending Verification', 'submitted': DateTime.now(), 'file': proof.name};
      _notify('Proof of payment received', 'Your payment is under review by management.');
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> markRead({String? id}) async {
    for (final n in notifs) { if (id == null || n['notification_id'] == id) n['is_read'] = true; }
    notifyListeners();
    try {
      if (sb != null) {
        final q = sb!.from('notification').update({'is_read': true}).eq('student_id', user['student_id']);
        await (id == null ? q : q.eq('notification_id', id));
      }
    } catch (_) {}
  }
}

final app = AppState();
