import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/product_model.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  // Calcula el total multiplicando PRECIO x CANTIDAD
  double get total {
    double sum = 0;
    for (var item in globalCart) {
      sum += (item.product.priceValue * item.quantity);
    }
    return sum;
  }

  Future<void> _sendOrderToWhatsApp() async {
    const String phoneNumber = "51946227753";
    String message = "¡Hola Migna Store! 🛒\nQuisiera realizar este pedido:\n\n";

    for (var item in globalCart) {
      // Ahora el mensaje dice: "3x Nombre del producto"
      message += "• ${item.quantity}x ${item.product.name} - S/ ${(item.product.priceValue * item.quantity).toStringAsFixed(2)}\n";
    }

    message += "\n*Total a Pagar: S/ ${total.toStringAsFixed(2)}*";
    message += "\n\nQuedo atento a la confirmación.";

    final Uri whatsappUrl = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    try {
      if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
        throw 'No se pudo abrir WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mi Carrito")),
      body: globalCart.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text("Tu carrito está vacío", style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(15),
              itemCount: globalCart.length,
              separatorBuilder: (c, i) => const Divider(),
              itemBuilder: (context, index) {
                final item = globalCart[index];
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]
                  ),
                  child: Row(
                    children: [
                      // 1. IMAGEN PEQUEÑA
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: Image.network(
                            item.product.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 30, color: Colors.grey)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // 2. NOMBRE Y PRECIO UNITARIO
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(item.product.price, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),

                      // 3. CONTROLES DE CANTIDAD (- 1 +)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                removeOneItem(index);
                              });
                            },
                          ),
                          Text(
                              "${item.quantity}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                            onPressed: () {
                              setState(() {
                                addToCart(item.product); // Reutilizamos la función sumar
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // PANEL INFERIOR DE TOTAL
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))]
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total a Pagar:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("S/ ${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo)),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: _sendOrderToWhatsApp,
                    icon: const Icon(Icons.send),
                    label: const Text("PEDIR POR WHATSAPP", style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}