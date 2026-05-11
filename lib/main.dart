import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shams_mobile_app/views/main_screen.dart';

import 'utils/theme.dart';

Future<void> main() async {
  // Ensure Flutter engine is fully initialized before calling native code.
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for a consistent mobile experience.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase.
  try {
    await Supabase.initialize(
      url: const String.fromEnvironment('SUPABASE_URL'),
      anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
    debugPrint('Continuing in offline mode for UI testing.');
  }

  runApp(const ShamsApp());
}

/// Root widget of the Shams Platform application.
class ShamsApp extends StatelessWidget {
  const ShamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ── App Identity ────────────────────────────────────────────
      title: 'شمس',
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────────────────────────
      theme: ShamsTheme.light,

      // ── Locale & RTL ────────────────────────────────────────────
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'), // Arabic (Saudi Arabia) — primary
        Locale('en', 'US'), // English — fallback
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Entry Point ─────────────────────────────────────────────
      home: const WorkshopDashboardScreen(),
    );
  }
}
