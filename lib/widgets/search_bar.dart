import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

/// ShamsSearchDelegate — شريط بحث مُحسَّن بتصميم Shams Platform
class ShamsSearchDelegate extends SearchDelegate<String?> {
  final List<String> searchSuggestions;

  ShamsSearchDelegate({required this.searchSuggestions});

  @override
  String get searchFieldLabel => 'ابحث هنا...';

  @override
  TextStyle get searchFieldStyle => GoogleFonts.tajawal(fontSize: 15);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: GoogleFonts.tajawal(
          fontSize: 15,
          color: colorScheme.onPrimary.withValues(alpha: 0.7),
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return [
      if (query.isNotEmpty)
        IconButton(
          tooltip: 'مسح البحث',
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
          icon: Icon(Icons.close_rounded, color: colorScheme.onPrimary),
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: 'رجوع',
      onPressed: () => close(context, null),
      icon: Icon(Icons.arrow_back_ios_rounded, color: colorScheme.onPrimary),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _filterList(query);
    return _buildList(context, results, isResult: true);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions =
        query.isEmpty ? searchSuggestions : _filterList(query);
    return _buildList(context, suggestions, isResult: false);
  }

  List<String> _filterList(String q) => searchSuggestions
      .where((e) => e.toLowerCase().contains(q.toLowerCase()))
      .toList();

  Widget _buildList(
    BuildContext context,
    List<String> items, {
    required bool isResult,
  }) {
    if (items.isEmpty) {
      return _buildEmptyState(context);
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

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 64,
            color: colorScheme.primary.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج لـ "$query"',
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'جرّب كلمة مختلفة',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SearchTile
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
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: ext.cardSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ext.borderLight),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.05),
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
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: _highlightedText(context, label, query)),
              Icon(
                Icons.north_west_rounded,
                size: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _highlightedText(BuildContext context, String text, String query) {
    final colorScheme = Theme.of(context).colorScheme;

    if (query.isEmpty) {
      return Text(text,
          style: GoogleFonts.tajawal(
              fontSize: 15, color: colorScheme.onSurface));
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex == -1) {
      return Text(text,
          style: GoogleFonts.tajawal(
              fontSize: 15, color: colorScheme.onSurface));
    }

    return RichText(
      text: TextSpan(
        style:
            GoogleFonts.tajawal(fontSize: 15, color: colorScheme.onSurface),
        children: [
          if (matchIndex > 0)
            TextSpan(text: text.substring(0, matchIndex)),
          TextSpan(
            text: text.substring(matchIndex, matchIndex + query.length),
            style: GoogleFonts.tajawal(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
              backgroundColor:
                  colorScheme.secondary.withValues(alpha: 0.25),
            ),
          ),
          if (matchIndex + query.length < text.length)
            TextSpan(text: text.substring(matchIndex + query.length)),
        ],
      ),
    );
  }
}
