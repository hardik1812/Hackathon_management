import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

// A simple data class to hold the information for each person.
class Person {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  void dispose() {
    nameController.dispose();
    emailController.dispose();
  }
}

class AddData extends StatefulWidget {
  const AddData({super.key});

  @override
  State<AddData> createState() => _AddDataState();
}

class _AddDataState extends State<AddData> {
  final _teamNameController = TextEditingController();
  final List<Person> _teamMembers = [];
  final List qrcodes=[];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _addMember();
  }

  void _addMember() {
    setState(() {
      _teamMembers.add(Person());
    });
  }

  void _removeMember(int index) {
    _teamMembers[index].dispose();
    setState(() {
      _teamMembers.removeAt(index);
    });
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    for (var member in _teamMembers) {
      member.dispose();
    }
    super.dispose();
  }

  // New function to check if email exists
  Future<bool> _emailExists(String email) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collectionGroup('members')
        .where('email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Team'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _teamNameController,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Please enter a team name' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Team Members',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      onPressed: _addMember,
                      icon: const Icon(Icons.add),
                      tooltip: 'Add Member',
                    ),
                  ],
                ),
                const Divider(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _teamMembers.length,
                  itemBuilder: (context, index) {
                    return MemberInputCard(
                      key: ValueKey(index),
                      person: _teamMembers[index],
                      onRemove: () => _removeMember(index),
                      isRemoveButtonEnabled: _teamMembers.length > 1,
                    );
                  },
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          // Check for duplicate emails
                          for (var member in _teamMembers) {
                            if (await _emailExists(member.emailController.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Email ${member.emailController.text} is already registered')),
                              );
                              return;
                            }
                          }

                          final firestore = FirebaseFirestore.instance;
                          final teamDoc = firestore.collection('teams').doc(_teamNameController.text);
                          
                          await teamDoc.set({
                            'teamName': _teamNameController.text,
                            'memberCount': _teamMembers.length,
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          for (var member in _teamMembers) {
                            await teamDoc.collection('members').doc(member.emailController.text).set({
                              'name': member.nameController.text,
                              'email': member.emailController.text,
                              'status': false,
                              'refreshmentsClaimed': true
                            });
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Team saved successfully!')),
                          );
                          
                          for(var member in _teamMembers){
                            qrcodes.add(PrettyQrView(qrImage: QrImage(QrCode.fromData(
                              data: '{"name" : "${member.nameController.text}"}',
                              errorCorrectLevel: QrErrorCorrectLevel.L
                            ))));
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error saving team: $e')),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Team', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// A reusable widget for each team member's input fields.
class MemberInputCard extends StatefulWidget {
  final Person person;
  final VoidCallback onRemove;
  final bool isRemoveButtonEnabled;

  const MemberInputCard({
    super.key,
    required this.person,
    required this.onRemove,
    required this.isRemoveButtonEnabled,
  });

  @override
  State<MemberInputCard> createState() => _MemberInputCardState();
}

class _MemberInputCardState extends State<MemberInputCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('New Member', style: TextStyle(fontWeight: FontWeight.bold)),
                if (widget.isRemoveButtonEnabled)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: widget.onRemove,
                    tooltip: 'Remove Member',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: widget.person.nameController,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a name' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: widget.person.emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value!.isEmpty) return 'Please enter an email';
                if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
  
}


