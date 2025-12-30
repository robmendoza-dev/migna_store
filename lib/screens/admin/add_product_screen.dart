import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/web_upload_service.dart';
import '../../models/product_model.dart';

class AddProductScreen extends StatefulWidget {
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

  Uint8List? _webImage;
  bool _isUploading = false;
  bool _isOffer = false; // <--- NUEVA VARIABLE DE ESTADO

  final WebUploadService _uploadService = WebUploadService();

  @override
  void initState() {
    super.initState();
    if (widget.productToEdit != null) {
      _nameController.text = widget.productToEdit!.name;
      _priceController.text = widget.productToEdit!.price.replaceAll('S/ ', '');
      _descController.text = widget.productToEdit!.description;
      _isOffer = widget.productToEdit!.isOffer; // <--- CARGAMOS EL VALOR SI EDITAMOS
    }
  }

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

  Future<void> _uploadProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      try {
        String? imageUrl;

        if (_webImage != null) {
          imageUrl = await _uploadService.uploadImage(_webImage!);
        } else if (widget.productToEdit != null) {
          imageUrl = widget.productToEdit!.imagePath;
        }

        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Debes seleccionar una imagen')),
          );
          setState(() => _isUploading = false);
          return;
        }

        Map<String, dynamic> data = {
          'name': _nameController.text.toUpperCase(),
          'price': "S/ ${_priceController.text}",
          'description': _descController.text,
          'imagePath': imageUrl,
          'isOffer': _isOffer, // <--- GUARDAMOS SI ES OFERTA
          'createdAt': Timestamp.now(),
        };

        if (widget.docId != null) {
          await FirebaseFirestore.instance
              .collection('products')
              .doc(widget.docId)
              .update(data);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto actualizado')));
        } else {
          await FirebaseFirestore.instance.collection('products').add(data);
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto creado')));
        }

        if (mounted) Navigator.pop(context);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        ? Image.memory(_webImage!, fit: BoxFit.contain)
                        : (widget.productToEdit != null
                        ? Image.network(widget.productToEdit!.imagePath, fit: BoxFit.contain)
                        : const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                        Text("Toca para cambiar imagen"),
                      ],
                    )),
                  ),
                ),
                const SizedBox(height: 20),

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

                // --- AQUÍ ESTÁ EL NUEVO INTERRUPTOR DE OFERTA ---
                const SizedBox(height: 10),
                SwitchListTile(
                  title: const Text("¿Marcar como OFERTA?", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Aparecerá una etiqueta naranja en el producto"),
                  activeColor: Colors.orange,
                  value: _isOffer,
                  onChanged: (bool value) {
                    setState(() {
                      _isOffer = value;
                    });
                  },
                ),
                // ------------------------------------------------

                const SizedBox(height: 20),
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