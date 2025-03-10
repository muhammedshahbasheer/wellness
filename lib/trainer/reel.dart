import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UploadReelPage extends StatelessWidget {
  const UploadReelPage({Key? key}) : super(key: key);

  // Cloudinary Configuration
  final String cloudinaryUrl = 'https://api.cloudinary.com/v1_1/dvijd3hxi/video/upload';
  final String uploadPreset = 'reel_video';

  Future<void> _pickAndUploadVideo(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
      );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Uploading video...')),
        );

        http.MultipartRequest request = http.MultipartRequest('POST', Uri.parse(cloudinaryUrl))
          ..fields['upload_preset'] = uploadPreset;

        if (kIsWeb) {
          Uint8List? fileBytes = result.files.single.bytes;
          if (fileBytes != null) {
            request.files.add(http.MultipartFile.fromBytes(
              'file',
              fileBytes,
              filename: result.files.single.name,
            ));
          }
        } else {
          File videoFile = File(result.files.single.path!);
          request.files.add(await http.MultipartFile.fromPath('file', videoFile.path));
        }

        var response = await request.send();
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);

        print('Response Data: $jsonResponse');
        print('Response Status: ${response.statusCode}');

        if (response.statusCode == 200) {
          String videoUrl = jsonResponse['secure_url'];
          await FirebaseFirestore.instance.collection('reels').add({
            'reel_link': videoUrl,
            'timestamp': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Video uploaded and saved successfully!')),
          );
        } else {
          print('Upload failed: ${response.statusCode}');
          print('Error message: ${jsonResponse['error']['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload failed: ${jsonResponse['error']['message']}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No video selected.')),
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Reel'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _pickAndUploadVideo(context),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
          child: const Text('Pick and Upload Video', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
