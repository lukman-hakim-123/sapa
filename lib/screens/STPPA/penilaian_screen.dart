// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sapa/providers/hasil_provider.dart';
import 'package:sapa/widgets/custom_button.dart';
import '../../models/anak_model.dart';
import '../../models/hasil_model.dart';
import '../../models/stppa_model.dart';
import '../../providers/stppa_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/my_double_tap_exit.dart';

class PenilaianScreen extends ConsumerStatefulWidget {
  final AnakModel anak;
  const PenilaianScreen({super.key, required this.anak});

  @override
  ConsumerState<PenilaianScreen> createState() => PenilaianScreenState();
}

class PenilaianScreenState extends ConsumerState<PenilaianScreen> {
  Map<int, int> answers = {};
  int currentPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final selected = ref.read(selectedAgeKategoriProvider);
    if (selected != null) {
      Future.microtask(() {
        ref
            .read(stppaNotifierProvider.notifier)
            .fetchByKategori(
              selected['kategori'].toString().toLowerCase(),
              selected['usia'],
            );
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final userProfileState = ref.watch(userProfileNotifierProvider);
    final stppaState = ref.watch(stppaNotifierProvider);
    final hasilState = ref.watch(hasilNotifierProvider);
    final selected = ref.read(selectedAgeKategoriProvider);

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: stppaState.when(
          data: (questions) {
            if (questions.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CustomText(text: 'Tidak ada pertanyaan'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => context.go('/pilihAnak'),
                      child: const Text("Kembali"),
                    ),
                  ],
                ),
              );
            }

            final int questionsPerPage = (questions.length / 3).ceil();
            final startIndex = (currentPage - 1) * questionsPerPage;
            final endIndex = (startIndex + questionsPerPage).clamp(
              0,
              questions.length,
            );
            final currentQuestions = questions.sublist(startIndex, endIndex);
            final allAnswered = currentQuestions.every(
              (q) => answers.containsKey(q.nomor),
            );
            final grouped = <String, List<StppaModel>>{};
            for (var q in currentQuestions) {
              grouped.putIfAbsent(q.indikator, () => []).add(q);
            }
            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 161, 21),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.only(top: 50),
                        child: CustomText(
                          text: "STPPA",
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        left: 5.0,
                        top: 40.0,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => context.go('/pilihAnak'),
                        ),
                      ),
                      Positioned(
                        top: 75,
                        left: 0,
                        right: 0,
                        child: CustomText(
                          text: widget.anak.nama,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Positioned(
                        top: 95,
                        left: 0,
                        right: 0,
                        child: CustomText(
                          text: selected?['kategori'] ?? "-",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Positioned(
                        top: 120,
                        left: 0,
                        right: 0,
                        child: CustomText(
                          text:
                              "Halaman $currentPage dari ${((questions.length / questionsPerPage).ceil())}",
                          color: Colors.white,
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Positioned(
                        top: 150,
                        left: 20,
                        right: 20,
                        child: LinearProgressIndicator(
                          value: (questions.isEmpty)
                              ? 0
                              : currentPage /
                                    (questions.length / questionsPerPage)
                                        .ceil(),
                          backgroundColor: Colors.white.withValues(alpha: 0.4),
                          color: Colors.white,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: grouped.length,
                    itemBuilder: (context, index) {
                      final indikator = grouped.keys.elementAt(index);
                      final pertanyaanList = grouped[indikator]!;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 2,
                        color: const Color.fromARGB(255, 255, 161, 21),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: indikator,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              ...pertanyaanList.map(
                                (q) => Card(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                  ),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: "${q.nomor}. ${q.pernyataan}",
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildAnswerButton(
                                              q.nomor,
                                              3,
                                              "Mampu",
                                              Color.fromARGB(255, 132, 233, 0),
                                            ),
                                            _buildAnswerButton(
                                              q.nomor,
                                              2,
                                              "Mampu dengan Bantuan",
                                              Color(0xFF5ce1e6),
                                            ),
                                            _buildAnswerButton(
                                              q.nomor,
                                              1,
                                              "Belum Mampu",
                                              Color(0xFFff93b2),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: 40,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (currentPage > 1)
                          Expanded(
                            flex: 5,
                            child: CustomButton(
                              text: "Kembali",
                              backgroundColor: AppColors.primary,
                              onPressed: () {
                                setState(() => currentPage--);
                                _scrollController.animateTo(
                                  0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                            ),
                          ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 6,
                          child: CustomButton(
                            isLoading: hasilState.isLoading,
                            text:
                                currentPage <
                                    (questions.length / questionsPerPage).ceil()
                                ? "Selanjutnya"
                                : "Selesai",
                            backgroundColor:
                                currentPage <
                                    (questions.length / questionsPerPage).ceil()
                                ? AppColors.secondary
                                : Colors.green.shade400,
                            onPressed: allAnswered
                                ? () {
                                    if (currentPage <
                                        (questions.length / questionsPerPage)
                                            .ceil()) {
                                      setState(() => currentPage++);
                                      _scrollController.animateTo(
                                        0,
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeOut,
                                      );
                                    } else {
                                      _handleSubmit(questions, context);
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          ),
          error: (err, _) => Center(child: Text("Error: $err")),
        ),
      ),
    );
  }

  void _handleSubmit(List<dynamic> questions, BuildContext context) async {
    final userProfile = ref.read(userProfileNotifierProvider).value;
    final anak = widget.anak;
    final selected = ref.read(selectedAgeKategoriProvider);
    final tanggal = DateFormat('dd-MM-yyyy').format(DateTime.now());

    if (userProfile == null || selected == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data tidak lengkap")));
      return;
    }

    final mampu = <String>[];
    final bantuan = <String>[];
    final belum = <String>[];

    final jawabanMap = <String, int>{};

    for (var q in questions) {
      final ans = answers[q.nomor] ?? 0;
      jawabanMap[q.nomor.toString()] = ans;

      if (ans == 3) {
        mampu.add(q.judul);
      } else if (ans == 2) {
        bantuan.add(q.judul);
      } else if (ans == 1) {
        belum.add(q.judul);
      }
    }

    final contohMampu = mampu.take(3).toList();
    final contohBantuan = bantuan.take(2).toList();
    final contohBelum = belum.take(1).toList();

    final kesimpulanBuffer = StringBuffer();
    if (contohMampu.isNotEmpty) {
      kesimpulanBuffer.write("Anak mampu ${contohMampu.join(', ')}");
    }
    if (contohBantuan.isNotEmpty) {
      if (kesimpulanBuffer.isNotEmpty) kesimpulanBuffer.write(". ");
      kesimpulanBuffer.write(
        "Dengan bantuan, anak mampu ${contohBantuan.join(', ')}",
      );
    }
    if (contohBelum.isNotEmpty) {
      if (kesimpulanBuffer.isNotEmpty) kesimpulanBuffer.write(". ");
      kesimpulanBuffer.write(
        "Namun, anak belum mampu ${contohBelum.join(', ')}",
      );
    }
    if (kesimpulanBuffer.isNotEmpty) kesimpulanBuffer.write(".");
    final kesimpulan = kesimpulanBuffer.toString();

    final templatesBelum = [
      "Disarankan pembiasaan melalui kegiatan sehari-hari agar anak dapat ",
      "Orang tua perlu memberikan dukungan tambahan agar anak dapat ",
    ];
    final templatesBantuan = [
      "Anak dapat distimulasi dengan permainan sederhana untuk membantu anak ",
      "Perlu stimulasi lebih lanjut agar anak dapat ",
    ];
    final randomPrefixBelum =
        templatesBelum[Random().nextInt(templatesBelum.length)];
    final randomPrefixBantuan =
        templatesBantuan[Random().nextInt(templatesBantuan.length)];

    String rekomendasi = "";
    if (belum.isNotEmpty) {
      final selectedBelum = belum.toList();
      if (selectedBelum.length > 1) {
        final last = selectedBelum.removeLast();
        rekomendasi +=
            "$randomPrefixBelum${selectedBelum.join(', ')} dan $last.\n";
      } else {
        rekomendasi += "$randomPrefixBelum${selectedBelum.first}.";
      }
    }
    if (bantuan.isNotEmpty) {
      final selectedBantuan = bantuan.take(3).toList();
      if (selectedBantuan.length > 1) {
        final last = selectedBantuan.removeLast();
        rekomendasi +=
            "$randomPrefixBantuan${selectedBantuan.join(', ')} dan $last.\n";
      } else {
        rekomendasi += "$randomPrefixBantuan${selectedBantuan.first}.";
      }
    }

    if (rekomendasi.isEmpty) {
      rekomendasi = "Terus tingkatkan kemampuan yang sudah dikuasai anak.";
    }

    final jawabanJson = jsonEncode(jawabanMap);
    final hasil = HasilModel(
      id: "",
      anakId: anak.id,
      guruId: userProfile.id,
      email: anak.email,
      namaAnak: anak.nama,
      namaGuru: userProfile.nama,
      imageId: anak.imageId,
      kategori: selected['kategori'],
      tanggal: tanggal,
      usia: selected['usia'],
      kesimpulan: kesimpulan,
      rekomendasi: rekomendasi,
      jawaban: jawabanJson,
      sekolah: anak.sekolah,
    );
    try {
      await ref.read(hasilNotifierProvider.notifier).createHasil(hasil);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Penilaian berhasil disimpan"),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/pilihAnak');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal simpan: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAnswerButton(int nomor, int value, String label, Color color) {
    final isSelected = answers[nomor] == value;
    final hasAnswered = answers.containsKey(nomor);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            answers[nomor] = value;
          });
        },
        child: Container(
          height: 70,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : hasAnswered
                ? color.withValues(alpha: 0.3)
                : color,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: CustomText(
            text: label,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
