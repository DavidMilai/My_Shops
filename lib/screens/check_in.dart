import 'dart:collection';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:myshop/services/database.dart';

class CheckInScreen extends StatefulWidget {
  @override
  _CheckInScreenState createState() => _CheckInScreenState();
  final String userEmail;
  CheckInScreen({@required this.userEmail});
}

DateTime now = DateTime.now();
String formattedDate = DateFormat('kk:mm:ss EEE d MMM').format(now);

class _CheckInScreenState extends State<CheckInScreen> {
  final Geolocator geoLocator = Geolocator();
  Position position;
  String date = formattedDate;
  var selectedStore;
  List<DropdownMenuItem> stores = [];
  String currentAddress, storeName;
  double myLatitude;
  double myLongitude;
  File selectedImage;
  String uploadedPicUrl;
  bool isLoading = false;
  GoogleMapController mapController;
  Set<Marker> markers = HashSet<Marker>();

  getLocation() async {
    position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    getAddressFromLatLng();
  }

  uploadPic() async {
    String fileName = selectedImage.path;
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = storageReference.putFile(selectedImage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    uploadedPicUrl = await storageReference.getDownloadURL();
  }

  String storeNameValidator(var value) {
    if (value.length < 1) {
      return 'Please enter a store name';
    } else {
      return null;
    }
  }

  getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geoLocator.placemarkFromCoordinates(
          position.latitude, position.longitude);

      Placemark place = p[0];

      currentAddress =
          "${place.subLocality}, ${place.locality}, ${place.country}";
      print(currentAddress);
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic> storeToAdd;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Widget getImage() {
    if (selectedImage != null) {
      return Image.file(selectedImage,
          width: 250, height: 250, fit: BoxFit.cover);
    } else {
      return Image.asset(
        'assets/placeholder.jpg',
        width: 250,
        height: 250,
        fit: BoxFit.cover,
      );
    }
  }

  takePhoto() async {
    File image = (await ImagePicker.pickImage(source: ImageSource.camera));
    if (image != null) {
      File croppedImage = (await ImageCropper.cropImage(
          sourcePath: image.path,
          compressQuality: 100,
          maxHeight: 700,
          maxWidth: 700,
          compressFormat: ImageCompressFormat.jpg,
          androidUiSettings: AndroidUiSettings(
              toolbarColor: Colors.amber,
              toolbarTitle: "Resize image",
              statusBarColor: Colors.brown,
              backgroundColor: Colors.white),
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1)));
      setState(() {
        selectedImage = croppedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            onTap: () {
              print('*****Milai*****');
              uploadPic();
              print('*****not worked*****');
            },
            child: Text('Check in store')),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                getImage(),
                MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    color: Colors.amber,
                    child: GestureDetector(
                      child: Text(
                        'Take a photo',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onPressed: () {
                      takePhoto();
                    }),
                StreamBuilder<QuerySnapshot>(
                  stream:
                      Firestore.instance.collection('Emily Atieno').snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot == null) {
                      Text('Loading');
                    } else {
                      stores.clear();
                      for (int i = 0; i < snapshot.data.documents.length; i++) {
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
                MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    color: Colors.amber,
                    child: Text(
                      'Update location',
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
                            setState(
                              () {
                                markers.add(
                                  Marker(
                                    markerId: MarkerId('mylocation'),
                                    position: LatLng(
                                        position.latitude, position.longitude),
                                  ),
                                );
                              },
                            );
                          },
                          initialCameraPosition: CameraPosition(
                            target:
                                LatLng(position.latitude, position.longitude),
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
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 1,
                    ),
                  ),
                  onPressed: () async {
                    if (selectedStore == null || selectedImage == null) {
                      setState(
                        () {
                          _showDialog();
                        },
                      );
                    } else {
                      setState(
                        () {
                          isLoading = true;
                        },
                      );
                      myLatitude = position.latitude;
                      myLongitude = position.longitude;
                      await uploadPic();
                      await DatabaseService(userEmail: widget.userEmail)
                          .setStoreData(selectedStore, myLatitude, myLongitude,
                              date, uploadedPicUrl)
                          .then((value) => Navigator.pop(context));
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Alert!!!"),
          content: new Text("Please select a store and take a photo"),
          actions: <Widget>[
            FlatButton(
              color: Colors.green,
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
