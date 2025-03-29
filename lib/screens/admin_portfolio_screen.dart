import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:glassmorphism/glassmorphism.dart';

class AdminPortfolioScreen extends StatefulWidget {
  const AdminPortfolioScreen({Key? key}) : super(key: key);

  @override
  _AdminPortfolioScreenState createState() => _AdminPortfolioScreenState();
}

class _AdminPortfolioScreenState extends State<AdminPortfolioScreen> {
  final List<String> artists = ['Alecs', 'Blanca', 'Denis'];
  String? selectedArtist;
  File? selectedImage;
  Uint8List? webImage;
  final picker = ImagePicker();
  bool isUploading = false;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => webImage = bytes);
      } else {
        setState(() => selectedImage = File(pickedFile.path));
      }
    }
  }

  Future<void> uploadImage() async {
    if (selectedArtist == null || (selectedImage == null && webImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selectează un artist și o imagine înainte de a încărca.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref().child('portofolio/$fileName');
      UploadTask uploadTask;

      if (kIsWeb) {
        uploadTask = ref.putData(webImage!);
      } else {
        uploadTask = ref.putFile(selectedImage!);
      }

      final snapshot = await uploadTask;
      final imageUrl = await snapshot.ref.getDownloadURL();

      final artistRef = FirebaseFirestore.instance.collection('portofolio').doc(selectedArtist);

      await artistRef.set({
        'urls': FieldValue.arrayUnion([imageUrl])
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Imagine încărcată cu succes!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        selectedImage = null;
        webImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la încărcare: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  Future<void> deleteImage(String artist, String imageUrl) async {
    try {
      await FirebaseStorage.instance.refFromURL(imageUrl).delete();

      final artistRef = FirebaseFirestore.instance.collection('portofolio').doc(artist);
      await artistRef.update({
        'urls': FieldValue.arrayRemove([imageUrl])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Imagine ștearsă!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Eroare la ștergere: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildGallery(String artist) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('portofolio').doc(artist).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('Nu există imagini.'));
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final List urls = data['urls'] ?? [];

        return urls.isEmpty
            ? const Center(child: Text('Galeria este goală.'))
            : GridView.builder(
                itemCount: urls.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final url = urls[index];
                  return Stack(
                    children: [
                      GlassmorphicContainer(
                        width: double.infinity,
                        height: double.infinity,
                        borderRadius: 20,
                        blur: 20,
                        alignment: Alignment.center,
                        border: 2,
                        linearGradient: _glassGradient(),
                        borderGradient: _borderGradient(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(url, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => deleteImage(artist, url),
                          child: const CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.red,
                            child: Icon(Icons.close, size: 16, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  );
                },
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Administrare Portofolii"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  GlassmorphicContainer(
                    width: double.infinity,
                    height: 180,
                    borderRadius: 20,
                    blur: 20,
                    alignment: Alignment.center,
                    border: 2,
                    linearGradient: _glassGradient(),
                    borderGradient: _borderGradient(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DropdownButton<String>(
                          value: selectedArtist,
                          hint: const Text("Alege artist"),
                          onChanged: (val) => setState(() => selectedArtist = val),
                          items: artists.map((artist) {
                            return DropdownMenuItem(
                              value: artist,
                              child: Text(artist),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: pickImage,
                          child: const Text("Selectează Imagine"),
                        ),
                        const SizedBox(height: 10),
                        if (selectedImage != null || webImage != null)
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: kIsWeb
                                  ? Image.memory(webImage!, fit: BoxFit.cover)
                                  : Image.file(selectedImage!, fit: BoxFit.cover),
                            ),
                          ),
                        const SizedBox(height: 10),
                        isUploading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: uploadImage,
                                child: const Text("Încarcă"),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text("Galerie Portofoliu", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: selectedArtist == null
                        ? const Center(child: Text('Selectează un artist pentru a vedea galeria.'))
                        : _buildGallery(selectedArtist!),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _glassGradient() {
    return LinearGradient(
      colors: [
        Colors.white.withOpacity(0.1),
        Colors.white.withOpacity(0.2),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  LinearGradient _borderGradient() {
    return const LinearGradient(
      colors: [Colors.white54, Colors.white24],
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1D4350), Color(0xFFA43931)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
