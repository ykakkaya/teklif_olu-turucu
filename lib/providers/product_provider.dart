import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';

final productsProvider = StateNotifierProvider<ProductsNotifier, List<Product>>((ref) {
  return ProductsNotifier();
});

class ProductsNotifier extends StateNotifier<List<Product>> {
  ProductsNotifier() : super([]);

  void addProduct(Product product) {
    state = [...state, product];
  }

  void removeProduct(int index) {
    state = [...state]..removeAt(index);
  }

  void updateProduct(int index, Product product) {
    final newList = [...state];
    newList[index] = product;
    state = newList;
  }
}
