import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_typography.dart';
import '../theme/nuvi_spacing.dart';

class NuviInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final String? errorText;
  final bool enabled;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final VoidCallback? onSuffixIconPressed;
  final FormFieldValidator<String>? validator;

  const NuviInputField({
    super.key,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.errorText,
    this.enabled = true,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.onSuffixIconPressed,
    this.validator,
  });

  @override
  State<NuviInputField> createState() => _NuviInputFieldState();
}

class _NuviInputFieldState extends State<NuviInputField> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  late bool _obscureText;
  late TextEditingController _effectiveController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _obscureText = widget.obscureText;
    _effectiveController =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color borderColor = NuviColors.border;
    if (widget.errorText != null) {
      borderColor = NuviColors.error;
    } else if (_isFocused) {
      borderColor = NuviColors.secondary; // Mustard glow
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: NuviTypography.textTheme.labelLarge?.copyWith(
            color: widget.enabled
                ? NuviColors.onSurface
                : NuviColors.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: NuviSpacing.xs),
        Container(
          decoration: BoxDecoration(
            color: widget.enabled
                ? NuviColors.surface
                : NuviColors.surfaceVariant,
            borderRadius: BorderRadius.circular(NuviRadii.small),
            border: Border.all(color: borderColor, width: _isFocused ? 2 : 1),
            boxShadow: _isFocused && widget.errorText == null
                ? [
                    BoxShadow(
                      color: NuviColors.secondary.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: Offset.zero,
                    ),
                  ]
                : null,
          ),
          child: TextFormField(
            controller: _effectiveController,
            focusNode: _focusNode,
            enabled: widget.enabled,
            obscureText: _obscureText,
            onChanged: widget.onChanged,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            validator: widget.validator,
            style: NuviTypography.textTheme.bodyMedium?.copyWith(
              color: widget.enabled
                  ? NuviColors.onSurface
                  : NuviColors.onSurface.withValues(alpha: 0.5),
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: NuviTypography.textTheme.bodyMedium?.copyWith(
                color: NuviColors.onSurface.withValues(alpha: 0.4),
              ),
              prefixIcon: widget.prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: _isFocused
                            ? NuviColors.primary
                            : NuviColors.onSurface.withValues(alpha: 0.5),
                      ),
                      child: widget.prefixIcon!,
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: NuviColors.onSurface.withValues(alpha: 0.5),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : (widget.suffixIcon != null
                        ? IconButton(
                            icon: widget.suffixIcon!,
                            onPressed: widget.onSuffixIconPressed,
                            color: NuviColors.onSurface.withValues(alpha: 0.5),
                          )
                        : null),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: NuviSpacing.md,
                vertical: NuviSpacing.md,
              ),
              isDense: true,
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: NuviSpacing.xs),
            child: Text(
              widget.errorText!,
              style: NuviTypography.textTheme.bodySmall?.copyWith(
                color: NuviColors.error,
              ),
            ),
          ),
      ],
    );
  }
}
