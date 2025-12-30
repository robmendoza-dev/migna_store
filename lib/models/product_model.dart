import 'package:flutter/foundation.dart';

class Product {
  final String name;
  final String price;
  final String imagePath;
  final String description;
  final bool isOffer;

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    this.isOffer = false,
  });

  double get priceValue {
    try {
      String cleanPrice = price.replaceAll('S/ ', '').trim();
      return double.parse(cleanPrice);
    } catch (e) {
      return 0.0;
    }
  }
}

// --- NUEVA CLASE PARA AGRUPAR CANTIDADES ---
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

// --- LÓGICA DEL CARRITO ACTUALIZADA ---

// Ahora es una lista de CartItem, no de Product
List<CartItem> globalCart = [];

final ValueNotifier<int> cartCountNotifier = ValueNotifier(0);

// Función INTELIGENTE para agregar (ahora acepta cantidad)
void addToCart(Product product, {int quantity = 1}) {
  // 1. Buscamos si el producto ya existe
  try {
    CartItem existingItem = globalCart.firstWhere((item) => item.product.name == product.name);
    // 2. Si existe, sumamos la cantidad que nos piden (no solo 1)
    existingItem.quantity += quantity;
  } catch (e) {
    // 3. Si no existe, lo creamos con esa cantidad
    globalCart.add(CartItem(product: product, quantity: quantity));
  }

  _updateCount();
}

// Función para restar cantidad o borrar
void removeOneItem(int index) {
  if (globalCart[index].quantity > 1) {
    globalCart[index].quantity--; // Si hay varios, restamos uno
  } else {
    globalCart.removeAt(index); // Si queda 1, lo borramos de la lista
  }
  _updateCount();
}

// Función para borrar el producto entero (sin importar la cantidad)
void deleteProductCompletely(int index) {
  globalCart.removeAt(index);
  _updateCount();
}

// Función auxiliar para contar el total de items (ej: 2 zapateros + 1 escoba = 3 items)
void _updateCount() {
  int totalCount = 0;
  for (var item in globalCart) {
    totalCount += item.quantity;
  }
  cartCountNotifier.value = totalCount;
}