import 'package:conversation/pages/home_page.dart';
import 'package:conversation/signInPage/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    loginStatus();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Container(),
    );
  }

  loginStatus() async{
    var auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    await Future.delayed(Duration(seconds: 2));

    if(user != null){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(uid: user.uid),));
    }
    else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage(),));
    }
  }
}
