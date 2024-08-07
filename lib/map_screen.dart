// ignore_for_file: must_be_immutable, deprecated_member_use

import 'dart:async';
import 'dart:developer';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:map/constants.dart';
import 'package:map/utils.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import 'custom_marker.dart';

class MapScreen extends StatefulWidget {
  MapScreen({
    super.key,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController searchController = TextEditingController();
  LatLng? _currentPosition;
  late GoogleMapController currentMapController;
  List<MarkerData> _customMarkers = [];

  final places = GoogleMapsPlaces(apiKey: mapKey);
  List<Prediction> predictions = [];
  late String _mapTheme;

  void initState() {
    loadMapStyle();
    mapPreProcessing();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Stack(
                children: [
                  CustomGoogleMapMarkerBuilder(
                    // screenshotDelay: ,
                    customMarkers: _customMarkers,
                    builder: (p0, markers) {
                      if (markers == null) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return GoogleMap(
                          initialCameraPosition: CameraPosition(
                              target: LatLng(_currentPosition!.latitude,
                                  _currentPosition!.longitude),
                              zoom: 15),
                          onMapCreated: onMapCreated,
                          mapType: MapType.terrain,
                          onTap: (argument) {
                            _customMarkers.clear();
                            _customMarkers.add(
                              MarkerData(
                                  marker: Marker(
                                      markerId: const MarkerId('1'),
                                      position: argument),
                                  child: TextOnImage()),
                            );
                            setState(() {});
                          },
                          markers: markers);
                    },
                  ),
                  Positioned(
                    top: 15,
                    right: 10,
                    left: 10,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0)),
                      height: 50,
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          getPredictions(value).then((predictionsList) {
                            log(predictionsList.toString() + '==== value ===');
                            setState(() {
                              predictions = predictionsList;
                            });
                          });
                        },
                        decoration: InputDecoration(
                          label: const Text(
                            "بحث",
                            style: TextStyle(fontSize: 15),
                          ),
                          prefixIcon: const Icon(
                            Icons.map,
                            color: Colors.grey,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 15.0, horizontal: 15.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  predictions.length == 0
                      ? SizedBox.shrink()
                      : Positioned(
                          top: 100,
                          right: 10,
                          left: 10,
                          child: Container(
                            color: Colors.white,
                            height: 100,
                            child: ListView.builder(
                              itemCount: predictions.length,
                              itemBuilder: (BuildContext context, int index) {
                                return ListTile(
                                  title: Text(
                                    predictions[index].description!,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  onTap: () async {
                                    PlacesDetailsResponse response =
                                        await places.getDetailsByPlaceId(
                                            predictions[index].placeId!);
                                    if (response.isOkay) {
                                      double lat = response
                                          .result.geometry!.location.lat;
                                      double lng = response
                                          .result.geometry!.location.lng;
                                      _changeLocation(10, LatLng(lat, lng));
                                      predictions.clear();
                                      setState(() {});
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
    );
  }

  void loadMapStyle() {
    DefaultAssetBundle.of(context)
        .loadString('assets/map_theme/map_theme.json')
        .then((mapTheme) {
      _mapTheme = mapTheme;
    });
  }

  void onMapCreated(GoogleMapController controller) {
    Completer<GoogleMapController> gmCompleter = Completer();
    gmCompleter.complete(controller);
    gmCompleter.future.then((gmController) {
      currentMapController = gmController;
      currentMapController.setMapStyle(_mapTheme);
    });
  }

  void setCurrentLocation(LatLng currentPosition) {
    _currentPosition = LatLng(31.5017, 34.4668);
    setState(() {});
  }

  Future<void> addMarkerToMap(LatLng currentPosition) async {
    _customMarkers.add(
      MarkerData(
          marker:
              Marker(markerId: const MarkerId('1'), position: currentPosition),
          child: TextOnImage()),
    );
    setState(() {});
  }

  void mapPreProcessing() async {
    Position? _currentPosition = await AppUtils.determinePosition(context);
    setCurrentLocation(LatLng(
        _currentPosition?.latitude ?? 23, _currentPosition?.longitude ?? 47));
    addMarkerToMap(LatLng(31.5017, 34.4668));
  }

  Future<List<Prediction>> getPredictions(String query) async {
    PlacesAutocompleteResponse response = await places.autocomplete(
      query,
    );
    if (response.isOkay) {
      return response.predictions;
    } else {
      return [];
    }
  }

  void _changeLocation(double zoom, LatLng latLng) {
    double newZoom = zoom > 15 ? zoom : 15;
    _currentPosition = latLng;
    setState(() async {
      currentMapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: newZoom)));
      _customMarkers.clear();
      _currentPosition = latLng;
      _customMarkers.add(
        MarkerData(
            marker: Marker(markerId: const MarkerId('1'), position: latLng),
            child: TextOnImage()),
      );
    });
  }
}
