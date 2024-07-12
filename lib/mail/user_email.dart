import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserEmail {
  final String stmpServer;
  final String username;
  final String password;

  UserEmail({
    required this.stmpServer,
    required this.username,
    required this.password,
  });

  Future<void> sendEmail(String recipientEmail, String subject, String text) async {
    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'UCSI Report')
      ..recipients.add(recipientEmail)
      ..subject = subject
      ..text = text;

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } on MailerException catch (e) {
      print('Message not sent. \n' + e.toString());
    }
  }
}
