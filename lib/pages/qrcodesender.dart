import 'package:flutter/material.dart';

class Qrcodesender extends StatefulWidget {
  final List qrlist;
  Qrcodesender({super.key,required this.qrlist});

  @override
  State<Qrcodesender> createState() => _QrcodesenderState();
}

class _QrcodesenderState extends State<Qrcodesender> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: widget.qrlist.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: 400,
            height: 500,
            child: SizedBox(
              child: Image(image: widget.qrlist[index] as ImageProvider),
            ),
          );
        },
      ),
    );
  }
}