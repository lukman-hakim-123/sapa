import 'package:appwrite/models.dart' as models;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/user_profile_service.dart';
import '../utils/provider.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import 'user_profile_provider.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  late final AuthService _authService = AuthService(
    account: ref.read(appwriteAccountProvider),
  );
  late final UserProfileNotifier _userProfileNotifier = ref.read(
    userProfileNotifierProvider.notifier,
  );
  late final UserProfileService _userProfileService = UserProfileService(
    db: ref.read(appwriteDatabaseProvider),
    storage: ref.read(appwriteStorageProvider),
  );

  @override
  Future<models.User?> build() async {
    return checkSession();
  }

  Future<void> login(
    String email,
    String password, {
    bool fromRegister = false,
  }) async {
    if (!fromRegister) {
      state = const AsyncValue.loading();
    }

    final result = await _authService.login(email: email, password: password);
    if (result.isSuccess) {
      final user = result.resultValue;
      state = AsyncValue.data(user);

      if (user != null) {
        await _userProfileNotifier.fetchUserProfile(user.$id);
      }
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      resetState();
    }
  }

  Future<void> register(String email, String password, String nama) async {
    state = const AsyncValue.loading();

    final authResult = await _authService.createAccount(
      email: email,
      password: password,
    );

    if (authResult.isSuccess) {
      final userId = authResult.resultValue?.$id ?? '';
      final userProfile = UserProfile(
        id: userId,
        nama: nama,
        email: email,
        foto: '',
        level_user: 3,
      );

      await _userProfileService.createUserProfile(userProfile);

      await login(email, password, fromRegister: true);
    } else {
      state = AsyncValue.error(authResult.errorMessage!, StackTrace.current);
      resetState();
    }
  }

  Future<void> logout() async {
    if (state.value == null) return;
    state = const AsyncValue.loading();
    final result = await _authService.logout();
    if (result.isSuccess) {
      state = const AsyncValue.data(null);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      resetState();
    }
  }

  void resetState() async {
    Future.delayed(const Duration(seconds: 1), () {
      state = const AsyncValue.data(null);
    });
  }

  Future<models.User?> checkSession() async {
    try {
      final sessionResult = await _authService.getCurrentSession();

      if (sessionResult.isSuccess) {
        final userResult = await _authService.getCurrentUser();
        if (userResult.isSuccess) {
          state = AsyncValue.data(userResult.resultValue);
          return userResult.resultValue;
        }
      }
    } catch (e) {
      print('Error checking session: $e');
    }
    return null;
  }
}
