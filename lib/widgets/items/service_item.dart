import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ServiceItem extends StatelessWidget {
  final String svgPath;
  final String label;
  final double iconSize;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final bool? expanded;

  const ServiceItem({
    super.key,
    required this.svgPath,
    required this.label,
    this.iconSize = 32,
    this.onTap,
    this.onDoubleTap,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    return expanded == true
        ? Expanded(
            child: _buildMain(context),
          )
        : _buildMain(context);
  }

  _buildMain(BuildContext context) {
    ThemeData theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: Ink(
          child: InkWell(
        onDoubleTap: onDoubleTap,
        onTap: onTap ??
            () {
              true;
            },
        borderRadius: BorderRadius.circular(12),
        splashFactory: InkRipple.splashFactory,
        splashColor: theme.colorScheme.primary.withOpacity(0.08),
        highlightColor: theme.colorScheme.primary.withOpacity(0.04),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SvgPicture.asset(
                    svgPath,
                    width: iconSize,
                    height: iconSize,
                    colorFilter: ColorFilter.mode(
                      theme.colorScheme.primary,
                      BlendMode.srcIn,
                    ),
                  )),
              SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ) ??
                    theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      )),
    );
  }
}