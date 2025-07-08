import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../widgets/term_list_widget.dart';

class CategoryTermsScreen extends StatelessWidget {
  final TermCategory category;

  const CategoryTermsScreen({Key? key, required this.category}) : super(key: key);

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
          final categoryTerms = termProvider.getTermsByCategory(category);
          
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategoryHeader(categoryTerms.length),
                SizedBox(height: 16),
                Expanded(
                  child: TermListWidget(terms: categoryTerms),
                ),
              ],
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
            color: _getCategoryColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(),
            color: _getCategoryColor(),
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
                  color: Color(0xFF4F5A67).withOpacity(0.6),
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
      case TermCategory.other:
        return Icons.more_horiz;
    }
  }

  Color _getCategoryColor() {
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