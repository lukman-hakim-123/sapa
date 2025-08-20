import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/hasil_service.dart';
import '../models/hasil_model.dart';
import '../utils/provider.dart';
import 'user_profile_provider.dart';

part 'hasil_provider.g.dart';

final isPrintingProvider = StateProvider<bool>((ref) => false);

@riverpod
class HasilNotifier extends _$HasilNotifier {
  late final HasilService _hasilService = HasilService(
    db: ref.read(appwriteDatabaseProvider),
  );

  @override
  Future<List<HasilModel>> build() async {
    final profileAsync = ref.watch(userProfileNotifierProvider);

    if (profileAsync.isLoading) {
      return [];
    }
    if (profileAsync.hasError) {
      throw profileAsync.error!;
    }

    final profile = profileAsync.value;
    if (profile == null) return [];

    if (profile.level_user == 2) {
      final result = await _hasilService.getAllHasilByGuruId(profile.id);
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else if (profile.level_user == 3) {
      final result = await _hasilService.getAllHasilByEmail(profile.email);
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    } else {
      final result = await _hasilService.getAllHasil();
      if (result.isSuccess) {
        return result.resultValue ?? [];
      } else {
        throw Exception(result.errorMessage);
      }
    }
  }

  Future<void> createHasil(HasilModel hasil) async {
    state = const AsyncValue.loading();
    try {
      final result = await _hasilService.createHasil(hasil);

      if (result.isSuccess) {
        state = AsyncValue.data([...state.value ?? [], result.resultValue!]);
      } else {
        state = AsyncValue.error(result.errorMessage!, StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> fetchHasilById(String hasilId) async {
    state = const AsyncValue.loading();
    final result = await _hasilService.getHasilById(hasilId);
    if (result.isSuccess) {
      state = AsyncValue.data([result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> deleteHasil(String hasilId) async {
    state = const AsyncValue.loading();
    final result = await _hasilService.deleteHasil(hasilId);
    if (result.isSuccess) {
      state = AsyncValue.data(
        (state.value ?? []).where((hasil) => hasil.id != hasilId).toList(),
      );
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  String getPublicImageUrl(String fileId) {
    return _hasilService.getPublicImageUrl(fileId);
  }
}
