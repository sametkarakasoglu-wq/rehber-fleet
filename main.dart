import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/rental_new_page.dart';
import 'pages/return_list_page.dart';
import 'pages/reservation_list_page.dart';
import 'pages/reports_page.dart';
import 'pages/settings_page.dart';
import 'pages/vehicle_manager_page.dart';
import 'services/storage_service.dart';
import 'services/background_task.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().cancelAll();
  await registerWeeklyEmailTask();
  runApp(const RehberFleetApp());
}

class RehberFleetApp extends StatelessWidget {
  const RehberFleetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rehber Otomotiv',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: StorageService.getVehicles(),
        builder: (context, snap) {
          if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          final list = (snap.data as List<Map<String, dynamic>>);
          // If first run (no vehicles), go to vehicle manager
          if (list.isEmpty) {
            return const VehicleManagerPage(firstRun: true);
          }
          return const RootShell();
        },
      ),
      routes: {
        '/rental/new': (_) => const RentalNewPage(),
        '/return/list': (_) => const ReturnListPage(),
        '/reservation/list': (_) => const ReservationListPage(),
        '/reports': (_) => const ReportsPage(),
        '/settings': (_) => const SettingsPage(),
      },
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _index = 0;
  final _pages = const [
    HomePage(),
    RentalNewPage(),
    ReturnListPage(),
    ReservationListPage(),
    ReportsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          NavigationDestination(icon: Icon(Icons.vpn_key), label: 'Kiralama'),
          NavigationDestination(icon: Icon(Icons.assignment_return), label: 'İade'),
          NavigationDestination(icon: Icon(Icons.event), label: 'Rezervasyon'),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Raporlar'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ayarlar'),
        ],
        onDestinationSelected: (i) => setState(() => _index = i),
      ),
    );
  }
}
