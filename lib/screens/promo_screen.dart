import 'package:flutter/material.dart';

class PromoScreen extends StatelessWidget { // ✅ Numele clasei corectat
  const PromoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔹 Lista promoțiilor (poți înlocui cu date din Firebase)
    final List<Map<String, String>> promotions = [
      {
        "image": "assets/images/promo1.jpg",
        "title": "Reducere 20% la tatuaje",
        "description": "Profită de o reducere specială la toate tatuajele!",
      },
      {
        "image": "assets/images/promo2.jpg",
        "title": "Voucher cadou 50 RON",
        "description": "Cumpără un voucher cadou pentru cineva drag!",
      },
      {
        "image": "assets/images/promo3.jpg",
        "title": "Piercing + Îngrijire gratuită",
        "description": "Fă-ți un piercing și primești îngrijire gratuită!",
      },
    ];

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
        child: ListView.builder(
          itemCount: promotions.length,
          itemBuilder: (context, index) {
            final promo = promotions[index];
            return _buildPromoCard(promo);
          },
        ),
      ),
    );
  }

  Widget _buildPromoCard(Map<String, String> promo) {
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
              aspectRatio: 3 / 1, // ✅ Raport de 1/3
              child: Image.asset(
                promo["image"]!,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 🔹 Detaliile promoției
          Padding(
            padding: const EdgeInsets.all(15),
            child: ListTile(
              title: Text(
                promo["title"]!,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  promo["description"]!,
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
