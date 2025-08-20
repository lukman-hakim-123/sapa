import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/stppa_model.dart';
import '../services/stppa_service.dart';
import '../utils/provider.dart';

part 'stppa_provider.g.dart';

final selectedAgeKategoriProvider = StateProvider<Map<String, dynamic>?>(
  (ref) => null,
);

@riverpod
class StppaNotifier extends _$StppaNotifier {
  late final StppaService _stppaService = StppaService(
    db: ref.read(appwriteDatabaseProvider),
  );

  @override
  Future<List<StppaModel>> build() async {
    final selected = ref.watch(selectedAgeKategoriProvider);

    if (selected == null) {
      return [];
    }

    final result = await _stppaService.getAllStppaByKategori(
      selected['kategori'].toString().toLowerCase(),
      selected['usia'],
    );

    if (result.isSuccess) {
      return result.resultValue ?? [];
    } else {
      throw Exception(result.errorMessage);
    }
  }

  Future<void> fetchByKategori(String kategori, int usia) async {
    state = const AsyncValue.loading();
    final result = await _stppaService.getAllStppaByKategori(kategori, usia);
    if (result.isSuccess) {
      state = AsyncValue.data(result.resultValue ?? []);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> fetchBySubKategori(String subKategori, int usia) async {
    state = const AsyncValue.loading();
    final result = await _stppaService.getStppaBySubKategori(subKategori, usia);
    if (result.isSuccess) {
      state = AsyncValue.data(result.resultValue ?? []);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  void setLoading() {
    state = const AsyncLoading();
  }
}
