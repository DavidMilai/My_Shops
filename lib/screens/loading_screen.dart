import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

final Geolocator geolocator = Geolocator();
Position position;
String currentAddress;
GoogleMapController mapController;
Set<Marker> markers = HashSet<Marker>();

DateTime now = DateTime.now();
String formattedDate = DateFormat('kk:mm:ss EEE d MMM').format(now);

getLocation() async {
  position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  getAddressFromLatLng();
}

getAddressFromLatLng() async {
  try {
    List<Placemark> p = await geolocator.placemarkFromCoordinates(
        position.latitude, position.longitude);

    Placemark place = p[0];

    currentAddress =
        "${place.subLocality}, ${place.locality}, ${place.country}";
    print(currentAddress);
  } catch (e) {
    print(e);
  }
}

final spinKit = SpinKitFadingGrid(
  color: Colors.brown,
  size: 150.0,
);

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    getLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.brown,
    ));
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Brand Expert'),
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MaterialButton(
                    color: Colors.blue,
                    child: Text('Get location'),
                    onPressed: () {
                      print(position);
                      setState(() {
                        getLocation();
                      });
                    }),
                currentAddress == null
                    ? Text('')
                    : Text(
                        "$currentAddress \n $formattedDate",
                        textAlign: TextAlign.center,
                      ),
                currentAddress == null
                    ? Container()
                    : Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20)),
                        height: size.height * 0.5,
                        child: GoogleMap(
                          onMapCreated: (GoogleMapController controller) {
                            mapController = controller;
                            setState(() {
                              markers.add(
                                Marker(
                                  markerId: MarkerId('mylocation'),
                                  position: LatLng(
                                      position.latitude, position.longitude),
                                ),
                              );
                            });
                          },
                          initialCameraPosition: CameraPosition(
                            target:
                                LatLng(position.latitude, position.longitude),
                            zoom: 12,
                          ),
                          markers: markers,
                        ),
                      ),
              ],
            ),
          ),
        ));
  }
}
