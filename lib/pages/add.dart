import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

// A simple data class to hold the information for each person.
class Person {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool wantsRefreshments = false;

  // A method to dispose of the controllers to prevent memory leaks.
  void dispose() {
    nameController.dispose();
    numberController.dispose();
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
    // Start with one member entry by default.
    _addMember();
  }

  // Function to add a new person to the list.
  void _addMember() {
    setState(() {
      _teamMembers.add(Person());
    });
  }

  // Function to remove a person from the list.
  void _removeMember(int index) {
    // Dispose controllers before removing to avoid memory leaks
    _teamMembers[index].dispose();
    setState(() {
      _teamMembers.removeAt(index);
    });
  }

  @override
  void dispose() {
    // Dispose of the team name controller.
    _teamNameController.dispose();
    // Dispose of all controllers in the team members list.
    for (var member in _teamMembers) {
      member.dispose();
    }
    super.dispose();
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
                // Team Name Text Field
                TextFormField(
                  controller: _teamNameController,
                  decoration: const InputDecoration(
                    labelText: 'Team Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.group),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a team name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Header for the members list
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
                    // Add member button
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
                // List of Team Members
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _teamMembers.length,
                  itemBuilder: (context, index) {
                    return MemberInputCard(
                      key: ValueKey(index), // Important for list state management
                      person: _teamMembers[index],
                      onRemove: () => _removeMember(index),
                      isRemoveButtonEnabled: _teamMembers.length > 1,
                    );
                  },
                ),
                const SizedBox(height: 30),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                      try {
                        // Get Firestore instance
                        final firestore = FirebaseFirestore.instance;
                        
                        // Create a new team document with team name as the ID
                        final teamDoc = firestore.collection('teams').doc(_teamNameController.text);
                        
                        // Save team data
                        await teamDoc.set({
                        'teamName': _teamNameController.text,
                        'memberCount': _teamMembers.length,
                        'createdAt': FieldValue.serverTimestamp(),
                        });

                        // Save each member in a subcollection
                        for (var member in _teamMembers) {
                        await teamDoc.collection('members').doc(member.emailController.text).set({
                          'name': member.nameController.text,
                          'number': member.numberController.text,
                          'email': member.emailController.text,
                          'wantsRefreshments': member.wantsRefreshments,
                          'status':false
                        });
                        }

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Team saved successfully!')),
                        );
                        for(var member in _teamMembers){
                          qrcodes.add(PrettyQrView(qrImage: QrImage(QrCode.fromData(data: '{"name" : "${member.nameController.text}"}', errorCorrectLevel: QrErrorCorrectLevel.L))));
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
              controller: widget.person.numberController,
              decoration: const InputDecoration(labelText: 'Number'),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value!.isEmpty ? 'Please enter a number' : null,
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
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Opted for Refreshments'),
              value: widget.person.wantsRefreshments,
              onChanged: (bool value) {
                setState(() {
                  widget.person.wantsRefreshments = value;
                });
              },
              activeColor: Colors.deepPurple,
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
  
}


