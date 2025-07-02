import 'dart:async';

import 'package:buz_manager/screens/bussiness_selection.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 1.0;
  @override
  void initState() {
    super.initState();

    //Change opacity
    Timer(Duration(seconds: 1), (){
      setState(() {
        _opacity=0.0;
      });
    });
    //Navigate to Bussiness Selection
    Timer(Duration(seconds: 3), (){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>BuzSelection()),);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade700,
      body: Center(
        child: AnimatedOpacity(opacity: _opacity, duration: Duration(seconds: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business_center,size: 80.0,color: Colors.white,),

            Text('Bussiness Manager', 
            style: TextStyle(
              color: Colors.white, 
              fontSize: 28.0, 
              fontWeight: FontWeight.bold
              ),
            )
          ],
        ),
      ),
      ),
    );
  }
}