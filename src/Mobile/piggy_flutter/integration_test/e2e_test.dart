import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:piggy_flutter/main.dart' as app;

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 45),
}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (finder.evaluate().isNotEmpty) {
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      return;
    }
  }
  final texts = tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data ?? '')
      .where((text) => text.isNotEmpty)
      .toList();
  fail('Timed out waiting for $finder. Visible text: $texts');
}

Future<void> _skipIntroIfNeeded(WidgetTester tester) async {
  if (find.text('SKIP').evaluate().isNotEmpty) {
    await tester.tap(find.text('SKIP'));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }
  if (find.text('DONE').evaluate().isNotEmpty) {
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }
}

Future<void> _waitForAppReady(WidgetTester tester) async {
  final end = DateTime.now().add(const Duration(seconds: 60));
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 500));
    if (find.text('This month').evaluate().isNotEmpty ||
        find.text('Sign in to continue').evaluate().isNotEmpty ||
        find.text('SKIP').evaluate().isNotEmpty ||
        find.text('DONE').evaluate().isNotEmpty ||
        find.text('Travel more').evaluate().isNotEmpty ||
        find.byIcon(Icons.add).evaluate().isNotEmpty) {
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      return;
    }
  }
  fail('App did not become ready');
}

Future<void> _ensureLoggedIn(WidgetTester tester) async {
  await _waitForAppReady(tester);

  if (find.byIcon(Icons.add).evaluate().isNotEmpty) {
    return;
  }

  await _skipIntroIfNeeded(tester);
  await tester.pumpAndSettle(const Duration(seconds: 3));

  if (find.byIcon(Icons.add).evaluate().isNotEmpty) {
    return;
  }

  if (find.text('Travel more').evaluate().isNotEmpty) {
    // Swipe through intro pages to reach DONE
    for (var i = 0; i < 3; i++) {
      if (find.text('DONE').evaluate().isNotEmpty) {
        await tester.tap(find.text('DONE'));
        break;
      }
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  if (find.byIcon(Icons.add).evaluate().isNotEmpty) {
    return;
  }

  await _pumpUntilFound(tester, find.text('Sign in to continue'));

  final familyField = find.byKey(const Key('login_family_field'));
  final usernameField = find.byKey(const Key('login_username_field'));
  final passwordField = find.byKey(const Key('login_password_field'));

  await tester.tap(familyField);
  await tester.enterText(familyField, 'Default');
  await tester.tap(usernameField);
  await tester.enterText(usernameField, 'admin');
  await tester.tap(passwordField);
  await tester.enterText(passwordField, '123qwe');

  await tester.tap(find.text('SIGN IN'));
  await tester.pump(const Duration(seconds: 2));

  // Allow time for auth API round-trip
  for (var attempt = 0; attempt < 45; attempt++) {
    await tester.pump(const Duration(seconds: 2));
    if (find.byIcon(Icons.add).evaluate().isNotEmpty) {
      await tester.pumpAndSettle(const Duration(milliseconds: 200));
      return;
    }
    if (find.textContaining('Invalid').evaluate().isNotEmpty) {
      fail('Login failed with validation error on screen');
    }
  }

  final texts = tester
      .widgetList<Text>(find.byType(Text))
      .map((text) => text.data ?? '')
      .where((text) => text.isNotEmpty)
      .toList();
  fail('Login did not reach dashboard. Visible text: $texts');
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.dragFrom(const Offset(5, 400), const Offset(300, 400));
  await tester.pumpAndSettle(const Duration(seconds: 2));
  await _pumpUntilFound(tester, find.text('Logout'));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('full app E2E smoke test', (tester) async {
    await app.main();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await _skipIntroIfNeeded(tester);
    await _ensureLoggedIn(tester);
    expect(find.byIcon(Icons.add), findsOneWidget);

    // Bottom navigation tabs (MaterialCommunityIcons)
    final bottomNavY = tester.getSize(find.byType(MaterialApp)).height - 80;
    await tester.tapAt(Offset(120, bottomNavY));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tapAt(Offset(280, bottomNavY));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tapAt(Offset(800, bottomNavY));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tapAt(Offset(40, bottomNavY));
    await _pumpUntilFound(tester, find.byIcon(Icons.add));

    // Drawer: categories, reports, settings
    await _openDrawer(tester);
    await tester.tap(find.text('Categories'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Categories'), findsWidgets);
    await _openDrawer(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await _openDrawer(tester);
    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Reports'), findsWidgets);
    await _openDrawer(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await _openDrawer(tester);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
    expect(find.text('Default Currency'), findsOneWidget);
    await _openDrawer(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Add transaction FAB opens form
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.text('Amount'), findsWidgets);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Logout
    await _openDrawer(tester);
    await tester.tap(find.text('Logout'));
    await _pumpUntilFound(tester, find.text('Sign in to continue'));
    expect(find.text('SIGN IN'), findsOneWidget);
  });
}
