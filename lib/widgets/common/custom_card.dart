import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget? startWidget;
  final String? label;
  final double? labelSize;
  final Widget? endWidget;
  final Widget? child;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;

  const CustomCard({
    super.key,
    this.startWidget,
    this.label,
    this.labelSize,
    this.endWidget,
    this.child,
    this.padding = const EdgeInsets.all(16),
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null || endWidget != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (startWidget != null) ...[
                    startWidget!,
                    SizedBox(width: 8),
                  ],
                  if (label != null)
                    Text(
                      label!,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: labelSize,
                      ),
                    ),
                  if (endWidget != null) endWidget!,
                ],
              ),
            if (child != null) ...[
              if (label != null || endWidget != null) SizedBox(height: 16),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
