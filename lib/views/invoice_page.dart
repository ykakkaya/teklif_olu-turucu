import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teklif/providers/settings_provider.dart';
import 'package:teklif/services/pdf_service.dart';
import '../models/company.dart';
import '../models/client.dart';
import '../models/product.dart';

class InvoicePage extends ConsumerWidget {
  final Company company;
  final Client client;
  final List<Product> products;
  final String selectedCurrency;
  final double totalAmount;

  const InvoicePage({
    super.key,
    required this.company,
    required this.client,
    required this.products,
    required this.selectedCurrency,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teklif Önizleme',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.ios_share_sharp),
          //   onPressed: () => InvoiceShareService.shareInvoice(
          //     company: company,
          //     client: client,
          //     products: products,
          //     selectedCurrency: selectedCurrency,
          //     totalAmount: totalAmount,
          //   ),
          // ),
          IconButton(
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            ),
            onPressed: () async {
              final renderBox = context.findRenderObject() as RenderBox?;
              final sharePosition = renderBox != null
                  ? renderBox.localToGlobal(Offset.zero) & renderBox.size
                  : const Rect.fromLTWH(0, 0, 1, 1);

              await PdfService.sharePdf(
                company: company,
                client: client,
                products: products,
                selectedCurrency: selectedCurrency,
                totalAmount: totalAmount,
                settings: settings,
                sharePositionOrigin: sharePosition,
              );
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.print),
          //   onPressed: () {
          //     // TODO: Implement print functionality
          //   },
          // ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildHeader(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildClientInfo(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildProductsList(),
            const SizedBox(height: 24),
            _buildTotalSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (company.logo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Image.network(
                  company.logo!,
                  height: 60,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.business, size: 60),
                ),
              ),
            Text(
              company.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tarih: ${DateTime.now().toString().split(' ')[0]}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Müşteri Bilgileri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              client.name,
              style: const TextStyle(fontSize: 16),
            ),
            if (client.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                client.description,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ürünler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final product = products[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${product.quantity} ${product.unit}'),
                        Text(
                          '${product.unitPrice} ${product.currency}',
                        ),
                      ],
                    ),
                    if (product.discountRate > 0)
                      Text(
                        'İndirim: %${product.discountRate}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    Text('KDV: %${product.vatRate}'),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Toplam KDV DAHİL: ${product.total.toStringAsFixed(2)} ${product.currency}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Genel Toplam ',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${totalAmount.toStringAsFixed(2)} $selectedCurrency',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
