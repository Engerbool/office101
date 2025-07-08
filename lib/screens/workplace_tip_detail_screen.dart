import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/workplace_tip.dart';
import '../widgets/neumorphic_container.dart';

class WorkplaceTipDetailScreen extends StatelessWidget {
  final WorkplaceTip tip;

  const WorkplaceTipDetailScreen({Key? key, required this.tip}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '직장생활 팁',
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
            onPressed: () => _shareTip(context),
            tooltip: '팁 공유',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: 24),
            _buildContentSection(),
            if (tip.keyPoints.isNotEmpty) ...[
              SizedBox(height: 24),
              _buildKeyPointsSection(),
            ],
            SizedBox(height: 24),
            _buildCategorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return NeumorphicContainer(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F5A67),
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getCategoryColor().withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tip.category.displayName,
                              style: TextStyle(
                                fontSize: 12,
                                color: _getCategoryColor(),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (tip.priority == 1) ...[
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Color(0xFFFF7043).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '중요',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFFF7043),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '상세 내용',
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
              tip.content,
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

  Widget _buildKeyPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '핵심 포인트',
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.checklist,
                      color: Color(0xFF5A8DEE),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Text(
                      '꼭 기억해야 할 포인트들',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4F5A67),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ...tip.keyPoints.asMap().entries.map((entry) {
                  final index = entry.key;
                  final point = entry.value;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Color(0xFF5A8DEE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            point,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF4F5A67),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
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
                  tip.category.displayName,
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

  void _shareTip(BuildContext context) {
    final shareText = '''
💡 ${tip.title}

${tip.content}

✅ 핵심 포인트:
${tip.keyPoints.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value}').join('\n')}

- 직장생활은 처음이라 앱에서 공유
    '''.trim();

    Clipboard.setData(ClipboardData(text: shareText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('팁이 클립보드에 복사되었습니다'),
        backgroundColor: Color(0xFF5A8DEE),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (tip.category) {
      case TipCategory.schedule:
        return Icons.schedule;
      case TipCategory.report:
        return Icons.assignment_turned_in;
      case TipCategory.meeting:
        return Icons.groups;
      case TipCategory.communication:
        return Icons.forum;
      case TipCategory.general:
        return Icons.work;
    }
  }

  Color _getCategoryColor() {
    switch (tip.category) {
      case TipCategory.schedule:
        return Color(0xFF5A8DEE);
      case TipCategory.report:
        return Color(0xFF42A5F5);
      case TipCategory.meeting:
        return Color(0xFF66BB6A);
      case TipCategory.communication:
        return Color(0xFFFFCA28);
      case TipCategory.general:
        return Color(0xFF78909C);
    }
  }
}