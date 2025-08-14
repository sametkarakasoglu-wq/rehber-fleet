import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../services/fleet_store.dart';
import '../services/email_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kWeeklyEmailTask = 'weekly_email_task';

Future<void> registerWeeklyEmailTask() async {
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  // Android exact weekly is not guaranteed; use periodic every 7 days.
  await Workmanager().registerPeriodicTask(
    'weekly_email_task_id',
    kWeeklyEmailTask,
    frequency: const Duration(days: 7),
    initialDelay: const Duration(days: 7),
    constraints: Constraints(networkType: NetworkType.connected),
    backoffPolicy: BackoffPolicy.linear,
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    if (taskName == kWeeklyEmailTask) {
      try {
        // Build Excel
        final rentals = await FleetStore.rentals();
        final excel = Excel.createExcel();
        final sheet = excel['Summary'];
        sheet.appendRow(['Plaka','Müşteri','Teslim','Tah. İade','Durum']);
        for (final r in rentals) {
          sheet.appendRow([r['plate'], r['customerName'], r['startTs'], r['estEndTs'], r['status']]);
        }
        final bytes = excel.encode()!;
        final dir = await getApplicationDocumentsDirectory();
        final excelPath = '${dir.path}/haftalik_ozet.xlsx';
        final excelFile = File(excelPath)..writeAsBytesSync(bytes);

        // Build PDF
        final doc = pw.Document();
        doc.addPage(pw.Page(build: (ctx){
          return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text('Haftalık Filo Özeti', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            for (final r in rentals) pw.Text('${r['plate']} • ${r['customerName']} • ${r['status']}')
          ]);
        }));
        final pdfPath = '${dir.path}/haftalik_ozet.pdf';
        final pdfFile = File(pdfPath);
        await pdfFile.writeAsBytes(await doc.save());

        // Load SMTP settings from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final smtpHost = prefs.getString('smtpHost') ?? '';
        final smtpPort = prefs.getInt('smtpPort') ?? 465;
        final useSsl = prefs.getBool('smtpSsl') ?? true;
        final username = prefs.getString('smtpUser') ?? '';
        final password = prefs.getString('smtpPass') ?? '';
        final toEmail = prefs.getString('smtpTo') ?? '';
        final fromName = prefs.getString('smtpFromName') ?? 'Rehber Otomotiv';

        if (smtpHost.isNotEmpty && username.isNotEmpty && password.isNotEmpty && toEmail.isNotEmpty) {
          await EmailService.sendEmail(
            settings: EmailSettings(
              smtpHost: smtpHost, smtpPort: smtpPort, useSsl: useSsl,
              username: username, password: password, toEmail: toEmail, fromName: fromName
            ),
            subject: 'Haftalık Filo Özeti',
            htmlBody: '<p>Haftalık özet ektedir.</p>',
            attachments: [excelFile, pdfFile],
          );
        }
      } catch (e) {
        // ignore
      }
    }
    return Future.value(true);
  });
}
