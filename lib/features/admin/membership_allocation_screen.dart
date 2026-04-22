import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';

// ════════════════════════════════════════════════════════════
//  MEMBERSHIP ALLOCATION SCREEN
//  • Duration selector  (3 / 5 / 10 years)
//  • Trip Type selector (India / India + Asia / India + International)
//  • Facilities / Immunities toggles
//  • Expiry (auto or manual override)
// ════════════════════════════════════════════════════════════
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
  // ── Duration ────────────────────────────────────────────
  int selectedYears = 5;

  // ── Trip Type ────────────────────────────────────────────
  String selectedTripType = 'India';
  static const _tripTypes = [
    _TripOption(
      label: 'India',
      subtitle: 'Domestic travel only',
      icon: Icons.flag_rounded,
      color: Color(0xFF1565C0),
    ),
    _TripOption(
      label: 'India + Asia',
      subtitle: 'India & Asian destinations',
      icon: Icons.language_rounded,
      color: Color(0xFF2E7D32),
    ),
    _TripOption(
      label: 'India + International',
      subtitle: 'Worldwide destinations',
      icon: Icons.public_rounded,
      color: Color(0xFF6A1B9A),
    ),
  ];

  // ── Immunities ───────────────────────────────────────────
  bool holiday = true;
  bool Insurance = true;
  bool gym = true;
  bool swimmingPool = true;
  bool eventpass = true;
  bool resortAccess = true;
  bool banquetAccess = true;
  bool complimentPlot = true;

  // ── Expiry ───────────────────────────────────────────────
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
          "Holiday": holiday,
          "Insurance": Insurance,
          "Gym": gym,
          "SwimmingPool": swimmingPool,
          "ComplimentPlot": complimentPlot,
          "Eventpass": eventpass,
          "ResortAccess": resortAccess,
          "BanquetAccess": banquetAccess,
        },
        requestId: widget.requestId,
        packageRequestId: widget.packageRequestId,
      );

      // Save trip type + holidays to user doc
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .update({
            "totalHolidays": totalHolidays,
            "usedHolidays": 0,
            "remainingHolidays": totalHolidays,
            "tripType": selectedTripType,
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
            // ── Requested package badge ────────────────────
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

            // ── Duration ───────────────────────────────────
            Text("PACKAGE DURATION", style: AppTextStyles.labelUppercase),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [3, 5, 10].map((years) {
                      final bool sel = selectedYears == years;
                      return GestureDetector(
                        onTap: () => setState(() => selectedYears = years),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.primary
                                : AppColors.background,
                            borderRadius: AppRadius.medium,
                            border: Border.all(
                              color: sel ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "$years Yrs",
                                style: AppTextStyles.headingSmall.copyWith(
                                  color: sel
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "${years * 7} days",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: sel
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

            // ── Trip Type ──────────────────────────────────
            Text("TRIP TYPE", style: AppTextStyles.labelUppercase),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: _tripTypes.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final opt = entry.value;
                  final bool sel = selectedTripType == opt.label;
                  final bool isLast = idx == _tripTypes.length - 1;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            setState(() => selectedTripType = opt.label),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 2,
                          ),
                          child: Row(
                            children: [
                              // Icon badge
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: sel
                                      ? opt.color.withOpacity(0.12)
                                      : AppColors.background,
                                  borderRadius: AppRadius.small,
                                  border: Border.all(
                                    color: sel
                                        ? opt.color.withOpacity(0.4)
                                        : AppColors.border,
                                  ),
                                ),
                                child: Icon(
                                  opt.icon,
                                  color: sel ? opt.color : AppColors.textHint,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              // Label + subtitle
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opt.label,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: sel
                                            ? opt.color
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      opt.subtitle,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Radio indicator
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: sel ? opt.color : AppColors.border,
                                    width: sel ? 6 : 2,
                                  ),
                                  color: Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!isLast)
                        const Divider(height: 1, color: AppColors.divider),
                    ],
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // ── Immunities ─────────────────────────────────
            Text(
              "FACILITIES / IMMUNITIES",
              style: AppTextStyles.labelUppercase,
            ),
            const SizedBox(height: 10),
            AppCard(
              child: Column(
                children: [
                  _ImmunityTile(
                    title: "Holiday",
                    icon: Icons.beach_access_rounded,
                    value: holiday,
                    onChanged: (v) => setState(() => holiday = v),
                  ),
                  _ImmunityTile(
                    title: "Insurance",
                    icon: Icons.health_and_safety_outlined,
                    value: Insurance,
                    onChanged: (v) => setState(() => Insurance = v),
                  ),
                  _ImmunityTile(
                    title: "Gym Access",
                    icon: Icons.fitness_center_rounded,
                    value: gym,
                    onChanged: (v) => setState(() => gym = v),
                  ),
                  _ImmunityTile(
                    title: "Swimming Pool",
                    icon: Icons.pool_rounded,
                    value: swimmingPool,
                    onChanged: (v) => setState(() => swimmingPool = v),
                  ),
                  _ImmunityTile(
                    title: "Compliment Plot",
                    icon: Icons.villa_outlined,
                    value: complimentPlot,
                    onChanged: (v) => setState(() => complimentPlot = v),
                  ),
                  _ImmunityTile(
                    title: "Event Pass",
                    icon: Icons.confirmation_number_rounded,
                    value: eventpass,
                    onChanged: (v) => setState(() => eventpass = v),
                  ),
                  _ImmunityTile(
                    title: "Resort Access",
                    icon: Icons.villa_rounded,
                    value: resortAccess,
                    onChanged: (v) => setState(() => resortAccess = v),
                  ),
                  _ImmunityTile(
                    title: "Banquet Access",
                    icon: Icons.meeting_room_rounded,
                    value: banquetAccess,
                    onChanged: (v) => setState(() => banquetAccess = v),
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Expiry ─────────────────────────────────────
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
                        if (picked != null) {
                          setState(() => customExpiry = picked);
                        }
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

            // ── Summary preview ────────────────────────────
            _AllocationSummary(
              years: selectedYears,
              tripType: selectedTripType,
              totalHolidays: totalHolidays,
              expiry: _calculateExpiry(),
            ),

            const SizedBox(height: 24),

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

// ── Summary preview card before Allocate button ─────────────
class _AllocationSummary extends StatelessWidget {
  final int years;
  final String tripType;
  final int totalHolidays;
  final DateTime expiry;

  const _AllocationSummary({
    required this.years,
    required this.tripType,
    required this.totalHolidays,
    required this.expiry,
  });

  IconData _tripIcon() {
    switch (tripType) {
      case 'India + Asia':
        return Icons.language_rounded;
      case 'India + International':
        return Icons.public_rounded;
      default:
        return Icons.flag_rounded;
    }
  }

  Color _tripColor() {
    switch (tripType) {
      case 'India + Asia':
        return const Color(0xFF2E7D32);
      case 'India + International':
        return const Color(0xFF6A1B9A);
      default:
        return const Color(0xFF1565C0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ALLOCATION SUMMARY',
            style: AppTextStyles.labelUppercase.copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            icon: Icons.timer_rounded,
            label: 'Duration',
            value: '$years Years',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            icon: _tripIcon(),
            label: 'Trip Type',
            value: tripType,
            valueColor: _tripColor(),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            icon: Icons.sunny,
            label: 'Holiday Days',
            value: '$totalHolidays days',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            icon: Icons.calendar_today_rounded,
            label: 'Expires On',
            value: expiry.toLocal().toString().split(' ')[0],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ── Trip option model ────────────────────────────────────────
class _TripOption {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _TripOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

// ── Immunity tile ────────────────────────────────────────────
class _ImmunityTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _ImmunityTile({
    required this.title,
    required this.icon,
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      value
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      key: ValueKey(value),
                      color: value ? AppColors.primary : AppColors.border,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(
                    icon,
                    color: value ? AppColors.primary : AppColors.textHint,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
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
        if (!isLast) const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}
