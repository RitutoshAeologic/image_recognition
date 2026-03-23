import 'dart:developer';

class Logger {
  static void logInfo(String message) {
    log(message, name: "APP");
  }

  static void logError(String message) {
    log(message, name: "ERROR");
  }
}