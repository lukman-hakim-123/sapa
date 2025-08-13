import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sapa/widgets/custom_text.dart';

import '../../providers/auth_provider.dart';
import '../../widgets/app_colors.dart';

class DashboardScreen extends ConsumerWidget {
  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.attach_money,
      'label': 'Identitas Anak',
      'route': '/dashboard',
      'color': Color(0xFFFFD7B5),
      'sub': 'data profil anak',
    },
    {
      'icon': Icons.group,
      'label': 'STPPA',
      'route': '/dashboard',
      'color': Color(0xFFFBBBC1),
      'sub': 'standar pencapaian perkembangan anak',
    },
    {
      'icon': Icons.shopping_cart,
      'label': 'Hasil',
      'route': '/produk',
      'color': Color(0xFFB7DFF5),
      'sub': 'laporan penilaian',
    },
    {
      'icon': Icons.inventory,
      'label': 'Tambah Guru',
      'route': '/dashboard',
      'color': Color(0xFFD5C4B0),
      'sub': 'tambah akun guru',
    },
  ];

  final List<Map<String, String>> aktivitasTerbaru = [
    {
      'nama': 'Ahmad Fauzi',
      'aktivitas': 'Penilaian motorik kasar selesai',
      'avatar': '',
    },
    {
      'nama': 'Siti Aminah',
      'aktivitas': 'Profil anak diperbarui',
      'avatar': '',
    },
  ];

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final now = DateTime.now();
    final hari = DateFormat('EEEE', 'id_ID').format(now);
    final tanggal = DateFormat('d MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: authState.when(
        data: (user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(
                    top: 60,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.secondary, AppColors.primary],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppColors.tertiary,
                            child: Icon(
                              Icons.person,
                              color: AppColors.text,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          CustomText(
                            text: user!.name,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomText(text: hari),
                          CustomText(
                            text: tanggal,
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom: 25,
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: menuItems.length,
                    itemBuilder: (context, index) {
                      final item = menuItems[index];
                      return GestureDetector(
                        onTap: () => context.go(item['route']),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: item['color'],
                                child: Icon(
                                  item['icon'],
                                  size: 35,
                                  color: AppColors.text,
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomText(
                                text: item['label'],
                                textAlign: TextAlign.center,
                                fontWeight: FontWeight.bold,
                              ),
                              CustomText(
                                text: item['sub'],
                                textAlign: TextAlign.center,
                                fontSize: 12,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomText(
                    text: 'Aktifitas Terbaru',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(top: 12),
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: aktivitasTerbaru.length,
                    itemBuilder: (context, index) {
                      final item = aktivitasTerbaru[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ListTile(
                          leading:
                              item['avatar'] != null &&
                                  item['avatar']!.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    item['avatar']!,
                                  ),
                                )
                              : CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey[700],
                                  ),
                                ),
                          title: CustomText(
                            text: item['nama']!,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          subtitle: CustomText(text: item['aktivitas']!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
