import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:lottie/lottie.dart';

void showCustomFlushbar(
  BuildContext context, {
  required String message,
  required String icon,
  required Color color,
}) {
  Flushbar(
    margin: const EdgeInsets.all(16),
    borderRadius: BorderRadius.circular(12),
    backgroundColor: color,
    duration: const Duration(seconds: 2),
    icon: Lottie.asset(icon, width: 40, height: 40, repeat: false),
    messageText: Text(
      message,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    ),
  ).show(context);
}
