import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sapa/widgets/custom_text.dart';

import '../../providers/auth_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../widgets/app_colors.dart';

class DashboardScreen extends ConsumerWidget {
  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': 'assets/icons/anak.svg',
      'label': 'Identitas Anak',
      'route': '/anak',
      'color': Color(0xFFFFD7B5),
      'sub': 'data profil anak',
    },
    {
      'icon': 'assets/icons/evaluasi.svg',
      'label': 'STPPA',
      'route': '/stppa',
      'color': Color(0xFFFBBBC1),
      'sub': 'standar pencapaian perkembangan anak',
    },
    {
      'icon': 'assets/icons/hasil.svg',
      'label': 'Hasil',
      'route': '/produk',
      'color': Color(0xFFB7DFF5),
      'sub': 'laporan penilaian',
    },
    {
      'icon': 'assets/icons/add_guru.svg',
      'label': 'Tambah Guru',
      'route': '/guru',
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

  List<int> getLockedMenus(int userLevel) {
    if (userLevel == 3) {
      return [1, 3];
    } else if (userLevel == 2) {
      return [3];
    } else {
      return [];
    }
  }

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userProfileState = ref.watch(userProfileNotifierProvider);
    final now = DateTime.now();
    final hari = DateFormat('EEEE', 'id_ID').format(now);
    final tanggal = DateFormat('d MMMM yyyy', 'id_ID').format(now);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: authState.when(
        data: (user) {
          return userProfileState.when(
            data: (profile) {
              final int userLevel = profile!.level_user;
              final lockedMenus = getLockedMenus(userLevel);
              final url = ref
                  .read(userProfileNotifierProvider.notifier)
                  .getPublicImageUrl;
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: AppColors.tertiary,
                                child:
                                    (profile.foto.isNotEmpty ||
                                        profile.foto != '')
                                    ? ClipOval(
                                        child: Image.network(
                                          url(profile.foto),
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
                                      )
                                    : Icon(
                                        Icons.person,
                                        size: 30,
                                        color: Colors.white,
                                      ),
                              ),
                              const SizedBox(width: 16),
                              CustomText(
                                text: profile.nama,
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
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(top: 30, bottom: 25),
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
                          final isLocked = lockedMenus.contains(index);
                          return GestureDetector(
                            onTap: () {
                              if (isLocked) {
                                String message = '';
                                if (userLevel == 3) {
                                  message = 'Fitur ini hanya untuk guru';
                                } else if (userLevel == 2 &&
                                    item['label'] == 'Tambah Guru') {
                                  message =
                                      'Fitur ini hanya untuk kepala sekolah';
                                }
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Akses Ditolak'),
                                    content: Text(message),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                context.go(item['route']);
                              }
                            },
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isLocked
                                          ? Colors.grey[300]
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 6,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: item['color'],
                                          child: SvgPicture.asset(
                                            item['icon'],
                                            width: 35,
                                            height: 35,
                                            fit: BoxFit.scaleDown,
                                            colorFilter: ColorFilter.mode(
                                              AppColors.text,
                                              BlendMode.srcIn,
                                            ),
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
                                ),
                                if (isLocked)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Icon(
                                      Icons.lock,
                                      color: Colors.grey[700],
                                      size: 20,
                                    ),
                                  ),
                              ],
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
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 100.0),
                  ],
                ),
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            ),
            error: (err, _) => Center(child: Text("Error: $err")),
          );
        },
        loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.secondary),
        ),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
