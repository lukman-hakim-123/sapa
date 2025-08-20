import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../models/hasil_model.dart';

class PdfGenerator {
  static Future<pw.Document> generateDetailHasil(
    String namaAnak,
    List<HasilModel> hasilList,
    int selectedPeriod,
  ) async {
    final pdf = pw.Document();

    final fontRegular = pw.Font.ttf(
      await rootBundle.load("assets/fonts/DMSans-Regular.ttf"),
    );

    final fontBold = pw.Font.ttf(
      await rootBundle.load("assets/fonts/DMSans-Bold.ttf"),
    );

    final byKategori = <String, List<HasilModel>>{};
    for (final h in hasilList) {
      byKategori.putIfAbsent(h.kategori, () => []);
      byKategori[h.kategori]!.add(h);
    }

    for (final list in byKategori.values) {
      list.sort((a, b) => a.tanggal.compareTo(b.tanggal));
    }

    final periodIndex = selectedPeriod - 1;
    final entriesThisPeriod = <HasilModel>[];
    for (final entry in byKategori.entries) {
      if (periodIndex < entry.value.length) {
        entriesThisPeriod.add(entry.value[periodIndex]);
      }
    }

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Center(
            child: pw.Text(
              "Detail Hasil Periode $selectedPeriod",
              style: pw.TextStyle(font: fontBold, fontSize: 20),
            ),
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            "Nama Anak: $namaAnak",
            style: pw.TextStyle(font: fontBold, fontSize: 16),
          ),
          pw.SizedBox(height: 12),

          if (entriesThisPeriod.isEmpty)
            pw.Center(
              child: pw.Text(
                "Tidak ada data untuk periode ini",
                style: pw.TextStyle(font: fontBold, fontSize: 16),
              ),
            )
          else
            ...entriesThisPeriod.map((h) {
              final lines = <String>[];
              if (h.contohMampu.trim().isNotEmpty) {
                lines.add("Mampu: ${h.contohMampu}");
              }
              if (h.contohMampuBantuan.trim().isNotEmpty) {
                lines.add("Mampu dengan bantuan: ${h.contohMampuBantuan}");
              }
              if (h.contohBelumMampu.trim().isNotEmpty) {
                lines.add("Belum mampu: ${h.contohBelumMampu}");
              }

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 12),
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      h.kategori,
                      style: pw.TextStyle(font: fontBold, fontSize: 14),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Sub Kategori: ${h.subKategori}",
                      style: pw.TextStyle(font: fontRegular, fontSize: 14),
                    ),
                    pw.SizedBox(height: 4),
                    ...lines.map((l) => pw.Bullet(text: l)),
                  ],
                ),
              );
            }),
        ],
      ),
    );

    return pdf;
  }
}
