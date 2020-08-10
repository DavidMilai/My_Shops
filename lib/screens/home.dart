import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:myshop/screens/loading_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController mapController;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  Set<Marker> markers = HashSet<Marker>();
  CollectionReference collectionReference =
      Firestore.instance.collection('Visited Stores');

  getSignedInUser() async {
    final user = await _auth.currentUser();
    if (user != null) {
      loggedInUser = user;
    }
  }

  checkMac() {
    Firestore.instance.collection("users").getDocuments().then((querySnapshot) {
      querySnapshot.documents.forEach((result) {
        Firestore.instance
            .collection("users")
            .document(result.documentID)
            .collection("Email")
            .getDocuments()
            .then((querySnapshot) {
          querySnapshot.documents.forEach((result) {
            print('*******DATA******');
            print(result.data);
            print('*******DATA******');
          });
        });
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSignedInUser();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('The Brand Expert'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(
              'Recent Store Visits',
              style: TextStyle(fontSize: 25),
            ),
            StreamBuilder(
                stream: collectionReference.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot == null) {
                    return Center(child: Text('Loading...'));
                  } else {
                    return Expanded(
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, index) {
                            var doc = snapshot.data.documents[index].data;
                            return Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Container(
                                  height: size.height * 0.3,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.3),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        height: size.height * 0.2,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20)),
                                          child: GoogleMap(
                                            onMapCreated: (GoogleMapController
                                                controller) {
                                              mapController = controller;
                                              setState(() {
                                                markers.add(
                                                  Marker(
                                                    markerId:
                                                        MarkerId('mylocation'),
                                                    position: LatLng(
                                                        doc['Latitude'],
                                                        doc['Longitude']),
                                                  ),
                                                );
                                              });
                                            },
                                            initialCameraPosition:
                                                CameraPosition(
                                              target: LatLng(doc['Latitude'],
                                                  doc['Longitude']),
                                              zoom: 12,
                                            ),
                                            markers: markers,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          'Store: ${doc['Store']}',
                                          style: TextStyle(
                                              letterSpacing: 1,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(5.0),
                                        child: Text(
                                          'Date: ${doc['Date']}',
                                          style: TextStyle(
                                              letterSpacing: 1,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  )),
                            );
                          }),
                    );
                  }
                })
          ],
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
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add,
            size: 40,
          ),
          onPressed: () {
            // checkMac();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoadingScreen(),
              ),
            );
          }),
    );
  }
}
