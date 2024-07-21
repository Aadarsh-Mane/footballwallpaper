import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _requestController = TextEditingController();
  final _idController = TextEditingController(); // Controller for request ID
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _requestDetails; // To hold request details

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      try {
        final requestRef = await _firestore.collection('requests').add({
          'name': _nameController.text,
          'email': _emailController.text,
          'request': _requestController.text,
          'status': 'Pending',
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Generate and store the unique ID for the request
        final requestId = requestRef.id;
        await requestRef.update({'request_id': requestId});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Request submitted successfully! Your Request ID is $requestId')),
        );
        _nameController.clear();
        _emailController.clear();
        _requestController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: $e')),
        );
      }
    }
  }

  Future<void> _fetchRequestDetails(String requestId) async {
    try {
      final requestDoc =
          await _firestore.collection('requests').doc(requestId).get();
      if (requestDoc.exists) {
        setState(() {
          _requestDetails = requestDoc.data();
        });
      } else {
        setState(() {
          _requestDetails = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No request found with ID: $requestId')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch request details: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Request Wallpaper'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: _nameController,
                      decoration: InputDecoration(
                          labelText: 'Name', focusColor: Colors.white),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      style: TextStyle(color: Colors.white),
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _requestController,
                      decoration: InputDecoration(labelText: 'Request Details'),
                      maxLines: 5,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter request details';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submitRequest,
                      child: Text('Submit Request'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _idController,
                decoration: InputDecoration(
                    labelText: 'Enter Request ID to Check Status'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _fetchRequestDetails(_idController.text),
                child: Text('Check Status'),
              ),
              if (_requestDetails != null) ...[
                SizedBox(height: 20),
                Text('Status: ${_requestDetails!['status']}'),
                Text('Request: ${_requestDetails!['request']}'),
                if (_requestDetails!['image_url'] != null)
                  Image.network(_requestDetails!['image_url']),
                // Add any additional fields you have in your request documents
              ] else if (_requestDetails == null &&
                  _idController.text.isNotEmpty) ...[
                SizedBox(height: 20),
                Text('No request found with this ID.'),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
