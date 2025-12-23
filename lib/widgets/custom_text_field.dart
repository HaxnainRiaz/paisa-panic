import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Custom text field widget with consistent styling
class CustomTextField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final String? prefixText;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final int? maxLines;
  final bool enabled;
  final String? errorText;

  const CustomTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.onSuffixTap,
    this.maxLines = 1,
    this.enabled = true,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null 
                ? Icon(prefixIcon) 
                : (prefixText != null 
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          prefixText!,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    : null),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(suffixIcon),
                    onPressed: onSuffixTap,
                  )
                : null,
            errorText: errorText,
          ),
        ),
      ],
    );
  }
}

