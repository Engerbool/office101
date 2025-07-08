import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import 'neumorphic_container.dart';

class CategoryFilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TermProvider>(
      builder: (context, termProvider, child) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip(
                context,
                termProvider,
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
        child: NeumorphicContainer(
          isPressed: isSelected,
          borderRadius: 20,
          depth: isSelected ? 2 : 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected 
                    ? _getCategoryColor(category)
                    : Color(0xFF4F5A67).withOpacity(0.7),
              ),
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
    }
  }
}