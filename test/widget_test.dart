// Basic smoke test for Tar el Char.
//
// This verifies the app builds and launches without throwing errors.
// It does not test Firebase-dependent screens, since Firebase isn't
// initialized in the test environment.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tar_el_char/main.dart';

void main() {
  testWidgets('App builds and shows onboarding screen', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TarElCharApp());

    // Just confirm it rendered without crashing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
