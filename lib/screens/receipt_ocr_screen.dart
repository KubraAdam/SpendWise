import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class ReceiptOCRScreen extends StatefulWidget {
  const ReceiptOCRScreen({super.key});

  @override
  State<ReceiptOCRScreen> createState() => _ReceiptOCRScreenState();
}

class _ReceiptOCRScreenState extends State<ReceiptOCRScreen> {
  File? _image;
  String _recognizedText = '';

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.camera);
    if (pickedImage == null) return;

    final imageFile = File(pickedImage.path);
    setState(() => _image = imageFile);

    await _processImage(imageFile);
  }

  Future<void> _processImage(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    setState(() {
      _recognizedText = recognizedText.text.trim();
    });

    await textRecognizer.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fiş Tarama'),
        backgroundColor: const Color(0xFF1C027B),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Kameradan Fiş Tara'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C027B),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            ),
            const SizedBox(height: 16),
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(_image!, height: 200),
              ),
            const SizedBox(height: 16),
            const Text(
              'Tanınan Yazı:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(child: Text(_recognizedText)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
