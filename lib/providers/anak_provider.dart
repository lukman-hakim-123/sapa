import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/anak_service.dart';
import '../models/anak_model.dart';
import '../utils/provider.dart';

part 'anak_provider.g.dart';

@riverpod
class AnakNotifier extends _$AnakNotifier {
  late final AnakService _anakService = AnakService(
    db: ref.read(appwriteDatabaseProvider),
    storage: ref.read(appwriteStorageProvider),
  );

  @override
  Future<List<AnakModel>> build() async {
    final result = await _anakService.getAllAnak();
    if (result.isSuccess) {
      return result.resultValue ?? [];
    } else {
      throw Exception(result.errorMessage);
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

  Future<void> updateAnak(
    AnakModel updatedAnak,
    AnakModel oldAnak, {
    File? photoFile,
  }) async {
    state = const AsyncValue.loading();
    try {
      final finalAnak = await _uploadPhoto(
        oldAnak,
        updatedAnak,
        photoFile: photoFile,
        isCreate: false, // boleh tanpa foto
      );

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

  Future<void> deleteAnak(String anakId) async {
    state = const AsyncValue.loading();
    final result = await _anakService.deleteAnak(anakId);
    if (result.isSuccess) {
      state = AsyncValue.data(
        (state.value ?? []).where((anak) => anak.id != anakId).toList(),
      );
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<AnakModel> _uploadPhoto(
    AnakModel oldAnak,
    AnakModel updatedAnak, {
    File? photoFile,
    bool isCreate = false,
  }) async {
    if (photoFile == null) {
      if (isCreate) throw Exception("Foto wajib diunggah saat create");
      return updatedAnak;
    }

    if (!isCreate && oldAnak.imageId.isNotEmpty) {
      try {
        await _anakService.deleteProfileImage(oldAnak.imageId);
        print("Old image deleted: ${oldAnak.imageId}");
      } catch (e) {
        print("Failed to delete old image: $e");
      }
    }

    final result = await _anakService.uploadProfileImage(
      photoFile,
      'anak_${oldAnak.email}',
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
