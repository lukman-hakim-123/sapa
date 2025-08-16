import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/anak_model.dart';
import '../../providers/anak_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';

class AnakScreen extends ConsumerWidget {
  const AnakScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final anakState = ref.watch(anakNotifierProvider);
    final searchController = TextEditingController();

    return Scaffold(
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
      body: RefreshIndicator(
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
                ),
              ),
              const SizedBox(height: 10.0),
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
                    final url = ref
                        .read(anakNotifierProvider.notifier)
                        .getPublicImageUrl;

                    return ListView.builder(
                      itemCount: anakList.length,
                      itemBuilder: (context, index) {
                        final anak = anakList[index];
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
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
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
                                  errorBuilder: (context, error, stackTrace) =>
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
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                CustomText(text: '${anak.usia} tahun'),
                                CustomText(text: anak.tanggalLahir),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () =>
                                      _deleteAnak(context, ref, anak.id),
                                ),
                              ],
                            ),
                            onTap: () =>
                                context.go('/anak-detail', extra: anak),
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
      ),
    );
  }

  void _navigateToDetail(BuildContext context, AnakModel anak) {
    Navigator.pushNamed(context, '/anak-detail', arguments: anak);
  }

  Future<void> _deleteAnak(
    BuildContext context,
    WidgetRef ref,
    String anakId,
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
      ref.read(anakNotifierProvider.notifier).deleteAnak(anakId);
    }
  }
}
