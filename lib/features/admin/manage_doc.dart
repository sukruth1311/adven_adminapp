import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';

import '../../../data/models/document_file.dart';
import 'package:uuid/uuid.dart';

class ManageDocumentsScreen extends StatefulWidget {
  const ManageDocumentsScreen({super.key});

  @override
  State<ManageDocumentsScreen> createState() => _ManageDocumentsScreenState();
}

class _ManageDocumentsScreenState extends State<ManageDocumentsScreen> {
  final _titleCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_titleCtrl.text.trim().isEmpty || _urlCtrl.text.trim().isEmpty) {
      AppSnackbar.show(context, "Please fill all fields", isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final doc = DocumentFile(
        id: const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        url: _urlCtrl.text.trim(),
        isPublic: true,
        uploadedAt: DateTime.now(),
      );
      await FirestoreService.instance.uploadDocument(doc);
      _titleCtrl.clear();
      _urlCtrl.clear();
      AppSnackbar.show(context, "Document added successfully", isSuccess: true);
    } catch (e) {
      AppSnackbar.show(context, "Error: $e", isError: true);
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Manage Documents"),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _titleCtrl,
              label: "Document Title",
              hint: "e.g. Membership Certificate",
              prefixIcon: Icons.description_outlined,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _urlCtrl,
              label: "Document URL",
              hint: "https://...",
              prefixIcon: Icons.link_rounded,
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 28),
            AppButton(
              label: "Add Document",
              loading: _loading,
              onTap: _add,
              icon: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
