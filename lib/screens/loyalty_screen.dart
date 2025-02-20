import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'qr_scanner_screen.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fidelizare', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.black,
          elevation: 2,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            'Trebuie să fii autentificat pentru a vedea punctele.',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fidelizare', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('loyalty_points')
                .doc(user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(
                  child: Text(
                    'Momentan nu ai puncte acumulate.',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                );
              }

              var data = snapshot.data!.data() as Map<String, dynamic>?;
              int totalPoints = data?['total_points'] ?? 0;
              List<dynamic>? history = data?['history'];

              return Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Puncte acumulate',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$totalPoints puncte',
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold, color: Colors.amber),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: history == null || history.isEmpty
                          ? const Center(
                              child: Text(
                                'Nu ai tranzacții înregistrate.',
                                style: TextStyle(fontSize: 16, color: Colors.white70),
                              ),
                            )
                          : ListView.builder(
                              itemCount: history.length,
                              itemBuilder: (context, index) {
                                var entry = history[index] as Map<String, dynamic>;
                                String amount = entry['amount']?.toString() ?? '0';
                                String points = entry['points']?.toString() ?? '0';
                                String date = entry['date'] ?? 'Data necunoscută';
                                return Card(
                                  color: Colors.grey.shade900,
                                  margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    title: Text(
                                      'Achiziție: $amount RON',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      'Puncte obținute: $points',
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    trailing: Text(
                                      date,
                                      style: const TextStyle(color: Colors.amber),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () async {
              final String? scannedCode = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScannerScreen()),
              );

              if (scannedCode != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Cod scanat: $scannedCode")),
                );
              }
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scanează cod QR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
