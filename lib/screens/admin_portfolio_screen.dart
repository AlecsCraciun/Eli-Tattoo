import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AdminPortfolioScreen extends StatefulWidget {
  const AdminPortfolioScreen({super.key});

  @override
  _AdminPortfolioScreenState createState() => _AdminPortfolioScreenState();
}

class _AdminPortfolioScreenState extends State<AdminPortfolioScreen> {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // 🔹 Selectează și încarcă imaginea în folderul "portofolio"
  Future<void> _uploadImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String fileName = 'portofolio/${DateTime.now().millisecondsSinceEpoch}.jpg';

    setState(() => _isUploading = true);

    try {
      // 🔹 Încarcă imaginea în Firebase Storage
      TaskSnapshot snapshot = await _storage.ref(fileName).putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      // 🔹 Salvează URL-ul imaginii în Firestore
      await _firestore.collection('portofolio').add({
        'imageUrl': downloadUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint("✅ Imagine încărcată cu succes în portofolio!");
    } catch (e) {
      debugPrint("❌ Eroare la încărcare: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // 🔹 Șterge imaginea din "portofolio"
  Future<void> _deleteImage(String docId, String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete(); // Șterge din Firebase Storage
      await _firestore.collection('portofolio').doc(docId).delete(); // Șterge din Firestore
      debugPrint("✅ Imagine ștearsă!");
    } catch (e) {
      debugPrint("❌ Eroare la ștergere: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administrare Portofoliu")),
      body: Column(
        children: [
          const SizedBox(height: 20),

          // 🔹 Buton de încărcare imagine
          ElevatedButton.icon(
            onPressed: _uploadImage,
            icon: const Icon(Icons.upload),
            label: const Text("Încarcă Imagine"),
          ),

          const SizedBox(height: 20),

          // 🔹 Afișăm lista imaginilor din portofoliu
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('portofolio').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final images = snapshot.data!.docs;

                if (images.isEmpty) {
                  return const Center(child: Text("Nu există imagini în portofoliu."));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final doc = images[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final String imageUrl = data['imageUrl'];

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteImage(doc.id, imageUrl),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
