class OfferSettings {
  final String terms;
  final String bankInfo;

  OfferSettings({
    this.terms = defaultTerms,
    this.bankInfo = '',
  });

  static const String defaultTerms = '''Teklif Geçerlilik Süresi
Bu teklif, sunulduğu tarihten itibaren 15 gün boyunca geçerlidir. Süre sonunda fiyat ve koşullar değişebilir.

Fiyatlandırma ve Ödeme
Belirtilen fiyatlara KDV dahildir.
Ödeme, sipariş onayı ile birlikte %50 oranında peşin, kalan tutar teslimatta veya belirlenen ödeme planına göre tahsil edilecektir.''';

  Map<String, dynamic> toJson() => {
        'terms': terms,
        'bankInfo': bankInfo,
      };

  factory OfferSettings.fromJson(Map<String, dynamic> json) => OfferSettings(
        terms: json['terms'] ?? defaultTerms,
        bankInfo: json['bankInfo'] ?? '',
      );
}
