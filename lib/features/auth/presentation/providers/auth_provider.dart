import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth_repository.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

String authErrorMessage(FirebaseAuthException error) {
  switch (error.code) {
    case 'invalid-email':
      return 'Email không hợp lệ.';
    case 'user-not-found':
      return 'Không tìm thấy tài khoản với email này.';
    case 'wrong-password':
    case 'invalid-login-credentials':
    case 'invalid-credential':
      return 'Email hoặc mật khẩu không chính xác.';
    case 'email-already-in-use':
      return 'Email này đã được sử dụng.';
    case 'weak-password':
      return 'Mật khẩu quá yếu. Hãy sử dụng ít nhất 6 ký tự.';
    case 'user-disabled':
      return 'Tài khoản này đã bị vô hiệu hóa.';
    case 'too-many-requests':
      return 'Bạn đã thử quá nhiều lần. Vui lòng thử lại sau.';
    case 'network-request-failed':
      return 'Không thể kết nối mạng. Hãy kiểm tra Internet.';
    case 'operation-not-allowed':
      return 'Phương thức đăng nhập chưa được bật trên Firebase.';
    default:
      final message = error.message?.trim();
      return message == null || message.isEmpty
          ? 'Đã xảy ra lỗi. Vui lòng thử lại.'
          : message;
  }
}
