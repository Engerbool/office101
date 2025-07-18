import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/platform_utils.dart';

/// iOS 스타일 스와이프 제스처 위젯
class IOSSwipeGesture extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeBack;
  final bool enableSwipeBack;
  final double swipeThreshold;
  
  const IOSSwipeGesture({
    Key? key,
    required this.child,
    this.onSwipeBack,
    this.enableSwipeBack = true,
    this.swipeThreshold = 0.3,
  }) : super(key: key);
  
  @override
  _IOSSwipeGestureState createState() => _IOSSwipeGestureState();
}

class _IOSSwipeGestureState extends State<IOSSwipeGesture>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _dragDistance = 0.0;
  bool _isDragging = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _onPanStart(DragStartDetails details) {
    if (!widget.enableSwipeBack) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final startX = details.globalPosition.dx;
    
    // 화면 왼쪽 가장자리에서 시작하는 경우에만 스와이프 활성화
    if (startX < 20.0) {
      setState(() {
        _isDragging = true;
        _dragDistance = 0.0;
      });
    }
  }
  
  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    setState(() {
      _dragDistance += details.delta.dx;
      _dragDistance = _dragDistance.clamp(0.0, screenWidth);
    });
    
    // 햅틱 피드백 (iOS에서만)
    if (PlatformUtils.isIOS && _dragDistance > screenWidth * 0.2) {
      HapticFeedback.selectionClick();
    }
  }
  
  void _onPanEnd(DragEndDetails details) {
    if (!_isDragging) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final velocity = details.velocity.pixelsPerSecond.dx;
    
    setState(() {
      _isDragging = false;
    });
    
    // 스와이프 임계값 검사
    if (_dragDistance > screenWidth * widget.swipeThreshold || velocity > 300) {
      _animateBack();
    } else {
      _animateCancel();
    }
  }
  
  void _animateBack() {
    _controller.forward().then((_) {
      widget.onSwipeBack?.call();
      _controller.reset();
      setState(() {
        _dragDistance = 0.0;
      });
    });
  }
  
  void _animateCancel() {
    _controller.reverse().then((_) {
      setState(() {
        _dragDistance = 0.0;
      });
    });
  }
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Stack(
          children: [
            // 메인 콘텐츠
            Transform.translate(
              offset: Offset(_dragDistance, 0),
              child: widget.child,
            ),
            // 뒤로가기 인디케이터
            if (_isDragging && _dragDistance > 0)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: _dragDistance,
                child: Container(
                  color: CupertinoColors.systemBackground,
                  child: Center(
                    child: Icon(
                      CupertinoIcons.back,
                      color: CupertinoColors.systemBlue,
                      size: 24,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      return widget.child;
    }
  }
}

/// iOS 스타일 페이지 전환 애니메이션
class IOSPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String? title;
  
  IOSPageRoute({
    required this.child,
    this.title,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          settings: settings,
          transitionDuration: Duration(milliseconds: 300),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (PlatformUtils.isIOS) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                )),
                child: child,
              );
            } else {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            }
          },
        );
}

/// iOS 스타일 모달 시트
class IOSModalSheet extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  
  const IOSModalSheet({
    Key? key,
    required this.child,
    this.title,
    this.actions,
  }) : super(key: key);
  
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    List<Widget>? actions,
  }) {
    if (PlatformUtils.isIOS) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (BuildContext context) => IOSModalSheet(
          child: child,
          title: title,
          actions: actions,
        ),
      );
    } else {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext context) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(height: 1),
              ],
              child,
              if (actions != null && actions.isNotEmpty) ...[
                Divider(height: 1),
                Container(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: actions,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 드래그 핸들
          Container(
            margin: EdgeInsets.only(top: 8),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 제목
          if (title != null) ...[
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                title!,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          // 내용
          child,
          // 액션 버튼들
          if (actions != null && actions!.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: actions!,
              ),
            ),
          ],
          // 안전 영역
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

/// iOS 스타일 당겨서 새로고침
class IOSRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  
  const IOSRefreshIndicator({
    Key? key,
    required this.child,
    required this.onRefresh,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (PlatformUtils.isIOS) {
      return CustomScrollView(
        slivers: [
          CupertinoSliverRefreshControl(
            onRefresh: onRefresh,
          ),
          SliverToBoxAdapter(
            child: child,
          ),
        ],
      );
    } else {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: child,
      );
    }
  }
}