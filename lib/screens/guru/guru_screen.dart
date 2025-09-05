import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sapa/models/user_profile_model.dart';
import '../../../providers/guru_provider.dart';
import '../../../providers/user_profile_provider.dart';
import '../../../widgets/app_colors.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class GuruScreen extends ConsumerStatefulWidget {
  const GuruScreen({super.key});

  @override
  ConsumerState<GuruScreen> createState() => _GuruScreenState();
}

class _GuruScreenState extends ConsumerState<GuruScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final guruState = ref.watch(guruNotifierProvider);
    final userProfileState = ref.watch(userProfileNotifierProvider);

    return MyDoubleTapExit(
      child: Scaffold(
        appBar: AppBar(
          title: const CustomText(
            text: 'Data Guru',
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
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(guruNotifierProvider);
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
                    CustomButton(
                      onPressed: () {
                        context.go('/formGuru');
                      },
                      height: 45.0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          CustomText(
                            text: 'Tambah data guru',
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
                      child: guruState.when(
                        data: (guruList) {
                          if (guruList.isEmpty) {
                            return SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
                                child: CustomText(
                                  text: 'Belum ada data guru',
                                  fontSize: 16,
                                ),
                              ),
                            );
                          }
                          final filtered = guruList.where((guru) {
                            return guru.nama.toLowerCase().contains(
                                  searchQuery,
                                ) ||
                                guru.email.toLowerCase().contains(searchQuery);
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
                              .read(guruNotifierProvider.notifier)
                              .getPublicImageUrl;
                          return ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final guru = filtered[index];
                              return Card(
                                color: Colors.white,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey[300],
                                    child: ClipOval(
                                      child: Image.network(
                                        url(guru.foto),
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
                                    text: guru.nama,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  subtitle: CustomText(
                                    text: guru.email,
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          context.go('/formGuru', extra: guru);
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _deleteGuru(context, ref, guru),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    context.go('/detailGuru', extra: guru);
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

  Future<void> _deleteGuru(
    BuildContext context,
    WidgetRef ref,
    UserProfile guru,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Guru'),
        content: const Text('Apakah Anda yakin ingin menghapus guru ini?'),
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
      ref.read(guruNotifierProvider.notifier).deleteGuru(guru);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data guru berhasil dihapus')),
      );
    }
  }
}
