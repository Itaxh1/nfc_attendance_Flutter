import 'package:device_info/device_info.dart';
import 'package:dpp/auth.dart';
import 'package:dpp/db.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _username = '';
  String _password = '';
  final _formkey = GlobalKey<FormState>();
  final _auth = AuthService();
  dynamic error = '';
  dynamic errors = '';
  final info = Functions();

  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade200,
        body: Stack(children: [
          Container(
              padding: EdgeInsets.fromLTRB(20, 130, 20, 0),
              child: Image(
                image: AssetImage('lib/images/login.png'),
                fit: BoxFit.contain,
              )),
          SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Container(
                    padding: EdgeInsets.fromLTRB(25, 65, 0, 350),
                    child: Text("Attendance",
                        style: GoogleFonts.poppins(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ))),
                Container(
                  padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        Text(
                          'Login',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700, fontSize: 25),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        username(),
                        SizedBox(height: 10),
                        password(),
                        SizedBox(height: 30),
                        Container(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(
                                      MediaQuery.of(context).size.width * 0.5,
                                      50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                                onPressed: () async {
                                  if (_formkey.currentState.validate()) {
                                    _formkey.currentState.save();
                                    errors =
                                        await _auth.sigin(_username, _password);
                                    error = errors;
                                    setState(() {});
                                    AndroidDeviceInfo device =
                                        await info.deviceinfo.androidInfo;
                                    dynamic id = await info.deviceCheck(
                                        _auth.firebaseAuth.currentUser.uid);
                                    if (id != device.androidId) {
                                      error = 'Device not matched.';
                                      setState(() {});
                                      await _auth.firebaseAuth.signOut();
                                    } else {
                                      if (_auth.firebaseAuth.currentUser !=
                                          null) {
                                        runApp(MaterialApp(home: Home()));
                                      }
                                    }
                                  }
                                },
                                child: Text(
                                  'LOGIN',
                                  style: GoogleFonts.poppins(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600),
                                ))),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          error,
                          style: GoogleFonts.poppins(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ]))
        ]));
  }

  Widget username() {
    return TextFormField(
      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.email),
        filled: true,
        labelStyle: GoogleFonts.poppins(),
        fillColor: Colors.white,
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        border: InputBorder.none,
        labelText: 'Email',
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Empty';
        }
        if (!value.contains('.com') || !value.contains('@')) {
          return 'Wrong Email format';
        }
        return null;
      },
      onSaved: (value) {
        setState(() {
          _username = value;
        });
      },
    );
  }

  Widget password() {
    return TextFormField(
      style: GoogleFonts.poppins(),
      obscureText: true,
      decoration: InputDecoration(
        labelStyle: GoogleFonts.poppins(),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.lock),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        labelText: 'Password',
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Empty';
        }
        return null;
      },
      onSaved: (value) {
        setState(() {
          _password = value;
        });
      },
    );
  }
}
