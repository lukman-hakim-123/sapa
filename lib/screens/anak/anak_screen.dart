import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/anak_model.dart';
import '../../providers/anak_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';

class AnakScreen extends ConsumerStatefulWidget {
  const AnakScreen({super.key});

  @override
  ConsumerState<AnakScreen> createState() => _AnakScreenState();
}

class _AnakScreenState extends ConsumerState<AnakScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakNotifierProvider);
    final userProfileState = ref.watch(userProfileNotifierProvider);
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: CustomText(
          text: 'Data Anak',
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
            context.go('/bottomNav');
          },
        ),
      ),
      body: userProfileState.when(
        data: (profile) {
          final int userLevel = profile!.level_user;
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
                  if (userLevel != 3)
                    CustomButton(
                      onPressed: () {
                        context.go('/formAnak');
                      },
                      height: 45.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          CustomText(
                            text: 'Tambah data anak',
                            color: Colors.white,
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                          Icon(Icons.add, color: Colors.white, size: 25.0),
                        ],
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
                          return anak.nama.toLowerCase().contains(searchQuery);
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    CustomText(text: '${anak.usia} tahun'),
                                    CustomText(
                                      text: anak.tanggalLahir,
                                      fontSize: 12,
                                    ),
                                  ],
                                ),
                                trailing: userLevel != 3
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {
                                              context.go(
                                                '/formAnak',
                                                extra: anak,
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () =>
                                                _deleteAnak(context, ref, anak),
                                          ),
                                        ],
                                      )
                                    : null,
                                onTap: () =>
                                    context.go('/detailAnak', extra: anak),
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
    );
  }

  Future<void> _deleteAnak(
    BuildContext context,
    WidgetRef ref,
    AnakModel anak,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Anak'),
        content: const Text('Apakah Anda yakin ingin menghapus anak ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(anakNotifierProvider.notifier).deleteAnak(anak);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data anak berhasil dihapus')),
      );
    }
  }
}
