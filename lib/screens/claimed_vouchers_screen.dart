import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClaimedVouchersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Voucherele mele')),
        body: Center(child: Text('Trebuie să fii logat pentru a vedea voucherele revendicate.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Voucherele mele'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('claimed_vouchers')
            .where('userId', isEqualTo: user.uid)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'Nu ai revendicat încă niciun voucher.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }
          return ListView(
            padding: EdgeInsets.all(10),
            children: snapshot.data!.docs.map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              return Card(
                color: Colors.grey.shade900,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  title: Text(data['title'], style: TextStyle(color: Colors.amber)),
                  subtitle: Text(
                    'Revendicat la: ${(data['claimedAt'] as Timestamp).toDate()}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Icon(Icons.check_circle, color: Colors.green),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
