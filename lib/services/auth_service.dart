import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import '../models/result.dart';

abstract class IAuthService {
  Future<Result<models.User>> createAccount({
    required String email,
    required String password,
  });
  Future<Result<models.User>> login({
    required String email,
    required String password,
  });
  Future<Result<models.User>> getCurrentUser();
  Future<Result<models.Session>> getCurrentSession();
  Future<Result<void>> logout();
  Future<Result<void>> updateEmail({
    required String newEmail,
    required String oldPassword,
  });

  Future<Result<void>> updatePassword({
    required String oldPassword,
    required String newPassword,
  });
}

class AuthService implements IAuthService {
  final Account _account;

  AuthService({required Account account}) : _account = account;

  @override
  Future<Result<models.User>> createAccount({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _account.create(
        userId: 'unique()',
        email: email,
        password: password,
      );

      return Result.success(user);
    } on AppwriteException catch (e) {
      return Result.failed(e.message.toString());
    }
  }

  @override
  Future<Result<models.User>> login({
    required String email,
    required String password,
  }) async {
    try {
      await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      final user = await _account.get();
      return Result.success(user);
    } on AppwriteException catch (e) {
      String message;

      if (e.code == 401) {
        message = 'Email atau password salah';
      } else if (e.code == 429) {
        message = 'Terlalu banyak percobaan. Mohon tunggu beberapa saat.';
      } else {
        message = e.message ?? 'Terjadi kesalahan, coba lagi nanti';
      }

      return Result.failed(message);
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _account.deleteSession(sessionId: 'current');
      return const Result.success(null);
    } on AppwriteException catch (e) {
      return Result.failed(e.message.toString());
    }
  }

  @override
  Future<Result<models.User>> getCurrentUser() async {
    try {
      // Retrieve the current user
      final user = await _account.get();
      return Result.success(user);
    } on AppwriteException catch (e) {
      return Result.failed(e.message.toString());
    }
  }

  @override
  Future<Result<models.Session>> getCurrentSession() async {
    try {
      final session = await _account.getSession(sessionId: 'current');
      return Result.success(session);
    } on AppwriteException catch (e) {
      return Result.failed(e.message.toString());
    }
  }

  @override
  Future<Result<void>> updateEmail({
    required String newEmail,
    required String oldPassword,
  }) async {
    try {
      await _account.updateEmail(email: newEmail, password: oldPassword);
      return const Result.success(null);
    } on AppwriteException catch (e) {
      return Result.failed(e.message ?? "Gagal update email");
    }
  }

  @override
  Future<Result<void>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _account.updatePassword(
        password: newPassword,
        oldPassword: oldPassword,
      );
      return const Result.success(null);
    } on AppwriteException catch (e) {
      return Result.failed(e.message ?? "Gagal update password");
    }
  }
}
