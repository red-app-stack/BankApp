import 'package:flutter/material.dart';
import '../../utils/themes/theme_extension.dart';

class StaticBackgroundWrapper extends StatelessWidget {
  final Widget child;

  const StaticBackgroundWrapper({super.key, required this.child});

  Widget buildBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).extension<CustomColors>()!.background!,
            Theme.of(context).extension<CustomColors>()!.background!,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        buildBackground(context),
        child,
      ],
    );
  }
}
