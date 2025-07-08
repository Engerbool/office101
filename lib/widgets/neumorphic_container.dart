import 'package:flutter/material.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double depth;
  final bool isPressed;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.depth = 4.0,
    this.isPressed = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shadowColor = Color(0xFFA6B4C4);
    final highlightColor = Color(0xFFFFFFFF);
    final baseColor = Color(0xFFEBF0F5);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: isPressed
            ? [
                BoxShadow(
                  color: shadowColor.withOpacity(0.2),
                  offset: Offset(2, 2),
                  blurRadius: depth,
                ),
                BoxShadow(
                  color: highlightColor.withOpacity(0.7),
                  offset: Offset(-2, -2),
                  blurRadius: depth,
                ),
              ]
            : [
                BoxShadow(
                  color: shadowColor.withOpacity(0.3),
                  offset: Offset(depth, depth),
                  blurRadius: depth * 2,
                ),
                BoxShadow(
                  color: highlightColor.withOpacity(0.8),
                  offset: Offset(-depth, -depth),
                  blurRadius: depth * 2,
                ),
              ],
      ),
      child: child,
    );
  }
}

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double depth;

  const NeumorphicButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.depth = 4.0,
  }) : super(key: key);

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed != null ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.onPressed != null ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: widget.onPressed != null ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        child: NeumorphicContainer(
          borderRadius: widget.borderRadius,
          padding: widget.padding ?? EdgeInsets.all(16.0),
          margin: widget.margin,
          depth: widget.depth,
          isPressed: _isPressed,
          child: widget.child,
        ),
      ),
    );
  }
}