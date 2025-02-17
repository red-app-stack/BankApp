import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../utils/themes/theme_extension.dart';

class ListItem extends StatelessWidget {
  final String? svgPath;
  final String? svgPathSub;
  final String? svgColor;
  final String title;
  final String? subtitle;
  final double iconSize;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDoubleTap;
  final bool showDivider;
  final bool showNotification;
  final Widget? leadingWidget;
  final Widget? trailingWidget;
  final VoidCallback? onMorePressed;

  const ListItem({
    super.key,
    this.svgPath,
    this.svgPathSub,
    this.svgColor,
    required this.title,
    this.subtitle,
    this.iconSize = 40,
    this.onTap,
    this.onLongPress,
    this.onDoubleTap,
    this.showDivider = false,
    this.showNotification = false,
    this.leadingWidget,
    this.trailingWidget,
    this.onMorePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: Ink(
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              onDoubleTap: onDoubleTap,
              borderRadius: BorderRadius.circular(12),
              splashFactory: InkRipple.splashFactory,
              splashColor: theme.colorScheme.primary.withValues(alpha: 0.08),
              highlightColor: theme.colorScheme.primary.withValues(alpha: 0.04),
              child: Padding(
                padding: onMorePressed == null
                    ? EdgeInsets.all(16)
                    : EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    if (leadingWidget != null)
                      leadingWidget!
                    else if (svgPath != null)
                      Stack(
                        alignment: Alignment.topRight,
                        clipBehavior: Clip.none,
                        children: [
                          SvgPicture.asset(
                            svgPath!,
                            width: iconSize,
                            height: iconSize,
                            colorFilter: svgColor != null
                                ? ColorFilter.mode(
                                    theme.colorScheme.primary,
                                    BlendMode.srcIn,
                                  )
                                : null,
                          ),
                          if (showNotification)
                            Positioned(
                              top: -3,
                              right: -3,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme
                                      .extension<CustomColors>()!
                                      .notifications,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          if (subtitle != null || svgPathSub != null) ...[
                            SizedBox(height: 4),
                            Row(
                              children: [
                                if (svgPathSub != null) ...[
                                  SvgPicture.asset(
                                    svgPathSub!,
                                    width: 30,
                                    height: 12,
                                  ),
                                  SizedBox(width: 8),
                                ],
                                if (subtitle != null)
                                  Expanded(
                                    child: Text(
                                      subtitle!,
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: theme
                                            .extension<CustomColors>()!
                                            .primaryVariant,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (trailingWidget != null)
                      trailingWidget!
                    else if (onMorePressed != null)
                      IconButton(
                        icon: SvgPicture.asset(
                          'assets/icons/other_horiz.svg',
                          width: iconSize,
                          height: iconSize,
                          colorFilter: ColorFilter.mode(
                            theme.colorScheme.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                        onPressed: onMorePressed,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: theme.colorScheme.secondaryContainer,
          ),
      ],
    );
  }
}
