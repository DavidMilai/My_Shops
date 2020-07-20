import 'dart:collection';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'products_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

final Geolocator geolocator = Geolocator();
Position position;
var selectedStore;
List<DropdownMenuItem> stores = [];
String currentAddress, storeName;
TextEditingController storeNameInputController;
GoogleMapController mapController;
Set<Marker> markers = HashSet<Marker>();

DateTime now = DateTime.now();
String formattedDate = DateFormat('kk:mm:ss EEE d MMM').format(now);

final GlobalKey<FormState> storeNameForm = GlobalKey<FormState>();

getLocation() async {
  position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  getAddressFromLatLng();
}

String storeNameValidator(String value) {
  if (value.length < 1) {
    return 'Please enter a store name';
  } else {
    return null;
  }
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

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    getLocation();
    storeNameInputController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('Brand Expert'),
          centerTitle: true,
        ),
        body: Form(
          key: storeNameForm,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(18))),
                        hintText: 'Store Name',
                      ),
                      onChanged: (value) {
                        storeName = value;
                      },
                      controller: storeNameInputController,
                      validator: storeNameValidator,
                      keyboardType: TextInputType.text,
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: Firestore.instance
                          .collection('Emily Atieno')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot == null) {
                          Text('Loading');
                        } else {
                          stores.clear();
                          for (int i = 0;
                              i < snapshot.data.documents.length;
                              i++) {
                            DocumentSnapshot snap = snapshot.data.documents[i];
                            stores.add(
                              DropdownMenuItem(
                                child: Text(snap.documentID),
                                value: '${snap.documentID}',
                              ),
                            );
                          }
                        }
                        return DropdownButton(
                          items: stores,
                          onChanged: (selectedValue) {
                            setState(() {
                              selectedStore = selectedValue;
                            });
                          },
                          value: selectedStore,
                          isExpanded: false,
                          hint: Text('Select Store'),
                        );
                      },
                    ),
                    SizedBox(height: 10),
                    MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        color: Colors.amber,
                        child: Text(
                          'Change location',
                          style: TextStyle(color: Colors.white),
                        ),
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
                            height: size.height * 0.2,
                            child: GoogleMap(
                              onMapCreated: (GoogleMapController controller) {
                                mapController = controller;
                                setState(() {
                                  markers.add(
                                    Marker(
                                      markerId: MarkerId('mylocation'),
                                      position: LatLng(position.latitude,
                                          position.longitude),
                                    ),
                                  );
                                });
                              },
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                    position.latitude, position.longitude),
                                zoom: 12,
                              ),
                              markers: markers,
                            ),
                          ),
                    SizedBox(height: 10),
                    MaterialButton(
                        color: Colors.amber,
                        minWidth: double.infinity,
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              letterSpacing: 1),
                        ),
                        onPressed: () {
                          if (storeNameForm.currentState.validate()) {
                            setState(() {
                              _showDialog();
                            });
                          }
                        }),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Confirm details"),
          content: new Text(
            "Confirm you are in $storeName's store in $currentAddress \nat $formattedDate",
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            FlatButton(
              child: new Text("Confirm"),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProductsScreen()));
              },
            ),
            FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
