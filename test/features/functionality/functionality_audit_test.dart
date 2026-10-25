import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/app/app_router.dart';
import 'package:nuroved_patient/core/models/family_member.dart';
import 'package:nuroved_patient/core/models/medical_record.dart';
import 'package:nuroved_patient/core/models/user_profile.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_profile_repository.dart';
import 'package:nuroved_patient/core/repositories/fake/fake_records_repository.dart';
import 'package:nuroved_patient/core/utils/platform_file.dart';
import 'package:nuroved_patient/features/diet/controllers/diet_controller.dart';
import 'package:nuroved_patient/features/diet/screens/meal_routine_history_screen.dart';
import 'package:nuroved_patient/features/family/controllers/family_controller.dart';
import 'package:nuroved_patient/features/family/screens/add_family_member_screen.dart';
import 'package:nuroved_patient/features/family/screens/edit_family_member_screen.dart';
import 'package:nuroved_patient/features/family/screens/family_profile_screen.dart';
import 'package:nuroved_patient/features/profile/controllers/profile_controller.dart';
import 'package:nuroved_patient/features/profile/screens/emergency_card_screen.dart';
import 'package:nuroved_patient/features/records/controllers/records_controller.dart';
import 'package:nuroved_patient/features/records/screens/records_screen.dart';
import 'package:nuroved_patient/features/routine/controllers/routine_controller.dart';
import 'package:nuroved_patient/features/routine/screens/add_medicine_screen.dart';
import 'package:nuroved_patient/features/routine/screens/edit_routine_screen.dart';
import 'package:nuroved_patient/features/visits/controllers/visits_controller.dart';
import 'package:nuroved_patient/features/visits/screens/add_visit_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Uint8List kTestTransparentPng = Uint8List.fromList([
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
]);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeProfileRepository fakeProfileRepo;
  late FakeRecordsRepository fakeRecordsRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    final initialProfile = const UserProfile(
      id: 'test-patient-primary-id',
      name: 'Primary Patient',
      email: 'patient@example.com',
      phone: '+919876543210',
      dateOfBirth: '1990-01-01',
      gender: 'Male',
      height: '175',
      weight: '70',
      bloodGroup: 'O+',
      allergies: ['Dust'],
      chronicConditions: ['None'],
    );

    final initialMember = const FamilyMember(
      id: 'member-001',
      name: 'Jane Doe',
      relation: 'Spouse',
      phone: '+919876543211',
      isEmergencyContact: true,
      bloodGroup: 'A+',
    );

    fakeProfileRepo = FakeProfileRepository(
      initialProfile: initialProfile,
      initialFamily: [initialMember],
    );

    ProfileController.resetForTesting(
      repository: fakeProfileRepo,
      initialProfile: initialProfile,
      initialFamily: [initialMember],
    );

    fakeRecordsRepo = FakeRecordsRepository(
      initialRecords: [
        MedicalRecord(
          id: 'rec-001',
          subjectId: 'test-patient-primary-id',
          title: 'Blood Test Results',
          profileName: 'Self',
          recordType: 'Lab Report',
          date: '10 Oct 2026',
          doctorName: 'Dr. Smith',
          description: 'Routine blood panel',
        ),
      ],
    );
    RecordsController.resetForTesting(repository: fakeRecordsRepo);
    await RecordsController.instance.loadRecords();

    VisitsController.resetForTesting();
    RoutineController.resetForTesting();
    DietController().deleteDietPlan();
  });

  group(
    'Domain Model & Controller: FamilyMember avatar image preservation',
    () {
      test(
        'FamilyMember retains AppPlatformFile across copyWith and getters',
        () {
          final platformFile = AppPlatformFile(
            bytes: kTestTransparentPng,
            name: 'avatar.png',
            size: kTestTransparentPng.length,
          );

          final member = FamilyMember(
            id: 'member-img-001',
            name: 'Bob',
            relation: 'Brother',
            imageFile: platformFile,
          );

          expect(member.imageFile, isNotNull);
          expect(member.imageFile?.name, equals('avatar.png'));
          expect(member.imageFile?.bytes, equals(kTestTransparentPng));

          final copied = member.copyWith(name: 'Bobby');
          expect(copied.name, equals('Bobby'));
          expect(copied.imageFile, isNotNull);
          expect(copied.imageFile?.name, equals('avatar.png'));
        },
      );

      test(
        'FamilyController forwards imageFile to ProfileController correctly',
        () async {
          final familyController = FamilyController();
          final platformFile = AppPlatformFile(
            bytes: kTestTransparentPng,
            name: 'profile_pic.png',
            size: kTestTransparentPng.length,
          );

          final result = await familyController.addFamilyMember({
            'name': 'Sister Alice',
            'relation': 'Sister',
            'age': '28',
            'gender': 'Female',
            'isEmergencyContact': false,
            'imageFile': platformFile,
          });

          expect(result.isSuccess, isTrue);

          final addedMember = ProfileController.instance.familyMembersList
              .firstWhere((m) => m.name == 'Sister Alice');
          expect(addedMember.imageFile, isNotNull);
          expect(addedMember.imageFile?.name, equals('profile_pic.png'));

          final legacyMap = ProfileController.instance.familyMembers.firstWhere(
            (m) => m['name'] == 'Sister Alice',
          );
          expect(legacyMap['imageFile'], isNotNull);
        },
      );
    },
  );

  group(
    'AddFamilyMemberScreen & EditFamilyMemberScreen: Form Validation and Feedback',
    () {
      testWidgets(
        'AddFamilyMemberScreen validates empty name and shows error SnackBar',
        (tester) async {
          await tester.pumpWidget(
            const MaterialApp(home: AddFamilyMemberScreen()),
          );
          await tester.pumpAndSettle();

          await tester.ensureVisible(find.text('Add New Profile'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Add New Profile'));
          await tester.pumpAndSettle();

          expect(find.text('Please enter a name'), findsOneWidget);
        },
      );

      testWidgets(
        'AddFamilyMemberScreen saves valid member and shows confirmation SnackBar',
        (tester) async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (ctx) => ElevatedButton(
                    onPressed: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => const AddFamilyMemberScreen(),
                      ),
                    ),
                    child: const Text('Open Add Screen'),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Open Add Screen'));
          await tester.pumpAndSettle();

          // Enter name
          await tester.enterText(find.byType(TextField).first, 'Uncle Leo');
          await tester.pumpAndSettle();

          await tester.ensureVisible(find.text('Add New Profile'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Add New Profile'));
          await tester.pumpAndSettle();

          expect(
            find.text('Family member added successfully!'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'EditFamilyMemberScreen validates empty name and shows error SnackBar',
        (tester) async {
          final member = {
            'id': 'member-001',
            'name': 'Jane Doe',
            'relation': 'Spouse',
            'phone': '+919876543211',
          };

          await tester.pumpWidget(
            MaterialApp(
              home: EditFamilyMemberScreen(memberData: member, index: 0),
            ),
          );
          await tester.pumpAndSettle();

          // Clear the name field
          await tester.enterText(find.byType(TextField).first, '');
          await tester.pumpAndSettle();

          await tester.ensureVisible(find.text('Save'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          expect(find.text('Name cannot be empty'), findsOneWidget);
        },
      );

      testWidgets(
        'EditFamilyMemberScreen saves updated member and shows confirmation SnackBar',
        (tester) async {
          final member = {
            'id': 'member-001',
            'name': 'Jane Doe',
            'relation': 'Spouse',
            'phone': '+919876543211',
          };

          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Builder(
                  builder: (ctx) => ElevatedButton(
                    onPressed: () => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => EditFamilyMemberScreen(
                          memberData: member,
                          index: 0,
                        ),
                      ),
                    ),
                    child: const Text('Open Edit Screen'),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Open Edit Screen'));
          await tester.pumpAndSettle();

          await tester.enterText(find.byType(TextField).first, 'Jane Updated');
          await tester.pumpAndSettle();

          await tester.ensureVisible(find.text('Save'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Save'));
          await tester.pumpAndSettle();

          expect(
            find.text('Family member updated successfully!'),
            findsOneWidget,
          );
        },
      );
    },
  );

  group(
    'MealRoutineHistoryScreen: Destructive Healthcare Action Confirmation',
    () {
      testWidgets(
        'Tapping delete opens confirmation dialog, canceling preserves plan',
        (tester) async {
          final samplePlan = {
            'days': [
              {
                'day': 'Day 1 Monday',
                'meals': [
                  {'name': 'Oatmeal', 'calories': 250, 'time': '8:00 AM'},
                ],
              },
            ],
          };
          DietController().saveDietPlan(samplePlan);

          await tester.pumpWidget(
            const MaterialApp(home: MealRoutineHistoryScreen()),
          );
          await tester.pumpAndSettle();

          expect(find.text('Weekly Meal Plan'), findsOneWidget);

          await tester.ensureVisible(find.text('Delete'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          // Confirmation dialog is visible
          expect(find.text('Delete Diet Plan?'), findsOneWidget);
          expect(
            find.text(
              'Are you sure you want to delete your saved meal routine? This will clear all weekly meal schedule data.',
            ),
            findsOneWidget,
          );

          // Tap Cancel
          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();

          // Plan must still be preserved
          expect(DietController().hasSavedPlan, isTrue);
          expect(find.text('Weekly Meal Plan'), findsOneWidget);
        },
      );

      testWidgets(
        'Confirming delete purges plan and shows confirmation SnackBar',
        (tester) async {
          final samplePlan = {
            'days': [
              {
                'day': 'Day 1 Monday',
                'meals': [
                  {'name': 'Oatmeal', 'calories': 250, 'time': '8:00 AM'},
                ],
              },
            ],
          };
          DietController().saveDietPlan(samplePlan);

          await tester.pumpWidget(
            const MaterialApp(home: MealRoutineHistoryScreen()),
          );
          await tester.pumpAndSettle();

          await tester.ensureVisible(find.text('Delete'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Delete'));
          await tester.pumpAndSettle();

          // Tap Delete in confirmation dialog
          await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
          await tester.pumpAndSettle();

          expect(DietController().hasSavedPlan, isFalse);
          expect(find.text('Diet plan deleted successfully'), findsOneWidget);
        },
      );
    },
  );

  group('AddMedicineScreen: Submission Debounce and Feedback', () {
    testWidgets('Empty fields show validation warning SnackBar', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddMedicineScreen()));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save Reminder'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Reminder'));
      await tester.pumpAndSettle();

      expect(
        find.text('Please select profile and enter medicine name'),
        findsOneWidget,
      );
    });
  });

  group('RecordsScreen: Medical Record Deletion Confirmation and Feedback', () {
    testWidgets(
      'Deleting record shows dialog and confirmation SnackBar on confirm',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: RecordsScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Blood Test Results'), findsAtLeastNWidgets(1));

        // Find delete button on RecordCard
        final deleteIcon = find.byIcon(Icons.delete_outline_rounded);
        expect(deleteIcon, findsOneWidget);
        await tester.tap(deleteIcon);
        await tester.pumpAndSettle();

        // Confirmation dialog is shown
        expect(find.text('Delete Medical Record?'), findsOneWidget);

        // Confirm deletion
        await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
        await tester.pumpAndSettle();

        expect(find.text('Record deleted successfully'), findsOneWidget);
      },
    );
  });

  group('FamilyProfilesScreen: Member Deletion Feedback', () {
    testWidgets('Deleting family member displays confirmation SnackBar', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: FamilyProfilesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Jane Doe'), findsOneWidget);
      final deleteBtn = find.byIcon(Icons.close);
      expect(deleteBtn, findsOneWidget);
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      expect(find.text('Remove Profile?'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(
        find.text('Removed "Jane Doe" from family profiles.'),
        findsOneWidget,
      );
    });
  });

  group('EditRoutineScreen & AddVisitScreen: Feedback SnackBars', () {
    testWidgets(
      'EditRoutineScreen validates empty meal name and shows error SnackBar',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: EditRoutineScreen(
              title: 'Breakfast',
              time: '08:00 AM',
              mealName: 'Oats',
              ingredients: ['Milk', 'Honey'],
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap edit note icon to enter meal name edit mode
        final editIcon = find.byIcon(Icons.edit_note_rounded);
        expect(editIcon, findsOneWidget);
        await tester.tap(editIcon);
        await tester.pumpAndSettle();

        // Clear meal name and attempt to save
        final mealNameField = find.byType(TextField).first;
        await tester.enterText(mealNameField, '');
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Save Meal'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save Meal'));
        await tester.pumpAndSettle();

        expect(find.text('Meal name cannot be empty'), findsOneWidget);
      },
    );

    testWidgets(
      'EditRoutineScreen updates meal and displays confirmation SnackBar',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const EditRoutineScreen(
                        title: 'Breakfast',
                        time: '08:00 AM',
                        mealName: 'Oats',
                        ingredients: ['Milk', 'Honey'],
                      ),
                    ),
                  ),
                  child: const Text('Open Edit Routine'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Edit Routine'));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Save Meal'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save Meal'));
        await tester.pumpAndSettle();

        expect(find.text('Meal routine updated successfully!'), findsOneWidget);
      },
    );

    testWidgets('AddVisitScreen saves visit and displays success SnackBar', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (_) => const AddVisitScreen()),
                ),
                child: const Text('Open Add Visit'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Add Visit'));
      await tester.pumpAndSettle();

      // Tap Profiles card to expand
      await tester.tap(find.text('Profiles'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Jane Doe').last);
      await tester.pumpAndSettle();

      // Expand Visit Details
      await tester.ensureVisible(find.text('Visit details'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Visit details'));
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      expect(textFields, findsAtLeastNWidgets(2));
      await tester.enterText(textFields.at(0), 'Cardiology Follow-up');
      await tester.enterText(textFields.at(1), 'Annual cardiac evaluation');
      await tester.pumpAndSettle();

      // Scroll to save button and tap
      await tester.ensureVisible(find.text('Save Visit'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save Visit'));
      await tester.pumpAndSettle();

      expect(find.text('Doctor visit added successfully!'), findsOneWidget);
    });
  });

  group('EmergencyCardScreen: Named Route Constants Integration', () {
    testWidgets('Family profile navigation uses AppRouter.familyProfiles', (
      tester,
    ) async {
      String? navigatedRoute;
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            navigatedRoute = settings.name;
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('Destination Screen')),
            );
          },
          home: const Scaffold(
            body: SingleChildScrollView(
              child: EmergencyCardView(
                data: {
                  'blood': 'O+',
                  'allergies': ['Dust'],
                  'chronicConditions': ['None'],
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap View all family profiles button
      await tester.ensureVisible(find.text('View all family profiles'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View all family profiles'));
      await tester.pumpAndSettle();

      expect(navigatedRoute, equals(AppRouter.familyProfiles));
    });
  });
}
