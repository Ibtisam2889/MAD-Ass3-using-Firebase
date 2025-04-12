import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class LocationNotesScreen extends StatefulWidget {
  const LocationNotesScreen({super.key});

  @override
  _LocationNotesScreenState createState() => _LocationNotesScreenState();
}

class _LocationNotesScreenState extends State<LocationNotesScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  Stream<QuerySnapshot> _locationNotesStream =
      FirebaseFirestore.instance.collection('location_notes').snapshots();

  Future<void> _addNoteDialog(BuildContext context) async {
    final _nameController = TextEditingController();
    final _addressController = TextEditingController();
    File? _localImage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Note', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 20),
              _localImage != null
                  ? Image.file(_localImage!, height: 100, width: 100)
                  : Text('No image selected', style: TextStyle(color: Colors.redAccent)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _localImage = File(pickedFile.path);
                        });
                      }
                    },
                    child: Text('Pick Image'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () async {
                      final capturedFile = await _picker.pickImage(source: ImageSource.camera);
                      if (capturedFile != null) {
                        setState(() {
                          _localImage = File(capturedFile.path);
                        });
                      }
                    },
                    child: Text('Capture Image'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('location_notes').add({
                  'name': _nameController.text,
                  'address': _addressController.text,
                  'date': DateTime.now().toIso8601String(),
                  'image_path': _localImage?.path,
                });
                Navigator.pop(context);
              },
              child: Text('Save', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateNoteDialog(BuildContext context, DocumentSnapshot note) async {
    final _nameController = TextEditingController(text: note['name']);
    final _addressController = TextEditingController(text: note['address']);
    File? _localImage = note['image_path'] != null ? File(note['image_path']) : null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Update Note', style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 20),
              _localImage != null
                  ? Image.file(_localImage!, height: 100, width: 100)
                  : Text('No image selected', style: TextStyle(color: Colors.redAccent)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        setState(() {
                          _localImage = File(pickedFile.path);
                        });
                      }
                    },
                    child: Text('Pick Image'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final capturedFile = await _picker.pickImage(source: ImageSource.camera);
                      if (capturedFile != null) {
                        setState(() {
                          _localImage = File(capturedFile.path);
                        });
                      }
                    },
                    child: Text('Capture Image'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.black, fontSize: 16)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance.collection('location_notes').doc(note.id).update({
                  'name': _nameController.text,
                  'address': _addressController.text,
                  'date': DateTime.now().toIso8601String(),
                  'image_path': _localImage?.path,
                });
                Navigator.pop(context);
              },
              child: Text('Save', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.greenAccent,
        title: Text('Location Notes'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _locationNotesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No location notes available'));
          }
          final notes = snapshot.data!.docs;
          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  leading: note['image_path'] != null
                      ? Image.file(File(note['image_path']), width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 50, color: Colors.grey),
                  title: Text(note['name'] ?? 'No Name'),
                  subtitle: Text(note['address'] ?? 'No Address'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _updateNoteDialog(context, note),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('location_notes')
                              .doc(note.id)
                              .delete();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNoteDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

