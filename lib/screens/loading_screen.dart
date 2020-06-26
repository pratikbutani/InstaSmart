import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Image.asset('assets/images/instasmartLogo.png'),
              height: 100,
              width: 100,
            ),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 45),
            ),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}