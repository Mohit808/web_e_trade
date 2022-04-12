import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_screenutil/flutter_screenutil.dart';


import 'main.dart';

class WelcomePage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return WelcomePageState();
  }
}
class WelcomePageState extends State<WelcomePage>{


  List list=[];
  @override
  void initState() {
    super.initState();
    getPlans();
  }

  getPlans() async {
    var url = Uri.parse('https://algostart.in/api/get_all_plans');
    var response = await http.get(url);
    String data=response.body;
    var value =jsonDecode(data);
    list=value['data'];

    setState(() {
      list;
    });
    print(list);
    print(list.length);
    print(list[0]['plan_name']);
  }

  @override
  Widget build(BuildContext context) {
    // ScreenUtil.init(
    //     BoxConstraints(
    //         maxWidth: MediaQuery.of(context).size.width,
    //         maxHeight: MediaQuery.of(context).size.height),
    //     designSize: Size(360, 750),
    //     orientation: Orientation.portrait);
    return Scaffold(
        body:
        Container(
          // color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0,right: 24.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: MediaQuery.of(context).size.height/2,child: ListView.builder(itemCount: list.length,itemBuilder: (BuildContext context,int index){
                  return
                    SizedBox(width: MediaQuery.of(context).size.width,height: 50,child:
                    GestureDetector(onTap: (){
                      // Navigator.of(context).push(MaterialPageRoute(builder: (context)=> MyHomePage()));
                      sendRequest(context,index);
                    },child:
                    Container(margin: EdgeInsets.only(bottom: 50),alignment: Alignment.center,decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),color: Colors.red,),
                      child: Text(list[index]['plan_name']+"-  "+list[index]['duration']+" days"+"  Rs: "+list[index]['price'],style: TextStyle(color: Colors.white,fontSize: 16),),),
                    )
                    );

                  //   Column(children: [
                  // Text('Plan: '+list[index]['plan_name']),
                  //   Row(children: [
                  //     Text('duration: '+list[index]['duration']),
                  //     Text('price: '+list[index]['price']),
                  //   ],)
                  // ],);
                }),),
                // Row(mainAxisAlignment: MainAxisAlignment.center,
                //   children: const [
                //     Text('Never Miss a Signal',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 30,color: Colors.white),),
                //   ],
                // ),
                // Row(mainAxisAlignment: MainAxisAlignment.center,
                //   children: const [
                //     Text('Try Web-E-Trade Premium, First 7 day free trial',style: TextStyle(color: Colors.white),),
                //   ],
                // ),

                // SizedBox(width: MediaQuery.of(context).size.width,height: MediaQuery.of(context).size.height/4,child:
                // Container(decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),color: Colors.red,image: DecorationImage(fit: BoxFit.fill,image: NetworkImage("https://image.shutterstock.com/image-vector/business-candle-stick-graph-chart-260nw-1192203445.jpg"))),),),

                // SizedBox(width: MediaQuery.of(context).size.width,height: 50,child:
                //     GestureDetector(onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context)=> MyHomePage()));},child:
                //     Container(alignment: Alignment.center,decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),color: Colors.red,),child: const Text('Try For Free',style: TextStyle(color: Colors.white,fontSize: 16),),),
                //         )
                // ),
                //
                // SizedBox(width: MediaQuery.of(context).size.width,height: 50,child:
                // GestureDetector(onTap: (){Navigator.of(context).push(MaterialPageRoute(builder: (context) => MyHomePage()));},
                //     child: Container(alignment: Alignment.center,decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)),color: Colors.green,),child: const Text('Register Users',style: TextStyle(color: Colors.white,fontSize: 16),),)),),
              ],
            ),
          ),
        ));
  }
  sendRequest(context,index) async {
    var url = Uri.parse('https://algostart.in/api/check_user_login?mobile=${mAuth.currentUser!.phoneNumber.toString().substring(3)}');
    var response = await http.post(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    print(mAuth.currentUser);
    var data=response.body;
    var value=jsonDecode(data);
    if(value['success']==false){
      print('Falseeeee');
      registerUserRequest(context,index);
    }else{
      if(value['data']['is_plan_expired']=='0'){
        print(value['data']['is_plan_expired']);
        FirebaseMessaging.instance.subscribeToTopic("web_e_trade");
        Navigator.of(context).push(MaterialPageRoute(builder: (context)=> MyHomePage()));

      }else{
        print(value['data']['is_plan_expired']);
        Fluttertoast.showToast(msg: 'Free trial has expired, subscribe now');
      }
    }

    // print(await http.read(Uri.parse('https://example.com/foobar.txt')));
  }

  registerUserRequest(context,index) async {
    var url = Uri.parse('https://algostart.in/api/register_user?plan_id=${list[index]['id']}&mobile=${mAuth.currentUser!.phoneNumber.toString().substring(3)}');
    var response = await http.post(url);
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    // print(mAuth.currentUser);
    var data=response.body;
    var value=jsonDecode(data);
    if(value['success']==true){
      print('true');
      FirebaseMessaging.instance.subscribeToTopic("web_e_trade");
      Navigator.of(context).push(MaterialPageRoute(builder: (context)=> MyHomePage()));
    }

    // print(value['data']['is_plan_expired']);

    // print(await http.read(Uri.parse('https://example.com/foobar.txt')));
  }
}


