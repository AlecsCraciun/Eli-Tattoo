import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:glassmorphism_ui/glassmorphism_ui.dart';

// 🔹 FullScreen Gallery (Corectare: Acum este înainte de PortfolioScreen)
class FullScreenGallery extends StatelessWidget {
  final List<String> imageList;
  final int initialIndex;

  const FullScreenGallery({super.key, required this.imageList, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PhotoViewGallery.builder(
        itemCount: imageList.length,
        pageController: PageController(initialPage: initialIndex),
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageList[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
      ),
    );
  }
}

// 🔹 PortfolioScreen
class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String? selectedArtist;
  List<String> imageList = [];
  List<String> allImages = [];

  @override
  void initState() {
    super.initState();
    _fetchAllImages();
  }

  void _fetchAllImages() async {
    List<String> tempImages = [];
    List<String> artists = ["Alecs", "Blanca", "Denis"];

    for (String artist in artists) {
      DocumentSnapshot snapshot =
          await FirebaseFirestore.instance.collection('portofolio').doc(artist).get();
      if (snapshot.exists) {
        var data = snapshot.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('urls')) {
          tempImages.addAll(List<String>.from(data['urls']));
        }
      }
    }

    tempImages.shuffle(Random());

    setState(() {
      allImages = tempImages;
      imageList = List.from(allImages);
    });
  }

  void _changeArtist(String? artist) async {
    if (artist == null) {
      setState(() => imageList = List.from(allImages));
      return;
    }

    DocumentSnapshot snapshot =
        await FirebaseFirestore.instance.collection('portofolio').doc(artist).get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('urls')) {
        setState(() {
          selectedArtist = artist;
          imageList = List<String>.from(data['urls']);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Portofoliu Artiști", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/background.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              const SizedBox(height: 120),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: ["Toți", "Alecs", "Blanca", "Denis"].map((artist) {
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _changeArtist(artist == "Toți" ? null : artist),
                        child: GlassContainer(
                          height: 40,
                          borderRadius: BorderRadius.circular(10),
                          blur: 10,
                          border: Border.all(width: 1, color: Colors.white.withOpacity(0.3)),
                          gradient: LinearGradient(
                            colors: selectedArtist == artist || (artist == "Toți" && selectedArtist == null)
                                ? [Colors.amber.withOpacity(0.4), Colors.amber.withOpacity(0.2)]
                                : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          child: Center(
                            child: Text(
                              artist,
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 10),

              if (selectedArtist != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: GlassContainer(
                    borderRadius: BorderRadius.circular(15),
                    blur: 10,
                    border: Border.all(width: 1, color: Colors.white.withOpacity(0.3)),
                    gradient: LinearGradient(
                      colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.07)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                              image: DecorationImage(
                                image: AssetImage("assets/images/${selectedArtist!.toLowerCase()}_avatar.jpg"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _getArtistBio(selectedArtist!),
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: imageList.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _openImageFullScreen(index),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          imageList[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, color: Colors.red);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openImageFullScreen(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenGallery(
          imageList: imageList,
          initialIndex: index,
        ),
      ),
    );
  }

  String _getArtistBio(String artist) {
    return {
      "Alecs": "Salut! Sunt Alecs, artist cu peste 10 ani de experiență...",
      "Blanca": "Bună! Sunt Blanca, iar pasiunea mea e să te ajut...",
      "Denis": "Hey! Sunt Denis, și mă pasionează arta în cele mai fine detalii...",
    }[artist] ?? "";
  }
}
