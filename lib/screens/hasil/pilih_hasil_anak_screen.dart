import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/hasil_model.dart';
import '../../providers/hasil_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class PilihHasilAnakScreen extends ConsumerStatefulWidget {
  const PilihHasilAnakScreen({super.key});

  @override
  ConsumerState<PilihHasilAnakScreen> createState() =>
      _PilihHasilAnakScreenState();
}

class _PilihHasilAnakScreenState extends ConsumerState<PilihHasilAnakScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';
  String searchDate = '';
  bool isDateSelected = false;

  @override
  Widget build(BuildContext context) {
    final hasilState = ref.watch(hasilNotifierProvider);
    final userProfileState = ref.watch(userProfileNotifierProvider);
    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const CustomText(
            text: 'Hasil Penilaian Anak',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
          backgroundColor: AppColors.primary,
          centerTitle: true,
          elevation: 0.0,
          scrolledUnderElevation: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/bottomNav'),
          ),
        ),
        body: userProfileState.when(
          data: (profile) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(hasilNotifierProvider);
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 50.0,
                            child: CustomTextFormField(
                              controller: searchController,
                              hintText: 'Cari nama anak...',
                              suffixIcon: const Icon(Icons.search),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: IconButton(
                            icon: Icon(
                              Icons.calendar_month,
                              color: isDateSelected
                                  ? Colors.red
                                  : AppColors.secondary,
                              size: 40,
                            ),
                            onPressed: () async {
                              if (isDateSelected) {
                                setState(() {
                                  searchDate = '';
                                  isDateSelected = false;
                                });
                              } else {
                                final selectedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (selectedDate != null) {
                                  setState(() {
                                    searchDate =
                                        "${selectedDate.day.toString().padLeft(2, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.year}";
                                    isDateSelected = true;
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: hasilState.when(
                        data: (hasilList) {
                          final grouped = <String, List<HasilModel>>{};
                          for (var hasil in hasilList) {
                            grouped.putIfAbsent(hasil.anakId, () => []);
                            grouped[hasil.anakId]!.add(hasil);
                          }
                          if (hasilList.isEmpty) {
                            return const Center(
                              child: CustomText(
                                text: 'Belum ada hasil penilaian',
                                fontSize: 16,
                              ),
                            );
                          }
                          final filtered = hasilList.where((hasil) {
                            final matchesName = hasil.namaAnak
                                .toLowerCase()
                                .contains(searchQuery);
                            final matchesDate =
                                searchDate.isEmpty ||
                                hasil.tanggal == searchDate;
                            return matchesName && matchesDate;
                          }).toList();

                          if (filtered.isEmpty) {
                            return const Center(
                              child: CustomText(
                                text: 'Data tidak ditemukan',
                                fontSize: 16,
                              ),
                            );
                          }

                          final url = ref
                              .read(hasilNotifierProvider.notifier)
                              .getPublicImageUrl;
                          final anakList = grouped.entries.map((entry) {
                            final anakResults = entry.value;

                            // Urutkan berdasarkan tanggal (asumsi format dd-MM-yyyy)
                            anakResults.sort((a, b) {
                              final dateA = DateTime.parse(
                                "${a.tanggal.split('-')[2]}-${a.tanggal.split('-')[1]}-${a.tanggal.split('-')[0]}",
                              );
                              final dateB = DateTime.parse(
                                "${b.tanggal.split('-')[2]}-${b.tanggal.split('-')[1]}-${b.tanggal.split('-')[0]}",
                              );
                              return dateB.compareTo(dateA); // descending
                            });

                            final latest =
                                anakResults.first; // hasil paling baru
                            final count =
                                anakResults.length; // jumlah penilaian

                            return {"hasil": latest, "count": count};
                          }).toList();
                          return ListView.builder(
                            itemCount: anakList.length,
                            itemBuilder: (context, index) {
                              final item = anakList[index];
                              final hasil = item["hasil"] as HasilModel;
                              final count = item["count"] as int;
                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[300],
                                    child: ClipOval(
                                      child: hasil.imageId.isNotEmpty
                                          ? Image.network(
                                              url(hasil.imageId),
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Center(
                                                  child: SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      value:
                                                          loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.error,
                                                    color: Colors.red,
                                                    size: 40,
                                                  ),
                                            )
                                          : const Icon(
                                              Icons.error,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                    ),
                                  ),
                                  title: CustomText(
                                    text: hasil.namaAnak,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(text: 'Tgl: ${hasil.tanggal}'),
                                      CustomText(text: 'Dinilai $count kali'),
                                    ],
                                  ),
                                  // trailing: IconButton(
                                  //   icon: const Icon(
                                  //     Icons.delete,
                                  //     color: Colors.red,
                                  //   ),
                                  //   onPressed: () =>
                                  //       _deleteHasil(context, ref, hasil.id),
                                  // ),
                                  onTap: () {
                                    final item = anakList[index];
                                    final hasil = item["hasil"] as HasilModel;
                                    final anakResults = grouped[hasil.anakId]!;
                                    context.go(
                                      '/detailHasil',
                                      extra: anakResults,
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, _) =>
                            Center(child: Text('Terjadi kesalahan: $error')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
