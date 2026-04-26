import 'package:flutter/material.dart';

class DietPlannerHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const DietPlannerHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 30, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: Color(0xFFE8F2EF),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFC7E2D9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 45),
            child: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5A6A6A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DietPlannerCard extends StatelessWidget {
  final Widget child;
  final IconData? icon;
  final String? title;

  const DietPlannerCard({
    super.key,
    required this.child,
    this.icon,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F2EF).withOpacity(0.6),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 15),
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: const Color(0xFF7CB9A8), size: 30),
                  const SizedBox(width: 15),
                ],
                Text(
                  title!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C4E4E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
          ],
          child,
        ],
      ),
    );
  }
}

class DietPlannerTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;

  const DietPlannerTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.onIncrement,
    this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A6A6A),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              fillColor: Colors.transparent,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: onIncrement != null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: onIncrement,
                          child: const Icon(
                            Icons.keyboard_arrow_up,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: onDecrement,
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

class DietPlannerSelectionList extends StatelessWidget {
  final List<String> options;
  final String? selectedValue;
  final Function(String) onSelected;

  const DietPlannerSelectionList({
    super.key,
    required this.options,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: options.map((option) {
          final isSelected = option == selectedValue;
          return GestureDetector(
            onTap: () => onSelected(option),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF7CB9A8) : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF2C4E4E),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check, color: Colors.white, size: 20),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DietPlannerDropdown extends StatefulWidget {
  final String label;
  final String hint;
  final List<String> options;
  final String? selectedValue;
  final Function(String) onSelected;

  const DietPlannerDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.options,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  State<DietPlannerDropdown> createState() => _DietPlannerDropdownState();
}

class _DietPlannerDropdownState extends State<DietPlannerDropdown> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A6A6A),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: CustomPaint(
            painter: DashedBorderPainter(),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.selectedValue ?? widget.hint,
                      style: TextStyle(
                        fontSize: 12,
                        color: widget.selectedValue == null
                            ? Colors.grey
                            : const Color(0xFF2C4E4E),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.arrow_downward,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_isExpanded) ...[
          const SizedBox(height: 15),
          DietPlannerSelectionList(
            options: widget.options,
            selectedValue: widget.selectedValue,
            onSelected: (val) {
              widget.onSelected(val);
              setState(() => _isExpanded = false);
            },
          ),
        ],
      ],
    );
  }
}

class DietPlannerActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const DietPlannerActionButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7CB9A8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          shadowColor: const Color(0xFF7CB9A8).withOpacity(0.3),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF7CB9A8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(12),
        ),
      );
    for (final pathMetric in path.computeMetrics()) {
      double distance = 0;
      while (distance < pathMetric.length) {
        canvas.drawPath(pathMetric.extractPath(distance, distance + 3), paint);
        distance += 5;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
