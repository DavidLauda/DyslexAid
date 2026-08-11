import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/reading_history.dart';
import 'screens/beranda_screen.dart';
import 'screens/kamus_kata_screen.dart';
import 'screens/riwayat_screen.dart';
import 'screens/latihan_screen.dart';
import 'widgets/glass_ui.dart';

import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/vocab_service.dart';
import 'services/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ReadingHistoryAdapter());
  await Hive.openBox<ReadingHistory>('reading_history_box');
  await Hive.openBox<List<String>>('global_box');
  await Hive.openBox('settings_box');
  await Hive.openBox<int>('vocab_stats_box');

  final vocabService = VocabService();
  try {
    await vocabService.loadDataset();
  } catch (e) {
    debugPrint("Gagal memuat dataset KBBI: $e");
    // Tetap lanjut runApp() dengan state kosong
  }

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          Provider<VocabService>.value(value: vocabService),
          ChangeNotifierProvider<SettingsProvider>(create: (_) => SettingsProvider()),
        ],
        child: const DyslexAidApp(),
      ),
    );
  });
}

class DyslexAidApp extends StatelessWidget {
  const DyslexAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    
    Color seedColor;
    switch (settings.appThemeIndex) {
      case 1: seedColor = const Color(0xFF0277BD); break; // Ocean Breeze (Light Blue)
      case 2: seedColor = const Color(0xFFFF7043); break; // Sunset Coral (Deep Orange)
      case 3: seedColor = const Color(0xFF7E57C2); break; // Lavender Dream (Deep Purple)
      case 0:
      default: seedColor = Colors.teal; break;
    }

    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: settings.isAppDarkMode ? Brightness.dark : Brightness.light,
    );

    return MaterialApp(
      title: 'DyslexAid',
      themeMode: settings.isAppDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.primary,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            color: colorScheme.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: colorScheme.primary),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: colorScheme.primary,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            color: colorScheme.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: colorScheme.primary),
        ),
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 1; // Default to Beranda

  final List<Widget> _screens = [
    const KamusKataScreen(),
    const BerandaScreen(),
    const RiwayatScreen(),
    const LatihanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GlassBackground(
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.auto_stories_rounded),
                    label: 'Kamus',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.space_dashboard_rounded),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history_rounded),
                    label: 'Riwayat',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.extension_rounded),
                    label: 'Latihan',
                  ),
                ],
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ),
        ),
      ),
      child: _screens[_currentIndex],
    );
  }
}
