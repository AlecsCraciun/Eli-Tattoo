import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Promoții", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("promotii").snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  "Momentan nu există promoții active.",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            var promos = snapshot.data!.docs;

            // 🔹 Filtrăm promoțiile expirate și validăm datele
            promos = promos.where((doc) {
              try {
                var data = doc.data() as Map<String, dynamic>;
                if (!data.containsKey("expiraLa") ||
                    !data.containsKey("imagine") ||
                    !data.containsKey("titlu") ||
                    !data.containsKey("descriere")) {
                  return false;
                }

                var expDate = DateTime.tryParse(data["expiraLa"]);
                return expDate != null && expDate.isAfter(DateTime.now());
              } catch (e) {
                return false;
              }
            }).toList();

            if (promos.isEmpty) {
              return const Center(
                child: Text(
                  "Momentan nu există promoții active.",
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return ListView.builder(
              itemCount: promos.length,
              itemBuilder: (context, index) {
                var promo = promos[index];
                var data = promo.data() as Map<String, dynamic>;

                return _buildPromoCard(
                  imageUrl: data["imagine"],
                  title: data["titlu"],
                  description: data["descriere"],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildPromoCard({required String imageUrl, required String title, required String description}) {
    return Card(
      color: Colors.grey.shade900,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Imaginea promoției (1/3 din înălțimea totală)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: AspectRatio(
              aspectRatio: 3 / 1,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, color: Colors.white, size: 50),
              ),
            ),
          ),

          // 🔹 Detaliile promoției
          Padding(
            padding: const EdgeInsets.all(15),
            child: ListTile(
              title: Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
