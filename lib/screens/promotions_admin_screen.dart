import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

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
  bool _showAddForm = false;

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

  Future<void> _pickExpiryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedExpiryDate = picked);
    }
  }

  Future<String?> _uploadImage() async {
    if (_selectedImage == null && _webImage == null) return null;
    
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
      print("Eroare la încărcarea imaginii: $e");
      return null;
    }
  }

  Future<void> _addPromotion() async {
    if (titleController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        _selectedExpiryDate == null ||
        (_selectedImage == null && _webImage == null)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Completează toate câmpurile obligatorii!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      String? imageUrl = await _uploadImage();
      if (imageUrl == null) throw Exception("Eroare la încărcarea imaginii");

      await _firestore.collection("promotii").add({
        "titlu": titleController.text.trim(),
        "descriere": descriptionController.text.trim(),
        "linkText": linkTextController.text.trim(),
        "linkUrl": linkUrlController.text.trim(),
        "imagine": imageUrl,
        "expiraLa": _selectedExpiryDate!.toIso8601String(),
        "timestamp": FieldValue.serverTimestamp(),
      });

      _clearForm();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Promoție adăugată cu succes!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Eroare la adăugarea promoției: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deletePromotion(String docId, String imageUrl) async {
    try {
      await _storage.refFromURL(imageUrl).delete();
      await _firestore.collection("promotii").doc(docId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Promoție ștearsă cu succes!"),
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

  void _clearForm() {
    titleController.clear();
    descriptionController.clear();
    linkTextController.clear();
    linkUrlController.clear();
    setState(() {
      _selectedImage = null;
      _webImage = null;
      _selectedExpiryDate = null;
      _showAddForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Administrare Promoții"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _showAddForm = !_showAddForm),
        child: Icon(_showAddForm ? Icons.close : Icons.add),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1D4350), Color(0xFFA43931)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_showAddForm) ...[
                    GlassmorphicContainer(
                      width: double.infinity,
                      height: 680,
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
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Adaugă Promoție Nouă",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: titleController,
                              decoration: InputDecoration(
                                labelText: "Titlu Promoție",
                                labelStyle: const TextStyle(color: Colors.white70),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.white30),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: descriptionController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: "Descriere",
                                labelStyle: const TextStyle(color: Colors.white70),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.white30),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: linkTextController,
                                    decoration: InputDecoration(
                                      labelText: "Text Link",
                                      labelStyle: const TextStyle(color: Colors.white70),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.white30),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.white),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.1),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextField(
                                    controller: linkUrlController,
                                    decoration: InputDecoration(
                                      labelText: "URL",
                                      labelStyle: const TextStyle(color: Colors.white70),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.white30),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: Colors.white),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white.withOpacity(0.1),
                                    ),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: _selectedImage != null
                                  ? Image.file(_selectedImage!, fit: BoxFit.cover)
                                  : _webImage != null
                                      ? Image.memory(_webImage!, fit: BoxFit.cover)
                                      : const Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.image_outlined,
                                                color: Colors.white70,
                                                size: 48,
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                "Selectează o imagine",
                                                style: TextStyle(color: Colors.white70),
                                              ),
                                            ],
                                          ),
                                        ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.image),
                                    label: const Text("Alege Imagine"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green.withOpacity(0.8),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _pickExpiryDate,
                                    icon: const Icon(Icons.calendar_today),
                                    label: Text(
                                      _selectedExpiryDate == null
                                          ? "Alege data"
                                          : DateFormat('yyyy-MM-dd')
                                              .format(_selectedExpiryDate!),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.withOpacity(0.8),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isUploading ? null : _addPromotion,
                                icon: _isUploading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.add),
                                label: Text(
                                  _isUploading ? "Se încarcă..." : "Adaugă Promoție",
                                  style: const TextStyle(fontSize: 16),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange.withOpacity(0.8),
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                                                    ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      "Promoții Active",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('promotii')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        );
                      }

                      final promotions = snapshot.data!.docs;
                      if (promotions.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.campaign_outlined, 
                                   color: Colors.white70, 
                                   size: 64),
                              SizedBox(height: 16),
                              Text(
                                "Nu există promoții active",
                                style: TextStyle(
                                  color: Colors.white70, 
                                  fontSize: 18
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: promotions.length,
                        itemBuilder: (context, index) {
                          final doc = promotions[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final DateTime expiryDate = 
                              DateTime.parse(data['expiraLa']);
                          final bool isExpired = 
                              expiryDate.isBefore(DateTime.now());

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: GlassmorphicContainer(
                              width: double.infinity,
                              height: 120,
                              borderRadius: 15,
                              blur: 20,
                              alignment: Alignment.center,
                              border: 2,
                              linearGradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(isExpired ? 0.05 : 0.1),
                                  Colors.white.withOpacity(isExpired ? 0.1 : 0.2),
                                ],
                              ),
                              borderGradient: LinearGradient(
                                colors: [
                                  Colors.white54.withOpacity(isExpired ? 0.3 : 1),
                                  Colors.white24.withOpacity(isExpired ? 0.3 : 1),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(data['imagine']),
                                      fit: BoxFit.cover,
                                      colorFilter: isExpired
                                          ? ColorFilter.mode(
                                              Colors.grey.withOpacity(0.7),
                                              BlendMode.saturation,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  data['titlu'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: isExpired 
                                        ? TextDecoration.lineThrough 
                                        : null,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['descriere'],
                                      style: TextStyle(
                                        color: Colors.white70,
                                        decoration: isExpired 
                                            ? TextDecoration.lineThrough 
                                            : null,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Expiră la: ${DateFormat('yyyy-MM-dd').format(expiryDate)}",
                                      style: TextStyle(
                                        color: isExpired 
                                            ? Colors.red.withOpacity(0.7) 
                                            : Colors.green,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                    size: 28,
                                  ),
                                  onPressed: () => _deletePromotion(
                                    doc.id,
                                    data['imagine'],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

