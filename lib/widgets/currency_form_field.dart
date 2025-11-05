import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyFormFields extends StatelessWidget {
  final TextEditingController dollarController;
  final TextEditingController euroController;

  const CurrencyFormFields({
    super.key,
    required this.dollarController,
    required this.euroController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: dollarController,
          decoration: const InputDecoration(
            labelText: 'Dolar Kuru',
            prefixText: '\$ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Dolar kuru zorunludur';
            }
            final normalized = value.replaceAll(',', '.');
            if (double.tryParse(normalized) == null) {
              return 'Geçerli bir sayı giriniz';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: euroController,
          decoration: const InputDecoration(
            labelText: 'Euro Kuru',
            prefixText: '€ ',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*[,.]?\d*')),
          ],
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Euro kuru zorunludur';
            }
            final normalized = value.replaceAll(',', '.');
            if (double.tryParse(normalized) == null) {
              return 'Geçerli bir sayı giriniz';
            }
            return null;
          },
        ),
      ],
    );
  }
}
