import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class NuviMotion {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 250);
  static const Curve curve = Curves.easeOut;
  static const double pressScale = 0.97;
  static const Duration rotate = Duration(seconds: 4);

  static final bool _inWidgetTest =
      !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  /// Looping, ambient motion (marquees, auto carousels, rotating bars,
  /// particles). Off under Reduce Motion, and in widget tests so
  /// `pumpAndSettle` can settle.
  static bool ambient(BuildContext context) =>
      !_inWidgetTest && !reduced(context);

  static Duration of(BuildContext context, [Duration d = medium]) =>
      reduced(context) ? Duration.zero : d;
}
