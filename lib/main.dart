import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/reading_history.dart';
import 'screens/beranda_screen.dart';
import 'screens/kamus_kata_screen.dart';
import 'screens/riwayat_screen.dart';

import 'package:provider/provider.dart';
import 'services/vocab_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inisialisasi Hive
  await Hive.initFlutter();
  Hive.registerAdapter(ReadingHistoryAdapter());
  await Hive.openBox<ReadingHistory>('reading_history_box');
  await Hive.openBox<List<String>>('global_box');

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
      Provider<VocabService>.value(
        value: vocabService,
        child: const DyslexAidApp(),
      ),
    );
  });
}

class DyslexAidApp extends StatelessWidget {
  const DyslexAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DyslexAid',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
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
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Kamus Kata',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
