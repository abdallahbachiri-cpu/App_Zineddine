import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return GoldenToolkit.runWithConfiguration(() async {
    await loadAppFonts();
    return testMain();
  }, config: GoldenToolkitConfiguration(enableRealShadows: true));
}
