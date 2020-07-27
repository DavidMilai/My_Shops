import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  bool isLoading = false;
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  String email, password, firstName, lastName;

  String pwdValidator(String value) {
    if (value.length < 6) {
      return 'Password must be longer than 8 characters';
    } else {
      return null;
    }
  }

  String nameValidator(String value) {
    if (value.length < 2) {
      return 'Enter Your name';
    } else {
      return null;
    }
  }

  String emailValidator(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value)) {
      return 'Email format is invalid';
    } else if (regex == null) {
      return 'Please enter an email address';
    } else {
      return null;
    }
  }

  CollectionReference collectionReference =
      Firestore.instance.collection('users');

  Map<String, dynamic> userToRegister;

  addUser() {
    userToRegister = {
      "Email": email,
      "Password": password,
      "First Name": firstName,
      "Last Name": lastName,
    };
    collectionReference.add(userToRegister).whenComplete(() =>
        FlutterToast.showToast(
                msg: "Account created wait for admin to set up",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 5,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 16.0)
            .then((value) => Navigator.popAndPushNamed(context, '/')));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: loginFormKey,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: ListView(
              children: [
                Align(
                  alignment: Alignment(-0.9, 0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.keyboard_backspace),
                  ),
                ),
                SizedBox(height: size.width / 7),
                Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: size.width / 5),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'First Name'),
                          validator: nameValidator,
                          onChanged: (value) {
                            firstName = value;
                          },
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Last Name'),
                          validator: nameValidator,
                          onChanged: (value) {
                            lastName = value;
                          },
                          obscureText: false,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.email,
                        size: 30,
                      ),
                      labelText: 'Email'),
                  onChanged: (value) {
                    email = value;
                  },
                  validator: emailValidator,
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 15),
                TextFormField(
                  decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, size: 30),
                      labelText: 'Password'),
                  validator: pwdValidator,
                  onChanged: (value) {
                    password = value;
                  },
                  obscureText: true,
                ),
                SizedBox(height: 25),
                MaterialButton(
                    color: Colors.amber,
                    minWidth: 250,
                    elevation: 10,
                    height: size.width / 10,
                    child: Text(
                      'Log in',
                      style: TextStyle(
                          color: Colors.white, letterSpacing: 1, fontSize: 18),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18.0),
                    ),
                    onPressed: () async {
                      if (loginFormKey.currentState.validate()) {
                        addUser();
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
