import 'dart:convert';

import 'package:flutter/material.dart';

class view extends StatelessWidget {
  final dynamic input;

  view({super.key, required this.input}) ;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
          
          Text(input['name']),

          ElevatedButton(onPressed: (){


          }, child: Text('Send Mail'))
        
        ])),
      ),
    );
  }
}
