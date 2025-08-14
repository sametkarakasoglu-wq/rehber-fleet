import 'package:flutter/material.dart';
import '../utils/date_utils.dart';
import 'package:uuid/uuid.dart';
import '../services/fleet_store.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';

class RentalNewPage extends StatefulWidget {
  const RentalNewPage({super.key});

  @override
  State<RentalNewPage> createState() => _RentalNewPageState();
}

class _RentalNewPageState extends State<RentalNewPage> {
  bool _invoiceAttached = false;
  String? _invoicePath;

  bool _invoiceAttached = FalseBool.falseValue;
  final _form = GlobalKey<FormState>();
  final _plate = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _tc = TextEditingController();
  final _start = ValueNotifier<DateTime>(DateTime.now());
  final _end = ValueNotifier<DateTime>(DateTime.now().add(const Duration(days: 1)));
  final _daily = TextEditingController(text: '1200'); // örnek
  final _startKm = TextEditingController(text: '0');
  final _deposit = TextEditingController(text: '0');

  int _days() => AppDate.fullDaysCeil(_start.value, _end.value);
  double _total() {
    final d = double.tryParse(_daily.text) ?? 0;
    return d * _days();
  }

  Future<void> _pickDate(ValueNotifier<DateTime> target) async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      initialDate: target.value,
    );
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(target.value));
    if (t == null) return;
    target.value = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    setState((){});
  }

  @override
  void initState() {
    super.initState();
    // Prefill from arguments if any
    final args = (WidgetsBinding.instance.platformDispatcher.views.isNotEmpty)
        ? ModalRoute.of(context)?.settings.arguments
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args['plate'] != null && _plate.text.isEmpty) _plate.text = args['plate'];
        if (args['start'] != null) _start.value = args['start'];
        if (args['end'] != null) _end.value = args['end'];
        // daily price could be prefilled later from vehicle db
      }
      // PREFILL_DONE
      return Scaffold(
      appBar: AppBar(title: const Text('Yeni Kiralama')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(controller: _plate, decoration: const InputDecoration(labelText: 'Plaka'), validator: (v)=> v==null||v.isEmpty?'Zorunlu':null),
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Ad Soyad'), validator: (v)=> v==null||v.isEmpty?'Zorunlu':null),
            TextFormField(controller: _phone, decoration: const InputDecoration(labelText: 'Telefon'), keyboardType: TextInputType.phone),
            TextFormField(controller: _tc, decoration: const InputDecoration(labelText: 'TC Kimlik (maskeli saklanacak)')),
            const SizedBox(height: 12),
            ValueListenableBuilder<DateTime>(
              valueListenable: _start,
              builder: (_, dt, __) => ListTile(
                title: const Text('Teslim Tarih & Saat'),
                subtitle: Text(AppDate.dt(dt)),
                trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: ()=>_pickDate(_start)),
              ),
            ),
            ValueListenableBuilder<DateTime>(
              valueListenable: _end,
              builder: (_, dt, __) => ListTile(
                title: const Text('Tahmini İade Tarih & Saat'),
                subtitle: Text(AppDate.dt(dt)),
                trailing: IconButton(icon: const Icon(Icons.calendar_today), onPressed: ()=>_pickDate(_end)),
              ),
            ),
            TextFormField(controller: _daily, decoration: const InputDecoration(labelText: 'Günlük Bedel (KDV dahil, ₺)'), keyboardType: TextInputType.number),
            TextFormField(controller: _startKm, decoration: const InputDecoration(labelText: 'Çıkış KM'), keyboardType: TextInputType.number),
            TextFormField(controller: _deposit, decoration: const InputDecoration(labelText: 'Depozito (₺)'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            ListTile(
              title: const Text('Toplam Ücret (otomatik)'),
              subtitle: Text('${_days()} gün × ${_daily.text} ₺ = ${_total().toStringAsFixed(2)} ₺'),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Fatura kesildi mi?'),
              value: _invoiceAttached,
              onChanged: (v)=> setState(()=> _invoiceAttached = v),
            ),
            if (_invoiceAttached) ListTile(
              title: const Text('Fatura PDF Ekle'),
              subtitle: Text(_invoicePath ?? 'Seçilmedi'),
              trailing: IconButton(icon: const Icon(Icons.attach_file), onPressed: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                if (result != null && result.files.single.path != null) {
                  setState(()=> _invoicePath = result.files.single.path);
                }
              }),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () async {
                if(_form.currentState?.validate()!=true) return;
                final id = const Uuid().v4();
                final rental = {
                  'id': id,
                  'plate': _plate.text.trim(),
                  'customerName': _name.text.trim(),
                  'customerPhone': _phone.text.trim(),
                  'tcMasked': _tc.text.trim(),
                  'startTs': _start.value.toIso8601String(),
                  'estEndTs': _end.value.toIso8601String(),
                  'startKm': int.tryParse(_startKm.text) ?? 0,
                  'dailyPriceVatIncl': double.tryParse(_daily.text) ?? 0.0,
                  'deposit': double.tryParse(_deposit.text) ?? 0.0,
                  'paymentMethod': 'N/A',
                  'invoiceAttached': _invoiceAttached,
                  'invoicePdfPath': _invoicePath,
                  'status': 'kirada',
                };
                await FleetOps.addRental(rental);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kiralama kaydedildi')));
                Navigator.pop(context);
              },
              child: const Text('Teslim Et'),
            )
          ],
        ),
      ),
    );
  }
}
