import 'package:dpp/auth.dart';
import 'package:dpp/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final _auth = AuthService();

  if (_auth.firebaseAuth.currentUser != null) {
    runApp(MaterialApp(
      title: 'App',
      home: Home(),
    ));
  } else {
    runApp(MaterialApp(
      title: 'App',
      home: Login(),
    ));
  }
}
