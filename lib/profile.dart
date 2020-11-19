import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:videostreaming/creator.dart';
import 'package:videostreaming/viewer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as Path;

import 'package:modal_progress_hud/modal_progress_hud.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  ProfilePage(this.uid);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  
  TextEditingController _nameController = TextEditingController();
  TextEditingController _numberController = TextEditingController();
  int toggleValue = 0;
  String usertype = "VIEWER";
  File _image;
  final picker = ImagePicker();
  bool showSpinner = false;

  Future getImages() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        print('No image selected.');
      }
    });
  }

  CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('users');

  _nextUserType() {
    
    FocusScope.of(context).unfocus();
    showSpinner= true;
    if (toggleValue == 0) {
      usertype = "VIEWER";
    } else {
      usertype = "CREATOR";
    }

    if (_nameController.text.isNotEmpty && _numberController.text.isNotEmpty && _image!=null) 
    {

      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref("Images/${Path.basename(_image.path)}");
      UploadTask uploadTask = firebaseStorageRef.putFile(_image);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) 
      {

        if (snapshot.state.toString() == "TaskState.running") {
          print("uploading");
        }
        else if(snapshot.state.toString()=="TaskState.success")
        {
          firebaseStorageRef.getDownloadURL().then((_imageUrl)
          {
                  Map<String, dynamic> mapData = {
                  "Name": _nameController.text,
                  "Number": _numberController.text,
                  'userType': usertype,
                  "profileImage":_imageUrl
                };

                collectionReference.doc(widget.uid).update(mapData);

                // Navigator.push(context, MaterialPageRoute(builder: (context)=>ProfilePage(widget.uid)));
                if (usertype == 'CREATOR') 
                {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CreatorPage(widget.uid)));
                } else if (usertype == 'VIEWER') {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => ViewerPage(widget.uid)));
                }
                



          });
        }

      }).onError((){
          Fluttertoast.showToast(
          msg: "Some Technical issue",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    
      });


   
  }
  else {
    showSpinner =false;
      Fluttertoast.showToast(
          msg: "Fields can't be empty!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: ModalProgressHUD
          (
            inAsyncCall: showSpinner,
                      child: Scaffold(
            body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
              child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 100),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Profile",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35.0),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "Let us know about you!",
                style: TextStyle(fontSize: 15.0, color: Colors.black45),
              ),
              SizedBox(
                height: 40.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () {
                      getImages();
                    },
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _image==null?AssetImage("images/profileimage.png"):FileImage(_image),
                      backgroundColor: Colors.white
                    )
                  )
                ],
              ),
              SizedBox(
                height: 40.0,
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                    labelText: "Name",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
              ),
              SizedBox(
                height: 30.0,
              ),
              TextField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Number",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0))),
              ),
              SizedBox(
                height: 30.0,
              ),
              Text(
                "Who are you going to be?",
                style: TextStyle(fontSize: 18.0, color: Colors.black54),
              ),
              SizedBox(
                height: 10.0,
              ),
              Row(
                children: [
                  ToggleSwitch(
                    minWidth: 120.0,
                    initialLabelIndex: toggleValue,
                    inactiveBgColor: Colors.black12,
                    labels: ['VIEWER', 'CREATOR'],
                    icons: [Icons.person, Icons.school],
                    onToggle: (index) {
                      print('switched to: $index');
                      setState(() {
                        toggleValue = index;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 60.0,
              ),
              Container(
                  width: MediaQuery.of(context).size.width,
                  child: RaisedButton(
                      onPressed: _nextUserType,
                      color: Theme.of(context).primaryColor,
                      elevation: 3.0,
                      child: Text(
                        "CONTINUE",
                        style: TextStyle(color: Colors.white),
                      )))
            ]),
        )),
      )),
          ),
    );
  }
}
