import 'package:flutter/material.dart';

class SlideMessageAnimation extends StatelessWidget {
  final Widget child;
  final bool isBot;
  final AnimationController controller;

  SlideMessageAnimation({
    required this.child,
    required this.isBot,
    required this.controller,
  }) : super(key: ValueKey(controller.value));

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: Offset(isBot ? -1.0 : 1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutQuart,
      )),
      child: FadeTransition(
        opacity: controller,
        child: child,
      ),
    );
  }
}
