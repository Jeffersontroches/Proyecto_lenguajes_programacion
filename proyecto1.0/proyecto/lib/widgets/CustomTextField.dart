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
      margin: const EdgeInsets.symmetric(vertical: 4), // menos espacio
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2), // blanco suave
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
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
              icon != null ? Icon(icon, color: Color(0xFF6B7280)) : null,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 20,
          ),
        ),
      ),
    );
  }
}
