import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sapa/models/hasil_model.dart';
import 'package:sapa/models/stppa_model.dart';
import 'package:sapa/screens/hasil/widget/kategori_card.dart';
import '../../models/anak_model.dart';
import '../../providers/anak_provider.dart';
import '../../providers/hasil_provider.dart';
import '../../providers/stppa_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_text.dart';

import '../../widgets/my_double_tap_exit.dart';

class DetailHasilScreen extends ConsumerStatefulWidget {
  final List<HasilModel> hasilList;
  const DetailHasilScreen({super.key, required this.hasilList});

  @override
  ConsumerState<DetailHasilScreen> createState() => _DetailHasilScreenState();
}

class _DetailHasilScreenState extends ConsumerState<DetailHasilScreen> {
  int selectedPeriod = 1;
  bool _isLoading = false;
  final kategoriOrder = [
    'Fisik Motorik',
    'Bahasa',
    'Sosial Emosional',
    'Kognitif',
    'Nilai Agama & Moral',
  ];
  final kategoriIcons = <String, String>{
    'Fisik Motorik': 'assets/icons/fm.svg',
    'Bahasa': 'assets/icons/bhs.svg',
    'Sosial Emosional': 'assets/icons/se.svg',
    'Kognitif': 'assets/icons/kg.svg',
    'Nilai Agama & Moral': 'assets/icons/nam.svg',
  };
  final kategoriColors = <String, Color>{
    'Fisik Motorik': Color(0xFFFFADAD),
    'Bahasa': Color(0xFFC3D6FF),
    'Sosial Emosional': Color(0xFFFF9DD8),
    'Kognitif': Color(0xFFE596E6),
    'Nilai Agama & Moral': Color(0xFFC7FFCA),
  };

