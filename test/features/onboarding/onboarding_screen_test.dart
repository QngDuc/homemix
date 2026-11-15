import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homemix/app/router/app_router.dart';

import '../../support/auth_test_setup.dart';

void main() {
  testWidgets('renders the welcome screen from the onboarding route', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [testFirebaseAuthOverride(signedIn: false)],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);
    router.go('/onboarding');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tự tay pha'), findsOneWidget);
    expect(find.text('Đồ uống'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(router.routeInformationProvider.value.uri.path, '/onboarding');
  });
}
