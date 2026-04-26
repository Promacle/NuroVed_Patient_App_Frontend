import 'package:flutter/material.dart';
import 'package:nuroved_patient/core/theme/app_colors.dart';

import '../controllers/app_settings_controller.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final AppSettingsController _controller = AppSettingsController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) => Scaffold(
        backgroundColor: AppColors.kMainBg,
        body: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildSettingsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: Color(0xFFE1ECE7),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(45)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const CircleAvatar(
              backgroundColor: Color(0xFF769E93),
              child: Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "App Setting",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C4E4E),
                ),
              ),
              Text(
                "Manage Your App Settings",
                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSettingItem(
          "Time Formate",
          _controller.timeFormat,
          ["12hr", "24hr"],
          (v) => _controller.setTimeFormat(v),
        ),
        _buildSettingItem("Weight Unit", _controller.weightUnit, [
          "Kg",
          "Lbs",
        ], (v) => _controller.setWeightUnit(v)),
        _buildSettingItem("Height Unit", _controller.heightUnit, [
          "Cm",
          "Ft",
        ], (v) => _controller.setHeightUnit(v)),
      ],
    );
  }

  // lib/features/settings/screens/app_settings_screen.dart

  // ... update the _buildSettingItem method:
  Widget _buildSettingItem(
    String title,
    String value,
    List<String> options,
    Function(String) onSelect,
  ) {
    return GestureDetector(
      onTap: () => _showOptions(title, options, value, onSelect),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(value, style: const TextStyle(fontSize: 20)),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOptions(
    String title,
    List<String> options,
    String current,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            ...options.map(
              (o) => ListTile(
                title: Text(o),
                trailing: o == current ? const Icon(Icons.check) : null,
                onTap: () {
                  onSelect(o);
                  Navigator.pop(c);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
