import 'package:flutter_test/flutter_test.dart';
import 'package:nuroved_patient/core/services/fake_notification_scheduler.dart';
import 'package:nuroved_patient/core/services/notification_scheduler.dart';

void main() {
  group('NotificationScheduler & Reminder Tests', () {
    late FakeNotificationScheduler scheduler;

    setUp(() {
      scheduler = FakeNotificationScheduler();
    });

    test(
      'default scheduler has granted permission and supports exact alarms & reboot reschedule',
      () async {
        expect(
          await scheduler.getPermissionStatus(),
          NotificationPermissionStatus.granted,
        );
        expect(scheduler.supportsExactAlarms, isTrue);
        expect(scheduler.supportsRebootReschedule, isTrue);
      },
    );

    test('scheduleReminder succeeds when permission is granted', () async {
      final res = await scheduler.scheduleReminder(
        id: 'rem-001',
        title: 'Metformin Reminder',
        body: 'Take 500mg with breakfast',
        scheduledTime: DateTime.now().add(const Duration(hours: 8)),
      );

      expect(res.isSuccess, isTrue);
      expect(scheduler.scheduledReminders.containsKey('rem-001'), isTrue);
      expect(scheduler.scheduledReminders.length, 1);
    });

    test(
      'scheduleReminder fails cleanly when permission is denied without crashing',
      () async {
        scheduler.permissionStatus = NotificationPermissionStatus.denied;

        final res = await scheduler.scheduleReminder(
          id: 'rem-002',
          title: 'Insulin Reminder',
          body: 'Take 10 units',
          scheduledTime: DateTime.now().add(const Duration(hours: 2)),
        );

        expect(res.isSuccess, isFalse);
        expect(scheduler.scheduledReminders.containsKey('rem-002'), isFalse);
        expect(scheduler.scheduledReminders.isEmpty, isTrue);
      },
    );

    test(
      'scheduleReminder fails when scheduler encounters OS failure',
      () async {
        scheduler.shouldFailScheduling = true;

        final res = await scheduler.scheduleReminder(
          id: 'rem-003',
          title: 'Aspirin Reminder',
          body: 'Take after lunch',
          scheduledTime: DateTime.now().add(const Duration(hours: 4)),
        );

        expect(res.isSuccess, isFalse);
        expect(scheduler.scheduledReminders.containsKey('rem-003'), isFalse);
      },
    );

    test(
      'cancelReminder removes specific reminder from scheduled list',
      () async {
        await scheduler.scheduleReminder(
          id: 'rem-004',
          title: 'Medicine A',
          body: 'Dose A',
          scheduledTime: DateTime.now().add(const Duration(hours: 1)),
        );
        await scheduler.scheduleReminder(
          id: 'rem-005',
          title: 'Medicine B',
          body: 'Dose B',
          scheduledTime: DateTime.now().add(const Duration(hours: 2)),
        );

        expect(scheduler.scheduledReminders.length, 2);

        await scheduler.cancelReminder('rem-004');
        expect(scheduler.scheduledReminders.containsKey('rem-004'), isFalse);
        expect(scheduler.scheduledReminders.containsKey('rem-005'), isTrue);
        expect(scheduler.scheduledReminders.length, 1);
      },
    );

    test('cancelAllReminders clears all scheduled reminders', () async {
      await scheduler.scheduleReminder(
        id: 'rem-006',
        title: 'Medicine C',
        body: 'Dose C',
        scheduledTime: DateTime.now().add(const Duration(hours: 1)),
      );
      await scheduler.scheduleReminder(
        id: 'rem-007',
        title: 'Medicine D',
        body: 'Dose D',
        scheduledTime: DateTime.now().add(const Duration(hours: 2)),
      );

      expect(scheduler.scheduledReminders.length, 2);

      await scheduler.cancelAllReminders();
      expect(scheduler.scheduledReminders.isEmpty, isTrue);
    });
  });
}
