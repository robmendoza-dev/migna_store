import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class WebUploadService {
  // DATOS DE TU CUENTA DE CLOUDINARY
  final String cloudName = "dkqc7xxuu";
  final String uploadPreset = "migna_preset"; // Debe ser "Unsigned" (Sin firmar)

  // Ahora la función SÍ acepta un argumento (bytes)
  Future<String?> uploadImage(Uint8List bytes) async {
    try {
      var uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      var request = http.MultipartRequest("POST", uri);

      // Configuramos el preset para que nos deje subir sin contraseña de servidor
      request.fields['upload_preset'] = uploadPreset;

      // Adjuntamos la imagen
      request.files.add(http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: 'producto_${DateTime.now().millisecondsSinceEpoch}.jpg'
      ));

      // Enviamos la petición
      var response = await request.send();

      if (response.statusCode == 200) {
        // Leemos la respuesta
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var jsonMap = jsonDecode(responseString);

        // Retornamos la URL segura de la imagen
        return jsonMap['secure_url'];
      } else {
        print("Error Cloudinary: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error subiendo imagen: $e");
      return null;
    }
  }
}