import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String selectedArtist = "Alecs"; // Artistul selectat
  final userId = FirebaseAuth.instance.currentUser?.uid ?? "guest"; // ID-ul utilizatorului

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
      appBar: AppBar(
        title: const Text("Portofoliu"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔹 Selectare artist
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ["Alecs", "Blanca", "Denis"].map((artist) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ElevatedButton(
                    onPressed: () => _changeArtist(artist),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedArtist == artist
                          ? Colors.amber.shade700
                          : Colors.grey.shade800,
                    ),
                    child: Text(artist),
                  ),
                );
              }).toList(),
            ),
          ),

          // 🔹 Galerie de imagini
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('portfolio')
                  .where('artist', isEqualTo: selectedArtist)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Nu există imagini pentru acest artist."));
                }

                var images = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    var imageData = images[index].data() as Map<String, dynamic>;
                    String imageUrl = imageData['url'] ?? "";
                    String imageId = images[index].id;

                    return StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('portfolio_likes')
                          .doc(imageId)
                          .snapshots(),
                      builder: (context, likeSnapshot) {
                        if (!likeSnapshot.hasData || !likeSnapshot.data!.exists) {
                          return _buildImageCard(imageUrl, imageId, 0, 0);
                        }
                        var data = likeSnapshot.data!;
                        List<dynamic> likes = data['likes'] ?? [];
                        List<dynamic> dislikes = data['dislikes'] ?? [];
                        bool isLiked = likes.contains(userId);
                        bool isDisliked = dislikes.contains(userId);

                        return _buildImageCard(imageUrl, imageId, likes.length, dislikes.length,
                            isLiked: isLiked, isDisliked: isDisliked);
                      },
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

  Widget _buildImageCard(String imageUrl, String imageId, int likes, int dislikes,
      {bool isLiked = false, bool isDisliked = false}) {
    return GestureDetector(
      onTap: () => _openImageFullScreen(imageUrl),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.thumb_up,
                    color: isLiked ? Colors.blue : Colors.white,
                  ),
                  onPressed: () => _toggleLike(imageId, true),
                ),
                Text(
                  "$likes",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(
                    Icons.thumb_down,
                    color: isDisliked ? Colors.red : Colors.white,
                  ),
                  onPressed: () => _toggleLike(imageId, false),
                ),
                Text(
                  "$dislikes",
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
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
}

// 🔹 Pagina pentru vizualizare fullscreen
class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
        ),
      ),
    );
  }
}
