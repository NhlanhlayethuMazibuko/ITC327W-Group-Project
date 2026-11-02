import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import 'package:big_brother_student_app/core/utils/format.dart';
import 'package:big_brother_student_app/models/models.dart';
import 'package:big_brother_student_app/services/application_service.dart';
import 'package:big_brother_student_app/services/auth_service.dart';

// These cover the places where the app and the ASP.NET site store the same
// data differently, so a change on either side shows up here.
void main() {
  group('statusLabel', () {
    test('tidies stored values', () {
      expect(statusLabel('awaiting_verification'), 'Awaiting Verification');
      expect(statusLabel('verified'), 'Verified');
      expect(statusLabel('Under Review'), 'Under Review');
    });

    test('treats the web and app words for a new viewing the same', () {
      expect(statusLabel('Requested'), statusLabel('Pending'));
    });

    test('shows a saved payment preference as awaiting payment', () {
      expect(statusLabel('preference_saved'), 'Awaiting Payment');
    });
  });

  group('Room.fromMap', () {
    test('uses the web admin amenity flags when the jsonb list is empty', () {
      final room = Room.fromMap({
        'room_id': 'r1',
        'room_type': 'Single Room',
        'price': 4000,
        'availability_status': true,
        'amenities': <String>[],
        'wifi': true,
        'laundry': false,
        'security': true,
        'shuttle': false,
        'furniture': true,
      });
      expect(room.wifi, isTrue);
      expect(room.laundry, isFalse);
      expect(room.security, isTrue);
      expect(room.furniture, isTrue);
    });

    test('prefers the jsonb amenity list when it has entries', () {
      final room = Room.fromMap({'room_id': 'r2', 'amenities': ['Laundry'], 'wifi': true});
      expect(room.laundry, isTrue);
      expect(room.wifi, isFalse);
    });
  });

  group('Viewing.fromMap', () {
    test('reads room type and gender from their columns', () {
      final v = Viewing.fromMap({
        'booking_id': 'b1',
        'room_type': 'Sharing',
        'gender': 'Female',
        'message': 'Room type: Singles; Gender: Male',
      });
      expect(v.roomType, 'Sharing');
      expect(v.gender, 'Female');
    });

    test('falls back to the message on older bookings', () {
      final v = Viewing.fromMap({'booking_id': 'b2', 'message': viewingMessage('Bachelors', 'Male')});
      expect(v.roomType, 'Bachelors');
      expect(v.gender, 'Male');
    });
  });

  group('AuthService.friendlyMessage', () {
    test('explains a failed verification email instead of a generic error', () {
      final m = AuthService.friendlyMessage(const AuthException('Error sending confirmation email'));
      expect(m, contains('was not created'));
    });

    test('wrong password stays a plain credentials message', () {
      final m = AuthService.friendlyMessage(const AuthException('Invalid login credentials'));
      expect(m, startsWith('Incorrect email or password'));
    });
  });

  group('ApplicationService.canChange', () {
    Application app(int statusId) =>
        Application.fromMap({'application_id': 'a', 'application_number': 'BB-APP-1', 'status_id': statusId});

    test('allows edit/delete while submitted or draft', () {
      expect(ApplicationService.canChange(app(kStatusSubmitted)), isTrue);
      expect(ApplicationService.canChange(app(kStatusDraft)), isTrue);
    });

    test('locks once management is reviewing or has decided', () {
      expect(ApplicationService.canChange(app(2)), isFalse);
      expect(ApplicationService.canChange(app(kStatusApproved)), isFalse);
      expect(ApplicationService.canChange(app(4)), isFalse);
    });
  });
}
