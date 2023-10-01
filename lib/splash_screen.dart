import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:machine_test_lilac/home_screen.dart';
import 'package:machine_test_lilac/login_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isGranted = true;

  @override
  void initState() {

    navigatePage();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    requestStoragePermission();
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text(
          'Flutter App',
          style: TextStyle(color: Colors.black, fontSize: 25,fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void navigatePage() async {
    SharedPreferences sharedpref = await SharedPreferences.getInstance();
    String token = sharedpref.getString("uuid").toString();
    Timer(
        const Duration(seconds: 3),
            () => {
          if(token.isEmpty||token == "null"){
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const LoginScreen()))
          }
          else{
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>  HomeScreen(vidlist: "",)))
          }

        });
  }

  requestStoragePermission() async {
    if (!await Permission.storage.isGranted) {
      PermissionStatus result = await Permission.storage.request();
      if (result.isGranted) {
        setState(() {
          _isGranted = true;
        });
      } else {
        setState(() {
          _isGranted = false;
        });
      }
    }
  }
}
