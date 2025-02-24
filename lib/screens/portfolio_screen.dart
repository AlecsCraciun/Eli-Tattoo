import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  _PortfolioScreenState createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  String selectedArtist = "Alecs";

  void _changeArtist(String artist) {
    setState(() {
      selectedArtist = artist;
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
          // 🔹 Meniu fix cu 3 butoane egale
          Container(
            color: Colors.grey.shade900,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: ["Alecs", "Blanca", "Denis"].map((artist) {
                return Expanded(
                  child: TextButton(
                    onPressed: () => _changeArtist(artist),
                    style: TextButton.styleFrom(
                      backgroundColor: selectedArtist == artist ? Colors.purpleAccent : Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text(
                      artist,
                      style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
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
                  radius: 100, // 🔹 Dimensiune redusă la 200px (100 = raza)
                  backgroundImage: AssetImage("assets/images/${selectedArtist.toLowerCase()}_avatar.jpg"),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getArtistBio(selectedArtist),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Galerie de imagini
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('portofolio') // ✅ CORECȚIE: folosește numele corect al colecției
                  .doc(selectedArtist)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  print("🔥 Firestore: Documentul pentru $selectedArtist NU există!");
                  return const Center(
                    child: Text("Nu există imagini pentru acest artist.",
                        style: TextStyle(color: Colors.white)),
                  );
                }

                var data = snapshot.data!.data() as Map<String, dynamic>?;

                if (data == null || !data.containsKey('urls') || data['urls'] == null) {
                  print("⚠️ Firestore: Documentul există, dar `urls` este NULL sau inexistent!");
                  return const Center(
                    child: Text("Nu există imagini pentru acest artist.",
                        style: TextStyle(color: Colors.white)),
                  );
                }

                List<dynamic> rawImageList = data['urls'];
                List<String> imageList = rawImageList.whereType<String>().toList();

                print("✅ Firestore: ${imageList.length} imagini găsite pentru $selectedArtist!");

                if (imageList.isEmpty) {
                  return const Center(
                    child: Text("Nu există imagini pentru acest artist.",
                        style: TextStyle(color: Colors.white)),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                  ),
                  itemCount: imageList.length,
                  itemBuilder: (context, index) {
                    String imageUrl = imageList[index];

                    return GestureDetector(
                      onTap: () => _openImageFullScreen(imageUrl),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withOpacity(0.5), width: 5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print("❌ Eroare la încărcarea imaginii: $error");
                              return const Icon(Icons.error, color: Colors.red);
                            },
                          ),
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
      "Alecs": "Salut! Sunt Alecs, artist cu peste 10 ani de experiență în lumea tatuajelor. Îmi place să creez artă care să te reprezinte, fie că alegi un design realist, geometric sau ornamental. Specialitatea mea? Să transform ideile tale în tatuaje care să te facă să zâmbești de fiecare dată când le privești! 🎨",
      "Blanca": "Bună! Sunt Blanca, iar pasiunea mea e să te ajut să strălucești prin piercing-uri cool și sigure! Cu experiență în toate tipurile de piercing și un ochi pentru detalii, sunt aici să-ți transform ideile în realitate. Vino să discutăm despre următorul tău piercing! 💫",
      "Denis": "Hey! Sunt Denis, și mă pasionează arta în cele mai fine detalii! Specializat în fine line, microrealism, black work și stippling, transform cu răbdare și precizie fiecare concept în tatuaje delicate și pline de personalitate. Hai să dăm viață ideilor tale! 🎨"
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
