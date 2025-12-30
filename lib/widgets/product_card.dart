import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../screens/client/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String productId;

  const ProductCard({
    super.key,
    required this.product,
    required this.productId
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product, productId: productId))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. IMAGEN
              Expanded(
                flex: 55,
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      color: Colors.white,
                      child: Hero(
                        tag: product.name,
                        child: Image.network(
                          product.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                    if (product.isOffer)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: const BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "OFERTA",
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 2. INFORMACIÓN
              Expanded(
                flex: 45,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  color: const Color(0xFFFAFAFA),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.price,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.indigo),
                          ),
                        ],
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 35,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE91E63),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () {
                            // --- AQUÍ ESTABA EL PROBLEMA ---
                            // Antes tenías: globalCart.add(product);
                            // Ahora usamos la función que avisa al contador:
                            addToCart(product);

                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${product.name} añadido"), duration: const Duration(seconds: 1), backgroundColor: Colors.green));
                          },
                          child: const Text("AGREGAR", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}