// lib/screens/client/home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Importante para seguridad
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../admin/add_product_screen.dart';
import '../login_screen.dart'; // Para ir al login
import 'cart_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Migna Store", style: TextStyle(color: Color(0xFF2D3E50), fontWeight: FontWeight.bold)),
        actions: [
          // Botón Carrito
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF2D3E50)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
          ),

          // Botón Login / Logout (Dinámico)
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Si está logueado, mostramos icono de Salir
                return IconButton(
                  icon: const Icon(Icons.logout, color: Colors.grey),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                );
              }
              // Si NO está logueado, mostramos icono de persona para ir a Login
              return IconButton(
                icon: const Icon(Icons.person, color: Colors.grey),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen())),
              );
            },
          )
        ],
      ),

      // BOTÓN FLOTANTE (Solo aparece si eres Admin/Logueado)
      floatingActionButton: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton(
              backgroundColor: const Color(0xFFE91E63),
              child: const Icon(Icons.add),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductScreen())),
            );
          }
          return Container(); // Si no es admin, no mostramos nada
        },
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('products').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No hay productos."));

          final docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.70,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              Product productFromCloud = Product(
                name: data['name'] ?? 'Sin Nombre',
                price: data['price'] ?? 'S/ 0.00',
                imagePath: data['imagePath'] ?? '',
                description: data['description'] ?? '',
              );
              return ProductCard(
                  product: productFromCloud,
                  productId: docs[index].id);
            },
          );
        },
      ),
    );
  }
}