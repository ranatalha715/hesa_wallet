import 'package:flutter/material.dart';
class HalfSwipeDismissible extends StatefulWidget {
  final Key key;
  final Widget child;
  final VoidCallback onDismissed;



  HalfSwipeDismissible({
    required this.key,
    required this.child,
    required this.onDismissed,

  });

  @override
  _HalfSwipeDismissibleState createState() => _HalfSwipeDismissibleState();
}

class _HalfSwipeDismissibleState extends State<HalfSwipeDismissible>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  double _dragExtent = 0.0;
  bool _isSwipingBack = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent = details.primaryDelta!;
      _isSwipingBack = _dragExtent > MediaQuery.of(context).size.width * 0.25;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_isSwipingBack) {
      _animationController.forward(from: _dragExtent / context.size!.width);
      _animationController.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDismissed();
        }
      });
    } else {
      _animationController.reverse();
    }
    _dragExtent = 0.0;
    _isSwipingBack = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          double animValue = _animationController.value;
          double dx = _dragExtent * (1 - animValue);
          return Transform.translate(
            offset: Offset(dx, 0.0),
            child: child,
          );
        },
        child: Dismissible(
          key: widget.key,
          direction: DismissDirection.endToStart,

          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                final screenWidth = MediaQuery.of(context).size.width;
                final dialogWidth = screenWidth * 0.85;
                return Dialog(
                  // Your dialog content goes here
                );
              },
            );
          },
          onDismissed: (direction) {
            setState(() {
              _dragExtent = 0.0;
            });
            widget.onDismissed();
          },
          background: Container(
            // Your background content goes here
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
