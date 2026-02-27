import 'package:admin_app/features/admin/admin_service_detail_scree.dart';
import 'package:admin_app/features/admin/edit_immunities_screen.dart';
import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/hotel_request.dart';
import 'membership_allocation_screen.dart';
import 'upload_document_screen.dart';

class AdminUserDetailScreen extends StatefulWidget {
  final String userId;
  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  final TextEditingController _holidayController = TextEditingController();

  @override
  void dispose() {
    _holidayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("User Details"),
        backgroundColor: AppColors.surface,
      ),
      body: StreamBuilder<AppUser?>(
        stream: FirestoreService.instance.streamUser(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingIndicator();
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text("User not found", style: AppTextStyles.bodyMedium),
            );
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Not logged in warning
                if (user.firebaseUid == null)
                  _WarningBanner(
                    message:
                        "User has not logged in yet — Firebase UID not generated.",
                  ),

                // Basic info
                const SizedBox(height: 4),
                _SectionTitle(title: "Basic Information"),
                AppCard(
                  child: Column(
                    children: [
                      _InfoRow(
                        label: "Custom UID",
                        value: user.customUid ?? "—",
                      ),
                      _InfoRow(
                        label: "Firebase UID",
                        value: user.firebaseUid ?? "Not linked",
                      ),
                      _InfoRow(
                        label: "Name",
                        value: user.name.isEmpty ? "—" : user.name,
                      ),
                      _InfoRow(
                        label: "Email",
                        value: user.email.isEmpty ? "—" : user.email,
                      ),
                      _InfoRow(label: "Phone", value: user.phone ?? "—"),
                      _InfoRow(
                        label: "Role",
                        value: user.role ?? "user",
                        isLast: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Membership section
                _SectionTitle(title: "Membership"),
                _MembershipSection(user: user, isAdmin: true),

                const SizedBox(height: 24),

                // Hotel Requests
                _SectionTitle(title: "Hotel Requests"),
                _HotelRequestsSection(user: user),

                const SizedBox(height: 24),

                // Service Requests
                _SectionTitle(title: "Service Requests"),
                _ServiceRequestsGrid(user: user),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Warning Banner ──────────────────────────
class _WarningBanner extends StatelessWidget {
  final String message;
  const _WarningBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.12),
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }
}

// ─── Section Title ───────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(title, style: AppTextStyles.headingSmall),
    );
  }
}

// ─── Info Row ────────────────────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(child: Text(value, style: AppTextStyles.bodyLarge)),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}

// ─── Membership Section ──────────────────────
class _MembershipSection extends StatelessWidget {
  final AppUser user;
  final bool isAdmin; // ← add this

  const _MembershipSection({required this.user, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    if (user.membershipActive == true) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ─── HEADER ─────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  user.membershipName ?? "Premium",
                  style: AppTextStyles.headingSmall,
                ),
                AppChip(
                  label: "ACTIVE",
                  bgColor: AppColors.success.withOpacity(0.12),
                  textColor: AppColors.success,
                ),
              ],
            ),

