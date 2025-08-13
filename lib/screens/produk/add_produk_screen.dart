import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/produk_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/produk_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/custom_text_field.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  const AddProductScreen({super.key});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  final _hargaPokokController = TextEditingController();
  final _hargaJualController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _jenisController = TextEditingController();

  @override
  void dispose() {
    _productNameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _hargaPokokController.dispose();
    _hargaJualController.dispose();
    _jumlahController.dispose();
    _jenisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productState = ref.watch(produkNotifierProvider);
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue>(produkNotifierProvider, (_, state) {
      if (state.value != null) {
        context.go('/produk');
      } else if (state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: ${state.error}')),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Produk',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => context.go('/produk'),
            child: const Text('BATAL', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Column(
                          children: [
                            Icon(Icons.add_shopping_cart,
                                size: 80, color: Colors.green),
                            SizedBox(height: 8),
                            Text(
                              'Tambah Produk Baru',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _productNameController,
                        labelText: 'Nama Produk',
                        validator: (value) => ValidationHelper.validateNotEmpty(
                            value, 'Nama Produk'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _descriptionController,
                        labelText: 'Deskripsi',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _skuController,
                        labelText: 'SKU',
                        validator: (value) =>
                            ValidationHelper.validateNotEmpty(value, 'SKU'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _hargaPokokController,
                        labelText: 'Harga Pokok',
                        keyboardType: TextInputType.number,
                        validator: (value) => ValidationHelper.validateNotEmpty(
                            value, 'Harga Pokok'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _hargaJualController,
                        labelText: 'Harga Jual',
                        keyboardType: TextInputType.number,
                        validator: (value) => ValidationHelper.validateNotEmpty(
                            value, 'Harga Jual'),
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _jumlahController,
                        labelText: 'Jumlah',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      CustomTextFormField(
                        controller: _jenisController,
                        labelText: 'Jenis (pcs/unit)',
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: productState.isLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  _formKey.currentState!.save();
                                  authState.when(
                                      data: (user) {
                                        ref
                                            .read(
                                                produkNotifierProvider.notifier)
                                            .createProduk(
                                              ProdukModel(
                                                id: '',
                                                namaProduk:
                                                    _productNameController.text,
                                                deskripsi:
                                                    _descriptionController.text,
                                                sku: _skuController.text,
                                                hargaPokok: double.parse(
                                                    _hargaPokokController.text),
                                                hargaJual: double.parse(
                                                    _hargaJualController.text),
                                                jumlah: double.parse(
                                                    _jumlahController.text),
                                                jenis: _jenisController.text,
                                                userId: user!.$id,
                                              ),
                                            );
                                      },
                                      loading: () => const Center(
                                          child: CircularProgressIndicator()),
                                      error: (error, _) =>
                                          Center(child: Text('Error: $error')));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                        ),
                        child: productState.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'TAMBAH PRODUK',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
