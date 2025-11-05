import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../providers/logo_provider.dart';

class CompanyFormFields extends ConsumerWidget {
  final TextEditingController nameController;
  final TextEditingController logoController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  const CompanyFormFields({
    super.key,
    required this.nameController,
    required this.logoController,
    required this.phoneController,
    required this.emailController,
  });

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final String path = '${directory.path}/company_logo.png';

      await File(image.path).copy(path);
      logoController.text = path;
      ref.read(logoProvider.notifier).setLogo(path);
    }
  }

  void _removeLogo(WidgetRef ref) {
    try {
      if (logoController.text.isNotEmpty) {
        final file = File(logoController.text);
        if (file.existsSync()) {
          file.deleteSync();
        }
      }
    } catch (e) {
      print('Logo dosyası silinemedi: $e');
    }
    logoController.clear();
    ref.read(logoProvider.notifier).removeLogo();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logoPath = ref.watch(logoProvider);

    return Column(
      children: [
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Firma Adı',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.business),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Firma adı zorunludur';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Telefon',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
            labelText: 'E-posta',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (!emailRegex.hasMatch(value)) {
                return 'Geçerli bir e-posta adresi giriniz';
              }
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: logoController,
                decoration: InputDecoration(
                  labelText: 'Logo',
                  border: const OutlineInputBorder(),
                  prefixIcon: logoPath != null
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.file(
                              File(logoPath),
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      : const Icon(Icons.image),
                ),
                readOnly: true,
              ),
            ),
            const SizedBox(width: 8),
            if (logoPath == null)
              ElevatedButton.icon(
                onPressed: () => _pickImage(context, ref),
                icon: const Icon(Icons.image),
                label: const Text('Logo Seç'),
              )
            else
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeLogo(ref),
                    tooltip: 'Logo\'yu Kaldır',
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(context, ref),
                    icon: const Icon(Icons.edit),
                    label: const Text('Değiştir'),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
