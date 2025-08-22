import 'dart:io';

import 'package:appwrite/appwrite.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/result.dart';
import '../services/anak_service.dart';
import '../services/auth_service.dart';
import '../services/hasil_service.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile_model.dart';
import '../utils/provider.dart';
import 'auth_provider.dart';

part 'user_profile_provider.g.dart';

@riverpod
class UserProfileNotifier extends _$UserProfileNotifier {
  late final UserProfileService _userProfileService = UserProfileService(
    db: ref.read(appwriteDatabaseProvider),
    storage: ref.read(appwriteStorageProvider),
  );
  late final AnakService _anakService = AnakService(
    db: ref.read(appwriteDatabaseProvider),
    storage: ref.read(appwriteStorageProvider),
  );
  late final HasilService _hasilService = HasilService(
    db: ref.read(appwriteDatabaseProvider),
  );
  late final AuthService _authService = AuthService(
    account: ref.read(appwriteAccountProvider),
  );

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

  Future<UserProfile> _uploadPhotoIfNeeded(
    UserProfile profile,
    UserProfile updatedProfile,
    File? photoFile,
  ) async {
    if (photoFile == null) return updatedProfile;

    if (profile.foto.isNotEmpty) {
      try {
        await _userProfileService.deleteProfileImage(profile.foto);
        print('Old profile image deleted: ${profile.foto}');
      } catch (e) {
        print('Failed to delete old image: $e');
      }
    }

    final uploadedFileId = await _userProfileService.uploadProfileImage(
      photoFile,
      'profile_${profile.id}',
    );

    if (uploadedFileId != null) {
      return updatedProfile.copyWith(foto: uploadedFileId);
    }

    return updatedProfile;
  }

  Future<Result<UserProfile>> updateUserProfileAdvanced(
    UserProfile userProfile, {
    required UserProfile updatedProfile,
    File? photoFile,
    String? oldPassword,
    String? newPassword,
  }) async {
    state = const AsyncValue.loading();
    final authUser = ref.read(authProvider).value;
    if (authUser == null) {
      state = AsyncValue.error("User tidak ditemukan", StackTrace.current);
      return Result.failed("User tidak ditemukan");
    }

    try {
      if (updatedProfile.email != userProfile.email) {
        final emailResult = await _authService.updateEmail(
          newEmail: updatedProfile.email,
          oldPassword: oldPassword ?? '',
        );

        if (!emailResult.isSuccess) {
          return Result.failed(emailResult.errorMessage!);
        }
      }

      if (newPassword != null && newPassword.isNotEmpty) {
        final passResult = await _authService.updatePassword(
          oldPassword: oldPassword ?? '',
          newPassword: newPassword,
        );

        if (!passResult.isSuccess) {
          return Result.failed(passResult.errorMessage!);
        }
      }

      var finalProfile = await _uploadPhotoIfNeeded(
        userProfile,
        updatedProfile,
        photoFile,
      );
      if (userProfile.email != updatedProfile.email) {
        await _anakService.updateEmailForAnak(
          userProfile.email,
          updatedProfile.email,
        );

        await _hasilService.updateEmailForHasil(
          userProfile.email,
          updatedProfile.email,
        );
      }

      final result = await _userProfileService.updateUserProfile(finalProfile);
      if (result.isSuccess) {
        state = AsyncValue.data(result.resultValue);
        return Result.success(result.resultValue!);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
        return Result.failed(result.errorMessage!);
      }
    } on AppwriteException catch (e) {
      if (e.code == 401) {
        state = AsyncValue.data(state.value);
        return Result.failed("Password lama salah");
      }
      state = AsyncValue.data(state.value);
      return Result.failed(e.message ?? "Gagal update profile");
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
      return Result.failed(e.toString());
    }
  }

  String getPublicImageUrl(String fileId) {
    return _userProfileService.getPublicImageUrl(fileId);
  }
}
