import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';

class FamilyFormFields {
  static const Color titleColor = Color(0xFF2C4E4E);

  static Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    Widget? suffixIcon,
    String? suffixText,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: enabled,
        style: const TextStyle(
          fontSize: 14,
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: AppColors.white,
          suffixIcon: suffixIcon,
          suffixText: suffixText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  static Widget buildDropdown({
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: titleColor),
          items: enabled
              ? items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList()
              : null,
          onChanged: enabled ? onChanged : null,
          disabledHint: Text(value),
        ),
      ),
    );
  }

  static Widget buildDatePicker({
    required BuildContext context,
    required TextEditingController controller,
    required bool enabled,
    required VoidCallback onDateSelected,
  }) {
    return GestureDetector(
      onTap: !enabled
          ? null
          : () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                controller.text = DateFormat('dd/MM/yyyy').format(picked);
                onDateSelected();
              }
            },
      child: AbsorbPointer(
        child: buildTextField(
          controller: controller,
          hint: "DOB",
          enabled: enabled,
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
            color: titleColor,
            size: 22,
          ),
          readOnly: true,
        ),
      ),
    );
  }
}
