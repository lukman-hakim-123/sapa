import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/produk_model.dart';
import '../../providers/produk_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/custom_text_field.dart';

class EditProdukScreen extends ConsumerStatefulWidget {
  final ProdukModel produk;

  const EditProdukScreen({super.key, required this.produk});

  @override
  ConsumerState<EditProdukScreen> createState() => _EditProdukScreenState();
}

class _EditProdukScreenState extends ConsumerState<EditProdukScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _productNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _skuController;
  late TextEditingController _hargaPokokController;
  late TextEditingController _hargaJualController;
  late TextEditingController _jumlahController;
  late TextEditingController _jenisController;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing product data
    _productNameController =
        TextEditingController(text: widget.produk.namaProduk);
    _descriptionController =
        TextEditingController(text: widget.produk.deskripsi);
    _skuController = TextEditingController(text: widget.produk.sku);
    _hargaPokokController =
        TextEditingController(text: widget.produk.hargaPokok.toStringAsFixed(0));
    _hargaJualController =
        TextEditingController(text: widget.produk.hargaJual.toStringAsFixed(0));
    _jumlahController =
        TextEditingController(text: widget.produk.jumlah.toStringAsFixed(0));
    _jenisController = TextEditingController(text: widget.produk.jenis);
  }

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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Produk',
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
                            Icon(Icons.edit, size: 80, color: Colors.blue),
                            SizedBox(height: 8),
                            Text(
                              'Edit Produk',
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
                                  ref
                                      .read(produkNotifierProvider.notifier)
                                      .updateProduk(
                                        ProdukModel(
                                          id: widget.produk.id,
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
                                          userId: widget.produk.userId,
                                        ),
                                        widget.produk,
                                      );
                                      context.go('/produk');
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
                                'UPDATE PRODUK',
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
