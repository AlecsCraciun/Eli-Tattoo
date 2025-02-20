import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';

class PortofoliuPage extends StatefulWidget {
  const PortofoliuPage({super.key});

  @override
  _PortofoliuPageState createState() => _PortofoliuPageState();
}

class _PortofoliuPageState extends State<PortofoliuPage> {
  String selectedArtist = 'Alecs'; // Artistul selectat inițial

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection('portofoliu').get().then((snapshot) {
      for (var doc in snapshot.docs) {
        print("📸 Tatuaj găsit: \${doc.data()}");
      }
    }).catchError((error) {
      print("❌ Eroare Firestore: \$error");
    });
  }

  Stream<List<Map<String, dynamic>>> getPortfolioImages(String selectedArtist) {
    return FirebaseFirestore.instance
        .collection('portofoliu')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'PORTOFOLIU',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 4,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filtre pentru artiști
          Container(
            padding: const EdgeInsets.all(15),
            color: AppColors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildArtistFilter('Alecs'),
                _buildArtistFilter('Denis'),
                _buildArtistFilter('Blanca'),
              ],
            ),
          ),
          // Grid de imagini cu debugging
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getPortfolioImages(selectedArtist),
              builder: (context, snapshot) {
                print("📢 StreamBuilder actualizat!");

                if (snapshot.connectionState == ConnectionState.waiting) {
                  print("⏳ Așteptare date...");
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  print("⚠️ Nu există imagini pentru acest artist.");
                  return const Center(
                    child: Text(
                      'Nu există imagini pentru acest artist.',
                      style: TextStyle(color: AppColors.gold, fontSize: 16),
                    ),
                  );
                }

                print("✅ Imagini găsite: \${snapshot.data!.length}");
                final images = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.all(10),
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      final imageUrl = images[index]['imageUrl'] ?? '';
                      final artist = images[index]['Artist'] ?? 'Necunoscut';

                      print("🖼 Afișează imagine: \$imageUrl");
                      return _buildPortfolioItem(imageUrl, artist);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistFilter(String name) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          selectedArtist = name;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedArtist == name ? AppColors.gold : AppColors.darkBackground,
        foregroundColor: selectedArtist == name ? AppColors.black : AppColors.gold,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.gold),
        ),
      ),
      child: Text(name),
    );
  }

  Widget _buildPortfolioItem(String imageUrl, String artist) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.gold),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.error, color: Colors.red),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
                child: Text(
                  'Artist: $artist',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
