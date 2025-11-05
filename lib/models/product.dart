class Product {
  final String name;
  final String unit;
  final String currency; // Added currency field
  final double unitPrice;
  final double quantity;
  final int vatRate;
  final double discountRate;
  // Base calculations
  double get subtotal => unitPrice * quantity;

  // VAT calculations
  double get vatAmount => subtotal * (vatRate / 100);
  double get withVat => subtotal + vatAmount;

  // Discount calculations - Now applied after VAT
  double get discountAmount => withVat * (discountRate / 100);

  // Final total - Now correctly ordered: (subtotal + VAT) - discount
  double get total => withVat - discountAmount;
  Product({
    required this.name,
    required this.unit,
    required this.currency, // Added to constructor
    required this.unitPrice,
    required this.quantity,
    required this.vatRate,
    this.discountRate = 0,
  });

  Product copyWith({
    String? name,
    String? unit,
    String? currency, // Added to copyWith
    double? unitPrice,
    double? quantity,
    int? vatRate,
    double? discountRate,
  }) {
    return Product(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      currency: currency ?? this.currency,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      vatRate: vatRate ?? this.vatRate,
      discountRate: discountRate ?? this.discountRate,
    );
  }
}
