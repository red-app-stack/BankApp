import 'package:flutter/material.dart';

class MyResizableWidthContainer extends StatefulWidget {
  final double initialWidth;
  final double minWidth;
  final double maxWidth;
  final Widget child;

  const MyResizableWidthContainer({
    super.key,
    required this.initialWidth,
    required this.minWidth,
    required this.maxWidth,
    required this.child,
  });

  @override
  MyResizableWidthContainerState createState() =>
      MyResizableWidthContainerState();
}

class MyResizableWidthContainerState extends State<MyResizableWidthContainer> {
  late double _width;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
  }

  @override
  void didUpdateWidget(MyResizableWidthContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialWidth != widget.initialWidth) {
      setState(() {
        _width = widget.initialWidth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _width += details.delta.dx;
          _width = _width.clamp(widget.minWidth, widget.maxWidth);
        });
      },
      child: SizedBox(
        width: _width,
        child: widget.child,
      ),
    );
  }
}

class SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  SliverAppBarDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 40.0;

  @override
  double get maxExtent => 40.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    throw UnimplementedError();
  }
}