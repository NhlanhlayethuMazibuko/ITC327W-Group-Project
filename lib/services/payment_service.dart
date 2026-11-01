import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/core.dart';
import '../models/models.dart';
import 'application_service.dart';
import 'storage_service.dart';

class PaymentService {
  SupabaseClient get _db => Supabase.instance.client;
  static const bucket = 'payment-proofs';

  /// The payment row is created by management after approval. Null means nothing is due yet.
  Future<Payment?> current() async {
    final app = await ApplicationService().latest();
    if (app == null) return null;
    final rows = await _db.from(Db.payment).select().eq('application_id', app.id).limit(1);
    return rows.isEmpty ? null : Payment.fromMap(rows.first, app.number);
  }

  Future<BankDetails?> bankDetails() async {
    final rows = await _db.from(Db.bankDetails).select().limit(1);
    return rows.isEmpty ? null : BankDetails.fromMap(rows.first);
  }

  /// Only stores the proof. Management confirms the money has actually arrived.
  Future<void> submitProof(String paymentId, UploadFile file) async {
    final path = await StorageService().upload(bucket, paymentId, file);
    await _db.from(Db.payment).update({'proof_of_payment': path, 'payment_date': isoDate(DateTime.now())}).eq('payment_id', paymentId);
  }
}
