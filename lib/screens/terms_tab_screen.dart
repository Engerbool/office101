import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/term_provider.dart';
import '../models/term.dart';
import '../widgets/neumorphic_container.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/category_filter_chips.dart';
import '../widgets/term_list_widget.dart';
import 'term_search_screen.dart';
import 'add_term_screen.dart';

class TermsTabScreen extends StatefulWidget {
  @override
  _TermsTabScreenState createState() => _TermsTabScreenState();
}

class _TermsTabScreenState extends State<TermsTabScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TermProvider>(
        builder: (context, termProvider, child) {
          if (termProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF5A8DEE)),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _buildQuickSearchSection(context)),
                    SizedBox(width: 12),
                    _buildAddButton(context),
                  ],
                ),
                SizedBox(height: 16),
                CategoryFilterChips(),
                SizedBox(height: 24),
                _buildFilteredTermsSection(termProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return NeumorphicContainer(
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.book,
                  color: Color(0xFF5A8DEE),
                  size: 28,
                ),
                SizedBox(width: 12),
                Text(
                  '용어사전',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4F5A67),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '모르는 직장 용어를 쉽게 찾아보세요!\n카테고리별 검색으로 더 빠르게 찾을 수 있습니다.',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4F5A67).withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSearchSection(BuildContext context) {
    return SearchBarWidget(
      controller: _searchController,
      onSearch: (query) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TermSearchScreen(initialQuery: query),
          ),
        );
      },
      hintText: '궁금한 용어를 검색해보세요...',
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddTermScreen()),
        );
      },
      child: NeumorphicContainer(
        borderRadius: 20,
        child: Container(
          width: 48,
          height: 48,
          child: Icon(
            Icons.add,
            color: Color(0xFF5A8DEE),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredTermsSection(TermProvider termProvider) {
    List<Term> termsToShow;
    
    if (termProvider.selectedCategory != null) {
      termsToShow = termProvider.getTermsByCategory(termProvider.selectedCategory!);
    } else {
      termsToShow = termProvider.getPopularTerms();
    }
    
    if (termsToShow.isEmpty) {
      return SizedBox();
    }

    return TermListWidget(
      terms: termsToShow,
      isCompact: true,
      showCategory: termProvider.selectedCategory == null,
    );
  }
}