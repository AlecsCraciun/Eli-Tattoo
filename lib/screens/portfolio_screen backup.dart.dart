import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String selectedArtist = "Alecs";
  final userId = FirebaseAuth.instance.currentUser?.uid ?? "guest";

  void _changeArtist(String artist) {
    setState(() {
      selectedArtist = artist;
    });
  }

  void _toggleLike(String imageId, bool isLiked) async {
    final docRef = FirebaseFirestore.instance.collection('portfolio_likes').doc(imageId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final doc = await transaction.get(docRef);
      if (!doc.exists) {
        transaction.set(docRef, {
          'likes': isLiked ? [userId] : [],
          'dislikes': isLiked ? [] : [userId],
        });
      } else {
        List<dynamic> likes = List.from(doc['likes'] ?? []);
        List<dynamic> dislikes = List.from(doc['dislikes'] ?? []);

        if (isLiked) {
          likes.contains(userId) ? likes.remove(userId) : likes.add(userId);
          dislikes.remove(userId);
        } else {
          dislikes.contains(userId) ? dislikes.remove(userId) : dislikes.add(userId);
          likes.remove(userId);
        }

        transaction.update(docRef, {
          'likes': likes,
          'dislikes': dislikes,
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Portofoliu Artiști", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 🔹 Meniu pentru selectarea artistului
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["Alecs", "Blanca", "Denis"].map((artist) {
                return ElevatedButton(
                  onPressed: () => _changeArtist(artist),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedArtist == artist ? Colors.purpleAccent : Colors.grey.shade800,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  ),
                  child: Text(artist, style: const TextStyle(fontSize: 16, color: Colors.white)),
                );
              }).toList(),
            ),
          ),

          // 🔹 Header cu avatar + bio
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage("assets/images/${selectedArtist.toLowerCase()}_avatar.jpg"),
                ),
                const SizedBox(height: 10),
                Text(
                  selectedArtist,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    _getArtistBio(selectedArtist),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Galerie de imagini (tip Instagram)
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('portfolio').doc(selectedArtist).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(
                    child: Text(
                      "Nu există imagini pentru acest artist.",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                var imageData = snapshot.data!.data() as Map<String, dynamic>;
                List<dynamic> imageUrls = imageData['urls'] ?? [];

                if (imageUrls.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nu există imagini pentru acest artist.",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    String imageUrl = imageUrls[index];

                    return _buildImageCard(imageUrl);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCard(String imageUrl) {
    return GestureDetector(
      onTap: () => _openImageFullScreen(imageUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(imageUrl, fit: BoxFit.cover),
      ),
    );
  }

  void _openImageFullScreen(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImage(imageUrl: imageUrl),
      ),
    );
  }

  String _getArtistBio(String artist) {
    return {
      "Alecs": "Expert în realism și black & grey, cu peste 10 ani de experiență.",
      "Blanca": "Maestră în piercing și body modifications.",
      "Denis": "Artist specializat în neo-traditional și color tattoos."
    }[artist] ?? "";
  }
}

// 🔹 Pagina pentru vizualizare fullscreen
class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: PhotoView(imageProvider: NetworkImage(imageUrl)),
      ),
    );
  }
}
