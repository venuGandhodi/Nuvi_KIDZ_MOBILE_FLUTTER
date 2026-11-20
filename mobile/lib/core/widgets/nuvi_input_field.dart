import 'package:flutter/material.dart';
import '../theme/nuvi_colors.dart';
import '../theme/nuvi_motion.dart';
import '../theme/nuvi_radii.dart';
import '../theme/nuvi_theme_ext.dart';

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

  /// When false the label isn't drawn above the field; [hint] is the
  /// visible placeholder and what screen readers announce.
  final bool showLabel;

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
    this.showLabel = true,
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
    final x = context.nuvi;
    Color borderColor = NuviColors.line;
    if (widget.errorText != null) {
      borderColor = NuviColors.sale;
    } else if (_isFocused) {
      borderColor = NuviColors.ink;
    }
    final muted = NuviColors.ink.withValues(alpha: 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showLabel) ...[
          Text(
            widget.label,
            style: x.nunito(
              13.5,
              weight: FontWeight.w700,
              color: widget.enabled ? NuviColors.ink : muted,
            ),
          ),
          const SizedBox(height: 6),
        ],
        AnimatedContainer(
          duration: NuviMotion.of(context, NuviMotion.fast),
          decoration: BoxDecoration(
            color: widget.enabled ? NuviColors.card : NuviColors.sageSoft,
            borderRadius: BorderRadius.circular(NuviRadii.pill),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: _isFocused && widget.errorText == null
                ? [
                    BoxShadow(
                      color: x.gold.withValues(alpha: 0.22),
                      blurRadius: 0,
                      spreadRadius: 3,
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
            style: x.body.copyWith(
              color: widget.enabled ? NuviColors.ink : muted,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: x.body.copyWith(color: NuviColors.inkFaint),
              prefixIcon: widget.prefixIcon != null
                  ? IconTheme(
                      data: IconThemeData(
                        color: _isFocused ? NuviColors.ink : muted,
                      ),
                      child: widget.prefixIcon!,
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      tooltip: _obscureText ? 'Show password' : 'Hide password',
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: muted,
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
                            color: muted,
                          )
                        : null),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              isDense: true,
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 14),
            child: Text(
              widget.errorText!,
              style: x.nunito(
                12.5,
                weight: FontWeight.w700,
                color: NuviColors.sale,
              ),
            ),
          ),
      ],
    );
  }
}
