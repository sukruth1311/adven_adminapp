import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';

import '../../data/models/offer.dart';
import 'package:uuid/uuid.dart';

class ManageOffersScreen extends StatefulWidget {
  const ManageOffersScreen({super.key});

  @override
  State<ManageOffersScreen> createState() => _ManageOffersScreenState();
}

class _ManageOffersScreenState extends State<ManageOffersScreen> {
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  DateTime? _validTill;
  bool _loading = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    if (_titleCtrl.text.trim().isEmpty ||
        _descriptionCtrl.text.trim().isEmpty) {
      AppSnackbar.show(context, "Please fill all fields", isError: true);
      return;
    }
    if (_validTill == null) {
      AppSnackbar.show(
        context,
        "Please select a valid-till date",
        isError: true,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final offer = Offer(
        id: const Uuid().v4(),
        title: _titleCtrl.text.trim(),
        description: _descriptionCtrl.text.trim(),
        isActive: true,
        validTill: _validTill!,
        createdAt: DateTime.now(),
      );
      await FirestoreService.instance.createOffer(offer);
      _titleCtrl.clear();
      _descriptionCtrl.clear();
      setState(() => _validTill = null);
      AppSnackbar.show(context, "Offer added successfully", isSuccess: true);
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
        title: const Text("Manage Offers"),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              controller: _titleCtrl,
              label: "Offer Title",
              hint: "e.g. Summer Special",
              prefixIcon: Icons.local_offer_outlined,
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _descriptionCtrl,
              label: "Description",
              hint: "Describe the offer...",
              prefixIcon: Icons.notes_rounded,
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            DatePickerButton(
              label: "Valid Till",
              value: _validTill,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                      ),
                    ),
                    child: child!,
                  ),
                );
                if (picked != null) setState(() => _validTill = picked);
              },
            ),
            const SizedBox(height: 28),
            AppButton(
              label: "Add Offer",
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
