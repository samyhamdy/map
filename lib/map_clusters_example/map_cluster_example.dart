import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class MapClusteringExample extends StatefulWidget {
  const MapClusteringExample({super.key});

  @override
  State<MapClusteringExample> createState() => _MapClusteringExampleState();
}

class _MapClusteringExampleState extends State<MapClusteringExample> {
  MapController mapController = MapController();
  List<String> governorates = [
    "Cairo",
    "Alexandria",
    "Giza",
    "Luxor",
    "Aswan",
    "Suez",
    "Ismailia",
    "Faiyum",
    "Minya",
    "Qena"
  ];
  List<Marker> markers = [];
  List latlngs = [
    LatLng(30.0444, 31.2357), // Cairo
    LatLng(31.2001, 29.9187), // Alexandria
    LatLng(30.0131, 31.2089), // Giza
    LatLng(25.6872, 32.6396), // Luxor
    LatLng(24.0889, 32.8998), // Aswan
    LatLng(30.5843, 32.2659), // Suez
    LatLng(30.5902, 32.2658), // Ismailia
    LatLng(29.3093, 30.8418), // Faiyum
    LatLng(28.1099, 30.7503), // Minya
    LatLng(26.1551, 32.7160) // Qena
  ];

  void addDummyMarkers() {
    for (int i = 0; i < latlngs.length; i++) {
      markers.add(Marker(
        point: latlngs[i],
        width: 100,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.green,
            ),
            child: Center(
              child: Text(
                governorates[i].toString(),
                style: TextStyle(
                    fontSize: 15,
                    decoration: TextDecoration.none,
                    color: Colors.white),
              ),
            ),
          );
        },
      ));
    }
  }

  @override
  void initState() {
    addDummyMarkers();
    getDistanceBetweenTwoPoints(30.0444, 31.2357, 31.2001, 29.9187);
    distanceBetweenUsingHaversineFormula(30.0444, 31.2357, 31.2001, 29.9187);

    getAddressFromLatLng(30.0444, 31.2357);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        rotation: 0,
        onTap: (tapPosition, point) {},
        center: LatLng(26.8206, 30.8025),
        zoom: 6,
        maxZoom: 15,
        minZoom: 2.5,
      ),
      children: <Widget>[
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            maxClusterRadius: 120,
            size: Size(50, 20),
            anchor: AnchorPos.align(AnchorAlign.center),
            fitBoundsOptions: const FitBoundsOptions(
              padding: EdgeInsets.all(50),
              maxZoom: 15,
            ),
            markers: markers,
            builder: (context, markers) {
              return Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5), color: Colors.red),
                child: Center(
                  child: Text(
                    markers.length.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1,
                        decoration: TextDecoration.none),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void getDistanceBetweenTwoPoints(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    double distanceInMeters = Geolocator.distanceBetween(
        startLatitude, startLongitude, endLatitude, endLongitude);

    print((distanceInMeters / 1000).toString() + " distance in km");
  }

  double distanceBetweenUsingHaversineFormula(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    var earthRadius = 6378137.0;
    var dLat = _toRadians(endLatitude - startLatitude);
    var dLon = _toRadians(endLongitude - startLongitude);

    var a = pow(sin(dLat / 2), 2) +
        pow(sin(dLon / 2), 2) *
            cos(_toRadians(startLatitude)) *
            cos(_toRadians(endLatitude));
    var c = 2 * asin(sqrt(a));
    print(((earthRadius * c) / 1000).toString() +
        " distance in km using haversine formula");
    return earthRadius * c;
  }

  static _toRadians(double degree) {
    return degree * pi / 180;
  }

  void getAddressFromLatLng(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    String fullAddress = placemarks[0].locality! +
        placemarks[0].country! +
        placemarks[0].administrativeArea!;
    print(fullAddress.toString() + "====fullAddress====");
  }
}
