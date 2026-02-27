import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';

class UploadUserDocumentScreen extends StatefulWidget {
  final String userId;
  final String requestId;
  final String type;
  final String title;

  const UploadUserDocumentScreen({
    super.key,
    required this.userId,
    required this.requestId,
    required this.type,
    required this.title,
  });

  @override
  State<UploadUserDocumentScreen> createState() =>
      _UploadUserDocumentScreenState();
}

class _UploadUserDocumentScreenState extends State<UploadUserDocumentScreen> {
  bool _loading = false;

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) return;

    final file = File(result.files.single.path!);

    setState(() => _loading = true);

    await FirestoreService.instance.uploadUserDocument(
      userId: widget.userId,
      requestId: widget.requestId,
      type: widget.type,
      title: widget.title,
      file: file,
    );

    setState(() => _loading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Document uploaded successfully")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Confirmation PDF")),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text("Upload PDF"),
                onPressed: _pickAndUpload,
              ),
      ),
    );
  }
}
