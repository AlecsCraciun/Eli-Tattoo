import 'dart:async';
import 'package:flutter_beacon/flutter_beacon.dart';

class BeaconService {
  StreamController<Beacon?> beaconController = StreamController<Beacon?>.broadcast();

  Stream<Beacon?> get beaconStream => beaconController.stream;

  Future<void> startScan() async {
    await flutterBeacon.initializeScanning;

    final regions = <Region>[
      Region(
        identifier: 'EliVoucherBeacon',
        proximityUUID: '13CC7F8DF0C84AAAA000AAAAAAAAAAAA',
      ),
    ];

    flutterBeacon.ranging(regions).listen((RangingResult result) {
      if (result.beacons.isNotEmpty) {
        final beacon = result.beacons.first;
        beaconController.add(beacon);
      } else {
        beaconController.add(null); // nu s-a detectat beaconul
      }
    });
  }

  void dispose() {
    beaconController.close();
  }
}
