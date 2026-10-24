import '../errors/failures.dart';
import '../utils/result.dart';
import 'notification_scheduler.dart';

/// In-memory fake implementation of [NotificationScheduler] for tests and development.
class FakeNotificationScheduler implements NotificationScheduler {
  NotificationPermissionStatus permissionStatus;
  bool shouldFailScheduling = false;
  bool exactAlarmsSupported;
  bool rebootRescheduleSupported;

  final Map<String, Map<String, dynamic>> _scheduledReminders = {};

  FakeNotificationScheduler({
    this.permissionStatus = NotificationPermissionStatus.granted,
    this.exactAlarmsSupported = true,
    this.rebootRescheduleSupported = true,
  });

  Map<String, Map<String, dynamic>> get scheduledReminders =>
      Map.unmodifiable(_scheduledReminders);

  @override
  Future<NotificationPermissionStatus> getPermissionStatus() async {
    return permissionStatus;
  }

  @override
  Future<NotificationPermissionStatus> requestPermission() async {
    // Returns current configured status, or updates denied to granted if simulating user approval
    return permissionStatus;
  }

  @override
  Future<Result<bool>> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool exact = true,
  }) async {
    if (permissionStatus != NotificationPermissionStatus.granted) {
      return const Result.failure(
        ValidationFailure(
          message:
              'Notification permission was denied. Please enable notifications in device settings.',
        ),
      );
    }

    if (exact && !exactAlarmsSupported) {
      return const Result.failure(
        ValidationFailure(
          message:
              'Exact alarm permission is disabled on this device. Reminders may be delayed.',
        ),
      );
    }

    if (shouldFailScheduling) {
      return const Result.failure(
        ServerFailure(
          message: 'Failed to register notification with system scheduler.',
        ),
      );
    }

    _scheduledReminders[id] = {
      'id': id,
      'title': title,
      'body': body,
      'scheduledTime': scheduledTime,
      'exact': exact,
    };

    return const Result.success(true);
  }

  @override
  Future<Result<bool>> cancelReminder(String id) async {
    _scheduledReminders.remove(id);
    return const Result.success(true);
  }

  @override
  Future<Result<bool>> cancelAllReminders() async {
    _scheduledReminders.clear();
    return const Result.success(true);
  }

  @override
  bool get supportsExactAlarms => exactAlarmsSupported;

  @override
  bool get supportsRebootReschedule => rebootRescheduleSupported;
}
