import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/anak_service.dart';
import '../models/anak_model.dart';
import '../services/hasil_service.dart';
import '../utils/provider.dart';
import 'user_profile_provider.dart';

part 'anak_provider.g.dart';

@riverpod
class AnakNotifier extends _$AnakNotifier {
  late final AnakService _anakService = AnakService(
    db: ref.read(appwriteDatabaseProvider),
    storage: ref.read(appwriteStorageProvider),
  );
  late final HasilService _hasilService = HasilService(
    db: ref.read(appwriteDatabaseProvider),
  );

  @override
  Future<List<AnakModel>> build() async {
    final profileAsync = ref.watch(userProfileNotifierProvider);

    if (profileAsync.isLoading) {
      state = const AsyncValue.loading();
    }
    if (profileAsync.hasError) {
      throw profileAsync.error!;
    }

    final profile = profileAsync.value;
    if (profile == null) return [];

    final level = profile.level_user;
    if (level == 2) {
      final result = await _anakService.getAnakByGuru(profile.id);
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else if (level == 3) {
      final result = await _anakService.getAnakByEmail(profile.email);
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else {
      final result = await _anakService.getAllAnak();
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    }
  }

  Future<void> createAnak(AnakModel anak, File photoFile) async {
    state = const AsyncValue.loading();
    try {
      final finalAnak = await _uploadPhoto(
        anak,
        anak,
        photoFile: photoFile,
        isCreate: true,
      );

      final result = await _anakService.createAnak(finalAnak);

      if (result.isSuccess) {
        state = AsyncValue.data([...state.value ?? [], result.resultValue!]);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> fetchAnakById(String anakId) async {
    state = const AsyncValue.loading();
    final result = await _anakService.getAnakById(anakId);
    if (result.isSuccess) {
      state = AsyncValue.data([result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<AnakModel?> getAnakById(String anakId) async {
    final result = await _anakService.getAnakById(anakId);
    if (result.isSuccess) {
      return result.resultValue!;
    } else {
      return null;
    }
  }

  Future<void> updateAnak(
    AnakModel updatedAnak,
    AnakModel oldAnak,
    File? photoFile,
  ) async {
    state = const AsyncValue.loading();
    try {
      final finalAnak = await _uploadPhoto(
        oldAnak,
        updatedAnak,
        photoFile: photoFile,
        isCreate: false,
      );

      if (oldAnak.email != updatedAnak.email) {
        await _hasilService.updateEmailForHasil(
          oldAnak.email,
          updatedAnak.email,
        );
      }
      final result = await _anakService.updateAnak(finalAnak);

      if (result.isSuccess) {
        final updatedList = (state.value ?? []).map((anak) {
          return anak.id == finalAnak.id ? finalAnak : anak;
        }).toList();

        state = AsyncValue.data(updatedList);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> deleteAnak(AnakModel anak) async {
    final previous = state.value ?? [];
    state = const AsyncValue.loading();

    try {
      await _anakService.deleteProfileImage(anak.imageId);
      final result = await _anakService.deleteAnak(anak.id);

      if (result.isSuccess) {
        state = AsyncValue.data(
          previous.where((a) => a.id != anak.id).toList(),
        );
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<AnakModel> _uploadPhoto(
    AnakModel oldAnak,
    AnakModel updatedAnak, {
    File? photoFile,
    bool isCreate = false,
  }) async {
    if (isCreate && photoFile == null) {
      throw Exception("Foto wajib diunggah saat create");
    }

    if (!isCreate && photoFile == null) {
      return updatedAnak.copyWith(imageId: oldAnak.imageId);
    }

    if (!isCreate && photoFile != null && oldAnak.imageId.isNotEmpty) {
      try {
        await _anakService.deleteProfileImage(oldAnak.imageId);
        print("Old image deleted: ${oldAnak.imageId}");
      } catch (e) {
        print("Failed to delete old image: $e");
      }
    }

    final result = await _anakService.uploadProfileImage(
      photoFile!,
      'anak_${updatedAnak.email}',
    );

    if (result.isSuccess) {
      return updatedAnak.copyWith(imageId: result.resultValue!);
    } else {
      throw Exception("Upload foto gagal: ${result.errorMessage}");
    }
  }

  String getPublicImageUrl(String fileId) {
    return _anakService.getPublicImageUrl(fileId);
  }
}
