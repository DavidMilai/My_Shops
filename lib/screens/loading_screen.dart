import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

final Geolocator geolocator = Geolocator();
Position position;
String currentAddress;

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
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Location'),
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
                        currentAddress,
                        textAlign: TextAlign.center,
                      )
              ],
            ),
          ),
        ));
  }
}
