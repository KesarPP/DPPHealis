import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dpp_app/models/coach_profile.dart';
import 'package:dpp_app/services/auth_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CoachProfile Model Tests', () {
    test('fromMap should fallback to default values for default/mock coach accounts', () {
      final profile = CoachProfile.fromMap(
        {'uid': 'test_coach_1'},
        defaultName: 'Dr. Sarah Mitchell',
        defaultEmail: 'coach@healis.org',
      );

      expect(profile.uid, 'test_coach_1');
      expect(profile.name, 'Dr. Sarah Mitchell');
      expect(profile.email, 'coach@healis.org');
      expect(profile.title, 'Senior Health Coach & Nutritionist');
      expect(profile.about, contains(' preventative health'));
      expect(profile.specializations, contains('Nutrition'));
      expect(profile.credentials.length, 3);
      expect(profile.credentials[0]['title'], 'Board Certified Health Coach');
    });

    test('fromMap should return empty fields for a new coach account', () {
      final profile = CoachProfile.fromMap(
        {'uid': 'new_coach_123'},
        defaultName: 'Dr. John Doe',
        defaultEmail: 'john.doe@healis.org',
      );

      expect(profile.uid, 'new_coach_123');
      expect(profile.name, 'Dr. John Doe');
      expect(profile.email, 'john.doe@healis.org');
      expect(profile.title, isEmpty);
      expect(profile.about, isEmpty);
      expect(profile.specializations, isEmpty);
      expect(profile.credentials, isEmpty);
    });

    test('toMap and fromMap serialization roundtrip', () {
      final original = CoachProfile(
        uid: 'coach_xyz',
        name: 'Dr. John Doe',
        email: 'john.doe@healis.org',
        title: 'Lead Endocrinologist',
        about: 'Endocrine health expert.',
        specializations: ['Diabetes', 'Hormones'],
        credentials: [
          {'title': 'MD', 'subtitle': 'Harvard', 'icon': 'school'}
        ],
        localImagePath: '/path/to/img.png',
      );

      final map = original.toMap();
      final deserialized = CoachProfile.fromMap(
        map,
        defaultName: 'Fallback Name',
        defaultEmail: 'fallback@healis.org',
      );

      expect(deserialized.uid, 'coach_xyz');
      expect(deserialized.name, 'Dr. John Doe');
      expect(deserialized.email, 'john.doe@healis.org');
      expect(deserialized.title, 'Lead Endocrinologist');
      expect(deserialized.about, 'Endocrine health expert.');
      expect(deserialized.specializations, equals(['Diabetes', 'Hormones']));
      expect(deserialized.credentials.length, 1);
      expect(deserialized.credentials[0]['title'], 'MD');
      expect(deserialized.localImagePath, '/path/to/img.png');
    });
  });

  group('AuthService Coach Profile Methods Tests', () {
    test('saveCoachProfile and getCoachProfile should retrieve from local cache when Firestore is absent', () async {
      final service = AuthService();
      final profile = CoachProfile(
        uid: 'coach_123',
        name: 'Dr. Elizabeth Blackwell',
        email: 'elizabeth@healis.org',
        title: 'Pioneer Coach',
        about: 'First female physician profile.',
        specializations: ['Primary Care'],
        credentials: [
          {'title': 'MD', 'subtitle': 'Geneva Medical College', 'icon': 'school'}
        ],
        localImagePath: '/path/to/photo.jpg',
      );

      await service.saveCoachProfile(profile);

      final fetched = await service.getCoachProfile('coach_123');

      expect(fetched.uid, 'coach_123');
      expect(fetched.name, 'Dr. Elizabeth Blackwell');
      expect(fetched.title, 'Pioneer Coach');
      expect(fetched.about, 'First female physician profile.');
      expect(fetched.specializations, equals(['Primary Care']));
      expect(fetched.credentials[0]['title'], 'MD');
      expect(fetched.localImagePath, '/path/to/photo.jpg');
    });

    test('getFirstCoachProfile should fall back to last_coach_profile', () async {
      final service = AuthService();
      final profile = CoachProfile(
        uid: 'coach_last',
        name: 'Dr. Last Coach',
        email: 'last@healis.org',
        title: 'Senior Practitioner',
        about: 'About last coach.',
        specializations: ['Geriatrics'],
        credentials: [],
      );

      await service.saveCoachProfile(profile);

      final fetched = await service.getFirstCoachProfile();

      expect(fetched.uid, 'coach_last');
      expect(fetched.name, 'Dr. Last Coach');
    });
  });
}
