import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/product_model.dart';
import '../../widgets/product_card.dart';
import '../admin/add_product_screen.dart';
import '../login_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Variable para guardar el texto de búsqueda
  String _searchText = "";

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String greeting = user != null ? "Hola, Admin 👋" : "Bienvenido a Migna 👋";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Migna Store"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CartScreen())),
          ),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return IconButton(
                  icon: const Icon(Icons.logout, color: Colors.grey),
                  onPressed: () => FirebaseAuth.instance.signOut(),
                );
              }
              return IconButton(
                icon: const Icon(Icons.person, color: Colors.grey),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
              );
            },
          )
        ],
      ),

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
          return Container();
        },
      ),

      body: Column(
        children: [
          // 1. BANNER + BUSCADOR
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Encuentra los mejores productos aquí",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),

                // BARRA DE BÚSQUEDA FUNCIONAL
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    onChanged: (value) {
                      // Cada vez que escribes, actualizamos el estado
                      setState(() {
                        _searchText = value.toLowerCase();
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "¿Qué estás buscando hoy?",
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.indigo),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. GRILLA FILTRADA
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').orderBy('createdAt', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState("No hay productos aún");
                }

                // FILTRADO LOCAL:
                // Tomamos todos los productos y filtramos los que coincidan con el texto
                final allDocs = snapshot.data!.docs;
                final filteredDocs = allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  return name.contains(_searchText);
                }).toList();

                // Si buscaste algo y no hay coincidencias
                if (filteredDocs.isEmpty) {
                  return _buildEmptyState("No encontramos ese producto 😔");
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    Product productFromCloud = Product(
                      name: data['name'] ?? 'Sin Nombre',
                      price: data['price'] ?? 'S/ 0.00',
                      imagePath: data['imagePath'] ?? '',
                      description: data['description'] ?? '',
                      isOffer: data['isOffer'] ?? false,
                    );
                    return ProductCard(product: productFromCloud, productId: doc.id);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget auxiliar para mostrar mensajes cuando no hay datos
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }
}