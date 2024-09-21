import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_platform_alert/flutter_platform_alert.dart';

class EmailUtils {
  static void sendEmail(BuildContext context) async {
    final Email email = Email(
      recipients: ['augustapphelp2@gmail.com'],
      cc: [],
      bcc: [],
      attachmentPaths: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      String title = 'Send feedback';
      String message =
          "Cannot send mail because the user's mail account has not been set up.";

      await FlutterPlatformAlert.showAlert(
        windowTitle: title,
        text: message,
      );
    }
  }
}
