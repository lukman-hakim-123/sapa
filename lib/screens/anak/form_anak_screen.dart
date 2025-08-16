import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../models/anak_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/anak_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';

class FormAnakScreen extends ConsumerStatefulWidget {
  final AnakModel? anak;
  const FormAnakScreen({super.key, this.anak});

  @override
  ConsumerState<FormAnakScreen> createState() => _FormAnakScreenState();
}

class _FormAnakScreenState extends ConsumerState<FormAnakScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _emailController = TextEditingController();
  final _usiaController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  String? _tanggalLahir;

  File? _pickedImage;
  String? gender;
  @override
  void initState() {
    super.initState();
    if (widget.anak != null) {
      _namaController.text = widget.anak!.nama;
      _alamatController.text = widget.anak!.alamat;
      _emailController.text = widget.anak!.email;
      _usiaController.text = widget.anak!.usia.toString();
      _tanggalLahir = widget.anak!.tanggalLahir;
      _tanggalLahirController.text = widget.anak!.tanggalLahir;
      gender = widget.anak!.jenisKelamin;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _emailController.dispose();
    _usiaController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 5),
      firstDate: DateTime(2000),
      lastDate: now,
    );
    if (picked != null) {
      final formatted = DateFormat('dd-MM-yyyy').format(picked);
      setState(() {
        _tanggalLahir = formatted;
        _tanggalLahirController.text = formatted;

        int age = now.year - picked.year;
        if (now.month < picked.month ||
            (now.month == picked.month && now.day < picked.day)) {
          age--;
        }
        _usiaController.text = age.toString();
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final newFileName = 'profile_$timestamp.jpg';

      final tempDir = Directory.systemTemp;
      final newPath = '${tempDir.path}/$newFileName';
      final newImage = await File(pickedFile.path).copy(newPath);

      setState(() {
        _pickedImage = newImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final anakState = ref.watch(anakNotifierProvider);
    final authState = ref.watch(authProvider);
    final url = ref.read(anakNotifierProvider.notifier).getPublicImageUrl;

    ref.listen<AsyncValue>(anakNotifierProvider, (_, state) {
      if (state.value != null) {
        context.go('/anak');
      } else if (state.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal: ${state.error}')));
      }
    });

    final isEdit = widget.anak != null;

    return Scaffold(
      appBar: AppBar(
        title: CustomText(
          text: isEdit ? 'Edit Anak' : 'Tambah Anak',
          color: Colors.white,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: AppColors.primary,
        scrolledUnderElevation: 0.0,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/anak'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 53,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      child: _pickedImage != null
                          ? ClipOval(
                              child: Image.file(
                                _pickedImage!,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            )
                          : isEdit && widget.anak!.imageId.isNotEmpty
                          ? ClipOval(
                              child: Image.network(
                                url(widget.anak!.imageId),
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              ),
                            )
                          : const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    onPressed: _pickImage,
                    child: CustomText(
                      text: isEdit ? 'Ganti Foto' : 'Tambah Foto',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.person, size: 25.0),
                  CustomText(text: 'Nama Anak', fontWeight: FontWeight.bold),
                ],
              ),
              const SizedBox(height: 4.0),
              CustomTextFormField(
                controller: _namaController,
                hintText: 'Nama Anak',
                validator: (value) =>
                    ValidationHelper.validateNotEmpty(value, 'Nama Anak'),
              ),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.date_range, size: 25.0),
                              CustomText(
                                text: 'Tanggal Lahir',
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4.0),
                          CustomTextFormField(
                            controller: _tanggalLahirController,
                            hintText: 'Tanggal Lahir',
                            readOnly: true,
                            suffixIcon: const Icon(
                              Icons.date_range,
                              color: Colors.grey,
                            ),
                            onTap: _pickDate,
                            validator: (value) =>
                                ValidationHelper.validateNotEmpty(
                                  value,
                                  'Tanggal Lahir',
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.cake, size: 25.0),
                              CustomText(
                                text: 'Usia',
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3.0),
                          CustomTextFormField(
                            controller: _usiaController,
                            keyboardType: TextInputType.number,
                            readOnly: !isEdit,
                            suffix: CustomText(
                              text: 'Tahun',
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                              vertical: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Row(
                children: [
                  SvgPicture.asset('assets/icons/gender.svg'),
                  CustomText(
                    text: 'Jenis Kelamin',
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(horizontal: -4),
                      title: CustomText(
                        text: "Laki-laki",
                        fontSize: 16.0,
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: "Laki-laki",
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() => gender = value);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      visualDensity: const VisualDensity(horizontal: -4),
                      title: CustomText(
                        text: "Perempuan",
                        fontSize: 16.0,
                        overflow: TextOverflow.ellipsis,
                      ),
                      value: "Perempuan",
                      groupValue: gender,
                      onChanged: (value) {
                        setState(() => gender = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_pin, size: 25.0),
                  CustomText(text: 'Alamat', fontWeight: FontWeight.bold),
                ],
              ),
              const SizedBox(height: 4.0),
              CustomTextFormField(
                controller: _alamatController,
                hintText: 'Alamat',
                maxLines: 2,
                validator: (value) =>
                    ValidationHelper.validateNotEmpty(value, 'Alamat'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.email, size: 25.0),
                  CustomText(text: 'Email', fontWeight: FontWeight.bold),
                ],
              ),
              const SizedBox(height: 4.0),
              CustomTextFormField(
                controller: _emailController,
                hintText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) => ValidationHelper.validateEmail(value),
              ),
              const SizedBox(height: 24),
              CustomButton(
                onPressed: anakState.isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          if (_tanggalLahir == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tanggal lahir belum dipilih'),
                              ),
                            );
                            return;
                          }
                          if (gender == null || gender == '') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Jenis kelamin belum dipilih'),
                              ),
                            );
                            return;
                          }
                          if (_pickedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Foto belum dipilih'),
                              ),
                            );
                            return;
                          }
                          authState.when(
                            data: (user) {
                              final updatedModel = AnakModel(
                                id: isEdit ? widget.anak!.id : '',
                                nama: _namaController.text,
                                alamat: _alamatController.text,
                                email: _emailController.text,
                                usia: int.parse(_usiaController.text),
                                tanggalLahir: _tanggalLahir!,
                                guruId: user!.$id,
                                jenisKelamin: gender!,
                                imageId: '',
                              );
                              if (isEdit) {
                                ref
                                    .read(anakNotifierProvider.notifier)
                                    .updateAnak(widget.anak!, updatedModel);
                              } else {
                                ref
                                    .read(anakNotifierProvider.notifier)
                                    .createAnak(updatedModel, _pickedImage!);
                              }
                            },
                            loading: () => Center(
                              child: CircularProgressIndicator(
                                color: AppColors.secondary,
                              ),
                            ),
                            error: (error, _) =>
                                Center(child: Text('Error: $error')),
                          );
                        }
                      },
                text: isEdit ? 'Edit Data Anak' : 'Tambah Anak',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
