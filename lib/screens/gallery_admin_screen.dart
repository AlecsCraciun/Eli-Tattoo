import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class GalleryAdminScreen extends StatefulWidget {
  const GalleryAdminScreen({super.key});

  @override
  _GalleryAdminScreenState createState() => _GalleryAdminScreenState();
}

class _GalleryAdminScreenState extends State<GalleryAdminScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  
  bool _isUploading = false;
  String _userRole = "user"; // 🔹 Implicit user
  String? _selectedArtist; // 🔹 Admin poate selecta un artist

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  // 🔹 Obține rolul utilizatorului din Firestore
  Future<void> _fetchUserRole() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection("users").doc(user.uid).get();
      if (userDoc.exists) {
        setState(() => _userRole = userDoc["role"]);
      }
    }
  }

  // 🔹 Selectează și încarcă o imagine în galeria unui artist
  Future<void> _uploadImage({String? artistId}) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);
    String targetUserId = artistId ?? user.uid;
    String fileName = 'gallery/$targetUserId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    setState(() => _isUploading = true);

    try {
      TaskSnapshot snapshot = await _storage.ref(fileName).putFile(imageFile);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('gallery').add({
        'url': downloadUrl,
        'uploadedBy': targetUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Eroare la încărcare: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // 🔹 Șterge o imagine (Admin sau Proprietar)
  Future<void> _deleteImage(String docId, String imageUrl, String uploaderId) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    if (_userRole == "admin" || user.uid == uploaderId) {
      try {
        await _storage.refFromURL(imageUrl).delete();
        await _firestore.collection('gallery').doc(docId).delete();
      } catch (e) {
        print("Eroare la ștergere: $e");
      }
    } else {
      print("Nu ai permisiunea de a șterge această imagine.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Administrare Galerii"),
        actions: [
          if (_userRole == "admin") // 🔹 Admin selectează artist pentru upload
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection("users").where("role", isEqualTo: "artist").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                List<DropdownMenuItem<String>> artistItems = snapshot.data!.docs.map((doc) {
                  return DropdownMenuItem(
                    value: doc.id,
                    child: Text(doc["name"]),
                  );
                }).toList();
                return DropdownButton<String>(
                  dropdownColor: Colors.grey.shade900,
                  value: _selectedArtist,
                  hint: const Text("Alege Artist", style: TextStyle(color: Colors.white)),
                  onChanged: (value) {
                    setState(() => _selectedArtist = value);
                  },
                  items: artistItems,
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () => _uploadImage(artistId: _selectedArtist),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('gallery').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final images = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _userRole == "admin" || data["uploadedBy"] == user?.uid;
          }).toList();

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
              final String imageUrl = data['url'];
              final String uploadedBy = data['uploadedBy'];

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(imageUrl, fit: BoxFit.cover, width: double.infinity),
                  ),
                  if (_userRole == "admin" || user?.uid == uploadedBy)
                    Positioned(
                      right: 5,
                      top: 5,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteImage(doc.id, imageUrl, uploadedBy),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
