import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:sapa/models/hasil_model.dart';
import 'package:sapa/screens/hasil/widget/kategori_card.dart';
import '../../providers/hasil_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_text.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';

class DetailHasilScreen extends ConsumerStatefulWidget {
  final List<HasilModel> hasilList;
  const DetailHasilScreen({super.key, required this.hasilList});

  @override
  ConsumerState<DetailHasilScreen> createState() => _DetailHasilScreenState();
}

class _DetailHasilScreenState extends ConsumerState<DetailHasilScreen> {
  int selectedPeriod = 1;
  DateTime _parseTanggal(String t) {
    final p = t.split('-');
    if (p.length == 3) {
      return DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
    }
    return DateTime(1970, 1, 1);
  }

  Future<void> _captureAndPrint() async {
    try {
      ref.read(isPrintingProvider.notifier).state = true;
      await Future.delayed(const Duration(milliseconds: 100));

      final doc = pw.Document();

      for (final key in _cardKeys) {
        final boundary =
            key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) continue;

        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final pngBytes = byteData!.buffer.asUint8List();
        final img = pw.MemoryImage(pngBytes);

        doc.addPage(
          pw.Page(
            build: (_) =>
                pw.Center(child: pw.Image(img, fit: pw.BoxFit.contain)),
          ),
        );
      }

      await Printing.layoutPdf(onLayout: (_) async => doc.save());
    } catch (e, st) {
      debugPrint("Gagal print: $e\n$st");
    } finally {
      ref.read(isPrintingProvider.notifier).state = false;
    }
  }

  final List<GlobalKey> _cardKeys = [];

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final hasilState = ref.watch(hasilNotifierProvider);
    final userProfile = ref.watch(userProfileNotifierProvider);
    final levelUser = userProfile.value?.level_user ?? 3;
    final isPrinting = ref.watch(isPrintingProvider);
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
          leading: isPrinting
              ? null
              : IconButton(
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

    for (final list in byKategori.values) {
      list.sort(
        (a, b) => _parseTanggal(a.tanggal).compareTo(_parseTanggal(b.tanggal)),
      );
    }

    final maxPeriods = byKategori.values.isEmpty
        ? 1
        : byKategori.values
              .map((e) => e.length)
              .reduce((a, b) => a > b ? a : b);

    if (selectedPeriod > maxPeriods) {
      selectedPeriod = maxPeriods;
    }
    final kategoriOrder = [
      'Fisik Motorik',
      'Bahasa',
      'Sosial Emosional',
      'Kognitif',
      'Nilai Agama dan Moral',
    ];
    final periodIndex = selectedPeriod - 1;
    final entriesThisPeriod = <HasilModel>[];
    for (final kategori in kategoriOrder) {
      final list = byKategori[kategori];
      if (list != null && periodIndex < list.length) {
        entriesThisPeriod.add(list[periodIndex]);
      }
    }

    final namaAnak = widget.hasilList.first.namaAnak;

    final kategoriIcons = <String, String>{
      'Fisik Motorik': 'assets/icons/fm.svg',
      'Bahasa': 'assets/icons/bhs.svg',
      'Sosial Emosional': 'assets/icons/se.svg',
      'Kognitif': 'assets/icons/kg.svg',
      'Nilai Agama dan Moral': 'assets/icons/nam.svg',
    };
    final kategoriColors = <String, Color>{
      'Fisik Motorik': Color(0xFFFFADAD),
      'Bahasa': Color(0xFFC3D6FF),
      'Sosial Emosional': Color(0xFFFF9DD8),
      'Kognitif': Color(0xFFC7FFCA),
      'Nilai Agama dan Moral': Color(0xFFE596E6),
    };

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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LegendItem(color: Colors.green, text: "Mampu"),
                          _LegendItem(
                            color: Colors.orange,
                            text: "Mampu dengan bantuan",
                          ),
                          _LegendItem(color: Colors.red, text: "Belum mampu"),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
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
                    return RepaintBoundary(
                      key: _cardKeys[index],
                      child: Column(
                        children: [
                          Visibility(
                            visible: isPrinting,
                            child: Container(
                              height: 60,
                              width: double.infinity,
                              color: AppColors.primary,
                              alignment: Alignment.center,
                              child: CustomText(
                                text: 'Detail Hasil',
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          Visibility(
                            visible: isPrinting,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _LegendItem(
                                        color: Colors.green,
                                        text: "Mampu",
                                      ),
                                      _LegendItem(
                                        color: Colors.orange,
                                        text: "Mampu dengan bantuan",
                                      ),
                                      _LegendItem(
                                        color: Colors.red,
                                        text: "Belum mampu",
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      CustomText(
                                        text: namaAnak,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      const SizedBox(height: 4.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.black12,
                                          ),
                                        ),
                                        child: DropdownButton<int>(
                                          value: selectedPeriod,
                                          underline: const SizedBox(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              setState(
                                                () => selectedPeriod = val,
                                              );
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
                                ],
                              ),
                            ),
                          ),
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
                              subKategori: h.subKategori,
                              isPrinting: isPrinting,
                              levelUser: levelUser,
                            ),
                          ),
                        ],
                      ),
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
          onPressed: _captureAndPrint,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
          label: const Text(
            "Download PDF",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;

  const _LegendItem({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 4),
        CustomText(text: text),
      ],
    );
  }
}
