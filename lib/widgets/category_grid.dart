import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../screens/category_terms_screen.dart';
import 'neumorphic_container.dart';
import '../constants/category_colors.dart';

class CategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: TermCategory.values.where((category) => category != TermCategory.other).map((category) {
        return _buildCategoryCard(context, category);
      }).toList(),
    );
  }

  Widget _buildCategoryCard(BuildContext context, TermCategory category) {
    return Consumer<TermProvider>(
      builder: (context, termProvider, child) {
        final termCount = termProvider.getTermsByCategory(category).length;
        
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryTermsScreen(category: category),
              ),
            );
          },
          child: NeumorphicContainer(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: CategoryColors.getCategoryBackgroundColor(category),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
                      color: CategoryColors.getCategoryColor(category),
                      size: 28,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    category.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F5A67),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    '$termCount개 용어',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4F5A67).withAlpha(153),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getCategoryIcon(TermCategory category) {
    switch (category) {
      case TermCategory.approval:
        return Icons.approval;
      case TermCategory.business:
        return Icons.business_center;
      case TermCategory.marketing:
        return Icons.campaign;
      case TermCategory.it:
        return Icons.computer;
      case TermCategory.hr:
        return Icons.people;
      case TermCategory.communication:
        return Icons.chat_bubble;
      case TermCategory.time:
        return Icons.schedule;
      case TermCategory.other:
        return Icons.more_horiz;
      case TermCategory.bookmarked:
        return Icons.bookmark;
    }
  }

}