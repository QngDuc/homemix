import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'package:homemix/app/app.dart';
import 'package:homemix/features/auth/presentation/providers/auth_provider.dart';

class TestFirebaseAuth extends Fake implements FirebaseAuth {
  TestFirebaseAuth({bool signedIn = true, this.resetError}) {
    if (signedIn) {
      _currentUser = _TestUser(email: 'tester@example.com');
    }
  }

  final _authStateController = StreamController<User?>.broadcast(sync: true);
  final FirebaseAuthException? resetError;
  User? _currentUser;
  String? lastResetEmail;

  @override
  User? get currentUser => _currentUser;

  @override
  Stream<User?> authStateChanges() async* {
    yield _currentUser;
    yield* _authStateController.stream;
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _currentUser = _TestUser(email: email);
    _authStateController.add(_currentUser);
    return _TestUserCredential(_currentUser);
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _currentUser = _TestUser(email: email);
    _authStateController.add(_currentUser);
    return _TestUserCredential(_currentUser);
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
    ActionCodeSettings? actionCodeSettings,
  }) async {
    if (resetError != null) throw resetError!;
    lastResetEmail = email;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  Future<void> dispose() => _authStateController.close();
}

Override testFirebaseAuthOverride({
  bool signedIn = true,
  FirebaseAuthException? resetError,
}) {
  return firebaseAuthProvider.overrideWith((ref) {
    final auth = TestFirebaseAuth(signedIn: signedIn, resetError: resetError);
    ref.onDispose(() => unawaited(auth.dispose()));
    return auth;
  });
}

Widget testMainApp({List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: [testFirebaseAuthOverride(), ...overrides],
    child: const MainApp(),
  );
}

class _TestUser extends Fake implements User {
  _TestUser({this.email});

  @override
  final String? email;

  String? _displayName;

  @override
  String? get displayName => _displayName;

  @override
  String get uid => 'test-user';

  @override
  Future<void> updateDisplayName(String? displayName) async {
    _displayName = displayName;
  }

  @override
  Future<void> reload() async {}
}

class _TestUserCredential extends Fake implements UserCredential {
  _TestUserCredential(this.user);

  @override
  final User? user;
}
