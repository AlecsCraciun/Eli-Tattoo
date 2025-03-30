import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:glassmorphism/glassmorphism.dart';

class TreasureHuntAdminScreen extends StatefulWidget {
  const TreasureHuntAdminScreen({super.key});

  @override
  _TreasureHuntAdminScreenState createState() => _TreasureHuntAdminScreenState();
}

class _TreasureHuntAdminScreenState extends State<TreasureHuntAdminScreen> {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Controllers
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController hintController = TextEditingController();

  // State variables
  File? _selectedImage;
  Uint8List? _webImage;
  bool _isUploading = false;
  bool _showAddForm = false;
  double? latitude;
  double? longitude;

  // Locație
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Serviciul de localizare este dezactivat."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Permisiunea pentru locație a fost refuzată."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permisiunea pentru locație a fost refuzată permanent."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Locația a fost marcată cu succes!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Eroare la obținerea locației: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Imagine
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _webImage = bytes);
        } else {
          setState(() => _selectedImage = File(pickedFile.path));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Eroare la selectarea imaginii: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Upload imagine
  Future<String?> _uploadImage(String voucherId) async {
    try {
      String fileName = 'treasure_hunt/$voucherId.jpg';
      Reference ref = _storage.ref().child(fileName);
      UploadTask uploadTask;

      if (kIsWeb) {
        if (_webImage == null) return null;
        uploadTask = ref.putData(_webImage!);
      } else {
        if (_selectedImage == null) return null;
        uploadTask = ref.putFile(_selectedImage!);
      }

      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Eroare încărcare imagine: $e");
      return null;
    }
  }

  // Adăugare voucher
  Future<void> _addVoucher() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        hintController.text.isEmpty ||
        latitude == null ||
        longitude == null ||
        (_selectedImage == null && _webImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completează toate câmpurile și adaugă o imagine!"),
          backgroundColor: Colors.red,
        ),
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
        "claimed": false,
      });

      String? imageUrl = await _uploadImage(docRef.id);
      if (imageUrl != null) {
        await docRef.update({"image_url": imageUrl});
      }

      _clearForm();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Voucher adăugat cu succes!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Eroare la adăugare voucher: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // Ștergere voucher
  Future<void> _deleteVoucher(String docId, String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
      await _firestore.collection("treasure_hunt_rewards").doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Voucher șters cu succes!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Eroare la ștergere: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Curățare formular
  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    hintController.clear();
    setState(() {
      _selectedImage = null;
      _webImage = null;
      latitude = null;
      longitude = null;
      _showAddForm = false;
    });
  }

  // UI Components
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

  Widget _buildAddVoucherForm() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 520,
      borderRadius: 20,
      blur: 20,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.2),
        ],
      ),
      borderGradient: const LinearGradient(
        colors: [Colors.white54, Colors.white24],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Titlu",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Descriere",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: hintController,
              decoration: const InputDecoration(
                labelText: "Indiciu",
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text("Marchează Locația"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _selectedImage != null
                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                  : _webImage != null
                      ? Image.memory(_webImage!, fit: BoxFit.cover)
                      : const Center(
                          child: Text(
                            "Selectează o imagine",
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Alege Imagine"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isUploading ? null : _addVoucher,
                  icon: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : const Icon(Icons.add),
                  label: Text(_isUploading ? "Se încarcă..." : "Adaugă Voucher"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("treasure_hunt_rewards")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "Nu există vouchere active.",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data() as Map<String, dynamic>;
            final bool isClaimed = data['claimed'] ?? false;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GlassmorphicContainer(
                width: double.infinity,
                height: 100,
                borderRadius: 20,
                blur: 20,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(isClaimed ? 0.05 : 0.1),
                    Colors.white.withOpacity(isClaimed ? 0.1 : 0.2),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    Colors.white54.withOpacity(isClaimed ? 0.3 : 1),
                    Colors.white24.withOpacity(isClaimed ? 0.3 : 1),
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: data['image_url'] != null
                          ? DecorationImage(
                              image: NetworkImage(data['image_url']),
                              fit: BoxFit.cover,
                              colorFilter: isClaimed
                                  ? ColorFilter.mode(
                                      Colors.grey.withOpacity(0.7),
                                      BlendMode.saturation,
                                    )
                                  : null,
                            )
                          : null,
                    ),
                    child: data['image_url'] == null
                        ? const Icon(Icons.image_not_supported, color: Colors.white54)
                        : null,
                  ),
                  title: Text(
                    data['title'] ?? 'Fără titlu',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: isClaimed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text(
                    data['description'] ?? '',
                    style: TextStyle(
                      color: Colors.white70,
                      decoration: isClaimed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isClaimed)
                        IconButton(
                          icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                                    onPressed: () async {
                            await _firestore
                                .collection("treasure_hunt_rewards")
                                .doc(doc.id)
                                .update({"claimed": true});
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteVoucher(doc.id, data['image_url']),
                      ),
                    ],
                  ),
                ),
              ),
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
        title: const Text("Administrare Treasure Hunt"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showAddForm = !_showAddForm),
        child: Icon(_showAddForm ? Icons.close : Icons.add),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_showAddForm) ...[
                      _buildAddVoucherForm(),
                      const SizedBox(height: 20),
                    ],
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text(
                        "Vouchere Active",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildVoucherList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

