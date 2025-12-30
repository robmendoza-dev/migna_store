import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Asegúrate de tener url_launcher en pubspec.yaml
import '../../models/product_model.dart'; // Importante para acceder a globalCart

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  // Calcula el total
  double get total {
    double sum = 0;
    for (var item in globalCart) { // Usamos globalCart
      sum += item.priceValue;
    }
    return sum;
  }

  // --- LÓGICA DE WHATSAPP ---
  Future<void> _sendOrderToWhatsApp() async {
    const String phoneNumber = "51946227753"; // TU NÚMERO
    String message = "¡Hola Migna Store! 🛒\nQuisiera realizar este pedido:\n\n";

    for (var product in globalCart) {
      message += "• ${product.name} (${product.price})\n";
    }

    message += "\n*Total a Pagar: S/ ${total.toStringAsFixed(2)}*";
    message += "\n\nQuedo atento a la confirmación de entrega.";

    final Uri whatsappUrl = Uri.parse("https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    try {
      if (!await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication)) {
        throw 'No se pudo abrir WhatsApp';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al abrir WhatsApp: $e"), backgroundColor: Colors.red),
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
            child: ListView.builder(
              itemCount: globalCart.length,
              itemBuilder: (context, index) {
                final item = globalCart[index];
                return ListTile(
                  // Usamos una lógica simple para la imagen en miniatura
                  leading: SizedBox(
                    width: 50,
                    height: 50,
                    child: item.imagePath.startsWith('http')
                        ? Image.network(item.imagePath, fit: BoxFit.cover)
                        : Image.asset(item.imagePath, fit: BoxFit.cover),
                  ),
                  title: Text(item.name),
                  subtitle: Text(item.price),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        globalCart.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
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