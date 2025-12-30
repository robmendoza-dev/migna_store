import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// IMPORTANTE: Corregimos la ruta para encontrar el servicio
import '../../services/web_upload_service.dart';
import '../../models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  // Parámetros opcionales para edición
  final Product? productToEdit;
  final String? docId;

  const AddProductScreen({super.key, this.productToEdit, this.docId});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // Variables para la imagen
  Uint8List? _webImage;
  bool _isUploading = false;

  // Instancia del servicio de subida
  final WebUploadService _uploadService = WebUploadService();

  // --- 1. INICIALIZAR DATOS SI ESTAMOS EDITANDO ---
  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _nameController.text = widget.productToEdit!.name;
      // Quitamos el "S/ " para que quede solo el número
      _priceController.text = widget.productToEdit!.price.replaceAll('S/ ', '');
      _descController.text = widget.productToEdit!.description;
    }
  }

  // Función para seleccionar imagen nueva
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      var f = await image.readAsBytes();
      setState(() {
        _webImage = f;
      });
    }
  }

  // Función inteligente: Sirve para CREAR y para EDITAR
  Future<void> _uploadProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      try {
        String? imageUrl;

        // A. DECIDIR QUÉ IMAGEN USAR
        if (_webImage != null) {
          // Caso 1: El usuario seleccionó una foto NUEVA -> Subir a Cloudinary
          imageUrl = await _uploadService.uploadImage(_webImage!);
        } else if (widget.productToEdit != null) {
          // Caso 2: Estamos editando y NO cambió la foto -> Usar la URL vieja
          imageUrl = widget.productToEdit!.imagePath;
        }

        // Validación: Si no hay imagen nueva ni vieja, detenemos todo
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes seleccionar una imagen')),
          );
          setState(() => _isUploading = false);
          return;
        }

        // B. PREPARAR DATOS
        Map<String, dynamic> data = {
          'name': _nameController.text.toUpperCase(),
          'price': "S/ ${_priceController.text}", // Formato de moneda
          'description': _descController.text,
          'imagePath': imageUrl,
          'createdAt': Timestamp.now(), // Actualiza la fecha de modificación
        };

        // C. GUARDAR EN FIREBASE
        if (widget.docId != null) {
          // MODO EDICIÓN: Actualizar documento existente
          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.docId)
              .update(data);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Producto actualizado correctamente')),
            );
          }
        } else {
          // MODO CREACIÓN: Crear nuevo documento
          await FirebaseFirestore.instance.collection('products').add(data);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Producto creado correctamente')),
            );
          }
        }

        if (mounted) Navigator.pop(context); // Volver al inicio

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Título dinámico
    final String title = widget.productToEdit != null ? "Editar Producto" : "Nuevo Producto";

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // PREVISUALIZACIÓN DE IMAGEN (MEJORADA)
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _webImage != null
                        ? Image.memory(_webImage!, fit: BoxFit.contain) // Foto nueva (memoria)
                        : (widget.productToEdit != null
                        ? Image.network(widget.productToEdit!.imagePath, fit: BoxFit.contain) // Foto vieja (internet)
                        : const Column( // Placeholder vacío
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        Text("Toca para cambiar imagen"),
                      ],
                    )),
                  ),
                ),
                const SizedBox(height: 20),

                // CAMPOS DE TEXTO
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: "Nombre del Producto", border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "Precio (Ej: 25.50)", border: OutlineInputBorder(), prefixText: "S/ "),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) => v!.isEmpty ? "Campo obligatorio" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: "Descripción", border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),

                // BOTÓN DE GUARDAR
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  onPressed: _isUploading ? null : _uploadProduct,
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.docId != null ? "GUARDAR CAMBIOS" : "GUARDAR PRODUCTO"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}