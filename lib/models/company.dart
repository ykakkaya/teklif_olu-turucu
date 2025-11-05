import 'package:get_storage/get_storage.dart';
import 'package:teklif/models/currency.dart';

class Company {
  final String name;
  final String? logo;
  final String? phone;
  final String? email;
  final Currency currency;

  Company({
    required this.name,
    this.logo,
    this.phone,
    this.email,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'logo': logo,
        'phone': phone,
        'email': email,
        'currency': currency.toJson(),
      };

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        name: json['name'] ?? '',
        logo: json['logo'],
        phone: json['phone'],
        email: json['email'],
        currency: Currency.fromJson(json['currency'] ?? {}),
      );

  Company copyWith({
    String? name,
    String? logo,
    String? phone,
    String? email,
    Currency? currency,
  }) {
    return Company(
      name: name ?? this.name,
      logo: logo ?? this.logo,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      currency: currency ?? this.currency,
    );
  }

  static Future<void> saveToStorage(Company? company) async {
    final box = GetStorage();
    if (company != null) {
      await box.write('company', company.toJson());
    } else {
      await box.remove('company');
    }
  }

  static Company? loadFromStorage() {
    final box = GetStorage();
    final data = box.read('company');
    if (data != null) {
      return Company.fromJson(data);
    }
    return null;
  }
}