  Future<void> generateFullReport({
    required List<HasilModel> hasilList,
    required AnakModel anak,
    required Map<String, List<StppaModel>> kategoriSoalMap,
  }) async {
    final doc = pw.Document();
    final tnrData = await rootBundle.load("assets/fonts/times.ttf");
    final tnrFont = pw.Font.ttf(tnrData);
    final tnrBoldData = await rootBundle.load(
      "assets/fonts/Times New Roman Bold.ttf",
    );
    final tnrBoldFont = pw.Font.ttf(tnrBoldData);

    for (final hasil in hasilList) {
      final soalList = kategoriSoalMap[hasil.kategori] ?? [];
      final jawaban = (jsonDecode(hasil.jawaban) as Map<String, dynamic>).map(
        (k, v) => MapEntry(int.parse(k), v as int),
      );
      final String title =
          'INSTRUMEN ASPEK PERKEMBANGAN ${hasil.kategori.toUpperCase()} UNTUK ANAK USIA ${(hasil.usia - 1).toString()}-${hasil.usia.toString()}';

      doc.addPage(
        pw.MultiPage(
          build: (context) => [
            pw.Center(
              child: pw.Text(
                title,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  font: tnrBoldFont,
                ),
              ),
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              'IDENTITAS SISWA',
              textAlign: pw.TextAlign.left,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                font: tnrBoldFont,
              ),
            ),
            pw.SizedBox(height: 5),

            pw.Table(
              columnWidths: {
                0: pw.FixedColumnWidth(150),
                1: pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Text('Nama Lengkap', style: pw.TextStyle(font: tnrFont)),
                    pw.Text(
                      ': ${anak.nama}',
                      style: pw.TextStyle(font: tnrFont),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Tempat, Tgl Lahir',
                      style: pw.TextStyle(font: tnrFont),
                    ),
                    pw.Text(
                      ': ${anak.tempatLahir}, ${anak.tanggalLahir}',
                      style: pw.TextStyle(font: tnrFont),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Usia', style: pw.TextStyle(font: tnrFont)),
                    pw.Text(
                      ': ${anak.usia}',
                      style: pw.TextStyle(font: tnrFont),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Alamat', style: pw.TextStyle(font: tnrFont)),
                    pw.Text(
                      ': ${anak.alamat}',
                      style: pw.TextStyle(font: tnrFont),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Nama Ayah', style: pw.TextStyle(font: tnrFont)),
                    pw.Text(
                      ': ${anak.namaAyah}',
                      style: pw.TextStyle(font: tnrFont),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Nama Ibu', style: pw.TextStyle(font: tnrFont)),
                    pw.Text(
                      ': ${anak.namaIbu}',
                      style: pw.TextStyle(font: tnrFont),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Tanggal Penilaian',
                      style: pw.TextStyle(font: tnrFont),
                    ),
                    pw.Text(
                      ': ${hasil.tanggal}',
                      style: pw.TextStyle(font: tnrFont),
                    ),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Text('Nama Sekolah', style: pw.TextStyle(font: tnrFont)),
                    pw.Text(
                      ': ${hasil.sekolah}',
                      style: pw.TextStyle(font: tnrFont),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 12),
            pw.Text(
              'INSTRUMEN CEKLIS (V)',
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                font: tnrBoldFont,
              ),
            ),
            pw.SizedBox(height: 10),

            pw.TableHelper.fromTextArray(
              headers: [
                'No',
                'Indikator',
                'Perilaku yang Diamati',
                'Mampu',
                'Mampu dengan bantuan',
                'Belum Mampu',
                'Ket',
              ],
              headerCellDecoration: pw.BoxDecoration(color: PdfColors.grey300),
              headerAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.center,
                2: pw.Alignment.center,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
              data: soalList.map((soal) {
                final val = jawaban[soal.nomor];
                return [
                  soal.nomor.toString(),
                  soal.indikator,
                  soal.pernyataan,
                  val == 3 ? 'V' : '',
                  val == 2 ? 'V' : '',
                  val == 1 ? 'V' : '',
                  '',
                ];
              }).toList(),
              columnWidths: {
                0: const pw.FixedColumnWidth(30), // kolom No
                1: const pw.FixedColumnWidth(100), // kolom Indikator
                2: const pw.FlexColumnWidth(), // kolom Perilaku (biar fleksibel)
                3: const pw.FixedColumnWidth(55), // kolom Mampu
                4: const pw.FixedColumnWidth(55), // kolom Bantuan
                5: const pw.FixedColumnWidth(55), // kolom Tidak Mampu
                6: const pw.FixedColumnWidth(40), // kolom Ket
              },
              cellAlignments: {
                0: pw.Alignment.center,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.centerLeft,
                3: pw.Alignment.center,
                4: pw.Alignment.center,
                5: pw.Alignment.center,
                6: pw.Alignment.center,
              },
              headerStyle: pw.TextStyle(
                font: tnrFont,
                fontWeight: pw.FontWeight.bold,
              ),
              cellStyle: pw.TextStyle(font: tnrFont),
            ),
            pw.SizedBox(height: 20),
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(100),
                1: const pw.FixedColumnWidth(10),
                2: const pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Kesimpulan',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        font: tnrBoldFont,
                      ),
                    ),
                    pw.Text(':'),
                    pw.Text(
                      hasil.kesimpulan,
                      style: pw.TextStyle(font: tnrFont),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(100),
                1: const pw.FixedColumnWidth(10),
                2: const pw.FlexColumnWidth(),
              },
              children: [
                pw.TableRow(
                  children: [
                    pw.Text(
                      'Rekomendasi',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        font: tnrBoldFont,
                      ),
                    ),
                    pw.Text(':'),
                    pw.Text(
                      hasil.rekomendasi,
                      style: pw.TextStyle(font: tnrFont),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  final List<GlobalKey> _cardKeys = [];

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final hasilState = ref.watch(hasilNotifierProvider);
    final userProfile = ref.watch(userProfileNotifierProvider);
    final levelUser = userProfile.value?.levelUser ?? 3;
    if (widget.hasilList.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const CustomText(
            text: 'Detail Hasil',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          backgroundColor: AppColors.primary,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/hasil'),
          ),
        ),
        body: const Center(child: CustomText(text: 'Belum ada data')),
      );
    }

    final byKategori = <String, List<HasilModel>>{};
    for (final h in widget.hasilList) {
      byKategori.putIfAbsent(h.kategori, () => []);
      byKategori[h.kategori]!.add(h);
    }

    for (final kategori in byKategori.keys) {
      byKategori[kategori] = byKategori[kategori]!.reversed.toList();
    }

    final maxPeriods = byKategori.values.isEmpty
        ? 1
        : byKategori.values
              .map((e) => e.length)
              .reduce((a, b) => a > b ? a : b);

    if (selectedPeriod > maxPeriods) {
      selectedPeriod = maxPeriods;
    }

    final periodIndex = selectedPeriod - 1;
    final entriesThisPeriod = <HasilModel>[];
    for (final kategori in kategoriOrder) {
      final list = byKategori[kategori];
      if (list != null && periodIndex < list.length) {
        entriesThisPeriod.add(list[periodIndex]);
      }
    }

    final namaAnak = widget.hasilList.first.namaAnak;

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const CustomText(
            text: 'Detail Hasil',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          backgroundColor: AppColors.primary,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/hasil'),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // const Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        //   children: [
                        //     _LegendItem(color: Colors.green, text: "Mampu"),
                        //     _LegendItem(
                        //       color: Colors.orange,
                        //       text: "Mampu dengan bantuan",
                        //     ),
                        //     _LegendItem(color: Colors.red, text: "Belum mampu"),
                        //   ],
                        // ),
                        CustomText(
                          text: namaAnak,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 4.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: DropdownButton<int>(
                            value: selectedPeriod,
                            underline: const SizedBox(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => selectedPeriod = val);
                              }
                            },
                            items: List.generate(
                              maxPeriods,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text('Periode ${i + 1}'),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (entriesThisPeriod.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CustomText(
                          text: 'Tidak ada kategori pada periode ini',
                        ),
                      ),
                    )
                  else
                    ...entriesThisPeriod.asMap().entries.map((entry) {
                      final index = entry.key;
                      final h = entry.value;
                      if (_cardKeys.length <= index) {
                        _cardKeys.add(GlobalKey());
                      }
                      final icon =
                          kategoriIcons[h.kategori] ?? 'assets/icons/fm.svg';
                      final color = kategoriColors[h.kategori] ?? Colors.grey;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 16,
                              left: 20,
                              right: 20,
                            ),
                            child: KategoriCard(
                              id: h.id,
                              hasil: h,
                              icon: icon,
                              color: color,
                              levelUser: levelUser,
                            ),
                          ),
                        ],
                      );
                    }),
                ],
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton.icon(
            onPressed: _isLoading
                ? null
                : () async {
                    if (_isLoading) return;

                    setState(() => _isLoading = true);
                    try {
                      final anakId = widget.hasilList.first.anakId;

                      final anak = await ref
                          .read(anakNotifierProvider.notifier)
                          .getAnakById(anakId);
                      if (anak == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data anak tidak ditemukan'),
                          ),
                        );
                        return;
                      }

                      final allKategoriSoal = await ref
                          .read(stppaNotifierProvider.notifier)
                          .fetchMultipleKategori(entriesThisPeriod);

                      await generateFullReport(
                        hasilList: entriesThisPeriod,
                        anak: anak,
                        kategoriSoalMap: allKategoriSoal,
                      );
                    } catch (e) {
                      debugPrint('Gagal generate PDF: $e');
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },

            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf, color: Colors.white),
            label: Text(
              _isLoading ? "Generating..." : "Download PDF",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
