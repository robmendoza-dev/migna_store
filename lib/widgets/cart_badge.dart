import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../screens/client/cart_screen.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: cartCountNotifier, // Escucha cambios en el conteo
      builder: (context, count, child) {
        return IconButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen()));
          },
          icon: Badge(
            isLabelVisible: count > 0, // Solo muestra el puntito rojo si hay items
            label: Text(count.toString()),
            backgroundColor: const Color(0xFFE91E63), // Color rosado de tu marca
            child: const Icon(Icons.shopping_cart_outlined),
          ),
        );
      },
    );
  }
}