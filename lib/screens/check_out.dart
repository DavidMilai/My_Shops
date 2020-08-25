import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:myshop/screens/home.dart';
import 'package:myshop/services/database.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class CheckOutScreen extends StatefulWidget {
  @override
  _CheckOutScreenState createState() => _CheckOutScreenState();
  final String selectedStore, email, date, uploadedPicUrl;
  final double myLatitude, myLongitude;
  CheckOutScreen(
      {this.selectedStore,
      this.email,
      this.myLatitude,
      this.myLongitude,
      this.date,
      this.uploadedPicUrl});
}

DateTime now = DateTime.now();
String formattedDate = DateFormat('kk:mm:ss EEE d MMM').format(now);

class _CheckOutScreenState extends State<CheckOutScreen> {
  bool isLoading = false;
  String checkoutDate = formattedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        title: Text('Checkout'),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Padding(
          padding: EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Checked in at ${widget.date}\n at ${widget.selectedStore}',
                textAlign: TextAlign.center,
                style: TextStyle(letterSpacing: 1, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Make sure you checkout once you\'re done',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              MaterialButton(
                color: Colors.amber,
                minWidth: double.infinity,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Checkout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  await DatabaseService(userEmail: widget.email)
                      .setStoreData(
                          widget.selectedStore,
                          widget.myLatitude,
                          widget.myLongitude,
                          widget.date,
                          widget.uploadedPicUrl,
                          checkoutDate)
                      .then(
                        (value) => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                HomeScreen(userEmail: widget.email),
                          ),
                        ),
                      )
                      .whenComplete(() {
                    setState(() {
                      isLoading = false;
                    });
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
