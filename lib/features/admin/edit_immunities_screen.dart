import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';

import '../../../data/models/app_user.dart';

class EditImmunitiesScreen extends StatefulWidget {
  final AppUser user;
  const EditImmunitiesScreen({super.key, required this.user});

  @override
  State<EditImmunitiesScreen> createState() => _EditImmunitiesScreenState();
}

class _EditImmunitiesScreenState extends State<EditImmunitiesScreen> {
  late Map<String, bool> immunities;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    immunities = Map.from(widget.user.immunities);
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      await FirestoreService.instance.updateImmunities(
        widget.user.id,
        immunities,
      );
      if (mounted) {
        AppSnackbar.show(
          context,
          "Immunities updated successfully",
          isSuccess: true,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AppSnackbar.show(context, "Error: $e", isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final keys = immunities.keys.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Edit Immunities"),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Facilities & Immunities",
                      style: AppTextStyles.headingSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Toggle facilities for ${widget.user.name.isEmpty ? 'this user' : widget.user.name}",
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    ...keys.asMap().entries.map((entry) {
                      final key = entry.value;
                      final isLast = entry.key == keys.length - 1;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      (immunities[key] ?? false)
                                          ? Icons.check_circle_rounded
                                          : Icons
                                                .radio_button_unchecked_rounded,
                                      color: (immunities[key] ?? false)
                                          ? AppColors.primary
                                          : AppColors.border,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(key, style: AppTextStyles.bodyLarge),
                                  ],
                                ),
                                Switch.adaptive(
                                  value: immunities[key] ?? false,
                                  onChanged: (value) {
                                    setState(() => immunities[key] = value);
                                  },
                                  activeColor: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                          if (!isLast) const Divider(height: 1),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: AppButton(
              label: "Save Changes",
              loading: _loading,
              onTap: _save,
              icon: const Icon(
                Icons.save_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
