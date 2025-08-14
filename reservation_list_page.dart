import 'package:flutter/material.dart';
import '../services/fleet_store.dart';
import '../utils/date_utils.dart';

class ReservationListPage extends StatefulWidget {
  const ReservationListPage({super.key});

  @override
  State<ReservationListPage> createState() => _ReservationListPageState();
}

class _ReservationListPageState extends State<ReservationListPage> {
  List<Map<String, dynamic>> _reservations = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _reservations = await FleetStore.reservations();
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rezervasyonlar')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Basit örnek rezervasyon ekle
          final now = DateTime.now();
          final item = {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'plate': '34 RL 5314',
            'customerId': null,
            'startTs': now.toIso8601String(),
            'endTs': now.add(const Duration(days: 3)).toIso8601String(),
            'pickupPlace': 'Ümraniye',
            'dropoffPlace': 'Kadıköy',
            'status': 'Bekliyor',
          };
          final list = await FleetStore.reservations();
          list.add(item);
          await FleetStore.setReservations(list);
          await _load();
        },
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _reservations.length,
        separatorBuilder: (_, __)=> const Divider(),
        itemBuilder: (_, i){
          final r = _reservations[i];
          final start = DateTime.parse(r['startTs']);
          final end = DateTime.parse(r['endTs']);
          return ListTile(
            title: Text("${r['plate']} – ${AppDate.dt(start)} → ${AppDate.dt(end)}"),
            subtitle: Text('Teslim: ${r['pickupPlace']} • İade: ${r['dropoffPlace']} • Durum: ${r['status']}'),
            trailing: FilledButton.tonal(
              onPressed: (){
                Navigator.pushNamed(context, '/rental/new', arguments: {
                  'plate': r['plate'],
                  'start': start,
                  'end': end,
                });
              },
              child: const Text('Kiralamaya Dönüştür'),
            ),
          );
        },
      ),
    );
  }
}
