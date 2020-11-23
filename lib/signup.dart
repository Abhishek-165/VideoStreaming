import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:videostreaming/signin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

    bool _obscuredText = true; 

  _toggle(){
    setState(() {
      _obscuredText = !_obscuredText;
    });
  }


  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
   
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
  _signUp()
  {
    FocusScope.of(context).unfocus();
    if(_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty)
    {
      FirebaseAuth.instance.createUserWithEmailAndPassword(email:_emailController.text , password: _passwordController.text).then((value) async{
      
      // Fluttertoast.showToast(
      //                                 msg: "Sucessfully Created !",
      //                                 toastLength: Toast.LENGTH_SHORT,
      //                                 gravity: ToastGravity.SNACKBAR,
      //                                 backgroundColor: Colors.black,
      //                                 textColor: Colors.white,
      //                                 fontSize: 16.0);
      await value.user.sendEmailVerification().then((value) {
              
            _message("Verification mail sent!");

            
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignInPage()));

            } ).catchError((onError){
            _message("Email does't exists!");
              
            });


    }).catchError((onError){
       _message("Account Already Exists");
                                
    }).timeout(Duration(seconds: 10),
    onTimeout: ()
    {
       _message("Check Internet Connectivity");
                                
    });
    }
    else
    {
      _message("Email and Passowrd can't be empty");
    }
    }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:SafeArea(
              child: GestureDetector(
          onTap: () => FocusScope.of(context)
              .unfocus(),
                child: SingleChildScrollView(child: Container(padding: EdgeInsets.symmetric(horizontal:40.0,vertical:100),child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text("Sign Up",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 35.0),),
            SizedBox(height: 10.0,),
            Text("Join our community!",style: TextStyle(fontSize: 15.0,color: Colors.black45),),
            SizedBox(height: 40.0,),
            TextField(controller: _emailController,decoration: InputDecoration(labelText: "Email",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0))),),
            SizedBox(height: 30.0,),
            TextField(controller:_passwordController,
          obscureText: _obscuredText,decoration: InputDecoration(labelText: "Password",border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),suffixIcon: FlatButton(onPressed: _toggle, child:Icon(Icons.remove_red_eye, color: _obscuredText ? Colors.black12 : Colors.black54))
          ),),
           SizedBox(height: 40.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaisedButton(elevation: 3.0,child: Text("SIGN UP",style: TextStyle(color: Colors.white),),onPressed: _signUp,color: Theme.of(context).primaryColor,),
            ],
            
          ),
          SizedBox(height: 60.0,),

  
     //Already have an account
     RichText(text:TextSpan(text:'Already have an account?',style: TextStyle(fontSize: 14.0,color: Colors.black),children:[
  TextSpan(text: ' Login', style: TextStyle(color: Colors.blueAccent, fontSize: 14),recognizer: TapGestureRecognizer()..onTap=(){
     Navigator.push(context, MaterialPageRoute(builder: (context)=>SignInPage()));
  }
        )
] ))
          ],),),),
        ),
      )
    );
 
  }
}