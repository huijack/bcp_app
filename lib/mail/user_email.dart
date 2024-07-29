import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UserEmail {
  final String smtpServer;
  final String username;
  final String password;

  UserEmail({
    required this.smtpServer,
    required this.username,
    required this.password,
  });

  factory UserEmail.fromEnv() {
    return UserEmail(
      smtpServer: dotenv.env['SMTP_SERVER']!,
      username: dotenv.env['EMAIL_USERNAME']!,
      password: dotenv.env['EMAIL_PASSWORD']!,
    );
  }

  Future<void> sendEmail(String recipientEmail, String subject, String text) async {
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'UCSI Report')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = text;

    try {
      final sendReport = await send(message, smtpServer);
      debugPrint('Message sent: $sendReport');
    } on MailerException catch (e) {
      debugPrint('Message not: $e');
    }
  }
}
