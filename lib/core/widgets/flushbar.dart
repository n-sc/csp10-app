import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showFlushbar(BuildContext context, String message,
    {int duration = 3, bool isError = false}) {
  Flushbar<void>(
    backgroundColor: isError ? Colors.red : const Color(0xff68B984),
    borderRadius: BorderRadius.circular(15),
    duration: Duration(seconds: duration),
    flushbarPosition: FlushbarPosition.TOP,
    message: message,
    padding: const EdgeInsets.all(20),
  ).show(context);
}
