import 'package:flutter/material.dart';

class M3ErrorText extends StatelessWidget {
  final String? errorText;
  final bool showIcon;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;

  const M3ErrorText({
    super.key,
    required this.errorText,
    this.showIcon = true,
    this.padding,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    if (errorText == null || errorText!.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final defaultStyle = theme.textTheme.bodySmall?.copyWith(
      color: colorScheme.error,
      fontWeight: FontWeight.w500,
    );
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showIcon) ...[
          Icon(
            Icons.error_outline_rounded,
            size: 16,
            color: colorScheme.error,
          ),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            errorText!,
            style: style ?? defaultStyle,
          ),
        ),
      ],
    );
    if (padding != null) {
      return Padding(
        padding: padding!,
        child: content,
      );
    }
    return content;
  }
}