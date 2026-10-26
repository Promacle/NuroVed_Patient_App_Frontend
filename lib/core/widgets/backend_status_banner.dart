import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../localization/app_localizations_extension.dart';

/// Renders a clear informative banner when backend configuration is missing,
/// informing the user that the app is operating in local in-memory mode.
class BackendStatusBanner extends StatelessWidget {
  const BackendStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppConfig.isBackendConfigured) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFEEBA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20, color: Color(0xFF856404)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.backendNotConfigured,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF856404),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.backendRunningOffline,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF856404),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
