import 'package:flutter/material.dart';
import '../../models/product_model.dart'; // Importante: ruta para salir y buscar el modelo

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Hero(
              tag: product.name,
              child: Image.network( // Cambié a network/asset dinámico según tu lógica
                product.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(product.imagePath, errorBuilder: (c,e,s) => const Icon(Icons.error)),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      Text(product.price, style: const TextStyle(fontSize: 22, color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Descripción", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(product.description, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const Spacer(),

                  // BOTÓN DE AGREGAR AL CARRITO
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () {
                        // Usamos la lista global
                        globalCart.add(product);

                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("¡${product.name} agregado al carrito!"),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("AGREGAR AL CARRITO"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}