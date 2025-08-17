import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/user_profile_model.dart';
import '../../providers/guru_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';

class DetailGuruScreen extends ConsumerWidget {
  final UserProfile guru;

  const DetailGuruScreen({super.key, required this.guru});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileState = ref.watch(userProfileNotifierProvider);
    final url = ref.read(guruNotifierProvider.notifier).getPublicImageUrl;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: CustomText(
          text: 'Detail Guru',
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20.0,
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/guru'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
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
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error, color: Colors.red, size: 40),
                    ),
                  ),
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
                      _buildDetailCard('Nama Guru', guru.nama),
                      _buildDetailCard('Email', guru.email),

                      const SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomButton(
              text: 'Edit Data',
              onPressed: () {
                GoRouter.of(context).push('/formGuru', extra: guru);
              },
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Hapus Data',
              onPressed: () => _deleteGuru(context, ref, guru.id),
              backgroundColor: Colors.red[700],
            ),
          ],
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

  Future<void> _deleteGuru(
    BuildContext context,
    WidgetRef ref,
    String guruId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Anak'),
        content: const Text('Apakah Anda yakin ingin menghapus data guru ini?'),
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
      await ref.read(guruNotifierProvider.notifier).deleteGuru(guru.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data guru berhasil dihapus')),
      );
      context.go('/guru');
    }
  }
}
