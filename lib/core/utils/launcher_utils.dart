import 'package:url_launcher/url_launcher.dart';

import 'app_logger.dart';

class LauncherUtils {
  static Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      AppLogger.error('Failed to launch URL', e);
    }
  }
}
