import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile_model.dart';
import '../utils/provider.dart';
import 'auth_provider.dart';

part 'user_profile_provider.g.dart';

@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  late final UserProfileService _userProfileService =
      UserProfileService(db: ref.read(appwriteDatabaseProvider));

  @override
  Future<UserProfile?> build() async {
    final authUser = ref.read(authProvider).value;
    if (authUser != null) {
      final result = await _userProfileService.getUserProfile(authUser.$id);
      if (result.isSuccess) {
        return result.resultValue;
      } else {
        throw Exception(result.errorMessage);
      }
    }
    return null;
  }

  Future<void> createUserProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    final result = await _userProfileService.createUserProfile(profile);
    if (result.isSuccess) {
      state = AsyncValue.data(result.resultValue);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> fetchUserProfile(String userId) async {
    state = const AsyncValue.loading();
    final result = await _userProfileService.getUserProfile(userId);
    if (result.isSuccess) {
      state = AsyncValue.data(result.resultValue);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> updateUserProfile(UserProfile updatedProfile) async {
    state = const AsyncValue.loading();
    final result = await _userProfileService.updateUserProfile(updatedProfile);
    if (result.isSuccess) {
      state = AsyncValue.data(result.resultValue);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }
}
