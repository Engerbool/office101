import 'package:flutter/material.dart';

/// 접근성을 고려한 아이콘 버튼 (최소 48dp 터치 타겟 보장)
class AccessibleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double? iconSize;
  final Color? color;
  final String? tooltip;
  final String? semanticsLabel;
  final EdgeInsetsGeometry? padding;
  final double? splashRadius;

  const AccessibleIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.iconSize,
    this.color,
    this.tooltip,
    this.semanticsLabel,
    this.padding,
    this.splashRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // 최소 터치 타겟 크기 보장 (Material Design 가이드라인: 48dp)
      constraints: BoxConstraints(
        minWidth: 48.0,
        minHeight: 48.0,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: iconSize ?? 24.0,
          color: color,
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        splashRadius: splashRadius ?? 24.0,
        padding: padding ?? EdgeInsets.all(8.0),
        // 접근성 라벨 추가
        iconSize: iconSize ?? 24.0,
      ),
    );
  }
}

/// 원형 아이콘 버튼 (Material Design Circle Button)
class CircularIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double? size;
  final Color? backgroundColor;
  final Color? iconColor;
  final String? tooltip;
  final String? semanticsLabel;
  final double elevation;

  const CircularIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.size,
    this.backgroundColor,
    this.iconColor,
    this.tooltip,
    this.semanticsLabel,
    this.elevation = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonSize = size ?? 56.0; // Material Design FAB 기본 크기
    
    return Container(
      width: buttonSize,
      height: buttonSize,
      child: Material(
        color: backgroundColor ?? theme.primaryColor,
        type: MaterialType.circle,
        elevation: elevation,
        child: InkWell(
          onTap: onPressed,
          customBorder: CircleBorder(),
          child: Container(
            width: buttonSize,
            height: buttonSize,
            child: Icon(
              icon,
              color: iconColor ?? Colors.white,
              size: (buttonSize * 0.4).clamp(16.0, 32.0),
            ),
          ),
        ),
      ),
    );
  }
}

/// 접근성 개선된 텍스트 버튼
class AccessibleTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? minWidth;
  final double? minHeight;
  final String? semanticsLabel;

  const AccessibleTextButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.textStyle,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.minWidth,
    this.minHeight,
    this.semanticsLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 88.0, // Material Design 최소 버튼 너비
        minHeight: minHeight ?? 48.0, // 최소 터치 타겟 높이
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }
}

/// 높이 조절 가능한 접근성 버튼
class AccessibleElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? minWidth;
  final double? minHeight;
  final double? elevation;
  final String? semanticsLabel;

  const AccessibleElevatedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.textStyle,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.minWidth,
    this.minHeight,
    this.elevation,
    this.semanticsLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minWidth: minWidth ?? 88.0,
        minHeight: minHeight ?? 48.0,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: padding ?? EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(
          text,
          style: textStyle,
        ),
      ),
    );
  }
}