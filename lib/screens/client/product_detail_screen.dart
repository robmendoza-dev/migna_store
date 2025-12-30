import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/product_model.dart';
import '../../widgets/cart_badge.dart';
import '../admin/add_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.productId
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

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
      await FirebaseFirestore.instance.collection('products').doc(widget.productId).delete();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Producto eliminado")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = FirebaseAuth.instance.currentUser != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detalles"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          const CartBadge(),
          if (isAdmin) ...[
            IconButton(
              tooltip: "Editar Producto",
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddProductScreen(productToEdit: widget.product, docId: widget.productId))
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
            height: 280,
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
            child: Hero(
              tag: widget.product.name,
              child: Image.network(
                widget.product.imagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
              ),
            ),
          ),

          // 2. PANEL DE DETALLES
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                  color: Colors.grey[50], // Fondo gris suave
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECCIÓN SUPERIOR: TÍTULO Y PRECIO ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                            widget.product.name,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3E50))
                        ),
                      ),
                      const SizedBox(width: 15), // Espacio entre nombre y precio
                      Text(
                          widget.product.price,
                          style: const TextStyle(fontSize: 24, color: Colors.indigo, fontWeight: FontWeight.w900)
                      ),
                    ],
                  ),

                  if (widget.product.isOffer)
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(5)),
                      child: const Text("OFERTA ESPECIAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),

                  // --- 1. DIVISOR VISUAL PARA DIFERENCIAR CAMPOS ---
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(thickness: 1, color: Colors.black12),
                  ),

                  // --- SECCIÓN INFERIOR: DESCRIPCIÓN ---
                  const Text("Descripción", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        widget.product.description.isEmpty ? "Sin descripción detallada." : widget.product.description,
                        style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- CONTROLES DE COMPRA ---
                  Row(
                    children: [
                      // Selector de Cantidad (Ahora con fondo blanco para diferenciarse)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Fondo blanco para resaltar
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))
                          ],
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, color: Colors.indigo),
                              onPressed: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
                              },
                            ),
                            Text(
                              "$_quantity",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.indigo),
                              onPressed: () {
                                setState(() => _quantity++);
                              },
                            ),
                          ],
                        ),
                      ),

                      // --- 2. ESPACIO AUMENTADO ---
                      const SizedBox(width: 25), // Antes era 15, ahora 25

                      // Botón "Agregar"
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE91E63),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            ),
                            onPressed: () {
                              addToCart(widget.product, quantity: _quantity);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("¡$_quantity x ${widget.product.name} agregados!"),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                              setState(() => _quantity = 1);
                            },
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text("AGREGAR", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
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