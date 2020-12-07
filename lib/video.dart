import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'constants.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewie/chewie.dart';

import 'package:flutter/services.dart' ;
 


class VideoPage extends StatefulWidget {
  String id, link, title, userSecondId, timeStamp;

  VideoPage(this.id, this.link, this.title, this.userSecondId, this.timeStamp);
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  TextEditingController _commentController = TextEditingController();
  VideoPlayerController _videoPlayerController1;
  ChewieController _chewieController;
  
  Future<void> _initialVideoPlayer;

  void initState() {
    _videoPlayerController1 = VideoPlayerController.network(widget.link);
    _initialVideoPlayer = _videoPlayerController1.initialize();
    super.initState();

  }

  void dispose() {
    _videoPlayerController1.dispose();
    _chewieController.dispose();
    super.dispose();
  }


  _message(String _msg) {
    Fluttertoast.showToast(
        msg: _msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  _writeComment()
  {
      
                    if (_commentController.text.isNotEmpty) {
                      DateTime dateTime = DateTime.now();

                      print("Data " + _commentController.text);
                      CollectionReference userNameReference =
                          FirebaseFirestore.instance.collection('users');
                      userNameReference
                          .doc(widget.id)
                          .get()
                          .then((userName) {
                        Map<String, dynamic> commentData = {
                          "userComment": _commentController.text,
                          "userName": userName["Name"],
                          "userId": widget.id,
                          "timeStamp": dateTime
                        };

                        CollectionReference collectionReference =
                            FirebaseFirestore.instance
                                .collection("videos")
                                .doc(widget.userSecondId)
                                .collection("Comments");
                        collectionReference
                            .doc()
                            .set(commentData)
                            .then((value) {
                          _commentController.clear();
                        });
                      });
                      //Map<String,dynamic> commentData ={"userName":"Abhishek","userComment":_commentController.text,};

                      //CollectionReference collectionReference = FirebaseFirestore.instance.collection('users').doc(widget.id).collection("videos").doc(widget.userSecondId).collection("Comments");
                      //collectionReference.doc().set(commentData);

                    } else {
                      _message("Please write a comment");
                    }
  }

  bool isEnabled = false;

  @override
  Widget build(BuildContext context) {



var isPortrait = MediaQuery.of(context).orientation;
    
  
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text("Uploads"),
        actions: [
          Icon(Icons.notifications),
          SizedBox(width: 10.0),
          Icon(Icons.search),
          SizedBox(width: 10.0)
        ],
      ),
      
      body: SafeArea(
              child: isPortrait==Orientation.portrait? Container(
            
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            
        mainAxisSize: MainAxisSize.min,
              
                  
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              FutureBuilder(
                  future: _initialVideoPlayer,
                  builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the VideoPlayer.
            return Container(
              
            height: 195,
                child: Chewie(
                  controller:  ChewieController(
              	videoPlayerController: _videoPlayerController1,     
              	aspectRatio: 16/9,
              	autoPlay: false,
              	looping: true,      
              	errorBuilder: (context, errorMessage) {
                  	return Center(
        		child: Padding(
            		padding: const EdgeInsets.all(8.0),
            		child: Text(
              			errorMessage,
              			style: TextStyle(color: Colors.white),
            		),
        		),
                  	);
              	},
  	)
              ),
            );
        } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Center(child: CircularProgressIndicator());
        }
                  },
              ),
              //title

              ListTile(
                  title: Text(
        widget.title,
        style: TextStyle(fontSize: 18.0),
                  ),
                  subtitle: Text(widget.timeStamp),
              ),

              Divider(
                  thickness: 1.0,
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text("Comments",
            style:
                  TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
              ),
              Divider(
                  thickness: 1.0,
              ),
              Expanded(child: buildStreamBuilder()),
              Container(
        decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.blue, width: 2.0),
            ),
        ),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: kMessageTextFieldDecoration,
                   
                  ),
              ),
              FlatButton(
                  
                  onPressed:_writeComment,
                  child: Icon(
                    Icons.send,
                    color: Colors.blue,
                  ),
              )
            ],
        )),
                  ],
              ),
          )




:Text("hello")




 ),
    ));
  }

  StreamBuilder<QuerySnapshot> buildStreamBuilder() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("videos")
          .doc(widget.userSecondId)
          .collection("Comments")
          .snapshots(),
      builder: (context, snapshot) {
        return !snapshot.hasData
            ? Container(
                child: Center(
                  child: Text("No Comments..."),
                ),
              )
            : ListView.separated(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot video = snapshot.data.docs[index];
                  return ListTile(
                      leading: Image.asset(
                        "images/videoicon.png",
                        height: 40,
                        width: 40,
                      ),
                      title: Text(video["userName"]),
                      subtitle: Text(video["userComment"]));
                },
                separatorBuilder: (context, index) {
                  return Divider(thickness: 1.0);
                },
              );
      },
    );
  }
}
