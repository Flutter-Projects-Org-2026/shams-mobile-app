import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class CityMultiSelectFilter extends StatefulWidget {
  final ValueChanged<List<String>> onSelectionChanged;

  const CityMultiSelectFilter({super.key, required this.onSelectionChanged});

  @override
  State<CityMultiSelectFilter> createState() => _CityMultiSelectFilterState();
}

class _CityMultiSelectFilterState extends State<CityMultiSelectFilter> {
  final List<String> _availableCities = [
    'تعز',
    'صنعاء',
    'عدن',
    'حضرموت',
    'مأرب',
    'الحديدة',
  ];

  final List<String> _selectedCities = [];

  void _showMultiSelectDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final colorScheme = Theme.of(context).colorScheme;
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(
                'اختر المحافظات',
                style: GoogleFonts.tajawal(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary),
                textAlign: TextAlign.center,
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _availableCities.length,
                  itemBuilder: (context, index) {
                    final city = _availableCities[index];
                    final isChecked = _selectedCities.contains(city);

                    return CheckboxListTile(
                      title: Text(city,
                          style: GoogleFonts.tajawal(fontSize: 15)),
                      value: isChecked,
                      activeColor: colorScheme.secondary,
                      checkColor: colorScheme.onSecondary,
                      onChanged: (bool? value) {
                        setStateDialog(() {
                          if (value == true) {
                            _selectedCities.add(city);
                          } else {
                            _selectedCities.remove(city);
                          }
                        });
                        setState(() {});
                        widget.onSelectionChanged(_selectedCities);
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'تم',
                    style: GoogleFonts.tajawal(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeCity(String city) {
    setState(() => _selectedCities.remove(city));
    widget.onSelectionChanged(_selectedCities);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Filter button ──
        GestureDetector(
          onTap: _showMultiSelectDialog,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: ext.borderLight, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_alt_outlined,
                    size: 20, color: colorScheme.onSurface),
                const SizedBox(width: 8),
                Text(
                  'المحافظات',
                  style: GoogleFonts.tajawal(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface),
                ),
                const SizedBox(width: 12),
                Icon(Icons.keyboard_arrow_down_rounded,
                    size: 20, color: colorScheme.onSurface),
                if (_selectedCities.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_selectedCities.length}',
                      style: GoogleFonts.tajawal(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // ── Selected city chips ──
        if (_selectedCities.isNotEmpty) ...[
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _selectedCities.map((city) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: InputChip(
                    label: Text(
                      city,
                      style: GoogleFonts.tajawal(
                          fontSize: 13,
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500),
                    ),
                    backgroundColor:
                        colorScheme.secondary.withValues(alpha: 0.15),
                    deleteIconColor: colorScheme.onSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: colorScheme.secondary),
                    ),
                    onDeleted: () => _removeCity(city),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}