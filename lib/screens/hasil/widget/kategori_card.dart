import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:sapa/screens/hasil/widget/pie_chart.dart';
import 'package:sapa/widgets/custom_text.dart';
import 'package:sapa/providers/hasil_provider.dart';

import '../../../models/hasil_model.dart';

final expandedProvider = StateProvider.family<bool, String>((ref, id) => false);

class KategoriCard extends ConsumerWidget {
  final String id;
  final String icon;
  final Color color;
  final String subKategori;
  final bool isPrinting;
  final int levelUser;
  final HasilModel hasil;

  const KategoriCard({
    super.key,
    required this.id,
    required this.hasil,
    required this.icon,
    required this.color,
    required this.subKategori,
    required this.levelUser,
    this.isPrinting = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(expandedProvider(id));
    final List<Map<String, dynamic>> parsedSubKategori =
        (jsonDecode(subKategori) as List)
            .map((e) => Map<String, dynamic>.from(e))
            .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  padding: EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                    color: color,
                  ),
                  child: SvgPicture.asset(icon, fit: BoxFit.cover),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: hasil.kategori,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    Row(
                      children: [
                        CustomText(
                          text: '${hasil.tanggal}, Usia: ${hasil.usia} Tahun',
                          fontSize: 12,
                        ),
                      ],
                    ),
                    CustomText(text: 'Guru: ${hasil.namaGuru}', fontSize: 14),
                  ],
                ),
                const Spacer(),
                if (!isPrinting && levelUser != 3)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: const Text("Hapus Data"),
                            content: const Text(
                              "Apakah Anda yakin ingin menghapus data ini?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.of(ctx).pop();
                                  await ref
                                      .read(hasilNotifierProvider.notifier)
                                      .deleteHasil(id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Data berhasil dihapus"),
                                      ),
                                    );
                                    context.go('/hasil');
                                  }
                                },
                                child: const Text(
                                  "Hapus",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              padding: const EdgeInsets.all(8),
              child: SubKategoriPieChart(subKategoriData: parsedSubKategori),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1E6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFCBA4), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!expanded) ...[
                    buildShortDescription(hasil),
                    InkWell(
                      onTap: () =>
                          ref.read(expandedProvider(id).notifier).state = true,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CustomText(
                          text: "Lihat selengkapnya",
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  if (expanded) ...[
                    buildFullDescription(hasil),
                    InkWell(
                      onTap: () =>
                          ref.read(expandedProvider(id).notifier).state = false,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: CustomText(
                          text: "Tutup",
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildShortDescription(HasilModel h) {
    final mampu = h.contohMampu.trim();
    final bantuan = h.contohMampuBantuan.trim();
    final belum = h.contohBelumMampu.trim();

    if (mampu.isEmpty && bantuan.isEmpty && belum.isEmpty) {
      return const Text("Belum ada catatan untuk kategori ini.");
    }

    final spans = <TextSpan>[];

    if (mampu.isNotEmpty) {
      spans.add(const TextSpan(text: "Anak mampu "));
      spans.add(
        TextSpan(
          text: mampu,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    if (bantuan.isNotEmpty) {
      if (spans.isNotEmpty) spans.add(const TextSpan(text: ". "));
      spans.add(const TextSpan(text: "Dengan bantuan, anak sudah bisa "));
      spans.add(
        TextSpan(
          text: bantuan,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    if (belum.isNotEmpty) {
      if (spans.isNotEmpty) spans.add(const TextSpan(text: ". "));
      spans.add(const TextSpan(text: "Namun, anak masih kesulitan dalam "));
      spans.add(
        TextSpan(
          text: belum,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: const TextStyle(fontSize: 14, height: 1.3, color: Colors.black),
        children: spans,
      ),
    );
  }

  Widget buildFullDescription(HasilModel h) {
    final mampu = h.contohMampu.trim().isNotEmpty
        ? h.contohMampu.split(",").map((e) => e.trim()).toList()
        : [];
    final bantuan = h.contohMampuBantuan.trim().isNotEmpty
        ? h.contohMampuBantuan.split(",").map((e) => e.trim()).toList()
        : [];
    final belum = h.contohBelumMampu.trim().isNotEmpty
        ? h.contohBelumMampu.split(",").map((e) => e.trim()).toList()
        : [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (mampu.isNotEmpty) ...[
          const CustomText(text: "Mampu:", fontWeight: FontWeight.bold),
          ...mampu.map((e) => CustomText(text: "• $e")),
          const SizedBox(height: 8),
        ],
        if (bantuan.isNotEmpty) ...[
          const CustomText(
            text: "Dengan Bantuan:",
            fontWeight: FontWeight.bold,
          ),
          ...bantuan.map((e) => CustomText(text: "• $e")),
          const SizedBox(height: 8),
        ],
        if (belum.isNotEmpty) ...[
          const CustomText(text: "Belum Mampu:", fontWeight: FontWeight.bold),
          ...belum.map((e) => CustomText(text: "• $e")),
        ],
      ],
    );
  }
}
