import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:manager_hackathon/pages/add.dart';
import 'package:manager_hackathon/pages/info.dart';



class homeapp extends StatelessWidget {
  const homeapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) { // This context is a descendant of MaterialApp
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AiBarcodeScanner(
                              overlayConfig: ScannerOverlayConfig(
                                borderColor: Colors.blue,
                                scannerAnimation: ScannerAnimation.center
                              ),
                              galleryIcon: Icons.photo,
                              cameraSwitchIcon: Icons.switch_camera_outlined,
                              flashOffIcon: Icons.flash_on,
                              
                              onDetect: (BarcodeCapture capture) async{
                                if (capture.barcodes.isNotEmpty) {
                                  final String? code = capture.barcodes.first.rawValue;
                                  if (code != null) {
                                    // Pop the scanner screen
                                    Navigator.of(context).pop();
                                    try{
                                    final code2=jsonDecode(code);
                                     await Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => view(input: code2)),
                                    );
                                    }catch(e){
                                      await Navigator.push(
                                       context,
                                       MaterialPageRoute(builder: (context) => homeapp()),
                                       );
                                      Fluttertoast.showToast(msg: 'Invalid Qr');
              
                                    }
                                   
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                      child: const Text('Qr Code', textAlign: TextAlign.center),
                    ),
                  ),
                  Padding(padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(onPressed: (){
                    Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => AddData()),
                     );
                  }, child: Text("Add data")),
                  ),
                  
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
