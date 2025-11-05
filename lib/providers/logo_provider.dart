import 'package:flutter_riverpod/flutter_riverpod.dart';

final logoProvider = StateNotifierProvider<LogoNotifier, String?>((ref) {
  return LogoNotifier();
});

class LogoNotifier extends StateNotifier<String?> {
  LogoNotifier() : super(null);

  void setLogo(String? path) {
    state = path;
  }

  void removeLogo() {
    state = null;
  }
}