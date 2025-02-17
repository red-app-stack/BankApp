import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum TransitionType {
  fade,
  scale,
  rotate,
  slideRight,
  slideLeft,
  slideUp,
  slideDown,
}

class RouteTransitions {
  static GetPageRoute createRoute(
    Widget page, {
    TransitionType transitionType = TransitionType.fade,
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return GetPageRoute(
      page: () => page,
      transition: _getTransition(transitionType),
      curve: curve,
      transitionDuration: duration,
    );
  }

  static Transition _getTransition(TransitionType type) {
    switch (type) {
      case TransitionType.fade:
        return Transition.fade;
      case TransitionType.scale:
        return Transition.zoom;
      case TransitionType.rotate:
        return Transition.circularReveal;
      case TransitionType.slideRight:
        return Transition.rightToLeft;
      case TransitionType.slideLeft:
        return Transition.leftToRight;
      case TransitionType.slideUp:
        return Transition.downToUp;
      case TransitionType.slideDown:
        return Transition.upToDown;
    }
  }
}
