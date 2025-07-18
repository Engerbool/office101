import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../screens/category_terms_screen.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_breakpoints.dart';
import 'neumorphic_container.dart';
import '../constants/category_colors.dart';

class CategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType) {
        final crossAxisCount = ResponsiveValues<int>(
          mobile: 2,
          tablet: 3,
          desktop: 4,
        ).getValue(deviceType);

        final spacing = ResponsiveValues<double>(
          mobile: 12,
          tablet: 16,
          desktop: 20,
        ).getValue(deviceType);

        final aspectRatio = ResponsiveValues<double>(
          mobile: 1.2,
          tablet: 1.1,
          desktop: 1.0,
        ).getValue(deviceType);

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          childAspectRatio: aspectRatio,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          children: TermCategory.values
              .where((category) => category != TermCategory.other)
              .map((category) {
            return _buildCategoryCard(context, category);
          }).toList(),
        );
      },
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
            padding: ResponsiveValues<EdgeInsets>(
              mobile: EdgeInsets.all(16.0),
              tablet: EdgeInsets.all(18.0),
              desktop: EdgeInsets.all(20.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ResponsiveContainer(
                  width: ResponsiveValues<double>(
                    mobile: 48,
                    tablet: 56,
                    desktop: 64,
                  ),
                  height: ResponsiveValues<double>(
                    mobile: 48,
                    tablet: 56,
                    desktop: 64,
                  ),
                  decoration: BoxDecoration(
                    color: CategoryColors.getCategoryBackgroundColor(category),
                    borderRadius: BorderRadius.circular(
                      ResponsiveValues<double>(
                        mobile: 12,
                        tablet: 14,
                        desktop: 16,
                      ).getValueFromContext(context),
                    ),
                  ),
                  child: ResponsiveIcon(
                    _getCategoryIcon(category),
                    color: CategoryColors.getCategoryColor(category),
                    size: ResponsiveValues<double>(
                      mobile: 28,
                      tablet: 32,
                      desktop: 36,
                    ),
                  ),
                ),
                ResponsiveSizedBox.height(
                  ResponsiveValues<double>(
                    mobile: 12,
                    tablet: 14,
                    desktop: 16,
                  ),
                ),
                ResponsiveText(
                  category.displayName,
                  fontSize: ResponsiveValues<double>(
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                  ),
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F5A67),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                ResponsiveSizedBox.height(
                  ResponsiveValues<double>(
                    mobile: 4,
                    tablet: 6,
                    desktop: 8,
                  ),
                ),
                ResponsiveText(
                  '$termCount개 용어',
                  fontSize: ResponsiveValues<double>(
                    mobile: 12,
                    tablet: 13,
                    desktop: 14,
                  ),
                  color: Color(0xFF4F5A67).withAlpha(153),
                ),
              ],
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
