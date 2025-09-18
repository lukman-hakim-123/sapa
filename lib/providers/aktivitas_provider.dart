import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'anak_provider.dart';
import 'hasil_provider.dart';
import '../models/aktivitas_model.dart';

final aktivitasProvider = FutureProvider<List<AktivitasModel>>((ref) async {
  final anakAsync = await ref.watch(anakNotifierProvider.future);
  final hasilAsync = await ref.watch(hasilNotifierProvider.future);

  final List<AktivitasModel> aktivitasList = [];

  for (var anak in anakAsync) {
    final createdAt = DateTime.parse(anak.$createdAt!);
    final updatedAt = DateTime.parse(anak.$updatedAt!);
    final isUpdated = updatedAt.isAfter(createdAt);

    aktivitasList.add(
      AktivitasModel(
        id: anak.id,
        tipe: "anak",
        namaAnak: anak.nama,
        imageId: anak.imageId,
        judul: isUpdated ? "Update Data Anak" : "Data Anak Baru",
        deskripsi: isUpdated
            ? "Data ${anak.nama} berhasil diperbarui"
            : "Anak ${anak.nama} berhasil ditambahkan",
        $createdAt: createdAt,
        $updatedAt: updatedAt,
      ),
    );
  }

  // Loop data Hasil
  for (var hasil in hasilAsync) {
    final createdAt = DateTime.parse(hasil.$createdAt!);
    final updatedAt = DateTime.parse(hasil.$updatedAt!);
    final isUpdated = updatedAt.isAfter(createdAt);

    aktivitasList.add(
      AktivitasModel(
        id: hasil.id,
        imageId: hasil.imageId,
        namaAnak: hasil.namaAnak,
        tipe: "hasil",
        judul: isUpdated ? "Update Hasil Penilaian" : "Hasil Penilaian Baru",
        deskripsi: isUpdated
            ? "Penilaian ${hasil.kategori} untuk ${hasil.namaAnak} diperbarui"
            : "Penilaian ${hasil.kategori} untuk ${hasil.namaAnak} ditambahkan",
        $createdAt: createdAt,
        $updatedAt: updatedAt,
      ),
    );
  }

  // Urutkan berdasarkan waktu terbaru (pakai updateAt biar update lebih kelihatan)
  aktivitasList.sort((a, b) {
    final dateA = a.$updatedAt;
    final dateB = b.$updatedAt;
    return dateB.compareTo(dateA);
  });

  // Ambil 5 terbaru
  return aktivitasList.take(5).toList();
});
