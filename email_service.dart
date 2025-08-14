import 'dart:io';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmailSettings {
  final String smtpHost;
  final int smtpPort;
  final bool useSsl;
  final String username;
  final String password;
  final String toEmail;
  final String fromName;

  EmailSettings({
    required this.smtpHost,
    required this.smtpPort,
    required this.useSsl,
    required this.username,
    required this.password,
    required this.toEmail,
    required this.fromName,
  });
}

class EmailService {
  static Future<void> sendEmail({
    required EmailSettings settings,
    required String subject,
    required String htmlBody,
    List<File> attachments = const [],
  }) async {
    final server = SmtpServer(
      settings.smtpHost,
      port: settings.smtpPort,
      ssl: settings.useSsl,
      username: settings.username,
      password: settings.password,
    );
    final message = Message()
      ..from = Address(settings.username, settings.fromName)
      ..recipients.add(settings.toEmail)
      ..subject = subject
      ..html = htmlBody;

    for (final f in attachments) {
      message.attachments.add(FileAttachment(f));
    }

    final sendReport = await send(message, server);
    // print(sendReport.toString());
  }
}
