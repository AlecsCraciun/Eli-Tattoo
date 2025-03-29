import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

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

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Serviciul de localizare este dezactivat."), backgroundColor: Colors.red),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permisiunea pentru locație a fost refuzată permanent."), backgroundColor: Colors.red),
        );
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Locația a fost marcată cu succes!"), backgroundColor: Colors.green),
    );
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() => _webImage = bytes);
      }
    } else {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
    }
  }

  Future<String?> _uploadImage(String voucherId) async {
    try {
      String fileName = 'treasure_hunt/$voucherId.jpg';
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

  Future<void> _addVoucher() async {
    if (titleController.text.isEmpty || descriptionController.text.isEmpty || hintController.text.isEmpty || latitude == null || longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Completează toate câmpurile și adaugă o imagine!"), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      DocumentReference docRef = await _firestore.collection("treasure_hunt_rewards").add({
        "title": titleController.text.trim(),
        "description": descriptionController.text.trim(),
        "hint": hintController.text.trim(),
        "latitude": latitude,
        "longitude": longitude,
        "timestamp": FieldValue.serverTimestamp(),
      });

      String? imageUrl = await _uploadImage(docRef.id);
      if (imageUrl != null) {
        await docRef.update({"image_url": imageUrl});
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Voucher adăugat cu succes!"), backgroundColor: Colors.green),
      );

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

  Future<void> _deleteVoucher(String docId, String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
      await _firestore.collection("treasure_hunt_rewards").doc(docId).delete();
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
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Titlu")),
            const SizedBox(height: 10),
            TextField(controller: descriptionController, decoration: const InputDecoration(labelText: "Descriere")),
            const SizedBox(height: 10),
            TextField(controller: hintController, decoration: const InputDecoration(labelText: "Indiciu")),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _getCurrentLocation, child: const Text("Marchează Voucher")),
            const SizedBox(height: 10),
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 150)
                : _webImage != null
                    ? Image.memory(_webImage!, height: 150)
                    : const SizedBox(height: 150, child: Center(child: Text("Selectează o imagine"))),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _pickImage, child: const Text("Alege Imagine")),
            const SizedBox(height: 10),
            _isUploading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _addVoucher, child: const Text("Adaugă Voucher")),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              "Vouchere Active",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection("treasure_hunt_rewards")
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("Nu există vouchere active."));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data() as Map<String, dynamic>;

                      return Card(
                        child: ListTile(
                          leading: data['image_url'] != null
                              ? Image.network(data['image_url'], width: 50, height: 50, fit: BoxFit.cover)
                              : const Icon(Icons.image_not_supported),
                          title: Text(data['title'] ?? 'Fără titlu'),
                          subtitle: Text(data['description'] ?? ''),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteVoucher(doc.id, data['image_url']),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
