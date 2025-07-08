import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import 'neumorphic_container.dart';

class CategoryFilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<TermProvider, ThemeProvider>(
      builder: (context, termProvider, themeProvider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context,
                termProvider,
                themeProvider,
                '전체',
                null,
                termProvider.selectedCategory == null,
              ),
              SizedBox(width: 8),
              ...TermCategory.values.where((category) => category != TermCategory.other).map((category) {
                return Row(
                  children: [
                    _buildFilterChip(
                      context,
                      termProvider,
                      themeProvider,
                      category.displayName,
                      category,
                      termProvider.selectedCategory == category,
                    ),
                    SizedBox(width: 8),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    TermProvider termProvider,
    ThemeProvider themeProvider,
    String label,
    TermCategory? category,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        termProvider.filterByCategory(category);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF5A8DEE) : themeProvider.cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Color(0xFF5A8DEE).withOpacity(0.3),
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: themeProvider.shadowColor.withOpacity(0.3),
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    ),
                    BoxShadow(
                      color: themeProvider.highlightColor.withOpacity(0.8),
                      offset: Offset(-2, -2),
                      blurRadius: 4,
                    ),
                  ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected 
                  ? Colors.white
                  : themeProvider.textColor.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(TermCategory? category) {
    if (category == null) return Color(0xFF5A8DEE);
    
    switch (category) {
      case TermCategory.approval:
        return Color(0xFF5A8DEE);
      case TermCategory.business:
        return Color(0xFF42A5F5);
      case TermCategory.marketing:
        return Color(0xFF66BB6A);
      case TermCategory.it:
        return Color(0xFFFF7043);
      case TermCategory.hr:
        return Color(0xFFAB47BC);
      case TermCategory.communication:
        return Color(0xFFFFCA28);
      case TermCategory.other:
        return Color(0xFF78909C);
      case TermCategory.bookmarked:
        return Color(0xFFFFCA28);
    }
  }
}