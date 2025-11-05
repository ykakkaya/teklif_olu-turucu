import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/company.dart';
import '../models/client.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/client_provider.dart';
import '../providers/company_provider.dart';
import '../views/invoice_page.dart';
import 'product_form_bottom_sheet.dart';

class ProductList extends ConsumerWidget {
  const ProductList({super.key});

  double convertCurrency(double amount, String fromCurrency, String toCurrency, WidgetRef ref) {
    final company = ref.watch(companyProvider);
    if (company == null) return amount;
    if (fromCurrency == toCurrency) return amount;

    // First convert to TL if needed
    double amountInTL = amount;
    if (fromCurrency == 'USD') {
      amountInTL = amount * company.currency.dollar;
    } else if (fromCurrency == 'EUR') {
      amountInTL = amount * company.currency.euro;
    }

    // Then convert TL to target currency if needed
    if (toCurrency == 'TL') {
      return amountInTL;
    } else if (toCurrency == 'USD') {
      return amountInTL / company.currency.dollar;
    } else if (toCurrency == 'EUR') {
      return amountInTL / company.currency.euro;
    }

    return amountInTL;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(productsProvider);
    final selectedCurrency = ref.watch(clientProvider).selectedCurrency;

    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Henüz ürün eklenmemiş'),
        ),
      );
    }

    final grandTotal = products.fold<Map<String, double>>({
      'TL': 0,
      'USD': 0,
      'EUR': 0,
    }, (totals, product) {
      totals[product.currency] = (totals[product.currency] ?? 0) + product.total;
      return totals;
    });

    return Column(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(context, product, index, ref);
          },
        ),
        const SizedBox(height: 16),
        _buildTotalCard(context, grandTotal, selectedCurrency, ref),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, int index, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(context, product, index, ref),
            const Divider(),
            _buildCalculationRow('Birim:', '${product.quantity} ${product.unit}'),
            _buildCalculationRow('Birim Fiyat:', '${product.unitPrice} ${product.currency}'),
            _buildCalculationRow(
              'Ara Toplam:',
              '${product.subtotal.toStringAsFixed(2)} ${product.currency}',
            ),
            if (product.discountRate > 0)
              _buildCalculationRow(
                'İndirim (${product.discountRate}%):',
                '-${product.discountAmount.toStringAsFixed(2)} ${product.currency}',
                color: Colors.red,
              ),
            _buildCalculationRow(
              'KDV (${product.vatRate}%):',
              '${product.vatAmount.toStringAsFixed(2)} ${product.currency}',
            ),
            const Divider(),
            _buildCalculationRow(
              'Toplam:',
              '${product.total.toStringAsFixed(2)} ${product.currency}',
              isBold: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context, Product product, int index, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            product.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editProduct(context, product, index, ref),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => ref.read(productsProvider.notifier).removeProduct(index),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalCard(BuildContext context, Map<String, double> grandTotal, String selectedCurrency, WidgetRef ref) {
    final convertedTotal = grandTotal.entries.fold<double>(
      0,
      (sum, entry) => sum + convertCurrency(entry.value, entry.key, selectedCurrency, ref),
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Genel Toplam',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${convertedTotal.toStringAsFixed(2)} $selectedCurrency',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const Divider(),
            ...grandTotal.entries.where((entry) => entry.value > 0).map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${entry.value.toStringAsFixed(2)} ${entry.key}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _createInvoice(context, ref),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Teklif Oluştur',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, {Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _editProduct(BuildContext context, Product product, int index, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ProductFormBottomSheet(
        editProduct: product,
        editIndex: index,
      ),
    );
  }

  void _createInvoice(BuildContext context, WidgetRef ref) {
    final company = ref.read(companyProvider);
    final client = ref.read(clientProvider);
    final products = ref.read(productsProvider);

    if (company == null) {
      _showError(context, 'Lütfen firma bilgilerini ayarlardan giriniz.');
      return;
    }

    if (client.name.isEmpty) {
      _showError(context, 'Lütfen müşteri firma adını giriniz.');
      return;
    }

    if (products.isEmpty) {
      _showError(context, 'Lütfen en az bir ürün ekleyiniz.');
      return;
    }

    final selectedCurrency = client.selectedCurrency;
    final grandTotal = products.fold<Map<String, double>>({
      'TL': 0,
      'USD': 0,
      'EUR': 0,
    }, (totals, product) {
      totals[product.currency] = (totals[product.currency] ?? 0) + product.total;
      return totals;
    });

    final convertedTotal = grandTotal.entries.fold<double>(
      0,
      (sum, entry) => sum + convertCurrency(entry.value, entry.key, selectedCurrency, ref),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InvoicePage(
          company: company,
          client: client,
          products: products,
          selectedCurrency: selectedCurrency,
          totalAmount: convertedTotal,
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
