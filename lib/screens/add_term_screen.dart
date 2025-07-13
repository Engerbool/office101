import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/term.dart';
import '../providers/term_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/error_display_widget.dart';

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
  bool _isSaving = false;

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '용어 추가',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textColor),
        actions: [
          _isSaving
              ? Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A8DEE)),
                      ),
                    ),
                  ),
                )
              : TextButton(
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
      backgroundColor: themeProvider.backgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(themeProvider),
              SizedBox(height: 24),
              _buildTermField(themeProvider),
              SizedBox(height: 16),
              _buildDefinitionField(themeProvider),
              SizedBox(height: 16),
              _buildExampleField(themeProvider),
              SizedBox(height: 16),
              _buildCategoryField(themeProvider),
              SizedBox(height: 16),
              _buildTagsField(themeProvider),
              SizedBox(height: 32),
              _buildSaveButton(themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeProvider themeProvider) {
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
                  color: themeProvider.textColor,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermField(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '용어 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
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
                  color: themeProvider.textColor.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(
                color: themeProvider.textColor,
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

  Widget _buildDefinitionField(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '정의 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
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
                  color: themeProvider.textColor.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(
                color: themeProvider.textColor,
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

  Widget _buildExampleField(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사용 예시',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
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
                  color: themeProvider.textColor.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리 *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
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
                color: themeProvider.textColor,
                fontSize: 16,
              ),
              dropdownColor: themeProvider.cardColor,
              items: TermCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(
                    category.displayName,
                    style: TextStyle(
                      color: themeProvider.textColor,
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

  Widget _buildTagsField(ThemeProvider themeProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '태그',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
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
                  color: themeProvider.textColor.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(
                color: themeProvider.textColor,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeProvider themeProvider) {
    return Container(
      width: double.infinity,
      child: GestureDetector(
        onTap: _isSaving ? null : _saveTerm,
        child: NeumorphicContainer(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSaving) ...[
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A8DEE)),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '저장 중...',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor.withOpacity(0.6),
                    ),
                  ),
                ] else ...[
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _saveTerm() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Input validation
      final termText = _termController.text.trim();
      final definitionText = _definitionController.text.trim();
      
      if (termText.isEmpty) {
        showErrorSnackBar(context, '용어를 입력해주세요.');
        return;
      }
      
      if (definitionText.isEmpty) {
        showErrorSnackBar(context, '정의를 입력해주세요.');
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
        term: termText,
        definition: definitionText,
        example: _exampleController.text.trim(),
        tags: tags,
        userAdded: true,
      );

      // 용어 저장
      final termProvider = Provider.of<TermProvider>(context, listen: false);
      final success = await termProvider.addTerm(newTerm);
      
      if (success) {
        // 성공 메시지 표시
        showSuccessSnackBar(context, '용어가 성공적으로 추가되었습니다!');
        
        // 화면 닫기
        Navigator.pop(context);
      } else {
        // TermProvider에서 오류 메시지를 처리함
        if (termProvider.hasError && termProvider.errorMessage != null) {
          showErrorSnackBar(context, termProvider.errorMessage!);
        } else {
          showErrorSnackBar(context, '용어 추가에 실패했습니다.');
        }
      }
    } catch (e) {
      // 예상치 못한 에러
      showErrorSnackBar(context, '예상치 못한 오류가 발생했습니다.');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }
}