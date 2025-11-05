import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/client.dart';

final clientProvider = StateNotifierProvider<ClientNotifier, Client>((ref) {
  return ClientNotifier();
});

class ClientNotifier extends StateNotifier<Client> {
  ClientNotifier()
      : super(Client(
          name: '',
          description: '',
          selectedCurrency: 'TL',
        ));

  void updateClient(Client client) {
    state = client;
  }

  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
  }

  void updateCurrency(String currency) {
    state = state.copyWith(selectedCurrency: currency);
  }
}