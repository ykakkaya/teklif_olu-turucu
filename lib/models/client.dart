class Client {
  final String name;
  final String description;
  final String selectedCurrency;

  Client({
    required this.name,
    required this.description,
    required this.selectedCurrency,
  });

  Client copyWith({
    String? name,
    String? description,
    String? selectedCurrency,
  }) {
    return Client(
      name: name ?? this.name,
      description: description ?? this.description,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'selectedCurrency': selectedCurrency,
    };
  }

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      selectedCurrency: json['selectedCurrency'] ?? 'TL',
    );
  }
}