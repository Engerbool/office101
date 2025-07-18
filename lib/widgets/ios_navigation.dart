import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/platform_utils.dart';
import '../providers/theme_provider.dart';
import '../utils/ios_icons.dart';

/// iOS 스타일 네비게이션 바
class IOSNavigationBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  
  const IOSNavigationBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return CupertinoNavigationBar(
            middle: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: foregroundColor ?? themeProvider.textColor,
              ),
            ),
            trailing: actions != null && actions!.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: actions!,
                  )
                : null,
            leading: leading,
            automaticallyImplyLeading: automaticallyImplyLeading,
            backgroundColor: backgroundColor ?? themeProvider.backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: themeProvider.dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
          );
        },
      );
    } else {
      return AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: foregroundColor,
          ),
        ),
        actions: actions,
        leading: leading,
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
      );
    }
  }
  
  @override
  Size get preferredSize => Size.fromHeight(
    PlatformUtils.isIOS ? 44.0 : kToolbarHeight,
  );
}

/// iOS 스타일 탭 바
class IOSTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<IOSTabItem> items;
  
  const IOSTabBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return CupertinoTabBar(
            currentIndex: currentIndex,
            onTap: onTap,
            backgroundColor: themeProvider.backgroundColor,
            activeColor: CupertinoColors.systemBlue,
            inactiveColor: CupertinoColors.systemGrey,
            items: items.map((item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon ?? item.icon),
              label: item.label,
            )).toList(),
          );
        },
      );
    } else {
      return Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: onTap,
            backgroundColor: themeProvider.backgroundColor,
            selectedItemColor: Color(0xFF5A8DEE),
            unselectedItemColor: themeProvider.textColor.withValues(alpha: 0.6),
            type: BottomNavigationBarType.fixed,
            items: items.map((item) => BottomNavigationBarItem(
              icon: Icon(item.icon),
              activeIcon: Icon(item.activeIcon ?? item.icon),
              label: item.label,
            )).toList(),
          );
        },
      );
    }
  }
}

/// iOS 탭 아이템 데이터 클래스
class IOSTabItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  
  const IOSTabItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}

/// iOS 스타일 버튼
class IOSButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final bool filled;
  final double? minSize;
  final EdgeInsetsGeometry? padding;
  
  const IOSButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.color,
    this.filled = false,
    this.minSize,
    this.padding,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      if (filled) {
        return CupertinoButton.filled(
          onPressed: onPressed,
          minSize: minSize ?? 44.0,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        return CupertinoButton(
          onPressed: onPressed,
          color: color,
          minSize: minSize ?? 44.0,
          padding: padding ?? EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w400,
              color: color ?? CupertinoColors.systemBlue,
            ),
          ),
        );
      }
    } else {
      if (filled) {
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? Color(0xFF5A8DEE),
            foregroundColor: Colors.white,
            minimumSize: Size(88, minSize ?? 48.0),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      } else {
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: color ?? Color(0xFF5A8DEE),
            minimumSize: Size(88, minSize ?? 48.0),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      }
    }
  }
}

/// iOS 스타일 액션 시트
class IOSActionSheet {
  static void show(
    BuildContext context, {
    required String title,
    String? message,
    required List<IOSActionSheetAction> actions,
  }) {
    if (PlatformUtils.isIOS) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (BuildContext context) => CupertinoActionSheet(
          title: Text(title),
          message: message != null ? Text(message) : null,
          actions: actions.map((action) => CupertinoActionSheetAction(
            onPressed: action.onPressed,
            isDestructiveAction: action.isDestructive,
            child: Text(action.text),
          )).toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: Text('취소'),
          ),
        ),
      );
    } else {
      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) => Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (message != null) ...[
                SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(fontSize: 14),
                ),
              ],
              SizedBox(height: 16),
              ...actions.map((action) => ListTile(
                title: Text(
                  action.text,
                  style: TextStyle(
                    color: action.isDestructive ? Colors.red : null,
                  ),
                ),
                onTap: action.onPressed,
              )),
              ListTile(
                title: Text('취소'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );
    }
  }
}

/// iOS 액션 시트 액션 데이터 클래스
class IOSActionSheetAction {
  final String text;
  final VoidCallback onPressed;
  final bool isDestructive;
  
  const IOSActionSheetAction({
    required this.text,
    required this.onPressed,
    this.isDestructive = false,
  });
}