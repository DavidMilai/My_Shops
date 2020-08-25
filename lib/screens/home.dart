import 'dart:collection';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:myshop/screens/check_in.dart';
import 'package:myshop/screens/selected_location.dart';
import 'package:wifi_info_plugin/wifi_info_plugin.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
  final String userEmail;
  HomeScreen({this.userEmail});
}

class _HomeScreenState extends State<HomeScreen> {
  WifiInfoWrapper _wifiObject;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  String mac;
  bool samePhone = true;
  CollectionReference collectionReference;
  CollectionReference collectionReferenceMac;

  getSignedInUser() async {
    final user = await _auth.currentUser();
    if (user != null) {
      loggedInUser = user;
    }
  }

  Future<void> initPlatformState() async {
    WifiInfoWrapper wifiObject;
    try {
      wifiObject = await WifiInfoPlugin.wifiDetails;
    } on PlatformException {}
    if (!mounted) return;
    setState(() {
      _wifiObject = wifiObject;
    });
  }

  checkMac(String macSearch) async {
    QuerySnapshot dataSnapshot = await collectionReferenceMac.getDocuments();
    List names = [];
    dataSnapshot.documents.forEach((document) {
      names.add(document.data['Mac Address']);
    });
    setState(() {
      samePhone = names.contains(macSearch);
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    getSignedInUser();
    collectionReference = Firestore.instance
        .collection('Visited Stores')
        .document(widget.userEmail)
        .collection('location');
    collectionReferenceMac = Firestore.instance.collection('users');
  }

  @override
  Widget build(BuildContext context) {
    mac = _wifiObject != null ? _wifiObject.macAddress.toString() : "ip";
    checkMac(mac);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          title: Text('The Brand Expert'),
        ),
        body: samePhone == true
            ? Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      'Recent Store Visits',
                      style: TextStyle(fontSize: 25),
                    ),
                    StreamBuilder(
                        stream: collectionReference.snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.data == null) {
                            return Column(
                              children: [
                                SizedBox(height: size.height * 0.25),
                                SpinKitWave(
                                  color: Colors.brown,
                                  size: 80,
                                ),
                              ],
                            );
                          } else {
                            return Expanded(
                              child: ListView.builder(
                                  physics: BouncingScrollPhysics(),
                                  itemCount: snapshot.data.documents.length,
                                  itemBuilder: (context, index) {
                                    var doc =
                                        snapshot.data.documents[index].data;
                                    return Padding(
                                      padding: EdgeInsets.all(5.0),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.2),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(20)),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                20)),
                                                    child: Image.network(
                                                      doc['picUrl'],
                                                      height: 100,
                                                    )),
                                              ),
                                              SizedBox(width: 5),
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Store:',
                                                        style: TextStyle(
                                                            letterSpacing: 1,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          ' ${doc['Store Name']}'),
                                                    ],
                                                  ),
                                                  SizedBox(height: 5),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        'Date:',
                                                        style: TextStyle(
                                                            letterSpacing: 1,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(' ${doc['Date']}'),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Spacer(),
                                              IconButton(
                                                  icon:
                                                      Icon(Icons.navigate_next),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            SelectedLocation(
                                                          latitude:
                                                              doc['Latitude'],
                                                          longitude:
                                                              doc['Longitude'],
                                                          imageUrl:
                                                              doc['picUrl'],
                                                          storeName:
                                                              doc['Store Name'],
                                                          dateTime: doc['Date'],
                                                          checkoutTime:
                                                              doc['checkout'],
                                                        ),
                                                      ),
                                                    );
                                                  })
                                            ],
                                          )),
                                    );
                                  }),
                            );
                          }
                        })
                  ],
                ),
              )
            : Center(
                child: Text(
                  'Kindly use the phone used to register',
                  style: TextStyle(fontSize: 20),
                ),
              ),
        drawer: Drawer(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(children: [
              DrawerHeader(
                  child: Image.asset(
                'assets/user.png',
              )),
              ListTile(
                leading: Icon(Icons.perm_identity),
                title: Text('My Profile'),
                onTap: () {},
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('Recent Stores'),
                onTap: () {},
              ),
              SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.lock_outline),
                title: Text('Change Password'),
                onTap: () {},
              ),
              Spacer(),
              MaterialButton(
                color: Colors.brown,
                onPressed: () {
                  Navigator.popAndPushNamed(context, '/');
                },
                child: Text(
                  'Log out',
                  style: TextStyle(letterSpacing: 1, color: Colors.white),
                ),
              )
            ]),
          ),
        ),
        floatingActionButton: samePhone == true
            ? FloatingActionButton(
                child: Icon(
                  Icons.add,
                  size: 40,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CheckInScreen(userEmail: loggedInUser.email),
                    ),
                  );
                })
            : Container());
  }
}
