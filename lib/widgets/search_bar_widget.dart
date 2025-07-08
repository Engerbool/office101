import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'neumorphic_container.dart';

class SearchBarWidget extends StatelessWidget {
  final Function(String) onSearch;
  final String? hintText;
  final TextEditingController? controller;

  const SearchBarWidget({
    Key? key,
    required this.onSearch,
    this.hintText,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return NeumorphicContainer(
          backgroundColor: themeProvider.cardColor,
          shadowColor: themeProvider.shadowColor,
          highlightColor: themeProvider.highlightColor,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: themeProvider.textColor.withOpacity(0.6),
                  size: 24,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: onSearch,
                    decoration: InputDecoration(
                      hintText: hintText ?? '용어를 검색해보세요...',
                      hintStyle: TextStyle(
                        color: themeProvider.subtitleColor.withOpacity(0.5),
                        fontSize: 16,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                    ),
                    style: TextStyle(
                      color: themeProvider.textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (controller?.text.isNotEmpty == true)
                  GestureDetector(
                    onTap: () {
                      controller?.clear();
                      onSearch('');
                    },
                    child: Icon(
                      Icons.clear,
                      color: themeProvider.textColor.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}