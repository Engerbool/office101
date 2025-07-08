import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/term.dart';
import '../widgets/neumorphic_container.dart';

class TermDetailScreen extends StatelessWidget {
  final Term term;

  const TermDetailScreen({Key? key, required this.term}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '용어 상세',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5A67),
          ),
        ),
        backgroundColor: Color(0xFFEBF0F5),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF4F5A67)),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _shareTerm(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTermHeader(),
            SizedBox(height: 24),
            _buildDefinitionSection(),
            if (term.example.isNotEmpty) ...[
              SizedBox(height: 24),
              _buildExampleSection(),
            ],
            if (term.tags.isNotEmpty) ...[
              SizedBox(height: 24),
              _buildTagsSection(),
            ],
            SizedBox(height: 24),
            _buildCategorySection(),
            if (term.userAdded) ...[
              SizedBox(height: 24),
              _buildUserAddedBadge(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTermHeader() {
    return NeumorphicContainer(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                term.term,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4F5A67),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getCategoryColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                term.category.displayName,
                style: TextStyle(
                  fontSize: 12,
                  color: _getCategoryColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefinitionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정의',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5A67),
          ),
        ),
        SizedBox(height: 12),
        NeumorphicContainer(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              term.definition,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4F5A67),
                height: 1.6,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExampleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사용 예시',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5A67),
          ),
        ),
        SizedBox(height: 12),
        NeumorphicContainer(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.format_quote,
                  size: 24,
                  color: Color(0xFF5A8DEE).withOpacity(0.6),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    term.example,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF4F5A67),
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관련 태그',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5A67),
          ),
        ),
        SizedBox(height: 12),
        NeumorphicContainer(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: term.tags.map((tag) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Color(0xFF4F5A67).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4F5A67).withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5A67),
          ),
        ),
        SizedBox(height: 12),
        NeumorphicContainer(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getCategoryColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getCategoryIcon(),
                    color: _getCategoryColor(),
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),
                Text(
                  term.category.displayName,
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4F5A67),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserAddedBadge() {
    return NeumorphicContainer(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              Icons.person_add,
              color: Color(0xFF5A8DEE),
              size: 24,
            ),
            SizedBox(width: 12),
            Text(
              '사용자가 추가한 용어입니다',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF5A8DEE),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareTerm(BuildContext context) {
    final shareText = '''
${term.term}

${term.definition}

${term.example.isNotEmpty ? '예시: ${term.example}' : ''}

- 직장생활은 처음이라 앱에서 공유
    '''.trim();

    Clipboard.setData(ClipboardData(text: shareText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('용어 정보가 클립보드에 복사되었습니다'),
        backgroundColor: Color(0xFF5A8DEE),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (term.category) {
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
    switch (term.category) {
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