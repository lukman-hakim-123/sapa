import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/anak_provider.dart';
import '../../providers/stppa_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class PilihAnakScreen extends ConsumerStatefulWidget {
  const PilihAnakScreen({super.key});

  @override
  ConsumerState<PilihAnakScreen> createState() => _PilihAnakScreenState();
}

class _PilihAnakScreenState extends ConsumerState<PilihAnakScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakNotifierProvider);
    final userProfileState = ref.watch(userProfileNotifierProvider);
    final selected = ref.watch(selectedAgeKategoriProvider);
    final selectedUsia = selected?['usia'];

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const CustomText(
            text: 'Pilih Anak',
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
            onPressed: () {
              ref.read(selectedAgeKategoriProvider.notifier).state = null;
              context.go('/stppa');
            },
          ),
        ),
        body: userProfileState.when(
          data: (profile) {
            if (profile == null) {
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(anakNotifierProvider);
                },
                child: Center(child: Text('profile kosong')),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(anakNotifierProvider);
              },
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50.0,
                      child: CustomTextFormField(
                        controller: searchController,
                        hintText: 'Search...',
                        suffixIcon: const Icon(Icons.search),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Expanded(
                      child: anakState.when(
                        data: (anakList) {
                          if (anakList.isEmpty) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
                                child: CustomText(
                                  text: 'Belum ada data anak',
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }
                          final filtered = anakList.where((anak) {
                            return anak.nama.toLowerCase().contains(
                              searchQuery,
                            );
                          }).toList();
                          if (filtered.isEmpty) {
                            return const Center(
                              child: CustomText(
                                text: 'Data tidak ditemukan',
                                fontSize: 16,
                              ),
                            );
                          }
                          if (selectedUsia != null) {
                            filtered.sort((a, b) {
                              if (a.usia == selectedUsia &&
                                  b.usia != selectedUsia) {
                                return -1;
                              } else if (a.usia != selectedUsia &&
                                  b.usia == selectedUsia) {
                                return 1;
                              } else {
                                return a.usia.compareTo(b.usia);
                              }
                            });
                          }
                          final url = ref
                              .read(anakNotifierProvider.notifier)
                              .getPublicImageUrl;
                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final anak = filtered[index];
                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[300],
                                    child: ClipOval(
                                      child: Image.network(
                                        url(anak.imageId),
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
                                            (context, error, stackTrace) =>
                                                const Icon(
                                                  Icons.error,
                                                  color: Colors.red,
                                                  size: 40,
                                                ),
                                      ),
                                    ),
                                  ),
                                  title: CustomText(
                                    text: anak.nama,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(text: '${anak.usia} tahun'),
                                      CustomText(
                                        text: anak.tanggalLahir,
                                        fontSize: 12,
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    context.go('/penilaian', extra: anak);
                                  },
                                ),
                              );
                            },
                          );
                        },
                        loading: () => Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                          ),
                        ),
                        error: (error, stack) =>
                            Center(child: Text('Terjadi kesalahan: $error')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          ),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
