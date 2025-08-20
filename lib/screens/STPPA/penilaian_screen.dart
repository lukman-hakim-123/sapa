import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sapa/providers/hasil_provider.dart';
import 'package:sapa/widgets/custom_button.dart';
import '../../models/anak_model.dart';
import '../../models/hasil_model.dart';
import '../../providers/stppa_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_text.dart';

class PenilaianScreen extends ConsumerStatefulWidget {
  final AnakModel anak;
  const PenilaianScreen({super.key, required this.anak});

  @override
  ConsumerState<PenilaianScreen> createState() => PenilaianScreenState();
}

class PenilaianScreenState extends ConsumerState<PenilaianScreen> {
  Map<int, int> answers = {};
  int currentPage = 1;

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
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final userProfileState = ref.watch(userProfileNotifierProvider);
    final stppaState = ref.watch(stppaNotifierProvider);
    final selected = ref.read(selectedAgeKategoriProvider);

    return Scaffold(
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
          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
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
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
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
                                  (questions.length / questionsPerPage).ceil(),
                        backgroundColor: Colors.white.withValues(alpha: 0.4),
                        color: Colors.white,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  padding: EdgeInsets.all(20.0),
                  itemCount: currentQuestions.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final realIndex = startIndex + index;
                    final q = questions[realIndex];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomText(
                              text: "${q.nomor}. ${q.pernyataan}",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildAnswerButton(
                                  q.nomor,
                                  3,
                                  "Mampu",
                                  Colors.green,
                                ),
                                _buildAnswerButton(
                                  q.nomor,
                                  2,
                                  "Mampu dengan Bantuan",
                                  Colors.orange,
                                ),
                                _buildAnswerButton(
                                  q.nomor,
                                  1,
                                  "Belum Mampu",
                                  Colors.pink,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
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
                            },
                          ),
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 6,
                        child: CustomButton(
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
      ),
    );
  }

  void _handleSubmit(List<dynamic> questions, BuildContext context) {
    debugPrint("Jawaban lengkap: $answers");

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

    List<String> contohMampuList = [];
    List<String> contohBantuanList = [];
    List<String> contohBelumList = [];

    final Map<String, Map<String, int>> subRekap = {};

    for (var q in questions) {
      final answer = answers[q.nomor];

      if (answer == 3) {
        contohMampuList.add(q.judul);
      } else if (answer == 2) {
        contohBantuanList.add(q.judul);
      } else if (answer == 1) {
        contohBelumList.add(q.judul);
      }

      subRekap.putIfAbsent(
        q.subKategori,
        () => {"mampu": 0, "bantuan": 0, "belum": 0},
      );

      if (answer == 3) {
        subRekap[q.subKategori]!["mampu"] =
            subRekap[q.subKategori]!["mampu"]! + 1;
      } else if (answer == 2) {
        subRekap[q.subKategori]!["bantuan"] =
            subRekap[q.subKategori]!["bantuan"]! + 1;
      } else if (answer == 1) {
        subRekap[q.subKategori]!["belum"] =
            subRekap[q.subKategori]!["belum"]! + 1;
      }
    }

    final subKategoriList = subRekap.entries.map((e) {
      return {
        "subKategori": e.key,
        "mampu": e.value["mampu"],
        "bantuan": e.value["bantuan"],
        "belum": e.value["belum"],
      };
    }).toList();

    final subKategoriJson = jsonEncode(subKategoriList);

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
      contohMampu: contohMampuList.join(", "),
      contohMampuBantuan: contohBantuanList.join(", "),
      contohBelumMampu: contohBelumList.join(", "),
      subKategori: subKategoriJson,
    );

    try {
      ref.read(hasilNotifierProvider.notifier).createHasil(hasil);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hasil berhasil disimpan"),
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
            color: Colors.white,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
