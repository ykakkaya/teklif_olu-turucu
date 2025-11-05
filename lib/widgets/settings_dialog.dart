import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teklif/models/currency.dart';
import '../models/company.dart';
import '../providers/company_provider.dart';
import 'company_form_fields.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _logoController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _dollarController = TextEditingController();
  final _euroController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final company = ref.read(companyProvider);
    if (company != null) {
      _nameController.text = company.name;
      _logoController.text = company.logo ?? '';
      _phoneController.text = company.phone ?? '';
      _emailController.text = company.email ?? '';
      _dollarController.text = company.currency.dollar.toString();
      _euroController.text = company.currency.euro.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _logoController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _dollarController.dispose();
    _euroController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final company = Company(
        name: _nameController.text,
        logo: _logoController.text.isEmpty ? null : _logoController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        currency: Currency(
          // Virgülü noktaya çevir (double.tryParse virgülü kabul etmez)
          dollar:
              double.tryParse(_dollarController.text.replaceAll(',', '.')) ??
                  0.0,
          euro:
              double.tryParse(_euroController.text.replaceAll(',', '.')) ?? 0.0,
        ),
      );

      await ref.read(companyProvider.notifier).saveCompany(company);
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Şirket Ayarları'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CompanyFormFields(
                nameController: _nameController,
                logoController: _logoController,
                phoneController: _phoneController,
                emailController: _emailController,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dollarController,
                decoration: const InputDecoration(
                  labelText: 'Dolar Kuru (TL)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Dolar kuru zorunludur';
                  // Virgülü noktaya çevir (double.tryParse virgülü kabul etmez)
                  final normalizedValue = value.replaceAll(',', '.');
                  final number = double.tryParse(normalizedValue);
                  if (number == null) return 'Geçerli bir sayı giriniz';
                  if (number <= 0) return 'Kur sıfırdan büyük olmalıdır';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _euroController,
                decoration: const InputDecoration(
                  labelText: 'Euro Kuru (TL)',
                  border: OutlineInputBorder(),
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Euro kuru zorunludur';
                  // Virgülü noktaya çevir (double.tryParse virgülü kabul etmez)
                  final normalizedValue = value.replaceAll(',', '.');
                  final number = double.tryParse(normalizedValue);
                  if (number == null) return 'Geçerli bir sayı giriniz';
                  if (number <= 0) return 'Kur sıfırdan büyük olmalıdır';
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveSettings,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
