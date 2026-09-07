import 'package:flutter/material.dart';

class SmgoCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color primaryColor;

  const SmgoCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.primaryColor = const Color.fromARGB(255, 37, 141, 70),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: value ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: value ? primaryColor : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: value
            ? const Icon(Icons.check, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}
