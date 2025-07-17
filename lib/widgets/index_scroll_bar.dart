import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/korean_sort_utils.dart';

class IndexScrollBar extends StatefulWidget {
  final ScrollController scrollController;
  final List<String> availableIndexes;
  final Function(String) onIndexSelected;
  final bool isVisible;

  const IndexScrollBar({
    Key? key,
    required this.scrollController,
    required this.availableIndexes,
    required this.onIndexSelected,
    required this.isVisible,
  }) : super(key: key);

  @override
  _IndexScrollBarState createState() => _IndexScrollBarState();
}

class _IndexScrollBarState extends State<IndexScrollBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // 초기에 바로 표시
    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(IndexScrollBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _animationController.forward();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return IgnorePointer(
          ignoring: !widget.isVisible,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 32,
                margin: EdgeInsets.only(right: 8, top: 80, bottom: 80),
                decoration: BoxDecoration(
                  color: Color(0xFF5A8DEE).withAlpha(102),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(26),
                      blurRadius: 8,
                      offset: Offset(-2, 0),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _buildIndexItems(themeProvider),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildIndexItems(ThemeProvider themeProvider) {
    return KoreanSortUtils.indexList.map((index) {
      final isAvailable = widget.availableIndexes.contains(index);
      final isSelected = _selectedIndex == index;
      
      return GestureDetector(
        onTap: isAvailable ? () => _onIndexTap(index) : null,
        child: Container(
          width: 28,
          height: 18,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected 
                ? Colors.white.withAlpha(77)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            index,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
              color: isAvailable 
                  ? (isSelected ? Colors.white : Colors.white)
                  : Colors.white.withAlpha(128),
            ),
          ),
        ),
      );
    }).toList();
  }

  void _onIndexTap(String index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // 콜백 함수 호출 (스크롤 이동 기능)
    widget.onIndexSelected(index);
    
    // 선택 상태를 잠시 후 해제 (비주얼 피드백용)
    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _selectedIndex = null;
        });
      }
    });
  }
}

class IndexIndicator extends StatelessWidget {
  final String currentIndex;
  final ThemeProvider themeProvider;

  const IndexIndicator({
    Key? key,
    required this.currentIndex,
    required this.themeProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: MediaQuery.of(context).size.height * 0.4,
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Color(0xFF5A8DEE).withAlpha(230),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: themeProvider.shadowColor.withAlpha(77),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            currentIndex,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}