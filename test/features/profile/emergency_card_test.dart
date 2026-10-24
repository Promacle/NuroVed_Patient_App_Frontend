import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/models/family_member.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/profile/screens/emergency_card_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest(Map<String, dynamic> data) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: EmergencyCardView(data: data)),
      ),
    );
  }

  group('EmergencyCardView - Empty State & No Hardcoded Defaults', () {
    testWidgets('renders unverified badge and "Not provided" for empty data', (
      tester,
    ) async {
      ProfileController.resetForTesting(
        initialProfile: UserProfile.empty(),
        initialFamily: [],
      );

      final emptyData = <String, dynamic>{
        'blood': '',
        'allergies': <String>[],
        'chronicConditions': <String>[],
      };

      await tester.pumpWidget(createWidgetUnderTest(emptyData));
      await tester.pumpAndSettle();

      // 1. Verify "PATIENT-ENTERED, UNVERIFIED" badge exists
      expect(find.text('PATIENT-ENTERED, UNVERIFIED'), findsOneWidget);

      // 2. Verify "Not provided" appears for missing fields
      expect(
        find.text('Not provided'),
        findsNWidgets(3),
      ); // Blood, Allergies, Conditions

      // 3. Verify hardcoded "B+" or "None" NEVER appears
      expect(find.text('B+'), findsNothing);
      expect(find.text('None'), findsNothing);

      // 4. Verify emergency contact fallback
      expect(find.text('Not assigned'), findsOneWidget);
    });
  });

  group('EmergencyCardView - Partial State', () {
    testWidgets(
      'renders provided blood group and "Not provided" for absent allergies',
      (tester) async {
        ProfileController.resetForTesting(
          initialProfile: UserProfile.empty(),
          initialFamily: [],
        );

        final partialData = <String, dynamic>{
          'blood': 'AB-',
          'allergies': <String>[],
          'chronicConditions': <String>['Asthma'],
        };

        await tester.pumpWidget(createWidgetUnderTest(partialData));
        await tester.pumpAndSettle();

        expect(find.text('AB-'), findsOneWidget);
        expect(find.text('Asthma'), findsOneWidget);
        expect(find.text('Not provided'), findsOneWidget); // For allergies
      },
    );
  });

  group('EmergencyCardView - Full State with Emergency Contact', () {
    testWidgets(
      'renders complete clinical data and designated emergency contact',
      (tester) async {
        const emergencyContact = FamilyMember(
          id: 'contact-uuid-1',
          name: 'Sarah Connor',
          relation: 'Sister',
          isEmergencyContact: true,
          phone: '+919876500000',
        );

        ProfileController.resetForTesting(
          initialProfile: const UserProfile(
            id: 'u1',
            name: 'John Connor',
            email: 'john@sky.net',
            phone: '+919876511111',
            dateOfBirth: '28/02/1985',
            gender: 'male',
            height: '180',
            weight: '80',
            bloodGroup: 'O-',
            allergies: ['Peanuts', 'Sulfa'],
            chronicConditions: ['Hypertension'],
          ),
          initialFamily: [emergencyContact],
        );

        final fullData = <String, dynamic>{
          'blood': 'O-',
          'allergies': ['Peanuts', 'Sulfa'],
          'chronicConditions': ['Hypertension'],
        };

        await tester.pumpWidget(createWidgetUnderTest(fullData));
        await tester.pumpAndSettle();

        // Clinical info
        expect(find.text('O-'), findsOneWidget);
        expect(find.text('Peanuts, Sulfa'), findsOneWidget);
        expect(find.text('Hypertension'), findsOneWidget);

        // Emergency Contact
        expect(find.text('Sarah Connor'), findsOneWidget);
        expect(find.text('Sister (Emergency Contact)'), findsOneWidget);
        expect(find.text('+919876500000'), findsOneWidget);

        // Badge
        expect(find.text('PATIENT-ENTERED, UNVERIFIED'), findsOneWidget);
      },
    );
  });
}
