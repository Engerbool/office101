import 'package:flutter/material.dart';

/// Material Design Ripple Effect를 적용한 버튼 위젯
class MaterialRippleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? rippleColor;
  final Color? highlightColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? minWidth;
  final double? minHeight;
  final bool enabled;
  final String? semanticsLabel;
  final String? semanticsHint;

  const MaterialRippleButton({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.rippleColor,
    this.highlightColor,
    this.borderRadius,
    this.padding,
    this.minWidth,
    this.minHeight,
    this.enabled = true,
    this.semanticsLabel,
    this.semanticsHint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 최소 터치 타겟 크기 확보 (Material Design 가이드라인: 48dp)
    final minTouchTarget = 48.0;
    
    Widget buttonChild = child;
    
    // 패딩 적용
    if (padding != null) {
      buttonChild = Padding(
        padding: padding!,
        child: buttonChild,
      );
    }
    
    // 최소 크기 제약 적용
    buttonChild = ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: minWidth ?? minTouchTarget,
        minHeight: minHeight ?? minTouchTarget,
      ),
      child: buttonChild,
    );
    
    // 접근성 적용
    if (semanticsLabel != null || semanticsHint != null) {
      buttonChild = Semantics(
        label: semanticsLabel,
        hint: semanticsHint,
        button: true,
        child: buttonChild,
      );
    }
    
    // 비활성 상태 처리
    if (!enabled) {
      buttonChild = Opacity(
        opacity: 0.38, // Material Design 비활성 상태 투명도
        child: buttonChild,
      );
    }
    
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        splashColor: rippleColor ?? theme.primaryColor.withValues(alpha: 0.12),
        highlightColor: highlightColor ?? theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: buttonChild,
      ),
    );
  }
}

/// 머티리얼 디자인 카드 버튼
class MaterialCardButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const MaterialCardButton({
    Key? key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.padding,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: margin,
      child: Material(
        color: backgroundColor ?? theme.cardColor,
        elevation: elevation ?? 2.0,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
          child: Container(
            padding: padding ?? EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 머티리얼 디자인 리스트 아이템
class MaterialListItem extends StatelessWidget {
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;

  const MaterialListItem({
    Key? key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.contentPadding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        onLongPress: enabled ? onLongPress : null,
        child: Container(
          padding: contentPadding ?? EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    if (subtitle != null) ...[
                      SizedBox(height: 4),
                      subtitle!,
                    ],
                  ],
                ),
              ),
              if (trailing != null) ...[
                SizedBox(width: 16),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}