import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_helper.dart';
import '../utils/responsive_breakpoints.dart';
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
          padding: ResponsiveValues<EdgeInsets>(
            mobile: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            tablet: EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
            desktop: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          ),
          child: Row(
            children: [
              ResponsiveIcon(
                Icons.search,
                color: themeProvider.textColor.withAlpha(153),
                size: ResponsiveValues<double>(
                  mobile: 24,
                  tablet: 26,
                  desktop: 28,
                ),
              ),
              ResponsiveSizedBox.width(
                ResponsiveValues<double>(
                  mobile: 12,
                  tablet: 14,
                  desktop: 16,
                ),
              ),
              Expanded(
                child: ResponsiveBuilder(
                  builder: (context, deviceType) {
                    return TextField(
                      controller: controller,
                      onSubmitted: onSearch,
                      decoration: InputDecoration(
                        hintText: hintText ?? '용어를 검색해보세요...',
                        hintStyle: TextStyle(
                          color: themeProvider.subtitleColor.withAlpha(128),
                          fontSize: ResponsiveValues<double>(
                            mobile: 16,
                            tablet: 17,
                            desktop: 18,
                          ).getValue(deviceType),
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: ResponsiveValues<double>(
                            mobile: 12.0,
                            tablet: 14.0,
                            desktop: 16.0,
                          ).getValue(deviceType),
                        ),
                      ),
                      style: TextStyle(
                        color: themeProvider.textColor,
                        fontSize: ResponsiveValues<double>(
                          mobile: 16,
                          tablet: 17,
                          desktop: 18,
                        ).getValue(deviceType),
                      ),
                    );
                  },
                ),
              ),
              if (controller?.text.isNotEmpty == true)
                GestureDetector(
                  onTap: () {
                    controller?.clear();
                    onSearch('');
                  },
                  child: ResponsiveIcon(
                    Icons.clear,
                    color: themeProvider.textColor.withAlpha(153),
                    size: ResponsiveValues<double>(
                      mobile: 20,
                      tablet: 22,
                      desktop: 24,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
