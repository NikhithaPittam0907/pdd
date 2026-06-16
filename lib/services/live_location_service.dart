import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';

class LiveLocationService {
  StreamSubscription<Position>? _positionStreamSubscription;
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  Future<String> startLiveLocationSharing() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied.';
    }

    Position currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    const String userId = "user_123";
    
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      _firestore.collection("live_locations").doc(userId).set({
        "latitude": position.latitude,
        "longitude": position.longitude,
        "timestamp": FieldValue.serverTimestamp(),
      });
    });

    return "https://www.google.com/maps/search/?api=1&query=${currentPosition.latitude},${currentPosition.longitude}";
  }

  Future<void> shareLocationLink(String link) async {
    await Share.share("Track my live location: $link");
  }

  void stopLiveLocationSharing() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }
}
