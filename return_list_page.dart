import 'package:flutter/material.dart';
import '../services/fleet_store.dart';
import '../utils/date_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class ReturnListPage extends StatefulWidget {
  const ReturnListPage({super.key});

  @override
  State<ReturnListPage> createState() => _ReturnListPageState();
}

class _ReturnListPageState extends State<ReturnListPage> {
  List<Map<String, dynamic>> _rentals = [];
  List<Map<String, dynamic>> _approaching = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _rentals = await FleetStore.rentals();
    _rentals = _rentals.where((e) => e['status'] == 'kirada').toList();
    _approaching = await FleetOps.approachingReturns3Days();
    setState((){});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('İade / Yaklaşan İadeler'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Kirada'),
            Tab(text: '3 Gün Kala'),
          ]),
        ),
        body: TabBarView(
          children: [
            _buildRentedList(),
            _buildApproachingList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRentedList() {
    if (_rentals.isEmpty) return const Center(child: Text('Kirada araç yok'));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _rentals.length,
      separatorBuilder: (_, __)=> const Divider(),
      itemBuilder: (_, i){
        final r = _rentals[i];
        final plate = r['plate'];
        final name = r['customerName'] ?? '';
        final est = DateTime.tryParse(r['estEndTs'] ?? '') ?? DateTime.now();
        return ListTile(
          title: Text('$plate'),
          subtitle: Text('Müşteri: $name • İade: ${AppDate.dt(est)}'),
          trailing: FilledButton(
            onPressed: ()=> Navigator.push(context, MaterialPageRoute(builder: (_)=> CheckinPage(rental: r))).then((_)=>_load()),
            child: const Text('Check-in'),
          ),
        );
      },
    );
  }

  Widget _buildApproachingList() {
    if (_approaching.isEmpty) return const Center(child: Text('3 gün kala iade yok'));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _approaching.length,
      separatorBuilder: (_, __)=> const Divider(),
      itemBuilder: (_, i){
        final r = _approaching[i];
        final plate = r['plate'];
        final name = r['customerName'] ?? '';
        final phone = r['customerPhone'] ?? '';
        final est = DateTime.tryParse(r['estEndTs'] ?? '') ?? DateTime.now();
        final now = DateTime.now();
        final remaining = est.difference(now).inDays;
        return ListTile(
          title: Text('$plate • $name'),
          subtitle: Text('İade: ${AppDate.dt(est)}  • Kalan: ${remaining < 0 ? 0 : remaining} gün'),
          trailing: Wrap(
            spacing: 8,
            children: [
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: () async {
                  final uri = Uri(scheme: 'tel', path: phone);
                  await launchUrl(uri);
                },
              ),
              IconButton(
                icon: const Icon(Icons.whatsapp),
                onPressed: () async {
                  final msg = Uri.encodeComponent('Yaklaşan iade – $plate | Müşteri: $name | İade: ${AppDate.dt(est)}');
                  final uri = Uri.parse('https://wa.me/$phone?text=$msg');
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class CheckinPage extends StatefulWidget {
  final Map<String, dynamic> rental;
  const CheckinPage({super.key, required this.rental});

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> {
  final _form = GlobalKey<FormState>();
  final _returnKm = TextEditingController();
  DateTime _dt = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İade Al')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: const Text('İade Tarih & Saat'),
              subtitle: Text(AppDate.dt(_dt)),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final now = DateTime.now();
                  final d = await showDatePicker(
                    context: context,
                    firstDate: DateTime(now.year-1),
                    lastDate: DateTime(now.year+2),
                    initialDate: _dt,
                  );
                  if (d==null) return;
                  final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_dt));
                  if (t==null) return;
                  setState(()=> _dt = DateTime(d.year,d.month,d.day,t.hour,t.minute));
                },
              ),
            ),
            TextFormField(controller: _returnKm, decoration: const InputDecoration(labelText: 'İade KM'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                if(_form.currentState?.validate()!=true) return;
                await FleetOps.completeRental(widget.rental['id'], {
                  'endTs': _dt.toIso8601String(),
                  'endKm': int.tryParse(_returnKm.text) ?? 0,
                  'status': 'tamamlandi',
                });
                if (!mounted) return;
                Navigator.of(context).push(MaterialPageRoute(builder: (_)=> SummaryPage(rentalId: widget.rental['id']))).then((_) => Navigator.of(context).pop());
              },
              child: const Text('Teslim Al'),
            )
          ],
        ),
      ),
    );
  }
}

class SummaryPage extends StatelessWidget {
  final String rentalId;
  const SummaryPage({super.key, required this.rentalId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: FleetStore.rentals(),
      builder: (context, snap) {
        if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final list = snap.data!;
        final r = list.firstWhere((e)=> e['id']==rentalId);
        final start = DateTime.parse(r['startTs']);
        final end = DateTime.tryParse(r['endTs'] ?? '') ?? DateTime.now();
        final days = AppDate.fullDaysCeil(start, end);
        final total = (r['dailyPriceVatIncl'] as num).toDouble() * days;
        final km = (r['endKm'] ?? 0) - (r['startKm'] ?? 0);

        return Scaffold(
          appBar: AppBar(title: const Text('Bilgi Ekranı')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plaka: ${r['plate']}'),
                Text('Müşteri: ${r['customerName']}'),
                Text('Teslim: ${AppDate.dt(start)}'),
                Text('İade: ${AppDate.dt(end)}'),
                Text('Gün: $days (başlanan gün tam sayılır)'),
                Text('KM: $km'),
                Text('Toplam Ücret: ${total.toStringAsFixed(2)} ₺ (KDV dahil)'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    FilledButton.tonal(
                      onPressed: (){
                        // TODO: PDF oluşturma entegrasyonu
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PDF oluşturma (örnek)')));
                      },
                      child: const Text('PDF Oluştur'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton(
                      onPressed: () async {
                        final msg = Uri.encodeComponent('Fatura/Özet – ${r['plate']} | ${days}gün | Toplam: ${total.toStringAsFixed(2)} ₺');
                        final phone = (r['customerPhone'] ?? '');
                        final uri = Uri.parse('https://wa.me/$phone?text=$msg');
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      },
                      child: const Text('WhatsApp'),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
