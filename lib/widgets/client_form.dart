import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teklif/widgets/offer_setting_dialog.dart';
import 'package:teklif/widgets/product_form_bottom_sheet.dart';
import 'package:teklif/widgets/product_list.dart';
import '../providers/client_provider.dart';

class ClientForm extends ConsumerWidget {
  const ClientForm({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final client = ref.watch(clientProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: client.name,
            decoration: const InputDecoration(
              labelText: 'Teklif Verilen Firma',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => ref.read(clientProvider.notifier).updateName(value),
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: client.description,
            decoration: const InputDecoration(
              labelText: 'Açıklama',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
            onChanged: (value) => ref.read(clientProvider.notifier).updateDescription(value),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: client.selectedCurrency,
            decoration: const InputDecoration(
              labelText: 'Para Birimi',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'TL', child: Text('TL')),
              DropdownMenuItem(value: 'USD', child: Text('USD')),
              DropdownMenuItem(value: 'EUR', child: Text('EUR')),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(clientProvider.notifier).updateCurrency(value);
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => const OfferSettingsDialog(),
              );
            },
            icon: const Icon(Icons.settings),
            label: const Text('Şartlar ve Banka Bilgileri'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const ProductFormBottomSheet(),
              );
            },
            label: Icon(Icons.add_circle_outline),
            icon: Text(
              'Ürün Ekle',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, iconColor: Colors.white),
          ),
          const SizedBox(height: 24),
          const ProductList(), // Add this line
        ],
      ),
    );
  }
}
