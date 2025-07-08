import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../widgets/neumorphic_container.dart';

class AddTermScreen extends StatefulWidget {
  @override
  _AddTermScreenState createState() => _AddTermScreenState();
}

class _AddTermScreenState extends State<AddTermScreen> {
  final _formKey = GlobalKey<FormState>();
  final _termController = TextEditingController();
  final _definitionController = TextEditingController();
  final _exampleController = TextEditingController();
  final _tagsController = TextEditingController();
  
  TermCategory _selectedCategory = TermCategory.other;

  @override
  void dispose() {
    _termController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '용어 추가',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5A67),
          ),
        ),
        backgroundColor: Color(0xFFEBF0F5),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF4F5A67)),
        actions: [
          TextButton(
            onPressed: _saveTerm,
            child: Text(
              '저장',
              style: TextStyle(
                color: Color(0xFF5A8DEE),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              SizedBox(height: 24),
              _buildTermField(),
              SizedBox(height: 16),
              _buildDefinitionField(),
              SizedBox(height: 16),
              _buildExampleField(),
              SizedBox(height: 16),
              _buildCategoryField(),
              SizedBox(height: 16),
              _buildTagsField(),
              SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return NeumorphicContainer(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Color(0xFF5A8DEE),
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                '새로운 용어를 추가하여 나만의 사전을 만들어보세요!',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF4F5A67),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '용어 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5A67),
          ),
        ),
        SizedBox(height: 8),
        NeumorphicContainer(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: TextFormField(
              controller: _termController,
              decoration: InputDecoration(
                hintText: '용어를 입력하세요',
                hintStyle: TextStyle(
                  color: Color(0xFF4F5A67).withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(
                color: Color(0xFF4F5A67),
                fontSize: 16,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '용어를 입력해주세요';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefinitionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정의 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5A67),
          ),
        ),
        SizedBox(height: 8),
        NeumorphicContainer(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: TextFormField(
              controller: _definitionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '용어의 정의를 입력하세요',
                hintStyle: TextStyle(
                  color: Color(0xFF4F5A67).withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(
                color: Color(0xFF4F5A67),
                fontSize: 16,
                height: 1.4,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '정의를 입력해주세요';
                }
                return null;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExampleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사용 예시',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5A67),
          ),
        ),
        SizedBox(height: 8),
        NeumorphicContainer(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: TextFormField(
              controller: _exampleController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: '용어를 사용한 예시를 입력하세요 (선택사항)',
                hintStyle: TextStyle(
                  color: Color(0xFF4F5A67).withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(
                color: Color(0xFF4F5A67),
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5A67),
          ),
        ),
        SizedBox(height: 8),
        NeumorphicContainer(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: DropdownButtonFormField<TermCategory>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              style: TextStyle(
                color: Color(0xFF4F5A67),
                fontSize: 16,
              ),
              dropdownColor: Color(0xFFEBF0F5),
              items: TermCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(
                    category.displayName,
                    style: TextStyle(
                      color: Color(0xFF4F5A67),
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '태그',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F5A67),
          ),
        ),
        SizedBox(height: 8),
        NeumorphicContainer(
          child: Padding(
            padding: EdgeInsets.all(4.0),
            child: TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                hintText: '태그를 쉼표로 구분하여 입력하세요 (예: 업무, 보고)',
                hintStyle: TextStyle(
                  color: Color(0xFF4F5A67).withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(
                color: Color(0xFF4F5A67),
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: _saveTerm,
        child: NeumorphicContainer(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.save,
                  color: Color(0xFF5A8DEE),
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  '용어 저장하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5A8DEE),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveTerm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 태그 처리
    List<String> tags = [];
    if (_tagsController.text.trim().isNotEmpty) {
      tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    // 고유 ID 생성
    final termId = 'user_${DateTime.now().millisecondsSinceEpoch}';

    // Term 객체 생성
    final newTerm = Term(
      termId: termId,
      category: _selectedCategory,
      term: _termController.text.trim(),
      definition: _definitionController.text.trim(),
      example: _exampleController.text.trim(),
      tags: tags,
      userAdded: true,
    );

    try {
      // 용어 저장
      await Provider.of<TermProvider>(context, listen: false).addTerm(newTerm);
      
      // 성공 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('용어가 성공적으로 추가되었습니다!'),
          backgroundColor: Color(0xFF5A8DEE),
          duration: Duration(seconds: 2),
        ),
      );

      // 화면 닫기
      Navigator.pop(context);
    } catch (e) {
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('용어 추가 중 오류가 발생했습니다: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}