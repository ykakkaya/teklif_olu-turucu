import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'package:teklif/models/offer_settings.dart';


class SettingsNotifier extends StateNotifier<OfferSettings> {
  SettingsNotifier() : super(OfferSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = GetStorage();
    final data = box.read('offerSettings');
    if (data != null) {
      state = OfferSettings.fromJson(data);
    }
  }

  Future<void> saveSettings(OfferSettings settings) async {
    final box = GetStorage();
    await box.write('offerSettings', settings.toJson());
    state = settings;
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, OfferSettings>((ref) {
  return SettingsNotifier();
});