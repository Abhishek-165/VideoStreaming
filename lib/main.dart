import 'package:flutter/material.dart';
import 'package:videostreaming/creator.dart';
import 'package:videostreaming/signin.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:videostreaming/viewer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  


  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,


    home: await _firstPage(),

    
    theme: ThemeData(
      primaryColor: Colors.blue,
    ),
  ));
}


  //Return String
   //prefs.setString("pageName",name);
   //prefs.setString("UID", uid);


 Future<Widget> _firstPage() async
{
 SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.getString("pageName")=="CREATOR")
    {
    return CreatorPage(prefs.getString("UID"));
    }
    else if(prefs.getString("pageName")=="VIEWER")
    {
    return ViewerPage(prefs.getString("UID"));
    }
    else
    {
      return SignInPage();
    }
}