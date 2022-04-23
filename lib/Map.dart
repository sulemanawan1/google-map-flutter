import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocode/geocode.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';


class LocationPicker extends StatefulWidget {

  final Function onChanged;

  const LocationPicker({Key? key, required this.onChanged}) : super(key: key);

  @override
  _LocationPickerState createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  double _selectedLat = 0.0;
  double _selectedLng = 0.0;
  Address? address;
  late String city;
  GeoCode geoCode = GeoCode();
  final Completer<GoogleMapController> _googleMapController = Completer();


  late Response response;

  TextEditingController _addressController = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;


    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          'Add Location',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_selectedLat, _selectedLng),
              ),
              onMapCreated: (GoogleMapController controller) {
                _googleMapController.complete(controller);
              },
              compassEnabled: false,
              myLocationEnabled: false,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              onCameraMove: (CameraPosition cameraPosition) {
                setState(() {
                  _selectedLat = cameraPosition.target.latitude;
                  _selectedLng = cameraPosition.target.longitude;
                });
              },
              onCameraIdle: () async {


                response = await reverseGeoDecoding(
                  lat: _selectedLat,
                  lng: _selectedLng,
                );



                setState(() {
                  print(_selectedLat);
                  print(_selectedLng);
                  _addressController.text =
                  response.data['results'][0]['formatted_address'];
                });
              },
            ),
            Icon(
              Icons.location_on,
              color: Colors.red,
              size: 50,
            ),

            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal:10,
                  ),
                  child: SizedBox(
                    width: s.width,
                    child: CupertinoButton(
                        child: const Text('Save'),
                        color: Colors.blue,
                        onPressed: () async {
                          // Navigator.pop(context);

                          response = await reverseGeoDecoding(
                            lat: _selectedLat,
                            lng: _selectedLng,
                          );
                          print(response);
                          print(_selectedLat);
                          print(_selectedLng);
                          //widget.onChanged(_selectedLat, _selectedLng, response.data['results'][0]['formatted_address']);
                        }),
                  ),
                )),
          ],
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.centerRight,
        child: FloatingActionButton(
          child: const Icon(Icons.location_on_outlined),
          onPressed: () {
            _getLocation();
          },
        ),
      ),
    );
  }

  _getLocation() async {
    final GoogleMapController controller = await _googleMapController.future;


    Position p =await  determinePosition();

    _selectedLat = p.latitude;
    _selectedLng = p.longitude;

    print( _selectedLat);
    print( _selectedLng);

    await controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(_selectedLat, _selectedLng), zoom: 16)));
  }
















  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services
//Geolocator.isLocationServiceEnabled();
      Geolocator.requestPermission();
      // return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }










}
 reverseGeoDecoding({
  lat,
  lng
}){
  return Dio().post('https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=AIzaSyBxYoAYSwy-GASmbxY8R3cVwaA_fPfsUJs');
}



// controller.animateCamera(CameraUpdate.newCameraPosition(
// CameraPosition(target: LatLng(_selectedLat, _selectedLng), zoom: 12)));