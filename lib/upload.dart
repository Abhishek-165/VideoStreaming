import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chewie/chewie.dart';

class UploadFile extends StatefulWidget {
  String uid,creatorName;
  UploadFile(this.uid,this.creatorName);

  @override
  _UploadFileState createState() => _UploadFileState();
}

class _UploadFileState extends State<UploadFile> {
  File _video;
  final picker = ImagePicker();
  VideoPlayerController _videoController;

  bool showSpinner = false;

  String _acessSpecifier = "Public";

  String _cloudUrl;

  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();

  _message(String _msg) {
    Fluttertoast.showToast(
        msg: _msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  Future getVideo() async {
    final pickedFile = await picker.getVideo(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _video = File(pickedFile.path);
        _videoController = VideoPlayerController.file(_video)
          ..initialize().then((value) {
            setState(() {});
            _videoController.pause();
          });
      } else {
        print('No image selected.');
      }
    });
  }

  _saveFile() async {
    FocusScope.of(context).unfocus();
    if (_title.text.isNotEmpty && _description.text.isNotEmpty) {
      setState(() {
        showSpinner = true;
      });
      Reference firebaseStorageRef = FirebaseStorage.instance
          .ref("Videos/${Path.basename(_video.path)}.mp4");
      UploadTask uploadTask = firebaseStorageRef.putFile(_video);

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.state.toString() == "TaskState.running") {
          print("uploading");
        }
        if (snapshot.state.toString() == "TaskState.success") {
          DateTime dateTime = DateTime.now();

          firebaseStorageRef.getDownloadURL().then((_cloudUrl) {
            if (_acessSpecifier == "Public") {
              //public
              Map<String, dynamic> publicDocument = {
                "videoTitle": _title.text,
                "videoDescription": _description.text,
                "videoRestriction": _acessSpecifier,
                "videoUrl": _cloudUrl,
                "uploaderId": widget.uid,
                "timeStamp": dateTime,
                "creatorName":widget.creatorName
              };

              CollectionReference collectionReference =
                  FirebaseFirestore.instance.collection('videos');

              collectionReference.add(publicDocument).then((value) {
                Map<String, dynamic> restrictedDocument = {
                  "videoTitle": _title.text,
                  "videoDescription": _description.text,
                  "videoRestriction": _acessSpecifier,
                  "videoUrl": _cloudUrl,
                  "timeStamp": dateTime
                };

                CollectionReference privateResRef =
                    FirebaseFirestore.instance.collection('users');
                privateResRef
                    .doc(widget.uid)
                    .collection("videos")
                    .doc(value.id)
                    .set(restrictedDocument);
              });
            } else {
              // private
              Map<String, dynamic> restrictedDocument = {
                "videoTitle": _title.text,
                "videoDescription": _description.text,
                "videoRestriction": _acessSpecifier,
                "videoUrl": _cloudUrl,
                "timeStamp": dateTime
              };

              CollectionReference privateResRef =
                  FirebaseFirestore.instance.collection('users');
              privateResRef
                  .doc(widget.uid)
                  .collection("videos")
                  .doc()
                  .set(restrictedDocument);
            }
          });

          //Next Page with message

          setState(() {
            showSpinner = false;

            _message("Sucessfully Uploaded !");
          });
          Navigator.pop(context);
        }
      }, onError: (Object e) {
        showSpinner = false;

        _message("Uploading Failed !"); // FirebaseException
      });
    } else {
      _message("Fields Can't be empty");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload a video"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
                child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _video == null
                      ? GestureDetector(
                          onTap: getVideo,
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  10.0,
                                ),
                                color: Colors.grey[300]),
                            margin: EdgeInsets.symmetric(vertical: 10.0),
                            height: 150.0,
                            child: Center(
                                child: Image.asset(
                              "images/add.png",
                              color: Colors.grey[600],
                              height: 80,
                              width: 80,
                            )),
                          ),
                        )
                      : Container(
                        height: 195,
                                                child: Chewie(
                            controller: ChewieController(
                            videoPlayerController: _videoController,
                            aspectRatio: 16 / 9,
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
                          )),
                      ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: _title,
                    decoration: InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  TextField(
                    controller: _description,
                    keyboardType: TextInputType.multiline,
                    minLines: 4, //Normal textInputField will be displayed
                    maxLines: 10,
                    decoration: InputDecoration(
                        labelText: "Description",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0))),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Choose who can see your video.",
                                style: TextStyle(fontSize: 18.0),
                              ),
                              SizedBox(
                                height: 15.0,
                              ),
                             _acessSpecifier=="Public"? Text(
                                  "With this option only you can see this video"):Text("With this option everyone can see this video")
                            ]),
                      ),
                      Expanded(
                        child: Column(children: [
                          DropdownButton<String>(
                            value: _acessSpecifier,
                            items: <String>['Public', 'Private']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _acessSpecifier = value;
                                setState(() {
                                  
                                });
                              });
                            },
                          )
                        ]),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Container(
                      width: MediaQuery.of(context).size.width,
                      child: RaisedButton(
                          elevation: 3.0,
                          onPressed: _saveFile,
                          child: Text(
                            "SAVE",
                            style: TextStyle(color: Colors.white),
                          ),
                          color: Theme.of(context).primaryColor)),
                ],
              ),
            )),
          ),
        ),
      ),
    );
  }
}
