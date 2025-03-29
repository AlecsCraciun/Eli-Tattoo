import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'dart:typed_data'; // Pentru Web
import 'package:flutter/foundation.dart'; // Detectare Web

class PromotionsAdminScreen extends StatefulWidget {
  const PromotionsAdminScreen({super.key});

  @override
  _PromotionsAdminScreenState createState() => _PromotionsAdminScreenState();
}

class _PromotionsAdminScreenState extends State<PromotionsAdminScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();
  
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController linkTextController = TextEditingController();
  TextEditingController linkUrlController = TextEditingController();

  File? _selectedImage;
  Uint8List? _webImage;
  DateTime? _selectedExpiryDate;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImage = bytes);
      }
    } else {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    }
  }

  Future<void> _pickExpiryDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() => _selectedExpiryDate = pickedDate);
    }
  }

  Future<String?> _uploadImage() async {
    try {
      String fileName = 'promotions/${DateTime.now().millisecondsSinceEpoch}.jpg';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(_webImage!);
      } else {
        uploadTask = ref.putFile(_selectedImage!);
      }

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Eroare încărcare imagine: $e");
      return null;
    }
  }

  Future<void> _addPromotion() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        (_selectedImage == null && _webImage == null) ||
        _selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completează toate câmpurile obligatorii!")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? imageUrl = await _uploadImage();
      if (imageUrl == null) return;

      await _firestore.collection('promotii').add({
        'titlu': titleController.text.trim(),
        'descriere': descriptionController.text.trim(),
        'imagine': imageUrl,
        'expiraLa': _selectedExpiryDate!.toIso8601String(),
        'timestamp': FieldValue.serverTimestamp(),
        'linkText': linkTextController.text.trim(),
        'linkUrl': linkUrlController.text.trim(),
      });

      titleController.clear();
      descriptionController.clear();
      linkTextController.clear();
      linkUrlController.clear();
      setState(() {
        _selectedImage = null;
        _webImage = null;
        _selectedExpiryDate = null;
      });
    } catch (e) {
      print("Eroare la adăugare promoție: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deletePromotion(String docId, String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
      await _firestore.collection('promotii').doc(docId).delete();
    } catch (e) {
      print("Eroare la ștergere promoție: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administrare Promoții")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Titlu Promoție"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Descriere"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: linkTextController,
              decoration: const InputDecoration(labelText: "Text Link (ex: Instagram)"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: linkUrlController,
              decoration: const InputDecoration(labelText: "URL Link (ex: https://instagram.com)"),
            ),
            const SizedBox(height: 10),

            _selectedImage != null
                ? Image.file(_selectedImage!, height: 150)
                : (_webImage != null
                    ? Image.memory(_webImage!, height: 150)
                    : const SizedBox(height: 150, child: Center(child: Text("Selectează o imagine")))),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Alege Imagine"),
            ),
            const SizedBox(height: 10),

            ListTile(
              title: Text(
                _selectedExpiryDate == null
                    ? "Alege data de expirare"
                    : "Expiră la: ${_selectedExpiryDate!.toLocal()}".split(' ')[0],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: _pickExpiryDate,
              ),
            ),

            const SizedBox(height: 10),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addPromotion,
                    child: const Text("Adaugă Promoție"),
                  ),

            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('promotii').orderBy('timestamp', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final promotions = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: promotions.length,
                    itemBuilder: (context, index) {
                      final doc = promotions[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          leading: Image.network(data['imagine'], width: 50, height: 50, fit: BoxFit.cover),
                          title: Text(data['titlu']),
                          subtitle: Text(data['descriere']),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePromotion(doc.id, data['imagine']),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
