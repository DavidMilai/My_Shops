import 'dart:math';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectedLocation extends StatefulWidget {
  @override
  _SelectedLocationState createState() => _SelectedLocationState();
  final latitude, longitude;
  final String storeName, imageUrl, checkoutTime, dateTime;
  SelectedLocation(
      {this.latitude,
      this.longitude,
      this.storeName,
      this.dateTime,
      this.checkoutTime,
      this.imageUrl});
}

class _SelectedLocationState extends State<SelectedLocation> {
  Set<Marker> markers = HashSet<Marker>();
  GoogleMapController mapController;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeName),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Photo of Store',
              style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold),
            ),
            Container(
              height: size.height * 0.35,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: Image.network(
                  widget.imageUrl,
                  height: 100,
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Location on Map',
              style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold),
            ),
            Container(
              height: size.height * 0.25,
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                child: GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    setState(() {
                      markers.add(
                        Marker(
                          markerId: MarkerId(
                              '${Random(DateTime.now().millisecondsSinceEpoch)}'),
                          position: LatLng(widget.latitude, widget.longitude),
                        ),
                      );
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(widget.latitude, widget.longitude),
                    zoom: 12,
                  ),
                  markers: markers,
                ),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Checked in at: ',
                  style:
                      TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold),
                ),
                Text(widget.dateTime),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Text(
                  'Checked out at: ',
                  style:
                      TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold),
                ),
                Text(widget.checkoutTime),
              ],
            )
          ],
        ),
      ),
    );
  }
}
