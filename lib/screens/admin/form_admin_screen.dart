import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_profile_model.dart';
import '../../providers/admin_provider.dart';
import '../../providers/user_profile_provider.dart';
import '../../utils/validation_helper.dart';
import '../../widgets/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/my_double_tap_exit.dart';

class FormAdminScreen extends ConsumerStatefulWidget {
  final UserProfile? admin;
  const FormAdminScreen({super.key, this.admin});

  @override
  ConsumerState<FormAdminScreen> createState() => _FormAdminScreenState();
}

class _FormAdminScreenState extends ConsumerState<FormAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _sekolahController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordLamaController = TextEditingController();
  final _ulangiPasswordBaruController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscure = true;
  bool _obscure3 = true;

  @override
  void initState() {
    super.initState();
    if (widget.admin != null) {
      _namaController.text = widget.admin!.nama;
      _emailController.text = widget.admin!.email;
      _sekolahController.text = widget.admin!.sekolah;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _sekolahController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminNotifierProvider);
    final isEdit = widget.admin != null;

    ref.listen<AsyncValue<List<UserProfile>>>(adminNotifierProvider, (
      _,
      state,
    ) {
      state.when(
        data: (listAdmin) {
          if (_isSubmitting) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  isEdit
                      ? 'Data Admin berhasil diperbarui'
                      : 'Data Admin berhasil ditambahkan',
                ),
              ),
            );
            setState(() => _isSubmitting = false);

            if (isEdit) {
              final updatedAdmin = listAdmin.firstWhere(
                (g) => g.id == widget.admin!.id,
                orElse: () => widget.admin!,
              );
              context.go('/detailAdmin', extra: updatedAdmin);
            } else {
              context.go('/admin');
            }
          }
        },
        error: (err, _) {
          if (_isSubmitting) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $err')));
            setState(() => _isSubmitting = false);
          }
        },
        loading: () {},
      );
    });

    return MyDoubleTapExit(
      child: Scaffold(
        appBar: AppBar(
          title: CustomText(
            text: isEdit ? 'Edit Admin' : 'Tambah Admin',
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
          backgroundColor: AppColors.primary,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/admin'),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.person, size: 25.0),
                      CustomText(
                        text: 'Nama Admin',
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4.0),
                  CustomTextFormField(
                    controller: _namaController,
                    hintText: 'Nama Admin',
                    validator: (value) =>
                        ValidationHelper.validateNotEmpty(value, 'Nama Admin'),
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
                    readOnly: isEdit,
                    validator: (value) => ValidationHelper.validateEmail(value),
                  ),
                  const SizedBox(height: 10),
                  isEdit
                      ? Container()
                      : Row(
                          children: [
                            Icon(Icons.lock, size: 25),
                            CustomText(
                              text: 'Password',
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                  const SizedBox(height: 4),
                  isEdit
                      ? Container()
                      : CustomTextFormField(
                          controller: _passwordLamaController,
                          obscureText: _obscure,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                          validator: (value) =>
                              ValidationHelper.validateMultiple(value, [
                                if (isEdit)
                                  (v) =>
                                      ValidationHelper.validatePasswordOnEmailChange(
                                        v,
                                        widget.admin!.email,
                                        _emailController.text,
                                      ),
                                (v) => ValidationHelper.validateNotEmpty(
                                  v,
                                  'Password',
                                ),
                                (v) =>
                                    ValidationHelper.validateOptionalMinLength(
                                      v,
                                      8,
                                      'Password',
                                    ),
                              ]),
                        ),
                  isEdit ? Container() : const SizedBox(height: 10),
                  isEdit
                      ? Container()
                      : Row(
                          children: [
                            Icon(Icons.lock, size: 25),
                            CustomText(
                              text: 'Ulangi Password',
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                  isEdit ? Container() : const SizedBox(height: 10),
                  isEdit
                      ? Container()
                      : CustomTextFormField(
                          controller: _ulangiPasswordBaruController,
                          obscureText: _obscure3,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure3
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _obscure3 = !_obscure3),
                          ),
                          validator: (value) =>
                              ValidationHelper.validateMultiple(value, [
                                (v) =>
                                    ValidationHelper.validateOptionalMinLength(
                                      v,
                                      8,
                                      'Ulangi Password',
                                    ),
                                (v) {
                                  if (v != _passwordLamaController.text &&
                                      !isEdit) {
                                    return 'Password tidak sama';
                                  }
                                  return null;
                                },
                              ]),
                        ),
                  isEdit ? Container() : const SizedBox(height: 10),
                  isEdit ? Container() :Row(
                    children: [
                      Icon(Icons.location_city, size: 25.0),
                      CustomText(
                        text: 'Nama Sekolah',
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                  isEdit ? Container() :const SizedBox(height: 4.0),
                  isEdit ? Container() :CustomTextFormField(
                    controller: _sekolahController,
                    hintText: 'Nama Sekolah',
                    validator: (value) => ValidationHelper.validateNotEmpty(
                      value,
                      'Nama Sekolah',
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    onPressed: adminState.isLoading || _isSubmitting
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isSubmitting = true);
                              final profile = ref
                                  .read(userProfileNotifierProvider)
                                  .value;
                              if (profile == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Profile belum dimuat'),
                                  ),
                                );
                                return;
                              }

                              if (isEdit) {
                                final UserProfile updatedModel = UserProfile(
                                  id: widget.admin!.id,
                                  email: widget.admin!.email,
                                  foto: widget.admin!.foto,
                                  levelUser: 1,
                                  nama: _namaController.text,
                                  sekolah: _sekolahController.text,
                                );
                                ref
                                    .read(adminNotifierProvider.notifier)
                                    .updateAdmin(updatedModel);
                              } else {
                                ref
                                    .read(adminNotifierProvider.notifier)
                                    .createAdmin(
                                      _namaController.text,
                                      _emailController.text,
                                      _passwordLamaController.text,
                                      _sekolahController.text,
                                    );
                              }
                            }
                          },
                    isLoading: _isSubmitting,
                    text: isEdit ? 'Edit Data Admin' : 'Tambah Data Admin',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
