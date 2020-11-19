import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:videostreaming/drawer.dart';
import 'package:videostreaming/video.dart';

class ViewerPage extends StatefulWidget {
  String uid;
  ViewerPage(this.uid);
  @override
  _ViewerPageState createState() => _ViewerPageState();
}

class _ViewerPageState extends State<ViewerPage> {

  String name="",email="",imageUrl="";



  void initState() {
   
    FirebaseFirestore.instance.collection('users').doc(widget.uid).get().then((user)  {

     name= user["Name"];
     email= user["Email"];
     imageUrl=user["profileImage"];
     setState(() {
       
     });

    });
    super.initState();
  }

  void dispose() {


    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
          child: Scaffold(
        appBar: AppBar(title: Text("Videos"),),
        drawer: DrawerPage(imageUrl,name,email),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("videos").snapshots(),
          builder: (context, snapshot) {
           if(!snapshot.hasData || snapshot.data.documents.isEmpty)
           {
                return Container(child: Center(child: Text("No videos"),));
           }
           else
           {
             return  ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      DocumentSnapshot videoSnapshot = snapshot.data.docs[index];
                      return Container(
                        margin: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        child: GestureDetector(
                          onTap:(){
                           Navigator.push(context, MaterialPageRoute(builder: (context)=>VideoPage(widget.uid,videoSnapshot["videoUrl"],videoSnapshot["videoTitle"],videoSnapshot.id,videoSnapshot["timeStamp"].toString())));
                            
                          },
                                                child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: Image.asset("images/videoicon.png",height: 40.0,width: 40.0,),
                                  title: Text(videoSnapshot["videoTitle"]),
                                  subtitle: Text(videoSnapshot["creatorName"]),
                                  trailing: GestureDetector(
                                      onTap: () {}, child: Icon(Icons.share)),
                                ),
                                Image.network("https://i.insider.com/5d41b075454a397c1a051dd5?width=1000&format=jpeg&auto=webp"),
                                ListTile(title: Text(videoSnapshot["videoDescription"]),),
                          
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: snapshot.data.docs.length);
           }
          },
        ),
      ),
    );
  }
}
