import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar (Yönetici)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(title: Text('Araç Tanımları (günlük KDV dahil, aylık net+KDV)')),
          ListTile(title: Text('Kullanıcı & Roller')),
          ListTile(title: Text('Bildirim saatleri: 21:00 TR')),
          ListTile(title: Text('Offline veri: açık')),
          ListTile(title: Text('Fatura PDF şablonu')),
          ListTile(title: Text('Dışa aktarım varsayılanları')),
        ],
      ),
    );
  }
}

class _SmtpForm extends StatefulWidget {
  const _SmtpForm();

  @override
  State<_SmtpForm> createState() => _SmtpFormState();
}

class _SmtpFormState extends State<_SmtpForm> {
  final _host = TextEditingController(text: 'smtp.gmail.com');
  final _port = TextEditingController(text: '465');
  bool _ssl = true;
  final _user = TextEditingController();
  final _pass = TextEditingController();
  final _to = TextEditingController(text: 'Samet.karakasoglu@gmail.com');
  final _fromName = TextEditingController(text: 'Rehber Otomotiv');

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    _host.text = p.getString('smtpHost') ?? _host.text;
    _port.text = (p.getInt('smtpPort') ?? int.tryParse(_port.text) ?? 465).toString();
    _ssl = p.getBool('smtpSsl') ?? _ssl;
    _user.text = p.getString('smtpUser') ?? '';
    _pass.text = p.getString('smtpPass') ?? '';
    _to.text = p.getString('smtpTo') ?? _to.text;
    _fromName.text = p.getString('smtpFromName') ?? _fromName.text;
    setState((){});
  }

  Future<void> _save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('smtpHost', _host.text.trim());
    await p.setInt('smtpPort', int.tryParse(_port.text) ?? 465);
    await p.setBool('smtpSsl', _ssl);
    await p.setString('smtpUser', _user.text.trim());
    await p.setString('smtpPass', _pass.text.trim());
    await p.setString('smtpTo', _to.text.trim());
    await p.setString('smtpFromName', _fromName.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('SMTP ayarları kaydedildi')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        const Text('Haftalık Özet E-posta (Otomatik)', style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: _host, decoration: const InputDecoration(labelText: 'SMTP Host (Gmail: smtp.gmail.com)')),
        Row(children: [
          Expanded(child: TextField(controller: _port, decoration: const InputDecoration(labelText: 'Port (SSL: 465)'), keyboardType: TextInputType.number)),
          const SizedBox(width: 12),
          Expanded(child: SwitchListTile(value: _ssl, onChanged: (v)=> setState(()=> _ssl=v), title: const Text('SSL'))),
        ]),
        TextField(controller: _user, decoration: const InputDecoration(labelText: 'Kullanıcı (Gmail adresi)')),
        TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Uygulama Şifresi')),        
        TextField(controller: _to, decoration: const InputDecoration(labelText: 'Alıcı e-posta')),        
        TextField(controller: _fromName, decoration: const InputDecoration(labelText: 'Gönderen Adı')),        
        const SizedBox(height: 8),
        FilledButton(onPressed: _save, child: const Text('Kaydet ve Etkinleştir')),
        const SizedBox(height: 8),
        const Text('Not: Gmail için 2A etkinleştirip "Uygulama Şifresi" oluşturmalısın.'),
      ],
    );
  }
}
