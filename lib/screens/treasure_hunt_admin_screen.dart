import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class TreasureHuntAdminScreen extends StatefulWidget {
  const TreasureHuntAdminScreen({super.key});

  @override
  _TreasureHuntAdminScreenState createState() => _TreasureHuntAdminScreenState();
}

class _TreasureHuntAdminScreenState extends State<TreasureHuntAdminScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController hintController = TextEditingController();

  File? _selectedImage;
  Uint8List? _webImage;
  bool _isUploading = false;
  double? latitude;
  double? longitude;

  // 🔹 Obține locația curentă
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Serviciul de localizare este dezactivat."),
        backgroundColor: Colors.red,
      ));
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Permisiunea pentru locație a fost refuzată permanent."),
          backgroundColor: Colors.red,
        ));
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Locația a fost marcată cu succes!"),
      backgroundColor: Colors.green,
    ));
  }

  // 🔹 Selectează imaginea
  Future<void> _pickImage() async {
    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null) {
        setState(() => _webImage = result.files.first.bytes);
      }
    } else {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    }
  }

  // 🔹 Încarcă imaginea și returnează URL-ul
  Future<String?> _uploadImage() async {
    try {
      String fileName = 'treasure_hunt/${DateTime.now().millisecondsSinceEpoch}.jpg';
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

  // 🔹 Salvează voucher-ul în Firestore
  Future<void> _addVoucher() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        hintController.text.isEmpty ||
        latitude == null ||
        longitude == null ||
        (_selectedImage == null && _webImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Completează toate câmpurile și adaugă o imagine!"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? imageUrl = await _uploadImage();
      if (imageUrl == null) return;

      await _firestore.collection("treasure_hunt_rewards").add({
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "hint": hintController.text.trim(),
        "latitude": latitude,
        "longitude": longitude,
        "imageUrl": imageUrl,
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Voucher adăugat cu succes!"),
        backgroundColor: Colors.green,
      ));

      titleController.clear();
      descriptionController.clear();
      hintController.clear();
      setState(() {
        _selectedImage = null;
        _webImage = null;
        latitude = null;
        longitude = null;
      });
    } catch (e) {
      print("Eroare la adăugare voucher: $e");
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // 🔹 Șterge voucher-ul
  Future<void> _deleteVoucher(String docId, String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
      await _firestore.collection("treasure_hunt").doc(docId).delete();
    } catch (e) {
      print("Eroare la ștergere voucher: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Administrare Treasure Hunt")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Titlu"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Descriere"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: hintController,
              decoration: const InputDecoration(labelText: "Indiciu"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text("Marchează Voucher"),
            ),
            const SizedBox(height: 10),
            _selectedImage != null || _webImage != null
                ? Image.memory(_webImage ?? Uint8List(0), height: 150)
                : const SizedBox(height: 150, child: Center(child: Text("Selectează o imagine"))),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Alege Imagine"),
            ),
            const SizedBox(height: 10),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _addVoucher,
                    child: const Text("Adaugă Voucher"),
                  ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection("treasure_hunt").orderBy("timestamp", descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final vouchers = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: vouchers.length,
                    itemBuilder: (context, index) {
                      final doc = vouchers[index];
                      final data = doc.data() as Map<String, dynamic>;
                      return Card(
                        child: ListTile(
                          title: Text(data["title"]),
                          subtitle: Text("Indiciu: ${data["hint"]}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteVoucher(doc.id, data["imageUrl"]),
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
