import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:videostreaming/creator.dart';
import 'package:videostreaming/profile.dart';
import 'package:videostreaming/signup.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:videostreaming/viewer.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _obscuredText = true;

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  String _userId;

  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _passwordcontroller = TextEditingController();

  _toggle() {
    setState(() {
      _obscuredText = !_obscuredText;
    });
  }

  //google signinButton

  Future<bool> checkIfDocExists(String docId) async {
  try {
    // Get reference to Firestore collection
    var collectionRef = FirebaseFirestore.instance.collection('users');

    var doc = await collectionRef.doc(docId).get();
    return doc.exists;
  } catch (e) {
    throw e;
  }
}

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

  _broker(userUid,emailID) async
  {

     bool docExists = await checkIfDocExists(userUid);
        CollectionReference collectionReference = FirebaseFirestore.instance.collection('users');
        //print("Document exists in Firestore? " + docExists.toString());
        if(docExists)
        {
          print("exists");
           collectionReference.doc(userUid).snapshots().listen((event) {
           Map checkType = event.data();

           if(checkType['userType']=='CREATOR')
           {
             _message("Sucessfully Login!");
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CreatorPage(userUid)));
           }
           else if(checkType['userType']=='VIEWER')
           {
             _message("Sucessfully Login!");
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ViewerPage(userUid)));
           }
           else if(checkType['userType']=='')
           {
             _message("Sucessfully Login!");
             Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ProfilePage(userUid))); 
       
           }
         });      

        }
        else
        {
        Map<String,dynamic> mapData ={"Email":emailID,"Name":"","Number":"",'userType':"","profileImage":""};
        
          
          collectionReference.doc(userUid).set(mapData);

          _message("Sucessfully Login!");

          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ProfilePage(userUid))); 
        }
  }

  goToProfile() {
    
    FocusScope.of(context).unfocus();
    if(_emailcontroller.text.isNotEmpty && _passwordcontroller.text.isNotEmpty)
    {
       FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailcontroller.text, password: _passwordcontroller.text).then((value) async{
        print(value.user.uid);


        if(value.user.emailVerified)
        {
          
            _broker(value.user.uid,_emailcontroller.text);
        }
        else
        {
          
           await value.user.sendEmailVerification().then((value) {
              
            _message("Verification mail sent!");
            } ).catchError((onError){
            _message("Email does't exists!");
              
            });
        }


        
      
        
       
       //_broker(value.user.uid,_emailcontroller.text);


      }).catchError((e){
       _message("Email or Password is wrong!");
      });

      
    }
    else
    {
     _message("Email and Password can't be empty!");
    }

  }

  _signInWithGoogle() async {
    //displays the list of account
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);

    final User user =
        (await firebaseAuth.signInWithCredential(credential)).user;

    _userId = user.uid;
    
    _broker(_userId,user.email);


    
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sign In",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  "Welcome back, we missed you!",
                  style: TextStyle(fontSize: 15.0, color: Colors.black45),
                ),
                SizedBox(
                  height: 40.0,
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailcontroller,
                  onChanged: null,
                  decoration: InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                ),
                SizedBox(
                  height: 30.0,
                ),

                TextField(
                  onChanged: null,
                  controller: _passwordcontroller,
                  obscureText: _obscuredText,
                  decoration: InputDecoration(
                      labelText: "Password",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      suffixIcon: FlatButton(
                          onPressed: _toggle,
                          child: Icon(Icons.remove_red_eye,
                              color: _obscuredText
                                  ? Colors.black12
                                  : Colors.black54))),
                ),

                SizedBox(
                  height: 40.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      elevation: 3.0,
                      child: Text(
                        "LOGIN",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: goToProfile,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ),
                SizedBox(
                  height: 40.0,
                ),

                //divider
                Row(children: <Widget>[
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.only(right: 15.0),
                        child: Divider(
                          color: Colors.black45,
                          height: 50,
                        )),
                  ),
                  Text(
                    "OR",
                    style: TextStyle(
                      color: Colors.black45,
                    ),
                  ),
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.only(left: 15.0),
                        child: Divider(
                          color: Colors.black45,
                          height: 50,
                        )),
                  ),
                ]),
                SizedBox(
                  height: 40.0,
                ),
                //google button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RaisedButton(
                      elevation: 3.0,
                      color: Colors.white,
                      child: Row(
                        children: [
                          Image.asset("images/googlelogo.png",
                              width: 20.0, height: 20.0),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text("Sign in with Google")
                        ],
                      ),
                      onPressed: _signInWithGoogle,
                    )
                  ],
                ),

                SizedBox(
                  height: 40.0,
                ),
                //dont have an account
                RichText(
                    text: TextSpan(
                        text: 'Don\'t have an account?',
                        style: TextStyle(fontSize: 14.0, color: Colors.black),
                        children: [
                      TextSpan(
                        text: ' Sign up',
                        style: TextStyle(color: Colors.blueAccent, fontSize: 14),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignUpPage()));
                          },
                      )
                    ]))
              ],
            ),
          ),
      ),
    ),
        ));
  }
}
