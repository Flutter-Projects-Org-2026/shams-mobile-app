import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// ShamsSearchDelegate — شريط بحث مُحسَّن بتصميم Shams Platform
///
/// الاستخدام:
/// ```dart
/// showSearch(
///   context: context,
///   delegate: ShamsSearchDelegate(searchSuggestions: myList),
/// );
/// ```
class ShamsSearchDelegate extends SearchDelegate<String?> {
  /// قائمة الاقتراحات الكاملة
  final List<String> searchSuggestions;

  ShamsSearchDelegate({required this.searchSuggestions});

  // ── إعدادات عامة ─────────────────────────────────────────────────────────

  @override
  String get searchFieldLabel => 'ابحث هنا...';

  @override
  TextStyle get searchFieldStyle => GoogleFonts.tajawal(
        fontSize: 15,
        color: ShamsColors.textGray,
      );

  @override
  ThemeData appBarTheme(BuildContext context) {
    return Theme.of(context).copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: ShamsColors.primaryBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: ShamsColors.bgWhite),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.tajawal(
          fontSize: 15,
          color: Colors.white70,
        ),
        border: InputBorder.none,
      ),
    );
  }

  // ── الأيقونات الجانبية ────────────────────────────────────────────────────

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'مسح البحث',
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: const Icon(Icons.close_rounded, color: ShamsColors.bgWhite),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'رجوع',
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_ios_rounded, color: ShamsColors.bgWhite),
    );
  }

  // ── نتائج البحث ───────────────────────────────────────────────────────────

  @override
  Widget buildResults(BuildContext context) {
    final results = _filterList(query);
    return _buildList(context, results, isResult: true);
  }

  // ── الاقتراحات ────────────────────────────────────────────────────────────

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions =
        query.isEmpty ? searchSuggestions : _filterList(query);
    return _buildList(context, suggestions, isResult: false);
  }

  // ── مساعد: فلترة القائمة ──────────────────────────────────────────────────

  List<String> _filterList(String q) => searchSuggestions
      .where((e) => e.toLowerCase().contains(q.toLowerCase()))
      .toList();

  // ── واجهة مشتركة للقائمة ─────────────────────────────────────────────────

  Widget _buildList(
    BuildContext context,
    List<String> items, {
    required bool isResult,
  }) {
    if (items.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        return _SearchTile(
          label: items[index],
          query: query,
          icon: isResult ? Icons.search_rounded : Icons.history_rounded,
          onTap: () {
            query = items[index];
            showResults(context);
          },
        );
      },
    );
  }

  // ── حالة فارغة ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: ShamsColors.primaryBlue.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج لـ "$query"',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9EA3B0),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرّب كلمة مختلفة',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: const Color(0xFFBFC3CE),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SearchTile — عنصر قائمة بحث مع تمييز الكلمة المطابقة
// ─────────────────────────────────────────────────────────────────────────────

class _SearchTile extends StatelessWidget {
  final String label;
  final String query;
  final IconData icon;
  final VoidCallback onTap;

  const _SearchTile({
    required this.label,
    required this.query,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: ShamsColors.bgWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEF0F4)),
            boxShadow: [
              BoxShadow(
                color: ShamsColors.primaryBlue.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: ShamsColors.primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: ShamsColors.primaryBlue),
              ),
              const SizedBox(width: 12),
              Expanded(child: _highlightedText(label, query)),
              const Icon(
                Icons.north_west_rounded,
                size: 16,
                color: Color(0xFFBFC3CE),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// يُلوّن الجزء المطابق من النص بالأصفر الشمسي
  Widget _highlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        style: GoogleFonts.tajawal(
          fontSize: 15,
          color: ShamsColors.textGray,
        ),
      );
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(
        text,
        style: GoogleFonts.tajawal(
          fontSize: 15,
          color: ShamsColors.textGray,
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: GoogleFonts.tajawal(fontSize: 15, color: ShamsColors.textGray),
        children: [
          if (matchIndex > 0) TextSpan(text: text.substring(0, matchIndex)),
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: GoogleFonts.tajawal(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: ShamsColors.primaryBlue,
              backgroundColor: ShamsColors.solarYellow.withValues(alpha: 0.25),
            ),
          ),
          if (matchIndex + query.length < text.length)
            TextSpan(text: text.substring(matchIndex + query.length)),
        ],
      ),
    );
  }
}
