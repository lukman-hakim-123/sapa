import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/produk_service.dart';
import '../models/produk_model.dart';
import '../utils/provider.dart';

part 'produk_provider.g.dart';

@riverpod
class ProdukNotifier extends _$ProdukNotifier {
  late final ProdukService _produkService =
      ProdukService(db: ref.read(appwriteDatabaseProvider));

  @override
  Future<List<ProdukModel>> build() async {
    final result = await _produkService.getAllProduk();
    if (result.isSuccess) {
      return result.resultValue ?? [];
    } else {
      throw Exception(result.errorMessage);
    }
  }

  Future<void> createProduk(ProdukModel produk) async {
    state = const AsyncValue.loading();
    final result = await _produkService.createProduk(produk);
    if (result.isSuccess) {
      state = AsyncValue.data([...state.value ?? [], result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> fetchProdukById(String produkId) async {
    state = const AsyncValue.loading();
    final result = await _produkService.getProdukById(produkId);
    if (result.isSuccess) {
      state = AsyncValue.data([result.resultValue!]);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> updateProduk(ProdukModel updatedProduk, ProdukModel produkModel) async {
    state = const AsyncValue.loading();
    final result = await _produkService.updateProduk(updatedProduk);
    if (result.isSuccess) {
      final updatedList = (state.value ?? []).map((produk) {
        return produk.id == updatedProduk.id ? updatedProduk : produk;
      }).toList();
      state = AsyncValue.data(updatedList);
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }

  Future<void> deleteProduk(String produkId) async {
    state = const AsyncValue.loading();
    final result = await _produkService.deleteProduk(produkId);
    if (result.isSuccess) {
      state = AsyncValue.data(
          (state.value ?? []).where((produk) => produk.id != produkId).toList());
    } else {
      state = AsyncValue.error(result.errorMessage!, StackTrace.current);
    }
  }
}
