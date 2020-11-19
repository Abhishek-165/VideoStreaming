import 'package:flutter/material.dart';
import 'package:videostreaming/drawer.dart';
import 'package:videostreaming/upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:videostreaming/video.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CreatorPage extends StatefulWidget {

String uid;
  CreatorPage(this.uid);
  @override
  _CreatorPageState createState() => _CreatorPageState();
}

class _CreatorPageState extends State<CreatorPage> {

String name="",email="",imageUrl="";
  

  Icon getIcon(String iconName)
  {
    print(iconName);
    if(iconName=="Public")
                {
                  
                 return Icon(Icons.public);
                } else
                {
                 return Icon(Icons.lock);
                }
  }



_checkLoginStatus() async{
     SharedPreferences prefs = await SharedPreferences.getInstance();
     prefs.setString("uid", widget.uid);

  }

@override
  void initState() {

    
    //_checkLoginStatus();

    FirebaseFirestore.instance.collection('users').doc(widget.uid).get().then((user)  {

     name= user["Name"];
     email= user["Email"];
     imageUrl=user["profileImage"];
     setState(() {
       
     });

    });
    
        super.initState();
  }

  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Scaffold(
            appBar: AppBar(title: Text("Uploads"),actions: [Icon(Icons.notifications),SizedBox(width:10.0),Icon(Icons.search),SizedBox(width:10.0)],),
            drawer: DrawerPage(imageUrl,name,email),
        body:StreamBuilder(
          stream:  FirebaseFirestore.instance.collection('users').doc(widget.uid).collection("videos").snapshots(),
          builder:(context,snapshot)
        {
          print(snapshot.hasData);
          if(!snapshot.hasData || snapshot.data.documents.isEmpty)
          {
            return Container(child: Center(child: Text("upload a video"),));
          }
          else
          {
            return ListView.separated(
            scrollDirection: Axis.vertical,
            itemCount: snapshot.data.documents.length,itemBuilder:(context,index)
          {
          DocumentSnapshot video =
                snapshot.data.documents[index];
                return ListTile(onTap: ()
                {
                  
                 Navigator.push(context, MaterialPageRoute(builder: (context)=>VideoPage(widget.uid,video["videoUrl"],video["videoTitle"],video.id,video["timeStamp"].toString())));
                },leading: Image.asset("images/videoicon.png",height: 40,width: 40,),title: Text(video["videoTitle"]),subtitle: Text(video["videoDescription"]),trailing: Column(children:[Text(video["videoRestriction"]),
                getIcon(video["videoRestriction"])
                ]));
        
          },
          
           separatorBuilder: (context, index) {
            return Divider(thickness: 1.0);
                                              },
          );
          }

        },),floatingActionButton: FloatingActionButton(
          child: Icon(Icons.upload_sharp),
          onPressed: ()
          {
            Navigator.push(context,MaterialPageRoute(builder: (context)=>UploadFile(widget.uid,name)));
          },
        ),
      ),
    );
  }
}