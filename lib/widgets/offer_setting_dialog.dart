import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/offer_settings.dart';
import '../providers/settings_provider.dart';

class OfferSettingsDialog extends ConsumerStatefulWidget {
  const OfferSettingsDialog({super.key});

  @override
  ConsumerState<OfferSettingsDialog> createState() => _OfferSettingsDialogState();
}

class _OfferSettingsDialogState extends ConsumerState<OfferSettingsDialog> {
  late TextEditingController _termsController;
  late TextEditingController _bankInfoController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _termsController = TextEditingController(text: settings.terms);
    _bankInfoController = TextEditingController(text: settings.bankInfo);
  }

  @override
  void dispose() {
    _termsController.dispose();
    _bankInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Şartlar ve Banka Bilgileri'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final settings = OfferSettings(
                terms: _termsController.text,
                bankInfo: _bankInfoController.text,
              );
              ref.read(settingsProvider.notifier).saveSettings(settings);
              Navigator.of(context).pop();
            },
            child: const Text(
              'Kaydet',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Şartlar ve Koşullar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _termsController,
              decoration: const InputDecoration(
                hintText: 'Şartlar ve koşulları buraya yazın...',
                border: OutlineInputBorder(),
              ),
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            const Text(
              'Banka Bilgileri',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bankInfoController,
              decoration: const InputDecoration(
                hintText: 'Banka bilgilerini buraya yazın...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }
}
