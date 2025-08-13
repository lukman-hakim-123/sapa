import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/produk_model.dart';
import '../../providers/produk_provider.dart';

class ProdukScreen extends ConsumerWidget {
  const ProdukScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final produkState = ref.watch(produkNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Daftar Produk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/dashboard');
          },
        ),
      ),
      body: produkState.when(
        data: (produkList) {
          if (produkList.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data produk',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: produkList.length,
            itemBuilder: (context, index) {
              final produk = produkList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.inventory,
                    color: Colors.orange,
                    size: 48,
                  ),
                  title: Text(
                    produk.namaProduk,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('jumlah: ${produk.jumlah.toStringAsFixed(0)}'),
                      Text('HPP: Rp ${produk.hargaPokok.toStringAsFixed(0)}'),
                      Text(
                        'Rp ${produk.hargaJual.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteProduk(context, ref, produk.id),
                  ),
                  onTap: () => context.go('/produk-detail', extra: produk),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Terjadi kesalahan: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddProduk(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToAddProduk(BuildContext context) {
    context.go('/addProduk');
  }

  void _navigateToDetail(BuildContext context, ProdukModel produk) {
    // Arahkan ke halaman detail produk
    Navigator.pushNamed(context, '/produk-detail', arguments: produk);
  }

  Future<void> _deleteProduk(
      BuildContext context, WidgetRef ref, String produkId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
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
      ref.read(produkNotifierProvider.notifier).deleteProduk(produkId);
    }
  }
}
