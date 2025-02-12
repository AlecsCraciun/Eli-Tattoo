import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart';

class TreasureHuntPage extends StatefulWidget {
  @override
  _TreasureHuntPageState createState() => _TreasureHuntPageState();
}

class _TreasureHuntPageState extends State<TreasureHuntPage> {
  GoogleMapController? _mapController;
  Location _location = Location();
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchTreasureLocations();
  }

  void _fetchTreasureLocations() async {
    FirebaseFirestore.instance.collection('treasures').get().then((snapshot) {
      setState(() {
        _markers = snapshot.docs.map((doc) {
          final data = doc.data();
          return Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(data['latitude'], data['longitude']),
            infoWindow: InfoWindow(title: data['hint']),
          );
        }).toSet();
      });
    });
  }

  void _getCurrentLocation() async {
    final locationData = await _location.getLocation();
    _mapController?.animateCamera(CameraUpdate.newLatLng(
      LatLng(locationData.latitude!, locationData.longitude!),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Treasure Hunt')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(45.657975, 25.601198), // Poziție inițială Brașov
          zoom: 12,
        ),
        onMapCreated: (controller) => _mapController = controller,
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        child: Icon(Icons.my_location),
      ),
    );
  }
}
