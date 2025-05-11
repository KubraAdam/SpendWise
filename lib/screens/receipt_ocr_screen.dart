import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReceiptOCRScreen extends StatefulWidget {
  const ReceiptOCRScreen({super.key});

  @override
  State<ReceiptOCRScreen> createState() => _ReceiptOCRScreenState();
}

class _ReceiptOCRScreenState extends State<ReceiptOCRScreen> {
  File? _image;
  String _recognizedText = '';
  String? _lastReceiptId; // 🔥 Güncelleme/Silme için Firestore belgesi ID'si
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(source: ImageSource.gallery);
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

    // 🔥 Firestore'a kayıt
    if (_recognizedText.isNotEmpty) {
      final docRef = await FirebaseFirestore.instance.collection('receipts').add({
        'text': _recognizedText,
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _lastReceiptId = docRef.id;
      });
    }
  }

  Future<void> _deleteReceipt() async {
    if (_lastReceiptId != null) {
      await FirebaseFirestore.instance.collection('receipts').doc(_lastReceiptId).delete();
      setState(() {
        _recognizedText = '';
        _lastReceiptId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fiş silindi.')),
      );
    }
  }

  Future<void> _editReceipt() async {
    final TextEditingController controller = TextEditingController(text: _recognizedText);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Fişi Düzenle'),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () async {
              final newText = controller.text.trim();
              if (_lastReceiptId != null && newText.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('receipts')
                    .doc(_lastReceiptId)
                    .update({'text': newText});
                setState(() => _recognizedText = newText);
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
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
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/receipt_list');
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('Fişlerim'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
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

            // 🔥 Eğer kayıtlı fiş varsa düzenleme ve silme seçenekleri
            if (_lastReceiptId != null && _recognizedText.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _editReceipt,
                    icon: const Icon(Icons.edit),
                    label: const Text('Düzenle'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _deleteReceipt,
                    icon: const Icon(Icons.delete),
                    label: const Text('Sil'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
