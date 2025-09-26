import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/calorie_provider.dart';
import 'screens/home_screen.dart';
import 'screens/deposit_screen.dart';
import 'screens/withdrawal_screen.dart';
import 'screens/history_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const CalorieBankApp());
}

class CalorieBankApp extends StatelessWidget {
  const CalorieBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CalorieProvider()..initialize(),
      child: MaterialApp(
        title: 'カロリー貯金',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            primary: Colors.green.shade600,
            secondary: Colors.orange.shade500,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
          ),
        ),
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const DepositScreen(),
    const WithdrawalScreen(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  void setCurrentIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
          NavigationDestination(icon: Icon(Icons.add_circle), label: '入金'),
          NavigationDestination(
            icon: Icon(Icons.remove_circle),
            label: '引き落とし',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: '履歴'),
          NavigationDestination(icon: Icon(Icons.settings), label: '設定'),
        ],
      ),
    );
  }
}
