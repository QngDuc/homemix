import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homemix/app/router/app_router.dart';
import 'package:homemix/features/auth/presentation/providers/auth_provider.dart';

import '../../support/auth_test_setup.dart';

void main() {
  testWidgets(
    'login navigates to registration and password visibility toggles',
    (tester) async {
      tester.view.physicalSize = const Size(393, 852);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final container = ProviderContainer(
        overrides: [testFirebaseAuthOverride(signedIn: false)],
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);
      router.go('/login');

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!', findRichText: true), findsOneWidget);
      expect(find.byKey(const Key('login-email')), findsOneWidget);
      expect(find.byKey(const Key('login-password')), findsOneWidget);
      final passwordInput = find.descendant(
        of: find.byKey(const Key('login-password')),
        matching: find.byType(EditableText),
      );
      expect(tester.widget<EditableText>(passwordInput).obscureText, isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(tester.widget<EditableText>(passwordInput).obscureText, isFalse);

      await tester.ensureVisible(find.text('Sign Up'));
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();
      expect(router.routeInformationProvider.value.uri.path, '/register');
      expect(find.byKey(const Key('register-name')), findsOneWidget);
      expect(
        find.byKey(const Key('register-confirm-password')),
        findsOneWidget,
      );
      expect(find.byType(Checkbox), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    },
  );

  testWidgets('a successful Firebase login opens a protected route', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [testFirebaseAuthOverride(signedIn: false)],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    router.go('/pantry');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/login');

    await tester.enterText(
      find.byKey(const Key('login-email')),
      'hello@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('login-password')),
      'password123',
    );
    await tester.ensureVisible(find.text('Log In'));
    await tester.tap(find.text('Log In'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/discover');
    expect(find.text('Bạn muốn pha món gì hôm nay?'), findsOneWidget);
  });

  testWidgets('registration saves the display name and opens Discover', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [testFirebaseAuthOverride(signedIn: false)],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    router.go('/register');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('register-name')), 'Ava Home');
    await tester.enterText(
      find.byKey(const Key('register-email')),
      'ava@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('register-password')),
      'password123',
    );
    await tester.enterText(
      find.byKey(const Key('register-confirm-password')),
      'password123',
    );
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    await tester.ensureVisible(find.text('Create Account'));
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(router.routeInformationProvider.value.uri.path, '/discover');
    expect(
      container.read(firebaseAuthProvider).currentUser?.displayName,
      'Ava Home',
    );
  });

  testWidgets('signing out from Discover returns to login', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testMainApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tài khoản'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Back!', findRichText: true), findsOneWidget);
  });

  testWidgets('unknown reset email receives the same generic confirmation', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [
        testFirebaseAuthOverride(
          signedIn: false,
          resetError: FirebaseAuthException(code: 'user-not-found'),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    router.go('/forgot-password');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('forgot-email')),
      'unknown@example.com',
    );
    await tester.ensureVisible(find.text('Send Reset Link'));
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();

    expect(
      find.text('If this email is registered, a reset link will be sent.'),
      findsOneWidget,
    );
    expect(find.text('Không tìm thấy tài khoản với email này.'), findsNothing);
  });

  testWidgets('forgot password validates email and offers return to login', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final container = ProviderContainer(
      overrides: [testFirebaseAuthOverride(signedIn: false)],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    router.go('/forgot-password');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Forgot Password?', findRichText: true), findsOneWidget);
    expect(find.byKey(const Key('forgot-email')), findsOneWidget);

    await tester.ensureVisible(find.text('Send Reset Link'));
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email address.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('forgot-email')),
      'hello@example.com',
    );
    await tester.ensureVisible(find.text('Send Reset Link'));
    await tester.tap(find.text('Send Reset Link'));
    await tester.pumpAndSettle();
    expect(
      find.text('If this email is registered, a reset link will be sent.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Back to Login'));
    await tester.pumpAndSettle();
    expect(router.routeInformationProvider.value.uri.path, '/login');
  });
}
