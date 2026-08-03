import 'package:flutter/material.dart';
import 'dart:math' as math;

class PageTurnWidget extends StatefulWidget {
  final Widget leftPage;
  final Widget rightPage;
  final Duration duration;

  const PageTurnWidget({
    super.key,
    required this.leftPage,
    required this.rightPage,
    this.duration = const Duration(milliseconds: 650),
  });

  @override
  State<PageTurnWidget> createState() => PageTurnWidgetState();
}

class PageTurnWidgetState extends State<PageTurnWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanUpdate(DragUpdateDetails details, double maxWidth) {
    setState(() {
      _dragExtent -= details.delta.dx;
      _dragExtent = _dragExtent.clamp(0.0, maxWidth);
      _controller.value = _dragExtent / maxWidth;
    });
  }

  void _onPanEnd(DragEndDetails details, double maxWidth) {
    if (_controller.value > 0.35 || details.velocity.pixelsPerSecond.dx < -300) {
      _controller.forward(from: _controller.value);
    } else {
      _controller.reverse(from: _controller.value);
    }
  }

  void nextPage() {
    _controller.forward();
  }

  void prevPage() {
    _controller.reverse();
  }

  Widget _buildSegment(int index, int total, double progress, Size size, Widget child, {bool isShadow = false}) {
    if (index == total) return const SizedBox.shrink();
    
    final segmentWidth = size.width / total;
    
    // Create a curling wave effect. 
    // The angle depends on the index and the global progress.
    // We want the curl to start at the right (index = total-1) and move left (index = 0).
    final curlPosition = progress * (total + 4) - 2; 
    
    // Distance from the current segment to the center of the curl
    final distance = (index - curlPosition).abs();
    
    // A bell curve for the angle, making it curl then flatten out
    double angle = 0.0;
    if (distance < 3.0) {
      angle = -math.pi / 4 * (1.0 - distance / 3.0);
    }
    
    // Also, a global rigid rotation to flip the page completely when progress -> 1
    angle += -math.pi * progress / total;
    
    return Transform(
      alignment: Alignment.centerLeft,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012)
        ..rotateY(angle),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: segmentWidth,
            height: size.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: OverflowBox(
                    minWidth: size.width,
                    maxWidth: size.width,
                    alignment: Alignment(-1.0 + (index * 2.0) / (total - 1), 0.0),
                    child: child,
                  ),
                ),
                if (isShadow)
                  Opacity(
                    opacity: (angle.abs() * 0.8).clamp(0.0, 0.5),
                    child: Container(color: Colors.black),
                  ),
              ],
            ),
          ),
          if (index < total - 1)
            _buildSegment(index + 1, total, progress, size, child, isShadow: isShadow),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        return GestureDetector(
          onHorizontalDragUpdate: (details) => _onPanUpdate(details, maxWidth),
          onHorizontalDragEnd: (details) => _onPanEnd(details, maxWidth),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final progress = _controller.value;
              
              return Stack(
                fit: StackFit.expand,
                children: [
                  // Underneath page (Right Page)
                  widget.rightPage,
                  
                  // Top page curling (Left Page)
                  if (progress < 1.0)
                    _buildSegment(0, 10, progress, constraints.biggest, widget.leftPage, isShadow: true),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
