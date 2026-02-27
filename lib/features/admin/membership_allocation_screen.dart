import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';

class MembershipAllocationScreen extends StatefulWidget {
  final String userId;
  final String requestId;
  final String requestedPackage;
  final String? packageRequestId;

  const MembershipAllocationScreen({
    super.key,
    required this.userId,
    required this.requestId,
    required this.requestedPackage,
    this.packageRequestId,
  });

  @override
  State<MembershipAllocationScreen> createState() =>
      _MembershipAllocationScreenState();
}

class _MembershipAllocationScreenState
    extends State<MembershipAllocationScreen> {
  int selectedYears = 5;
  bool Insurance = true;
  bool gym = true;
  bool swimmingPool = true;
  bool eventpass = true;
  bool resortAccess = true;
  bool banquetAccess = true;
  bool complimentPlot = true;
  bool manualExpiry = false;
  DateTime? customExpiry;
  bool loading = false;

  DateTime _calculateExpiry() {
    if (manualExpiry && customExpiry != null) return customExpiry!;
    return DateTime.now().add(Duration(days: 365 * selectedYears));
  }

  Future<void> _allocate() async {
    setState(() => loading = true);
    try {
      final expiry = _calculateExpiry();
      final totalHolidays = selectedYears * 7;

      await FirestoreService.instance.allocateMembership(
        userId: widget.userId,
        membershipName: "$selectedYears Years",
        membershipId: "${selectedYears}_years",
        expiryDate: expiry,
        immunities: {
          "Insurance": Insurance,
          "gym": gym,
          "swimmingPool": swimmingPool,
          "complimentPlot": complimentPlot,
          "eventpass": eventpass,
          "resortAccess": resortAccess,
          "banquetAccess": banquetAccess,
        },
        requestId: widget.requestId,
        packageRequestId: widget.packageRequestId,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
            "totalHolidays": totalHolidays,
            "usedHolidays": 0,
            "remainingHolidays": totalHolidays,
          });

      if (mounted) {
        AppSnackbar.show(
          context,
          "Membership allocated successfully!",
          isSuccess: true,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AppSnackbar.show(context, "Error: $e", isError: true);
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final int totalHolidays = selectedYears * 7;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Allocate Membership"),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Requested package badge
            AppCard(
              color: AppColors.primarySurface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(
                    Icons.luggage_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Requested Package",
                        style: AppTextStyles.labelUppercase,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.requestedPackage,
                        style: AppTextStyles.headingSmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Duration
            Text("PACKAGE DURATION", style: AppTextStyles.labelUppercase),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [3, 5, 10].map((years) {
                      final bool selected = selectedYears == years;
                      return GestureDetector(
                        onTap: () => setState(() => selectedYears = years),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.background,
                            borderRadius: AppRadius.medium,
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "$years Yrs",
                                style: AppTextStyles.headingSmall.copyWith(
                                  color: selected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${years * 7} days",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: selected
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: AppRadius.medium,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.sunny,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "$totalHolidays Holiday Days",
                          style: AppTextStyles.headingSmall.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Immunities
            Text(
              "FACILITIES / IMMUNITIES",
              style: AppTextStyles.labelUppercase,
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: [
                  _ImmunityTile(
                    title: " Insurance",
                    value: Insurance,
                    onChanged: (v) => setState(() => Insurance = v),
                  ),
                  _ImmunityTile(
                    title: "Gym Access",
                    value: gym,
                    onChanged: (v) => setState(() => gym = v),
                  ),
                  _ImmunityTile(
                    title: "Swimming Pool",
                    value: swimmingPool,
                    onChanged: (v) => setState(() => swimmingPool = v),
                  ),
                  _ImmunityTile(
                    title: "Compliment Plot",
                    value: complimentPlot,
                    onChanged: (v) => setState(() => complimentPlot = v),
                    isLast: true,
                  ),
                  _ImmunityTile(
                    title: "Event pass",
                    value: eventpass,
                    onChanged: (v) => setState(() => eventpass = v),
                  ),
                  _ImmunityTile(
                    title: "Resort Access",
                    value: resortAccess,
                    onChanged: (v) => setState(() => resortAccess = v),
                  ),
                  _ImmunityTile(
                    title: "Banquet Access",
                    value: banquetAccess,
                    onChanged: (v) => setState(() => banquetAccess = v),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Expiry
            Text("EXPIRY DATE", style: AppTextStyles.labelUppercase),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Manual Override", style: AppTextStyles.bodyLarge),
                      Switch.adaptive(
                        value: manualExpiry,
                        onChanged: (v) => setState(() => manualExpiry = v),
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                  if (manualExpiry) ...[
                    const Divider(height: 1),
                    const SizedBox(height: 8),
                    DatePickerButton(
                      label: "Custom Expiry Date",
                      value: customExpiry,
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2050),
                          builder: (ctx, child) => Theme(
                            data: Theme.of(ctx).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                              ),
                            ),
                            child: child!,
                          ),
                        );
                        if (picked != null)
                          setState(() => customExpiry = picked);
                      },
                    ),
                  ],
                  if (!manualExpiry) ...[
                    const SizedBox(height: 4),
                    Text(
                      "Auto-calculated: ${_calculateExpiry().toLocal().toString().split(' ')[0]}",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 32),

            AppButton(
              label: "Allocate Membership",
              loading: loading,
              onTap: _allocate,
              icon: const Icon(
                Icons.card_membership_rounded,
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

class _ImmunityTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ImmunityTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    value
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: value ? AppColors.primary : AppColors.border,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(title, style: AppTextStyles.bodyLarge),
                ],
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}
