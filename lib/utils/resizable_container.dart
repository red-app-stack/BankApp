import 'package:flutter/material.dart';

class ResizableWidthContainer extends StatefulWidget {
  final Widget child;
  final double initialWidth;
  final double minWidth;
  final double maxWidth;

  const ResizableWidthContainer({
    super.key,
    required this.child,
    this.initialWidth = 200.0,
    this.minWidth = 100.0,
    this.maxWidth = 300.0,
  });

  @override
  ResizableWidthContainerState createState() =>
      ResizableWidthContainerState();
}

class ResizableWidthContainerState extends State<ResizableWidthContainer> {
  late double _width;
  double? _prevX;

  @override
  void initState() {
    super.initState();
    _width = widget.initialWidth;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      final deltaX =
          details.globalPosition.dx - (_prevX ?? details.globalPosition.dx);
      _width = (_width + deltaX).clamp(widget.minWidth, widget.maxWidth);
      _prevX = details.globalPosition.dx;
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    _prevX = null;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _prevX = details.globalPosition.dx,
      onPanUpdate: _handlePanUpdate,
      onPanEnd: _handlePanEnd,
      child: SizedBox(
        width: _width,
        child: Stack(
          children: [
            widget.child,
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    width: 10,
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
