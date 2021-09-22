import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dpp/db.dart';
import 'package:dpp/login.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  dynamic result = '';
  final _auth = AuthService();
  final info = Functions();
  dynamic name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: EdgeInsets.fromLTRB(25, 65, 0, 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Attendance",
                  style: GoogleFonts.poppins(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  )),
              TextButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Confirm sign out?',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600, fontSize: 15)),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                    await _auth.firebaseAuth.signOut();
                                    runApp(MaterialApp(home: Login()));
                                  },
                                  child: Text('Sign out',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15))),
                              TextButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15)))
                            ],
                          );
                        });
                  },
                  child: Icon(
                    Icons.logout,
                    color: Colors.red,
                  ))
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Icon(
              Icons.account_circle,
              size: 50,
            ),
            SizedBox(width: 15),
            FutureBuilder(
                future: info.userdeets(_auth.firebaseAuth.currentUser.uid),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.data == null) {
                    return Shimmer.fromColors(
                      child: Container(
                        width: 100,
                        height: 15,
                        color: Colors.white,
                      ),
                      baseColor: Colors.grey.shade100,
                      highlightColor: Colors.grey.shade300,
                      enabled: true,
                    );
                  } else {
                    return Text(snapshot.data.toString(),
                        style: GoogleFonts.poppins(
                            fontSize: 25, fontWeight: FontWeight.w500));
                  }
                }),
          ]),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(25, 30, 50, 0),
          child: Text(
            "Attendances",
            style:
                GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 20),
          ),
        ),
        Container(
          padding: EdgeInsets.fromLTRB(25, 20, 25, 0),
          height: MediaQuery.of(context).size.height * 0.55,
          child: Column(
            children: [
              StreamBuilder(
                  stream:
                      info.userattendance(_auth.firebaseAuth.currentUser.uid),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    Map attendance = {};
                    try {
                      attendance = snapshot.data['attendance'];
                    } catch (e) {
                      attendance['1'] = 'df';
                    }
                    return Expanded(
                        child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: BouncingScrollPhysics(),
                      itemCount: attendance.length,
                      itemBuilder: (BuildContext context, int index) {
                        try {
                          Timestamp v =
                              attendance.values.elementAt(index)['time'];
                          Widget marked;
                          if (attendance.values.elementAt(index)['marked'] ==
                              true) {
                            marked = Text(
                              'PRESENT',
                              style: GoogleFonts.poppins(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500),
                            );
                          } else {
                            marked = Text('ABSENT',
                                style: GoogleFonts.poppins(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500));
                          }
                          return Card(
                            shadowColor: Colors.white,
                            borderOnForeground: false,
                            child: ListTile(
                              title: Text(
                                attendance.keys.elementAt(index),
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                DateFormat.yMMMd()
                                    .format(v.toDate())
                                    .toString(),
                                style: GoogleFonts.poppins(),
                              ),
                              trailing: marked,
                            ),
                          );
                        } catch (e) {
                          print(e);
                          return Card(
                            shadowColor: Colors.white,
                            borderOnForeground: false,
                            child: ListTile(
                              title: Text(
                                'No Attendance',
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          );
                        }
                      },
                    ));
                  })
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool isAvailable = await NfcManager.instance.isAvailable();
          if (isAvailable == false) {
            return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                      content: SizedBox(
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('TURN ON NFC !',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20,
                                      color: Colors.red))
                            ],
                          )));
                });
          } else {
            NfcManager.instance.startSession(onDiscovered: (NfcTag tag) {
              info.mark(_auth.firebaseAuth.currentUser.uid,
                  tag.data['isodep']['identifier'][0]);
              if (Navigator.of(context).canPop() == true) {
                Navigator.pop(context);
                NfcManager.instance.stopSession();
              }
            });
            return showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return AlertDialog(
                      content: SizedBox(
                          height: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.nfc, size: 50),
                              SizedBox(height: 10),
                              Text('Reading NFC',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 20))
                            ],
                          )));
                });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
      ),
    );
  }
}
