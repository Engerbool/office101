import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_breakpoints.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final ResponsiveValues<double>? borderRadius;
  final ResponsiveValues<EdgeInsets>? padding;
  final ResponsiveValues<EdgeInsets>? margin;
  final ResponsiveValues<double>? depth;
  final bool isPressed;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? highlightColor;
  final bool useResponsive;

  const NeumorphicContainer({
    Key? key,
    required this.child,
    this.borderRadius,
    this.padding,
    this.margin,
    this.depth,
    this.isPressed = false,
    this.backgroundColor,
    this.shadowColor,
    this.highlightColor,
    this.useResponsive = true,
  }) : super(key: key);

  /// 기본 크기로 생성 (하위 호환성)
  const NeumorphicContainer.simple({
    Key? key,
    required this.child,
    double borderRadius = 16.0,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double depth = 4.0,
    this.isPressed = false,
    this.backgroundColor,
    this.shadowColor,
    this.highlightColor,
  })  : borderRadius = null,
        padding = null,
        margin = null,
        depth = null,
        useResponsive = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final effectiveShadowColor = shadowColor ?? themeProvider.shadowColor;
    final effectiveHighlightColor =
        highlightColor ?? themeProvider.highlightColor;
    final effectiveBackgroundColor = backgroundColor ?? themeProvider.cardColor;

    if (!useResponsive) {
      // 하위 호환성을 위한 기본 구현
      return Container(
        decoration: BoxDecoration(
          color: effectiveBackgroundColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: _createShadows(
              effectiveShadowColor, effectiveHighlightColor, 4.0),
        ),
        child: child,
      );
    }

    // 반응형 기본값 정의
    final defaultBorderRadius = ResponsiveValues<double>(
      mobile: 12.0,
      tablet: 16.0,
      desktop: 20.0,
    );

    final defaultDepth = ResponsiveValues<double>(
      mobile: 3.0,
      tablet: 4.0,
      desktop: 6.0,
    );

    final deviceType = ResponsiveHelper.getDeviceType(context);

    final effectiveBorderRadius =
        (borderRadius ?? defaultBorderRadius).getValue(deviceType);
    final effectiveDepth = (depth ?? defaultDepth).getValue(deviceType);
    final effectivePadding = padding?.getValue(deviceType);
    final effectiveMargin = margin?.getValue(deviceType);

    return Container(
      margin: effectiveMargin,
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        boxShadow: _createShadows(
            effectiveShadowColor, effectiveHighlightColor, effectiveDepth),
      ),
      child: child,
    );
  }

  /// 그림자 생성 헬퍼 메서드
  List<BoxShadow> _createShadows(
      Color shadowColor, Color highlightColor, double depth) {
    if (isPressed) {
      return [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.2),
          offset: Offset(depth * 0.5, depth * 0.5),
          blurRadius: depth,
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.3),
          offset: Offset(depth, depth),
          blurRadius: depth * 2,
        ),
        BoxShadow(
          color: highlightColor.withValues(alpha: 0.7),
          offset: Offset(-depth * 0.5, -depth * 0.5),
          blurRadius: depth * 1.5,
        ),
      ];
    }
  }
}

class NeumorphicButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final ResponsiveValues<double>? borderRadius;
  final ResponsiveValues<EdgeInsets>? padding;
  final ResponsiveValues<EdgeInsets>? margin;
  final ResponsiveValues<double>? depth;
  final bool useResponsive;

  const NeumorphicButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.borderRadius,
    this.padding,
    this.margin,
    this.depth,
    this.useResponsive = true,
  }) : super(key: key);

  /// 기본 크기로 생성 (하위 호환성)
  const NeumorphicButton.simple({
    Key? key,
    required this.child,
    this.onPressed,
    double borderRadius = 16.0,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double depth = 4.0,
  })  : borderRadius = null,
        padding = null,
        margin = null,
        depth = null,
        useResponsive = false,
        super(key: key);

  @override
  _NeumorphicButtonState createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    // 기본 패딩 값
    final defaultPadding = ResponsiveValues<EdgeInsets>(
      mobile: EdgeInsets.all(12.0),
      tablet: EdgeInsets.all(16.0),
      desktop: EdgeInsets.all(20.0),
    );

    return GestureDetector(
      onTapDown: widget.onPressed != null
          ? (_) => setState(() => _isPressed = true)
          : null,
      onTapUp: widget.onPressed != null
          ? (_) => setState(() => _isPressed = false)
          : null,
      onTapCancel: widget.onPressed != null
          ? () => setState(() => _isPressed = false)
          : null,
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        child: NeumorphicContainer(
          borderRadius: widget.borderRadius,
          padding: widget.padding ?? defaultPadding,
          margin: widget.margin,
          depth: widget.depth,
          isPressed: _isPressed,
          useResponsive: widget.useResponsive,
          child: widget.child,
        ),
      ),
    );
  }
}
