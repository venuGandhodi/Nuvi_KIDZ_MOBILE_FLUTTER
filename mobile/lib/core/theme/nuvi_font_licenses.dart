import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Registers the bundled font licenses so they appear on the licenses page.
void registerNuviFontLicenses() {
  const files = {
    'Baloo 2': 'Baloo2-OFL.txt',
    'Nunito': 'Nunito-OFL.txt',
    'Fraunces': 'Fraunces-OFL.txt',
    'Mountains of Christmas': 'MountainsofChristmas-LICENSE.txt',
    'Paytone One': 'PaytoneOne-OFL.txt',
    'Yeseva One': 'YesevaOne-OFL.txt',
    'Kalam': 'Kalam-OFL.txt',
    'Yatra One': 'YatraOne-OFL.txt',
    'Rozha One': 'RozhaOne-OFL.txt',
    'Katibeh': 'Katibeh-OFL.txt',
  };
  LicenseRegistry.addLicense(() async* {
    for (final entry in files.entries) {
      final text = await rootBundle.loadString(
        'assets/fonts/licenses/${entry.value}',
      );
      yield LicenseEntryWithLineBreaks([entry.key], text);
    }
  });
}
