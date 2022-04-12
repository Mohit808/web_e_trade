import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return IntroPageState();
  }
}

class IntroPageState extends State<IntroPage>{
  get listPagesViewModel => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body:
    Container(child: IntroductionScreen(
      pages: listPagesViewModel,
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      color: Colors.orange,
      skipColor: Colors.red,
      doneColor: Colors.green,
      nextColor: Colors.blue,
      onDone: () {
        // When done button is press
      },
    ),),);
  }
}