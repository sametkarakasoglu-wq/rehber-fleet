import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../services/fleet_store.dart';
import '../utils/date_utils.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Raporlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(title: Text('Kirada: —')),
          ListTile(title: Text('Müsait: —')),
          ListTile(title: Text('Gelir (hafta): —')),
          ListTile(title: Text('Doluluk %: —')),
          ListTile(title: Text('Top araçlar: —')),
          SizedBox(height: 24),
          Text('Dışa Aktar: Excel / PDF (örnek)'),
        ],
      ),
    );
  }
}
