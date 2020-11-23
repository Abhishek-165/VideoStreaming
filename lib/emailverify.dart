import 'package:flutter/material.dart';

import 'package:pin_code_fields/pin_code_fields.dart';

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 100),
          child: Column(
            textDirection: TextDirection.rtl,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(50)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        'images/mail-send.png',
                        height: 50,
                        width: 50,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 80,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Email Verification",
                      style: TextStyle(
                          fontSize: 22.0, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              RichText(
                  textAlign: TextAlign.center,
                  softWrap: true,
                  text: TextSpan(children: <TextSpan>[
                    TextSpan(
                        text: "Verification link sent to ",
                        style: TextStyle(color: Colors.black)),
                    TextSpan(
                        text: "abhishek@gmail.com ",
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold))
                  ])),
                   SizedBox(
                height: 40,
              ),
              PinCodeTextField(
                appContext: context,
                onChanged: null,
                length: 4,
                keyboardType: TextInputType.number,
                
                animationType: AnimationType.fade,
                 pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 60,
                        fieldWidth: 50,
                        activeFillColor:Colors.blue,
                        inactiveColor: Colors.blue,
                        selectedColor: Colors.blue,
                        activeColor: Colors.green,
                      ),
              ),
              SizedBox(height: 30.0),
              // RichText(
              //   softWrap: true,
              //   textAlign: TextAlign.center,
              //   text: TextSpan(children:<TextSpan>[
              //   TextSpan(text: "Didn't receive this code"),
              //   TextSpan(text: "RESEND CODE",style: TextStyle(fontWeight:FontWeight.bold))
              // ])),
              Text("Didn't recive any code?",style: TextStyle(fontSize:18.0),),
               SizedBox(height: 20.0,),
          Container(
                          height: 60.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            
            
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow:[ BoxShadow(
                              color: Colors.blue[300],
            blurRadius: 10.0,
                            )]
                          ),
                          child: RaisedButton(
                            child: Text(
                              "Add",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20.0),
                            ),
                            onPressed: null,
                          ),
                        ),
                        SizedBox(height: 20.0,),
                        Text("clear",style: TextStyle(fontSize:18.0),)
            ],
          ),
        ),
      )),
    );
  }
}
