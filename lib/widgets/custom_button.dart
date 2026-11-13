import 'package:flutter/material.dart';

import 'scale_tap.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final callback = enabled ? onPressed : null;

    final content = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: outlined ? null : Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return ScaleTap(
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: outlined
            ? OutlinedButton(onPressed: callback, child: content)
            : FilledButton(onPressed: callback, child: content),
      ),
    );
  }
}
