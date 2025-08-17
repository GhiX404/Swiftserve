import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FileUploadService {
  static const String _imgurApiUrl = 'https://api.imgur.com/3/image';
  static const String _clientId = 'YOUR_IMGUR_CLIENT_ID'; // Replace with your Imgur client ID
  
  // For web platform
  static Future<String?> uploadImageWeb(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);
      final response = await http.post(
        Uri.parse(_imgurApiUrl),
        headers: {
          'Authorization': 'Client-ID $_clientId',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': base64Image,
          'type': 'base64',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data']['link'];
      } else {
        print('Error uploading image: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during image upload: $e');
      return null;
    }
  }

  // For mobile platforms
  static Future<String?> uploadImageMobile(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);
      
      final response = await http.post(
        Uri.parse(_imgurApiUrl),
        headers: {
          'Authorization': 'Client-ID $_clientId',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'image': base64Image,
          'type': 'base64',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['data']['link'];
      } else {
        print('Error uploading image: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception during image upload: $e');
      return null;
    }
  }

  // Platform-agnostic upload method
  static Future<String?> uploadImage(dynamic imageSource) async {
    if (kIsWeb && imageSource is Uint8List) {
      return uploadImageWeb(imageSource);
    } else if (imageSource is File) {
      return uploadImageMobile(imageSource);
    }
    return null;
  }

  // Pick image from gallery or camera
  static Future<dynamic> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    
    if (pickedFile != null) {
      if (kIsWeb) {
        // For web, return bytes
        return await pickedFile.readAsBytes();
      } else {
        // For mobile, return File
        return File(pickedFile.path);
      }
    }
    return null;
  }
} 