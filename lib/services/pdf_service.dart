import 'dart:io';
import 'dart:ui';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:teklif/models/offer_settings.dart';
import '../models/company.dart';
import '../models/client.dart';
import '../models/product.dart';

class PdfService {
  static Future<File> generateInvoicePdf({
    required Company company,
    required Client client,
    required List<Product> products,
    required String selectedCurrency,
    required double totalAmount,
    required OfferSettings settings,
  }) async {
    final pdf = pw.Document();
    final font = await _loadFont();
    final logo = await _loadLogo(company.logo);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: font,
        ),
        build: (context) => [
          _buildHeaderSection(company, client, logo),
          pw.SizedBox(height: 30),
          _buildProductsTable(products),
          pw.SizedBox(height: 20),
          _buildTotalSection(totalAmount, selectedCurrency),
          pw.SizedBox(height: 20),
          if (settings.terms.isNotEmpty || settings.bankInfo.isNotEmpty)
            _buildTermsAndBankInfo(settings),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/teklif.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<pw.Font> _loadFont() async {
    try {
      final fontData =
          await rootBundle.load('assets/fonts/OpenSans-Regular.ttf');
      return pw.Font.ttf(fontData);
    } catch (e) {
      print('Font yüklenemedi: $e');
      return pw.Font.helvetica();
    }
  }

  static Future<pw.Image?> _loadLogo(String? logoPath) async {
    if (logoPath == null || logoPath.isEmpty) return null;
    try {
      final file = File(logoPath);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        return pw.Image(pw.MemoryImage(bytes),
            height: 60, fit: pw.BoxFit.contain);
      }
    } catch (e) {
      print('Logo yüklenemedi: $e');
    }
    return null;
  }

  static pw.Widget _buildHeaderSection(
      Company company, Client client, pw.Image? logo) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Company Info
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null) ...[
                logo,
                pw.SizedBox(height: 10),
              ],
              pw.Text(
                company.name,
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              if (company.phone != null) ...[
                pw.SizedBox(height: 4),
                pw.Text('Tel: ${company.phone}'),
              ],
              if (company.email != null) ...[
                pw.SizedBox(height: 4),
                pw.Text('E-posta: ${company.email}'),
              ],
              pw.SizedBox(height: 8),
              pw.Text(
                'Tarih: ${DateTime.now().toString().split(' ')[0]}',
              ),
            ],
          ),
        ),
        pw.SizedBox(width: 40),
        // Client Info
        pw.Expanded(
          child: pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(5),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Müşteri Bilgileri',
                  style: pw.TextStyle(
                      fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 8),
                pw.Text(client.name),
                if (client.description.isNotEmpty) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    client.description,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildProductsTable(List<Product> products) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey500),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(1),
        5: const pw.FlexColumnWidth(1),
        6: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.grey300),
          children: [
            _buildTableHeader('Ürün'),
            _buildTableHeader('Miktar'),
            _buildTableHeader('Birim'),
            _buildTableHeader('Birim Fiyat'),
            _buildTableHeader('KDV'),
            _buildTableHeader('İndirim'),
            _buildTableHeader('Toplam', align: pw.TextAlign.right),
          ],
        ),
        ...products.map((product) => pw.TableRow(
              children: [
                _buildTableCell(product.name),
                _buildTableCell('${product.quantity}'),
                _buildTableCell(product.unit),
                _buildTableCell('${product.unitPrice}'),
                _buildTableCell('%${product.vatRate}'),
                _buildTableCell(product.discountRate > 0
                    ? '%${product.discountRate}'
                    : '-'),
                _buildTableCell(
                  '${product.total.toStringAsFixed(2)} ${product.currency}',
                  align: pw.TextAlign.right,
                  bold: true,
                ),
              ],
            )),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text,
      {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold, color: PdfColors.black),
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text,
      {pw.TextAlign align = pw.TextAlign.left, bool bold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: bold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
        textAlign: align,
      ),
    );
  }

  static pw.Widget _buildTotalSection(
      double totalAmount, String selectedCurrency) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        borderRadius: pw.BorderRadius.circular(5),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              'Genel Toplam',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              '${totalAmount.toStringAsFixed(2)} $selectedCurrency',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.red,
              ),
              textAlign: pw.TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTermsAndBankInfo(OfferSettings settings) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (settings.terms.isNotEmpty) ...[
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Şartlar ve Koşullar',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(settings.terms),
                ],
              ),
            ),
          ],
          if (settings.bankInfo.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Banka Bilgileri',
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(settings.bankInfo),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Future<void> sharePdf({
    required Company company,
    required Client client,
    required List<Product> products,
    required String selectedCurrency,
    required double totalAmount,
    required OfferSettings settings,
    Rect? sharePositionOrigin,
  }) async {
    final file = await generateInvoicePdf(
      company: company,
      client: client,
      products: products,
      selectedCurrency: selectedCurrency,
      totalAmount: totalAmount,
      settings: settings,
    );

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: '${company.name} - ${client.name} Teklif',
      sharePositionOrigin:
          sharePositionOrigin ?? const Rect.fromLTWH(0, 0, 1, 1),
    );
  }
}
