import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../screens/client/product_detail_screen.dart';
import '../screens/admin/add_product_screen.dart'; // Para poder editar

class ProductCard extends StatelessWidget {
  final Product product;
  // Necesitamos el ID del documento para poder borrarlo/editarlo de Firebase
  final String productId;

  const ProductCard({
    super.key,
    required this.product,
    required this.productId // <--- Nuevo parámetro obligatorio
  });

  // Función para borrar
  Future<void> _deleteProduct(BuildContext context) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Borrar producto?"),
        content: const Text("Esta acción no se puede deshacer."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancelar")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Borrar", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Producto eliminado")));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Verificamos si hay usuario logueado (Admin)
    final bool isAdmin = FirebaseAuth.instance.currentUser != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. IMAGEN Y BOTONES ADMIN (Stack)
          Expanded( // Usamos Expanded para que la imagen ocupe el espacio disponible
            child: Stack(
              children: [
                // La Imagen clicable
                Positioned.fill(
                  child: InkWell(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product))),
                    child: Hero(
                      tag: product.name,
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(product.imagePath), // Asumimos que ya todo viene de Cloudinary
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // SI ES ADMIN: Mostramos botones de Editar/Borrar arriba a la derecha
                if (isAdmin)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Row(
                      children: [
                        // Botón Editar
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 14,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 14, color: Colors.blue),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              // Navegamos a la pantalla de agregar, pero enviando el producto para editar
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddProductScreen(productToEdit: product, docId: productId))
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 5),
                        // Botón Borrar
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 14,
                          child: IconButton(
                            icon: const Icon(Icons.delete, size: 14, color: Colors.red),
                            padding: EdgeInsets.zero,
                            onPressed: () => _deleteProduct(context),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          // 2. INFO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Text(
                  product.name.toUpperCase(),
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  product.price,
                  style: const TextStyle(color: Color(0xFF2D3E50), fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 3. BOTÓN AÑADIR (Solo visible si NO eres admin, o para todos si prefieres)
          Container(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 30),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              ),
              onPressed: () {
                globalCart.add(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${product.name} añadido"), duration: const Duration(seconds: 1)),
                );
              },
              child: const Text("AÑADIR", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}