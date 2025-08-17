import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_colors.dart';
import '../../widgets/custom_text.dart';

class StppaScreen extends ConsumerWidget {
  const StppaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> kategoriItems = [
      {
        'title': 'Fisik Motorik',
        'description': 'perkembangan gerak kasar/halus, koordinasi tubuh',
        'color': Color(0xFFFFADAD),
        'icon': 'assets/icons/fm.svg',
        'onTap': () {},
      },
      {
        'title': 'Bahasa',
        'description': 'kemampuan berkomunikasi, kosakata, memahami instruksi',
        'color': Color(0xFFC3D6FF),
        'icon': 'assets/icons/bhs.svg',
        'onTap': () {},
      },
      {
        'title': 'Sosial Emosional',
        'description': 'interaksi dengan teman/guru, kontrol emosi, sikap',
        'color': Color(0xFFFF9DD8),
        'icon': 'assets/icons/se.svg',
        'onTap': () {},
      },
      {
        'title': 'Nilai Agama & Moral',
        'description': 'sikap beribadah, perilaku sopan, nilai moral',
        'color': Color(0xFFC7FFCA),
        'icon': 'assets/icons/nam.svg',
        'onTap': () {},
      },
      {
        'title': 'Kognitif',
        'description':
            'kemampuan berpikir, memecahkan masalah, mengenal konsep',
        'color': Color(0xFFE596E6),
        'icon': 'assets/icons/kg.svg',
        'onTap': () {},
      },
    ];
    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: 'STPPA',
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
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
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CustomText(
                text: 'Kategori Perkembangan',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            ...kategoriItems.map((item) {
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 4,
                child: Container(
                  height: 100.0,
                  alignment: Alignment.center,
                  child: ListTile(
                    leading: Container(
                      height: 50.0,
                      width: 50.0,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(12.0)),
                        color: item['color'],
                      ),
                      child: SvgPicture.asset(
                        item['icon'],
                        height: 40,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                    title: CustomText(
                      text: item['title'],
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    subtitle: CustomText(
                      text: item['description'],
                      fontSize: 14.0,
                    ),
                    onTap: item['onTap'],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
