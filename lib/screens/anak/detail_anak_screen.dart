import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/anak_model.dart';
import '../../providers/anak_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/my_double_tap_exit.dart';

class DetailAnakScreen extends ConsumerWidget {
  final AnakModel anak;

  const DetailAnakScreen({super.key, required this.anak});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileState = ref.watch(userProfileNotifierProvider);
    final url = ref.read(anakNotifierProvider.notifier).getPublicImageUrl;

    return MyDoubleTapExit(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: CustomText(
            text: 'Detail Anak',
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/anak'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
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
                                        loadingProgress.expectedTotalBytes !=
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
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: anak.nama,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          const SizedBox(height: 4),
                          CustomText(text: anak.email),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: Colors.white,
                    child: Column(
                      children: [
                        const SizedBox(height: 8.0),
                        _buildDetailCard(
                          'Tempat, Tgl Lahir',
                          "${anak.tempatLahir}, ${anak.tanggalLahir}",
                        ),
                        _buildDetailCard(
                          'Usia',
                          '${anak.usia.toString()} Tahun',
                        ),
                        _buildDetailCard('Jenis Kelamin', anak.jenisKelamin),
                        _buildDetailCard('Alamat', anak.alamat),
                        _buildDetailCard('Nama Ayah', anak.namaAyah),
                        _buildDetailCard('Nama Ibu', anak.namaIbu),
                        const SizedBox(height: 8.0),
                      ],
                    ),
                  ),
                ],
              ),
              userProfileState.when(
                data: (profile) {
                  final int userLevel = profile!.level_user;

                  return userLevel != 3
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomButton(
                                text: 'Edit Data',
                                onPressed: () {
                                  GoRouter.of(
                                    context,
                                  ).push('/formAnak', extra: anak);
                                },
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                text: 'Hapus Data',
                                onPressed: () =>
                                    _deleteAnak(context, ref, anak),
                                backgroundColor: Colors.red[700],
                              ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink();
                },
                loading: () => const SizedBox(
                  height: 60,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Error: $e'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(text: title, fontWeight: FontWeight.bold),
              const SizedBox(width: 16),
              Flexible(
                child: CustomText(
                  text: value.isNotEmpty ? value : '-',
                  textAlign: TextAlign.right,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: Colors.grey),
        ],
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
        content: const Text('Apakah Anda yakin ingin menghapus data anak ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(anakNotifierProvider.notifier).deleteAnak(anak);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data anak berhasil dihapus')),
      );
      context.go('/anak');
    }
  }
}
