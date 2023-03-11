import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp( // Add MaterialApp as a parent widget
      title: 'My App',
      home: LocationSearch(),
    );
  }
}
class LocationSearch extends StatefulWidget {
  @override
  _LocationSearchState createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  final TextEditingController _searchController = TextEditingController();
  final Set<Marker> _markers = {};
  late LatLng _currentLocation=LatLng(35.68, 51.41);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Search'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _searchLocation,
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 14,
              ),
              markers: _markers,
              onTap: (LatLng latLng) => _addMarker(latLng),
            ),
          ),
        ],
      ),
    );
  }

  void _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
   _currentLocation = LatLng(position.latitude, position.longitude);
  }

  void _searchLocation() async {
    String searchText = _searchController.text;
    List<Location> locations = await locationFromAddress(searchText);
    if (locations.length > 0) {
      Location location = locations.first;
      LatLng latLng = LatLng(location.latitude, location.longitude);
      _moveCamera(latLng);
      _addMarker(latLng);
    }
  }

  void _moveCamera(LatLng latLng) {
    CameraPosition cameraPosition = CameraPosition(
      target: latLng,
      zoom: 14,
    );
    GoogleMapController controller = _getMapController() as GoogleMapController;
    controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  void _addMarker(LatLng latLng) {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId('location'),
        position: latLng,
      ));
    });
  }

  Future<GoogleMapController> _getMapController() {
    final Future<GoogleMapController> controller = _controllerCompleter.future;
    assert(controller != null);
    return controller;
  }

  final Completer<GoogleMapController> _controllerCompleter =
      Completer<GoogleMapController>();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}