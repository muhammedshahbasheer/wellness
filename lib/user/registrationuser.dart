import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _image;
  Uint8List? _webImage;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  Future<String?> _uploadImageToCloudinary(dynamic imageFile) async {
    const cloudinaryUrl = "https://api.cloudinary.com/v1_1/dvijd3hxi/image/upload";
    const uploadPreset = "profile_images";

    final request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl));
    request.fields['upload_preset'] = uploadPreset;

    if (kIsWeb) {
      request.files.add(http.MultipartFile.fromBytes('file', imageFile, filename: 'profile.png'));
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final data = json.decode(responseData);

    if (response.statusCode == 200) {
      return data['secure_url'];
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed!')),
      );
      return null;
    }
  }

  void _registerTrainer() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text.trim() != _confirmPasswordController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')),
        );
        return;
      }

      if (_image == null && _webImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a profile image!')),
        );
        return;
      }

      try {
        String? imageUrl;

        if (kIsWeb && _webImage != null) {
          imageUrl = await _uploadImageToCloudinary(_webImage);
        } else if (_image != null) {
          imageUrl = await _uploadImageToCloudinary(_image!);
        }

        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        User? user = userCredential.user;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'age': int.parse(_ageController.text.trim()),
            'uid': user.uid,
            'role': 'user',
            'profileImageUrl': imageUrl ?? '',
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User Registered Successfully!')),
          );

          Navigator.pop(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Trainer Registration', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _webImage != null
                          ? MemoryImage(_webImage!)
                          : _image != null
                              ? FileImage(_image!) as ImageProvider
                              : null,
                      child: (_image == null && _webImage == null)
                          ? const Icon(Icons.camera_alt, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildTextField(_nameController, 'Name'),
                  _buildTextField(_emailController, 'Email', TextInputType.emailAddress),
                  _buildTextField(_ageController, 'Age', TextInputType.number),
                  _buildTextField(_passwordController, 'Password', TextInputType.visiblePassword, true),
                  _buildTextField(_confirmPasswordController, 'Confirm Password', TextInputType.visiblePassword, true),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _registerTrainer,
                    child: const Text('Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, [TextInputType? keyboardType, bool obscureText = false]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          filled: true,
          fillColor: Colors.grey[800],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        validator: (value) => value!.isEmpty ? 'Enter your $label' : null,
      ),
    );
  }
}
