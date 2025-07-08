import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/term_provider.dart';
import '../widgets/neumorphic_container.dart';
import 'terms_tab_screen.dart';
import 'email_templates_screen.dart';
import 'workplace_tips_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  @override
  _MainNavigationScreenState createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      TermsTabScreen(),
      EmailTemplatesScreen(),
      WorkplaceTipsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFEBF0F5),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFA6B4C4).withOpacity(0.3),
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.book,
                label: '용어사전',
                color: Color(0xFF5A8DEE),
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.email,
                label: '이메일',
                color: Color(0xFF42A5F5),
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.lightbulb,
                label: '꿀팁',
                color: Color(0xFFFFCA28),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = _currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: NeumorphicContainer(
          isPressed: isSelected,
          borderRadius: 20,
          depth: isSelected ? 2 : 4,
          child: Container(
            width: 80,
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? color : Color(0xFF4F5A67).withOpacity(0.6),
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? color : Color(0xFF4F5A67).withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}