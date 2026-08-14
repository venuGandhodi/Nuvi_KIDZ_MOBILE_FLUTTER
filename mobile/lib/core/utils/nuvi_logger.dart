import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// Centralized, safe debug logging utility for NUVI KIDZ diagnostic tracing.
/// Adheres strictly to security rules: NO secrets, tokens, passwords, or PII.
void nuviLog(String tag, String message) {
  final formatted = '[$tag] $message';
  if (kDebugMode) {
    // Print directly to console for instant terminal diagnostics
    // ignore: avoid_print
    print(formatted);
    dev.log(message, name: tag);
  }
}
