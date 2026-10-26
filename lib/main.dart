import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/localization/locale_controller.dart';

void main() async {
  // Ensure Flutter is initialized for native plugins like url_launcher
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize application language preference
  await LocaleController.instance.init();

  runApp(const MyApp());
}
