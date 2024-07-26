import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RequestScreen extends StatefulWidget {
  @override
  _RequestScreenState createState() => _RequestScreenState();
}

class _RequestScreenState extends State<RequestScreen> {
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
                'Request submitted successfully! Your Request ID is $requestId'),
            backgroundColor: Colors.green,
          ),
        );
        _nameController.clear();
        _emailController.clear();
        _requestController.clear();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit request: $e'),
            backgroundColor: Colors.red,
          ),
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
          SnackBar(
            content: Text('No request found with ID: $requestId'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch request details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyRequestId() {
    Clipboard.setData(ClipboardData(text: _idController.text)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request ID copied to clipboard!'),
          backgroundColor: Colors.blue,
        ),
      );
    });
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Submit a Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _requestController,
                        decoration: InputDecoration(
                          labelText: 'Request Details',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(color: Colors.white70),
                        ),
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
                        style: ElevatedButton.styleFrom(
                          // primary: Colors.blueGrey,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Submit Request'),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.grey[850],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check Request Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _idController,
                      decoration: InputDecoration(
                        labelText: 'Enter Request ID to Check Status',
                        labelStyle: TextStyle(color: Colors.white70),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _fetchRequestDetails(_idController.text),
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.blueGrey,
                        padding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text('Check Status'),
                    ),
                    if (_requestDetails != null) ...[
                      SizedBox(height: 20),
                      Text(
                        'Status: ${_requestDetails!['status']}',
                        style: TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Request: ${_requestDetails!['request']}',
                        style: TextStyle(color: Colors.white),
                      ),
                      if (_requestDetails!['image_url'] != null)
                        Image.network(_requestDetails!['image_url']),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _copyRequestId,
                        style: ElevatedButton.styleFrom(
                          // primary: Colors.blueGrey,
                          padding: EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text('Copy Request ID'),
                      ),
                    ] else if (_requestDetails == null &&
                        _idController.text.isNotEmpty) ...[
                      SizedBox(height: 20),
                      Text(
                        'No request found with this ID.',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
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