            if (user.expiryDate != null) ...[
              const SizedBox(height: 6),
              Text(
                "Expires: ${user.expiryDate!.toLocal().toString().split(' ')[0]}",
                style: AppTextStyles.bodySmall,
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),

            /// ─── FACILITIES TITLE ─────────────────────
            Text("Facilities", style: AppTextStyles.labelUppercase),
            const SizedBox(height: 10),

            /// ─── IMMUNITIES LIST ─────────────────────
            ...[
              ("Insurance", user.immunities["Insurance"] ?? false),
              ("Gym Access", user.immunities["gym"] ?? false),
              ("Swimming Pool", user.immunities["swimmingPool"] ?? false),
              ("Event Pass", user.immunities["eventpass"] ?? false),
              ("Resort Pass", user.immunities["resortAccess"] ?? false),
              ("Banquet Hall", user.immunities["banquetAccess"] ?? false),
              ("Plot", user.immunities["complimentPlot"] ?? false),
            ].map((entry) => _FacilityRow(title: entry.$1, enabled: entry.$2)),

            /// ─── ADMIN EDIT BUTTON ─────────────────────
            if (isAdmin) ...[
              const SizedBox(height: 18),
              AppButton(
                label: "Edit Immunities",

                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditImmunitiesScreen(user: user),

                      // userId: user.id,
                      // currentImmunities: user.immunities,
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      );
    }

    /// ─── NO MEMBERSHIP CARD ─────────────────────
    return AppCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: AppRadius.small,
                ),
                child: const Icon(
                  Icons.card_membership_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  "No Membership Allocated",
                  style: AppTextStyles.headingSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (isAdmin)
            AppButton(
              label: "Allocate Membership",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MembershipAllocationScreen(
                    userId: user.id,
                    requestId: "manual_allocation",
                    requestedPackage: "Manual Allocation",
                    packageRequestId: null,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FacilityRow extends StatelessWidget {
  final String title;
  final bool enabled;
  const _FacilityRow({required this.title, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            enabled ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: enabled ? AppColors.success : AppColors.border,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(title, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

// ─── Hotel Requests Section ──────────────────
class _HotelRequestsSection extends StatelessWidget {
  final AppUser user;

  const _HotelRequestsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    /// 🔥 SAFETY CHECK
    if (user.firebaseUid == null || user.firebaseUid!.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          "Hotel requests unavailable — user has no Firebase UID.",
          style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
        ),
      );
    }

    /// ✅ USE FIREBASE UID (NOT user.id)
    return StreamBuilder<List<HotelRequest>>(
      stream: FirestoreService.instance.streamUserHotelRequests(
        user.firebaseUid!,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              "No hotel requests yet.",
              style: AppTextStyles.bodySmall,
            ),
          );
        }

        final requests = snapshot.data!;

        return Column(
          children: requests.map((r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(r.location, style: AppTextStyles.headingSmall),
                        _StatusChip(status: r.status),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    /// DETAILS
                    _InfoRow(
                      label: "Check-in",
                      value: r.checkIn.toString().split(" ")[0],
                    ),
                    _InfoRow(
                      label: "Check-out",
                      value: r.checkOut.toString().split(" ")[0],
                    ),
                    _InfoRow(label: "Nights", value: r.nights.toString()),
                    _InfoRow(label: "Members", value: r.members.toString()),
                    _InfoRow(
                      label: "Travel",
                      value: r.travelMode,
                      isLast: true,
                    ),

                    const SizedBox(height: 14),

                    /// ACTION BUTTONS
                    Row(
                      children: [
                        /// APPROVE BUTTON
                        if (r.status == "pending")
                          Expanded(
                            child: AppButton(
                              label: "Approve",
                              height: 42,
                              onTap: () async {
                                await FirestoreService.instance
                                    .updateHotelRequestStatus(r.id, "approved");
                              },
                              icon: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),

                        if (r.status == "pending") const SizedBox(width: 10),

                        /// SEND PDF BUTTON
                        Expanded(
                          child: AppOutlinedButton(
                            label: "Send PDF",
                            icon: const Icon(
                              Icons.upload_file_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => UploadUserDocumentScreen(
                                  userId: user.firebaseUid!, // ✅ FIXED
                                  requestId: r.id,
                                  type: "hotel",
                                  title: "Hotel Confirmation",
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

/// ─── Service Requests Grid ───────────────────
class _ServiceRequestsGrid extends StatelessWidget {
  final AppUser user;
  const _ServiceRequestsGrid({required this.user});

  // MUST MATCH EXACTLY WITH serviceType IN FIRESTORE
  static const _services = [
    {"title": "holiday", "icon": Icons.beach_access_rounded},
    {"title": "swimming", "icon": Icons.pool_rounded},
    {"title": "gym", "icon": Icons.fitness_center_rounded},
    {"title": "resort pass", "icon": Icons.villa_rounded},
    {"title": "event pass", "icon": Icons.event_available_rounded},
    {"title": "banquet hall", "icon": Icons.church_rounded},
    {"title": "insurance", "icon": Icons.shield_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemBuilder: (context, i) {
        final s = _services[i];
        final title = s["title"] as String;
        final icon = s["icon"] as IconData;

        return AppCard(
          onTap: () {
            if (user.firebaseUid == null) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminServiceDetailScreen(
                  userId: user.firebaseUid!,
                  serviceType: title.toLowerCase().trim(),
                ),
              ),
            );
          },
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.medium,
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: AppTextStyles.labelUppercase.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Status Chip ─────────────────────────────
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    switch (status) {
      case "approved":
        bg = AppColors.success.withOpacity(0.12);
        text = AppColors.success;
        break;
      case "rejected":
        bg = AppColors.error.withOpacity(0.12);
        text = AppColors.error;
        break;
      default:
        bg = AppColors.warning.withOpacity(0.12);
        text = AppColors.warning;
    }
    return AppChip(label: status.toUpperCase(), bgColor: bg, textColor: text);
  }
}
