import '../utils/result.dart';

/// Notification permission status for reminder scheduling.
enum NotificationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  unsupported,
}

/// Abstract contract for scheduling medication reminders and health notifications.
abstract class NotificationScheduler {
  /// Checks the current notification permission status.
  Future<NotificationPermissionStatus> getPermissionStatus();

  /// Prompts the user for notification permissions (including Android 13+ POST_NOTIFICATIONS).
  Future<NotificationPermissionStatus> requestPermission();

  /// Schedules an exact or inexact medication reminder notification.
  /// Confirms scheduling succeeded before returning success.
  Future<Result<bool>> scheduleReminder({
    required String id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    bool exact = true,
  });

  /// Cancels an existing scheduled reminder by ID.
  Future<Result<bool>> cancelReminder(String id);

  /// Cancels all scheduled reminders for the application.
  Future<Result<bool>> cancelAllReminders();

  /// Returns whether the current platform and OS support exact alarm scheduling.
  bool get supportsExactAlarms;

  /// Returns whether scheduled alarms survive or are rescheduled on device reboot.
  bool get supportsRebootReschedule;
}
