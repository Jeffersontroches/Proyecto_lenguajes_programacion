import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final TextInputType inputType;
  final bool isObscure;
  final IconData? icon;

  const CustomTextField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    this.inputType = TextInputType.text,
    this.isObscure = false,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FB),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isObscure,
        keyboardType: inputType,
        style: const TextStyle(color: Color(0xFF1F2937), fontSize: 16),
        decoration: InputDecoration(
          prefixIcon:
              icon != null ? Icon(icon, color: const Color(0xFF6B7280)) : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 22,
          ),
        ),
      ),
    );
  }
}
