import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> checkFirestore() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  var snapshot = await firestore.collection('treasure_hunt_rewards').get();

  print("🔥 Firestore a returnat ${snapshot.docs.length} vouchere");
  for (var doc in snapshot.docs) {
    print("${doc.id} => ${doc.data()}");
  }
}
