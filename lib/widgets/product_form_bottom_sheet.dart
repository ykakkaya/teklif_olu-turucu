import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class ProductFormBottomSheet extends ConsumerStatefulWidget {
  final Product? editProduct;
  final int? editIndex;

  const ProductFormBottomSheet({
    super.key,
    this.editProduct,
    this.editIndex,
  });

  @override
  ConsumerState<ProductFormBottomSheet> createState() =>
      _ProductFormBottomSheetState();
}

class _ProductFormBottomSheetState
    extends ConsumerState<ProductFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _vatRateController = TextEditingController();
  final _discountRateController = TextEditingController();
  String _selectedUnit = 'Adet';
  String _selectedCurrency = 'TL';

  @override
  void initState() {
    super.initState();
    if (widget.editProduct != null) {
      _nameController.text = widget.editProduct!.name;
      _unitPriceController.text = widget.editProduct!.unitPrice.toString();
      _quantityController.text = widget.editProduct!.quantity.toString();
      _vatRateController.text = widget.editProduct!.vatRate.toString();
      _discountRateController.text =
          widget.editProduct!.discountRate.toString();
      _selectedUnit = widget.editProduct!.unit;
      _selectedCurrency = widget.editProduct!.currency;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _unitPriceController.dispose();
    _quantityController.dispose();
    _vatRateController.dispose();
    _discountRateController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final product = Product(
        name: _nameController.text,
        unit: _selectedUnit,
        currency: _selectedCurrency,
        // Virgülü noktaya çevirerek parse et
        unitPrice: double.parse(_unitPriceController.text.replaceAll(',', '.')),
        quantity: double.parse(_quantityController.text.replaceAll(',', '.')),
        vatRate: int.parse(_vatRateController.text),
        discountRate: _discountRateController.text.isEmpty
            ? 0
            : double.parse(_discountRateController.text.replaceAll(',', '.')),
      );

      if (widget.editIndex != null) {
        ref
            .read(productsProvider.notifier)
            .updateProduct(widget.editIndex!, product);
      } else {
        ref.read(productsProvider.notifier).addProduct(product);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.editProduct != null ? 'Ürün Düzenle' : 'Yeni Ürün Ekle',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ürün Adı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ürün adı zorunludur' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      decoration: const InputDecoration(
                        labelText: 'Birim',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Adet', child: Text('Adet')),
                        DropdownMenuItem(value: 'Kg', child: Text('Kg')),
                        DropdownMenuItem(value: 'Metre', child: Text('Metre')),
                        DropdownMenuItem(
                            value: 'Metrekare', child: Text('Metrekare')),
                        DropdownMenuItem(value: 'Litre', child: Text('Litre')),
                      ],
                      onChanged: (value) {
                        if (value != null)
                          setState(() => _selectedUnit = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedCurrency,
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
                        if (value != null)
                          setState(() => _selectedCurrency = value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _unitPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Birim Fiyat',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d*'))
                      ],
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Birim fiyat zorunludur'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Miktar',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d*'))
                      ],
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Miktar zorunludur' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _vatRateController,
                      decoration: const InputDecoration(
                        labelText: 'KDV Oranı (%)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) => value?.isEmpty ?? true
                          ? 'KDV oranı zorunludur'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _discountRateController,
                      decoration: const InputDecoration(
                        labelText: 'İndirim Oranı (%)',
                        hintText: 'Opsiyonel',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*[,.]?\d*')),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('İptal'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                          widget.editProduct != null ? 'Güncelle' : 'Kaydet'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
