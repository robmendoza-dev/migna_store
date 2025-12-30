import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../admin/add_product_screen.dart'; // Necesario para editar

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  final String productId; // <--- NUEVO DATO NECESARIO

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.productId
  });

  // Función para borrar
  Future<void> _deleteProduct(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Borrar producto?"),
        content: const Text("Esta acción eliminará el producto de la tienda."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Borrar", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      if (context.mounted) {
        Navigator.pop(context); // Salimos del detalle
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Producto eliminado")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificamos si es Admin
    final bool isAdmin = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detalles"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // SI ES ADMIN, MOSTRAMOS LAS OPCIONES AQUÍ
          if (isAdmin) ...[
            IconButton(
              tooltip: "Editar Producto",
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Vamos a editar. Al volver (then), salimos del detalle para refrescar la home
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductScreen(productToEdit: product, docId: productId))
                ).then((_) => Navigator.pop(context));
              },
            ),
            IconButton(
              tooltip: "Borrar Producto",
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteProduct(context),
            ),
          ]
        ],
      ),
      body: Column(
        children: [
          // 1. IMAGEN GRANDE
          Container(
            height: 300,
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Hero(
              tag: product.name,
              child: Image.network(
                product.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
              ),
            ),
          ),

          // 2. DETALLES (Borde redondeado hacia arriba)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: Colors.grey[50], // Fondo muy sutil
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y Precio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                            product.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3E50))
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                          product.price,
                          style: const TextStyle(fontSize: 24, color: Colors.indigo, fontWeight: FontWeight.w900)
                      ),
                    ],
                  ),

                  // Etiqueta de oferta si existe
                  if (product.isOffer)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(5)),
                      child: const Text("OFERTA ESPECIAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),

                  const SizedBox(height: 25),
                  const Text("Descripción", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        product.description.isEmpty ? "Sin descripción detallada." : product.description,
                        style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
                      ),
                    ),
                  ),

                  // BOTÓN DE AGREGAR AL CARRITO
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91E63),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: () {
                        globalCart.add(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("¡${product.name} agregado al carrito!"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text("AGREGAR AL CARRITO", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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