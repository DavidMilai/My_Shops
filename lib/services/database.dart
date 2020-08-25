import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final String userEmail;
  DatabaseService({this.userEmail});
  final CollectionReference userCollection =
      Firestore.instance.collection('users');

  Future setUserData(
      String email, String firstName, String lastName, var mac) async {
    return await userCollection.document(userEmail).setData({
      "Email": email,
      "First Name": firstName,
      "Last Name": lastName,
      "Mac Address": mac
    });
  }

  Future setStoreData(String selectedStore, double myLatitude,
      double myLongitude, String date, String imageurl, String checkout) async {
    final CollectionReference storeCollection =
        Firestore.instance.collection('Visited Stores');
    return await storeCollection
        .document(userEmail)
        .collection('location')
        .document('${DateTime.now().toString().substring(0, 16)}')
        .setData({
      "Store Name": selectedStore,
      "Latitude": myLatitude,
      "Longitude": myLongitude,
      "Date": date,
      'picUrl': imageurl,
      "checkout": checkout
    });
  }
}
