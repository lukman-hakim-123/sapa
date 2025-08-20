import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'anak_provider.dart';
import 'hasil_provider.dart';
import '../models/aktivitas_model.dart';

final aktivitasProvider = FutureProvider<List<AktivitasModel>>((ref) async {
  final anakAsync = await ref.watch(anakNotifierProvider.future);
  final hasilAsync = await ref.watch(hasilNotifierProvider.future);

  final List<AktivitasModel> aktivitasList = [];

  for (var anak in anakAsync) {
    aktivitasList.add(
      AktivitasModel(
        id: anak.id,
        tipe: "anak",
        namaAnak: anak.nama,
        imageId: anak.imageId,
        judul: "Data Anak",
        deskripsi: "Anak ${anak.nama} berhasil ditambahkan",
        tanggal: anak.tanggal,
      ),
    );
  }

  for (var hasil in hasilAsync) {
    aktivitasList.add(
      AktivitasModel(
        id: hasil.id,
        imageId: hasil.imageId,
        namaAnak: hasil.namaAnak,
        tipe: "hasil",
        judul: "Hasil Penilaian",
        deskripsi: "Penilaian ${hasil.kategori} untuk ${hasil.namaAnak}",
        tanggal: hasil.tanggal,
      ),
    );
  }

  final format = DateFormat('dd-MM-yyyy');

  aktivitasList.sort((a, b) {
    final dateA = format.parse(a.tanggal);
    final dateB = format.parse(b.tanggal);
    return dateB.compareTo(dateA);
  });

  // Ambil 5 terbaru saja
  return aktivitasList.take(5).toList();
});
