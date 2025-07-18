import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../widgets/term_list_widget.dart';
import '../widgets/error_display_widget.dart';
import '../constants/category_colors.dart';

class CategoryTermsScreen extends StatelessWidget {
  final TermCategory category;

  const CategoryTermsScreen({Key? key, required this.category})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          category.displayName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5A67),
          ),
        ),
        backgroundColor: Color(0xFFEBF0F5),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF4F5A67)),
      ),
      body: Consumer<TermProvider>(
        builder: (context, termProvider, child) {
          return LoadingErrorWidget(
            isLoading: termProvider.isLoading,
            errorMessage: termProvider.errorMessage,
            onRetry: () {
              termProvider.clearError();
              termProvider.retryLoadData();
            },
            child: Builder(
              builder: (context) {
                final categoryTerms = termProvider.getTermsByCategory(category);

                return Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (categoryTerms.isNotEmpty) ...[
                        _buildCategoryHeader(categoryTerms.length),
                        SizedBox(height: 16),
                      ],
                      Expanded(
                        child: TermListWidget(
                          terms: categoryTerms,
                          currentCategory: category,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryHeader(int termCount) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: CategoryColors.getCategoryBackgroundColor(category),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(),
            color: CategoryColors.getCategoryColor(category),
            size: 28,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                category.displayName,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F5A67),
                ),
              ),
              SizedBox(height: 4),
              Text(
                '$termCount개의 용어',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4F5A67).withAlpha(153),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon() {
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
        return Icons.access_time;
      case TermCategory.bookmarked:
        return Icons.bookmark;
      case TermCategory.other:
        return Icons.more_horiz;
    }
  }

}
