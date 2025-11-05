class Currency {
  final double dollar;
  final double euro;

  Currency({
    required this.dollar,
    required this.euro,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      dollar: json['dollar'].toDouble(),
      euro: json['euro'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dollar': dollar,
      'euro': euro,
    };
  }

  Currency copyWith({
    double? dollar,
    double? euro,
  }) {
    return Currency(
      dollar: dollar ?? this.dollar,
      euro: euro ?? this.euro,
    );
  }
}