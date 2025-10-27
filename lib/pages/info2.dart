import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class view2 extends StatelessWidget {
  final dynamic input;

  view2({super.key, required this.input});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(input['email'] ?? 'None'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Ensure email is not null or empty before querying
                          final String? email = input['email'];
                          if (email == null || email.isEmpty) {
                            Fluttertoast.showToast(msg: 'Email is missing.');
                            return;
                          }
                      
                          try {
                            // Find all documents in 'members' collections with this email
                            final querySnapshot = await FirebaseFirestore.instance
                                .collectionGroup('members')
                                .where('email', isEqualTo: email)
                                .get();
                      
                            if (querySnapshot.docs.isEmpty) {
                              Fluttertoast.showToast(
                                  msg: 'No members found with that email.');
                              return;
                            }
                      
                            // Use a batch write to update all found documents at once
                            final batch = FirebaseFirestore.instance.batch();
                            
                            for (var doc in querySnapshot.docs) {
                              // Update the 'status' field to 'active'
                              // You can change 'active' to whatever status you need
                                final data = doc.data() as Map<String, dynamic>;
                                final wants = data['refreshmentsClaimed'];
                                if (wants == false) {
                                Fluttertoast.showToast(msg: 'Refreshments not available');
                                } else {
                                batch.update(doc.reference, {'refreshmentsClaimed': false});
                                }
                            }
                      
                            // Commit all the changes in the batch
                            await batch.commit();
                      
                            Fluttertoast.showToast(
                                msg:
                                    'Updated status for ${querySnapshot.docs.length} membership(s).');
                          } catch (e) {
                            Fluttertoast.showToast(msg: 'Error updating status: $e');
                          }
                        },
                        child: Text('Change Refreshment status', textAlign: TextAlign.center,),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
