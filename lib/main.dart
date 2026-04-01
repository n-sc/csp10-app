import 'dart:developer' show log;

import 'package:csp10_app/app.dart';
import 'package:csp10_app/core/data/constants.dart';
import 'package:csp10_app/core/services/service_locator.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';

void main() {
  if (kDebugMode) {
    log("This app is running in debug mode");
    log("Using fake user session: ${Constants.useFakeSession}");
  }
  setupLocator();
  runApp(const App());
}
