import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../models/company.dart';
import '../models/currency.dart';

final companyProvider = StateNotifierProvider<CompanyNotifier, Company?>((ref) {
  return CompanyNotifier();
});

class CompanyNotifier extends StateNotifier<Company?> {
  CompanyNotifier() : super(null) {
    _loadCompany();
  }

  final _storage = GetStorage();
  static const _key = 'company_data';

  void _loadCompany() {
    final data = _storage.read(_key);
    if (data != null) {
      state = Company.fromJson(Map<String, dynamic>.from(data));
    }
  }

  Future<void> saveCompany(Company company) async {
    await _storage.write(_key, company.toJson());
    state = company;
  }

  Future<void> updateCurrency(Currency currency) async {
    if (state != null) {
      final updatedCompany = state!.copyWith(currency: currency);
      await saveCompany(updatedCompany);
    }
  }

  Future<void> clearCompany() async {
    await _storage.remove(_key);
    state = null;
  }
}