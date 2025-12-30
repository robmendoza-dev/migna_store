// lib/models/product_model.dart
class Product {
  final String name;
  final String price;
  final String imagePath;
  final String description;

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
  });

  // Ayuda a convertir "S/ 12.50" en el número 12.50 para sumar
  double get priceValue {
    return double.tryParse(price.replaceAll('S/ ', '').trim()) ?? 0.0;
  }
}

// --- MEMORIA TEMPORAL DEL CARRITO ---
// Al ponerlo aquí, cualquier archivo puede importar 'product_model.dart' y usar esta lista.
List<Product> globalCart = [];