FirebaseAuth mAuth=FirebaseAuth.instance;
// FirebaseFirestore myRef=FirebaseFirestore.instance;
// FirebaseStorage storage=FirebaseStorage.instance;
String myName='';
String myImage='';
String currentUser='';
//
// class Login extends StatefulWidget{
//   @override
//   State<StatefulWidget> createState() {
//     return LoginState();
//   }
// }
// class LoginState extends State<Login>{
//   TextEditingController textEditingController=new TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     String varica="";
//     return Scaffold(
//       body:
//       Center(
//         child: Padding(
//           padding: const EdgeInsets.only(left: 24.0,right: 24),
//           child: Wrap(direction: Axis.vertical,children: [
//             // RaisedButton(onPressed: () async {
//             //   // var value=await FirebaseAuth.instance.signInWithPhoneNumber("+918858459011",RecaptchaVerifier());
//             //   // varica=value.verificationId.toString();
//             //   FirebaseAuth.instance.verifyPhoneNumber(phoneNumber: "+918858459011", verificationCompleted: (abcd) async {
//             //     print(abcd.verificationId);
//             //     varica=abcd.verificationId.toString();
//             //   }, verificationFailed: (add){print("Failed  $add");}, codeSent: (sads,fh){print("==== ${sads} \n====$fh");}, codeAutoRetrievalTimeout: (as){});
//             // }),
//             // TextField(controller: textEditingController,),
//             // RaisedButton(child: Text("otp"),onPressed: () async {
//             //   PhoneAuthCredential css=await PhoneAuthProvider.credential(verificationId: varica, smsCode: textEditingController.text);
//             //   UserCredential user=await FirebaseAuth.instance.signInWithCredential(css);
//             //   print("Signin Ho gya");
//             //   var name=user.additionalUserInfo!.username;
//             //   print("Signin Ho gya after $name");
//             //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()),);
//             // }),
//             Wrap(direction: Axis.vertical,children: [
//               Text('Welcome!',style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
//               Text('Best platform for trading !',style: TextStyle(fontSize: 24,),),
//             ],),
//             SizedBox(child: Padding(
//               padding: const EdgeInsets.only(top: 32.0,bottom: 32),
//               child: Container(
//                 height: 150,
//                 width: MediaQuery.of(context).size.width/1.2,
//                 decoration: const BoxDecoration(
//                   image: DecorationImage(
//                     image: NetworkImage(
//                         'https://media.istockphoto.com/photos/financial-and-technical-data-analysis-graph-picture-id1145882183?k=20&m=1145882183&s=612x612&w=0&h=H30_SGkGv7vsUYaFxzh_uW3_7TaQlqavfaegpKMGl20='),
//                     fit: BoxFit.fill,
//                   ),
//
//                 ),
//               ),
//             ),),
//
//             Padding(
//               padding: const EdgeInsets.only(bottom: 18.0),
//               child: SizedBox(width: MediaQuery.of(context).size.width/1.2,height: 50,
//                 child: Container(padding: EdgeInsets.all(8),color: Colors.blueAccent,child:
//                 TextField(style: TextStyle(color: Colors.white),decoration: new InputDecoration(
//                     hintText: 'Mobile number',hintStyle: TextStyle(color: Colors.white)
//                 ),),),
//               ),
//             ),
//
//             Padding(
//               padding: const EdgeInsets.only(bottom: 18.0),
//               child: SizedBox(width: MediaQuery.of(context).size.width/1.2,height: 50,
//                 child: RaisedButton(color: Colors.blueAccent,child:
//                 Wrap(spacing: 16,
//                   children: [
//                     Icon(Icons.login,color: Colors.white,),
//                     Text('Send Otp',style: TextStyle(color: Colors.white,fontSize: 16),),
//
//                   ],
//                 ),onPressed: () async {
//                   // var value=await FirebaseAuth.instance.signInWithPhoneNumber("+918858459011");
//
//                   // MethodChannel('login').invokeMethod('method',"call");
//                 }),
//               ),
//             ),
//
//             ///////////  google button sizebox//////
//             SizedBox(width: MediaQuery.of(context).size.width/1.2,height: 50,
//               child: RaisedButton(color: Colors.redAccent,child:
//                Wrap(spacing: 16,
//                  children: [
//                    Icon(Icons.login,color: Colors.white,),
//                    Text('Login with Google',style: TextStyle(color: Colors.white,fontSize: 16),),
//                  ],
//                ),onPressed: () async {
//                 GoogleSignIn _googleSignIn = GoogleSignIn();
//                 _googleSignIn.signInSilently();
//                 GoogleSignInAccount?  googleUser=await _googleSignIn.signIn();
//                 GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
//                 AuthCredential credential =GoogleAuthProvider.credential(idToken: googleAuth.idToken,accessToken: googleAuth.accessToken);
//                 UserCredential dfd=await mAuth.signInWithCredential(credential);
//                 print("Hleoooo  ${dfd.user!.displayName}");
//                 print("Hleoooo  ${dfd.additionalUserInfo!.isNewUser}");
//                 Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()),);
//                 // .then((value) => {print(value!.displayName)});
//               }),
//             ),
//
//           ],),
//         ),
//       ),
//     );
//   }
// }
