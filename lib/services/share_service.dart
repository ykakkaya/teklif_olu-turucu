import 'package:share_plus/share_plus.dart';
import '../models/company.dart';
import '../models/client.dart';
import '../models/product.dart';

class InvoiceShareService {
  static String generateShareText({
    required Company company,
    required Client client,
    required List<Product> products,
    required String selectedCurrency,
    required double totalAmount,
  }) {
    final StringBuffer buffer = StringBuffer();
    
    // Company info
    buffer.writeln('Teklif Veren: ${company.name}');
    buffer.writeln('Tarih: ${DateTime.now().toString().split(' ')[0]}');
    buffer.writeln('');
    
    // Client info
    buffer.writeln('Müşteri: ${client.name}');
    if (client.description.isNotEmpty) {
      buffer.writeln('Açıklama: ${client.description}');
    }
    buffer.writeln('');
    
    // Products
    buffer.writeln('ÜRÜNLER');
    buffer.writeln('--------');
    for (final product in products) {
      buffer.writeln(product.name);
      buffer.writeln('Miktar: ${product.quantity} ${product.unit}');
      buffer.writeln('Birim Fiyat: ${product.unitPrice} ${product.currency}');
      if (product.discountRate > 0) {
        buffer.writeln('İndirim: %${product.discountRate}');
      }
      buffer.writeln('KDV: %${product.vatRate}');
      buffer.writeln('Toplam: ${product.total.toStringAsFixed(2)} ${product.currency}');
      buffer.writeln('');
    }
    
    // Total
    buffer.writeln('GENEL TOPLAM');
    buffer.writeln('-----------');
    buffer.writeln('${totalAmount.toStringAsFixed(2)} $selectedCurrency');
    
    return buffer.toString();
  }

  static Future<void> shareInvoice({
    required Company company,
    required Client client,
    required List<Product> products,
    required String selectedCurrency,
    required double totalAmount,
  }) async {
    final String shareText = generateShareText(
      company: company,
      client: client,
      products: products,
      selectedCurrency: selectedCurrency,
      totalAmount: totalAmount,
    );

    await Share.share(
      shareText,
      subject: '${company.name} - ${client.name} Teklif',
    );
  }
}