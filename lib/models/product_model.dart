class Product {
  final String name;
  final String price;
  final String imagePath;
  final String description;
  final bool isOffer; // <--- NUEVO CAMPO

  Product({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
    this.isOffer = false, // <--- Por defecto no es oferta
  });

  double get priceValue {
    return double.tryParse(price.replaceAll('S/ ', '').trim()) ?? 0.0;
  }
}

// Lista global del carrito
List<Product> globalCart = [];