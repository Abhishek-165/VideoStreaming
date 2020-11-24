import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:videostreaming/signin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DrawerPage extends StatefulWidget {

  String imageUrl="",name="",email="";
  DrawerPage(this.imageUrl,this.name,this.email);
  @override
  _DrawerPageState createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {

_message(String _msg)
{
  Fluttertoast.showToast(
                                      msg: _msg,
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.SNACKBAR,
                                      backgroundColor: Colors.black,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
}
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
              child: ListView(children: [
                UserAccountsDrawerHeader(currentAccountPicture: CircleAvatar(backgroundImage: NetworkImage(widget.imageUrl),),accountName: Text(widget.name), accountEmail: Text(widget.email)),
                GestureDetector(onTap: () async
                {
                  await FirebaseAuth.instance.signOut().then((value) async{
                    
                SharedPreferences prefs = await SharedPreferences.getInstance();

                prefs.setString("pageName", "");
                prefs.setString("UID", "");
                    _message("Sucessfully Sign out!");
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignInPage()));
                  });
                },child: ListTile(title: Text("Sign out"),trailing: Icon(Icons.logout),))
              ],),
            );
  }
}