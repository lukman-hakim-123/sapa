import 'dart:io';
import 'dart:math';

import 'package:appwrite/appwrite.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/result.dart';
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

  Future<void> _updateEmail(
    String newEmail,
    String oldPassword,
    Account account,
  ) async {
    if (newEmail.isNotEmpty && oldPassword.isNotEmpty) {
      await account.updateEmail(email: newEmail, password: oldPassword);
    }
  }

  Future<void> _updatePassword(
    String oldPassword,
    String newPassword,
    Account account,
  ) async {
    if (newPassword.isNotEmpty && oldPassword.isNotEmpty) {
      await account.updatePassword(
        password: newPassword,
        oldPassword: oldPassword,
      );
    }
  }

  Future<void> _updateName(
    String newName,
    String currentName,
    Account account,
  ) async {
    if (newName != currentName) {
      await account.updateName(name: newName);
    }
  }

  Future<UserProfile> _uploadPhotoIfNeeded(
    UserProfile profile,
    UserProfile updatedProfile,
    File? photoFile,
  ) async {
    if (photoFile == null) return profile;

    // Hapus foto lama dulu jika ada
    if (profile.foto.isNotEmpty) {
      try {
        await _userProfileService.deleteProfileImage(profile.foto);
        print('Old profile image deleted: ${profile.foto}');
      } catch (e) {
        print('Failed to delete old image: $e');
      }
    }

    final random = Random().nextInt(99999); // 0 - 99999
    final fileId = '${profile.id}_$random';

    final uploadedFileId = await _userProfileService.uploadProfileImage(
      photoFile,
      fileId,
    );

    if (uploadedFileId != null) {
      return profile.copyWith(foto: uploadedFileId);
    }

    return profile;
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
    final account = ref.read(appwriteAccountProvider);

    if (authUser == null) {
      state = AsyncValue.error("User tidak ditemukan", StackTrace.current);
      return Result.failed("User tidak ditemukan");
    }

    try {
      await _updateEmail(updatedProfile.email, oldPassword ?? '', account);
      await _updatePassword(oldPassword ?? '', newPassword ?? '', account);
      await _updateName(updatedProfile.nama, authUser.name, account);

      var finalProfile = await _uploadPhotoIfNeeded(
        userProfile,
        updatedProfile,
        photoFile,
      );

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
