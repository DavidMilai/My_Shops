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
      double myLongitude, String date) async {
    final CollectionReference storeCollection =
        Firestore.instance.collection(userEmail);
    return await storeCollection.document().setData({
      "Store Name": selectedStore,
      "Latitude": myLatitude,
      "Longitude": myLongitude,
      "Date": date,
    });
  }
}