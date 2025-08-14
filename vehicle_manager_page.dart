import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class VehicleManagerPage extends StatefulWidget {
  final bool firstRun;
  const VehicleManagerPage({super.key, this.firstRun = false});

  @override
  State<VehicleManagerPage> createState() => _VehicleManagerPageState();
}

class _VehicleManagerPageState extends State<VehicleManagerPage> {
  final _form = GlobalKey<FormState>();
  final _plate = TextEditingController();
  final _make = TextEditingController();
  final _model = TextEditingController();
  final _clazz = TextEditingController();
  final _daily = TextEditingController(); // KDV dahil
  final _monthlyNet = TextEditingController(); // net
  final _monthlyVat = TextEditingController(text: '0.20'); // oran

  List<Map<String, dynamic>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _vehicles = await StorageService.getVehicles();
    setState((){});
  }

  Future<void> _add() async {
    if (_form.currentState?.validate() != true) return;
    final v = {
      'plate': _plate.text.trim(),
      'make': _make.text.trim(),
      'model': _model.text.trim(),
      'clazz': _clazz.text.trim(),
      'dailyPriceVatIncl': double.tryParse(_daily.text.replaceAll(',', '.')) ?? 0.0,
      'monthlyPriceNet': double.tryParse(_monthlyNet.text.replaceAll(',', '.')) ?? 0.0,
      'monthlyVatRate': double.tryParse(_monthlyVat.text.replaceAll(',', '.')) ?? 0.0,
      'status': 'müsait',
    };
    _vehicles.add(v);
    await StorageService.setVehicles(_vehicles);
    _plate.clear(); _make.clear(); _model.clear(); _clazz.clear(); _daily.clear(); _monthlyNet.clear();
    setState((){});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Araç eklendi')));
  }

  Future<void> _delete(int index) async {
    final removed = _vehicles.removeAt(index);
    await StorageService.setVehicles(_vehicles);
    setState((){});
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${removed['plate']} silindi')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.firstRun,
        title: const Text('Araç Tanımları (Yönetici)'),
        actions: [
          if (widget.firstRun && _vehicles.isNotEmpty)
            TextButton(
              onPressed: ()=> Navigator.of(context).pop(),
              child: const Text('Bitti', style: TextStyle(color: Colors.white)),
            )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.firstRun)
            const Padding(
              padding: EdgeInsets.only(bottom: 12.0),
              child: Text('İlk kurulum: Araç marka/model/plaka ve fiyatları ekleyin. '
                  'Kaydedilen araçlar sistemde kalır; silene kadar görünür.',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          Form(
            key: _form,
            child: Column(
              children: [
                TextFormField(controller: _plate, decoration: const InputDecoration(labelText: 'Plaka'), validator: (v)=> v==null||v.isEmpty?'Zorunlu':null),
                TextFormField(controller: _make, decoration: const InputDecoration(labelText: 'Marka'), validator: (v)=> v==null||v.isEmpty?'Zorunlu':null),
                TextFormField(controller: _model, decoration: const InputDecoration(labelText: 'Model'), validator: (v)=> v==null||v.isEmpty?'Zorunlu':null),
                TextFormField(controller: _clazz, decoration: const InputDecoration(labelText: 'Sınıf (örn. Ekonomi)')),
                const SizedBox(height: 8),
                TextFormField(controller: _daily, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Günlük Fiyat (KDV DAHİL, ₺)'), validator: (v)=> v==null||v.isEmpty?'Zorunlu':null),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _monthlyNet, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Aylık Net (₺)'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _monthlyVat, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Aylık KDV Oranı (örn. 0.20)'))),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: _add, child: const Text('Araç Ekle')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text('Kayıtlı Araçlar', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_vehicles.isEmpty)
            const Text('Henüz araç yok.'),
          for (int i=0; i<_vehicles.length; i++)
            Card(
              child: ListTile(
                title: Text('${_vehicles[i]['plate']} • ${_vehicles[i]['make']} ${_vehicles[i]['model']}'),
                subtitle: Text('Günlük (KDV dahil): ${_vehicles[i]['dailyPriceVatIncl']} ₺ • Aylık: ${_vehicles[i]['monthlyPriceNet']} + KDV'),
                trailing: IconButton(icon: const Icon(Icons.delete), onPressed: ()=> _delete(i)),
              ),
            )
        ],
      ),
    );
  }
}
