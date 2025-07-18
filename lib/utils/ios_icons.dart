import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'platform_utils.dart';

/// iOS 스타일 아이콘 매핑 (SF Symbols 스타일)
class IOSIcons {
  /// 플랫폼별 아이콘 반환
  static IconData getIcon(String iconName) {
    if (PlatformUtils.isIOS) {
      return _getIOSIcon(iconName);
    } else {
      return _getAndroidIcon(iconName);
    }
  }
  
  /// iOS 전용 아이콘 매핑
  static IconData _getIOSIcon(String iconName) {
    switch (iconName) {
      // 네비게이션 아이콘
      case 'book':
        return CupertinoIcons.book;
      case 'email':
        return CupertinoIcons.mail;
      case 'lightbulb':
        return CupertinoIcons.lightbulb;
      case 'settings':
        return CupertinoIcons.settings;
      
      // 액션 아이콘
      case 'add':
        return CupertinoIcons.add;
      case 'search':
        return CupertinoIcons.search;
      case 'bookmark':
        return CupertinoIcons.bookmark_fill;
      case 'bookmark_border':
        return CupertinoIcons.bookmark;
      case 'share':
        return CupertinoIcons.share;
      case 'clear':
        return CupertinoIcons.clear;
      case 'back':
        return CupertinoIcons.back;
      case 'forward':
        return CupertinoIcons.forward;
      
      // 상태 아이콘
      case 'check':
        return CupertinoIcons.checkmark;
      case 'check_circle':
        return CupertinoIcons.checkmark_circle_fill;
      case 'error':
        return CupertinoIcons.exclamationmark_circle;
      case 'info':
        return CupertinoIcons.info_circle;
      case 'warning':
        return CupertinoIcons.exclamationmark_triangle;
      
      // 시스템 아이콘
      case 'dark_mode':
        return CupertinoIcons.moon;
      case 'light_mode':
        return CupertinoIcons.sun_max;
      case 'brightness_auto':
        return CupertinoIcons.brightness;
      case 'notifications':
        return CupertinoIcons.bell;
      case 'help':
        return CupertinoIcons.question_circle;
      case 'feedback':
        return CupertinoIcons.chat_bubble;
      case 'refresh':
        return CupertinoIcons.refresh;
      
      // 기타 아이콘
      case 'arrow_forward_ios':
        return CupertinoIcons.right_chevron;
      case 'arrow_back_ios':
        return CupertinoIcons.left_chevron;
      case 'expand_more':
        return CupertinoIcons.chevron_down;
      case 'expand_less':
        return CupertinoIcons.chevron_up;
      
      default:
        return CupertinoIcons.question_circle;
    }
  }
  
  /// Android 전용 아이콘 매핑
  static IconData _getAndroidIcon(String iconName) {
    switch (iconName) {
      // 네비게이션 아이콘
      case 'book':
        return Icons.book;
      case 'email':
        return Icons.email;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'settings':
        return Icons.settings;
      
      // 액션 아이콘
      case 'add':
        return Icons.add;
      case 'search':
        return Icons.search;
      case 'bookmark':
        return Icons.bookmark;
      case 'bookmark_border':
        return Icons.bookmark_border;
      case 'share':
        return Icons.share;
      case 'clear':
        return Icons.clear;
      case 'back':
        return Icons.arrow_back;
      case 'forward':
        return Icons.arrow_forward;
      
      // 상태 아이콘
      case 'check':
        return Icons.check;
      case 'check_circle':
        return Icons.check_circle;
      case 'error':
        return Icons.error;
      case 'info':
        return Icons.info;
      case 'warning':
        return Icons.warning;
      
      // 시스템 아이콘
      case 'dark_mode':
        return Icons.dark_mode;
      case 'light_mode':
        return Icons.light_mode;
      case 'brightness_auto':
        return Icons.brightness_auto;
      case 'notifications':
        return Icons.notifications;
      case 'help':
        return Icons.help;
      case 'feedback':
        return Icons.feedback;
      case 'refresh':
        return Icons.refresh;
      
      // 기타 아이콘
      case 'arrow_forward_ios':
        return Icons.arrow_forward_ios;
      case 'arrow_back_ios':
        return Icons.arrow_back_ios;
      case 'expand_more':
        return Icons.expand_more;
      case 'expand_less':
        return Icons.expand_less;
      
      default:
        return Icons.help;
    }
  }
}

/// iOS 스타일 아이콘 위젯
class IOSIcon extends StatelessWidget {
  final String iconName;
  final double? size;
  final Color? color;
  
  const IOSIcon(
    this.iconName, {
    Key? key,
    this.size,
    this.color,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Icon(
      IOSIcons.getIcon(iconName),
      size: size,
      color: color,
    );
  }
}

/// iOS 스타일 아이콘 버튼
class IOSIconButton extends StatelessWidget {
  final String iconName;
  final VoidCallback? onPressed;
  final double? size;
  final Color? color;
  final String? tooltip;
  
  const IOSIconButton({
    Key? key,
    required this.iconName,
    this.onPressed,
    this.size,
    this.color,
    this.tooltip,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CupertinoButton(
        padding: EdgeInsets.all(8),
        onPressed: onPressed,
        child: Icon(
          IOSIcons.getIcon(iconName),
          size: size ?? 24,
          color: color ?? CupertinoColors.systemBlue,
        ),
      );
    } else {
      return IconButton(
        onPressed: onPressed,
        icon: Icon(
          IOSIcons.getIcon(iconName),
          size: size ?? 24,
          color: color,
        ),
        tooltip: tooltip,
      );
    }
  }
}