import 'package:admin_app/features/admin/admin_service_detail_scree.dart';
import 'package:admin_app/features/admin/edit_immunities_screen.dart';
import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/firestore_service.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/hotel_request.dart';
import 'membership_allocation_screen.dart';
import 'upload_document_screen.dart';

// ══════════════════════════════════════════════════════════════════════
//  ADMIN USER DETAIL SCREEN
//  • Compact info card (no big boxes)
//  • Services as a list with name + basic status badge → tap to full detail
//  • Hotel request cards with approve + upload doc button
//  • Admin can upload doc → shows in user's Documents screen
// ══════════════════════════════════════════════════════════════════════
class AdminUserDetailScreen extends StatefulWidget {
  final String userId;
  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  State<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends State<AdminUserDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Member Details'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: StreamBuilder<AppUser?>(
        stream: FirestoreService.instance.streamUser(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const AppLoadingIndicator();
          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text('User not found', style: AppTextStyles.bodyMedium),
            );
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Not logged in warning ─────────────────────────
                if (user.firebaseUid == null)
                  _WarningBanner(
                    message:
                        'User has not logged in yet — Firebase UID not generated.',
                  ),

                // ── Member profile card ───────────────────────────
                _ProfileCard(user: user),
                const SizedBox(height: 20),

                // ── Membership ────────────────────────────────────
                const _SectionLabel('Membership'),
                const SizedBox(height: 10),
                _MembershipSection(user: user, isAdmin: true),
                const SizedBox(height: 24),

                // ── Holiday & Hotel Requests ──────────────────────
                const _SectionLabel('Holiday & Hotel Requests'),
                const SizedBox(height: 10),
                _HotelRequestsSection(user: user),
                const SizedBox(height: 24),

                // ── Service Requests list ─────────────────────────
                const _SectionLabel('Service Requests'),
                const SizedBox(height: 10),
                _ServiceRequestsList(user: user),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Profile card ──────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  final AppUser user;
  const _ProfileCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          // Avatar + name row
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.memberGradient,
                  ),
                  borderRadius: AppRadius.medium,
                ),
                child: Center(
                  child: Text(
                    (user.name.isNotEmpty ? user.name[0] : '?').toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name.isNotEmpty ? user.name : 'Unknown',
                      style: AppTextStyles.headingSmall,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.customUid ?? '—',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Status badge
              AppChip(
                label: user.membershipActive == true ? 'ACTIVE' : 'INACTIVE',
                bgColor: user.membershipActive == true
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.warning.withOpacity(0.1),
                textColor: user.membershipActive == true
                    ? AppColors.success
                    : AppColors.warning,
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 14),

          // Info rows
          _IRow(icon: Icons.phone_outlined, label: user.phone ?? '—'),
          _IRow(
            icon: Icons.email_outlined,
            label: user.email.isNotEmpty ? user.email : '—',
          ),
          _IRow(
            icon: Icons.badge_outlined,
            label: user.firebaseUid ?? 'Not linked yet',
          ),
          _IRow(
            icon: Icons.manage_accounts_rounded,
            label: user.role ?? 'user',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _IRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isLast;
  const _IRow({required this.icon, required this.label, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Warning banner ────────────────────────────────────────────────
class _WarningBanner extends StatelessWidget {
  final String message;
  const _WarningBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.warning.withOpacity(0.1),
      borderRadius: AppRadius.medium,
      border: Border.all(color: AppColors.warning.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.warning,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(message, style: AppTextStyles.bodySmall)),
      ],
    ),
  );
}

// ── Section label ─────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 3,
        height: 18,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        text.toUpperCase(),
        style: AppTextStyles.labelUppercase.copyWith(
          fontWeight: FontWeight.w800,
          fontSize: 11,
          color: AppColors.textPrimary,
        ),
      ),
    ],
  );
}

// ── Status chip ───────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, text;
    switch (status) {
      case 'approved':
        bg = AppColors.success.withOpacity(0.12);
        text = AppColors.success;
        break;
      case 'rejected':
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

// ── Info row ──────────────────────────────────────────────────────
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
  Widget build(BuildContext context) => Column(
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

// ── Membership section (preserved from original) ──────────────────
class _MembershipSection extends StatelessWidget {
  final AppUser user;
  final bool isAdmin;
  const _MembershipSection({required this.user, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    if (user.membershipActive == true) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  user.membershipName ?? 'Premium',
                  style: AppTextStyles.headingSmall,
                ),
                AppChip(
                  label: 'ACTIVE',
                  bgColor: AppColors.success.withOpacity(0.12),
                  textColor: AppColors.success,
                ),
              ],
            ),
            if (user.expiryDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Expires: ${user.expiryDate!.toLocal().toString().split(' ')[0]}',
                style: AppTextStyles.bodySmall,
              ),
            ],
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Text('Facilities', style: AppTextStyles.labelUppercase),
            const SizedBox(height: 8),
            ...[
              ('Insurance', user.immunities['Insurance'] ?? false),
              ('Gym Access', user.immunities['gym'] ?? false),
              ('Swimming Pool', user.immunities['swimmingPool'] ?? false),
              ('Event Pass', user.immunities['eventpass'] ?? false),
              ('Resort Pass', user.immunities['resortAccess'] ?? false),
              ('Banquet Hall', user.immunities['banquetAccess'] ?? false),
              ('Plot', user.immunities['complimentPlot'] ?? false),
            ].map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Icon(
                      e.$2 ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      color: e.$2 ? AppColors.success : AppColors.border,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Text(e.$1, style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ),

            // Holiday balance
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.beach_access_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text('Holiday Balance', style: AppTextStyles.labelMedium),
                const Spacer(),
                Text(
                  '${user.remainingHolidays ?? 0} / ${user.totalHolidays ?? 0} days',
                  style: AppTextStyles.headingSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            if (isAdmin) ...[
              const SizedBox(height: 16),
              AppButton(
                label: 'Edit Immunities',
                height: 42,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditImmunitiesScreen(user: user),
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

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
                  'No Membership Allocated',
                  style: AppTextStyles.headingSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isAdmin)
            AppButton(
              label: 'Allocate Membership',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MembershipAllocationScreen(
                    userId: user.id,
                    requestId: 'manual_allocation',
                    requestedPackage: 'Manual Allocation',
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

// ══════════════════════════════════════════════════════════════════
//  HOTEL REQUESTS SECTION
// ══════════════════════════════════════════════════════════════════
class _HotelRequestsSection extends StatelessWidget {
  final AppUser user;
  const _HotelRequestsSection({required this.user});

  @override
  Widget build(BuildContext context) {
    if (user.firebaseUid == null || user.firebaseUid!.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          'No hotel requests — user has not logged in yet.',
          style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
        ),
      );
    }

    return StreamBuilder<List<HotelRequest>>(
      stream: FirestoreService.instance.streamUserHotelRequests(
        user.firebaseUid!,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (!snap.hasData || snap.data!.isEmpty) {
          return AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'No holiday/hotel requests yet.',
              style: AppTextStyles.bodySmall,
            ),
          );
        }

        return Column(
          children: snap.data!
              .map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                r.location,
                                style: AppTextStyles.headingSmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _StatusChip(status: r.status),
                          ],
                        ),
                        if (r.subDestination.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            r.subDestination,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        const Divider(height: 1),
                        const SizedBox(height: 10),

                        // Details grid (compact)
                        Wrap(
                          spacing: 16,
                          runSpacing: 6,
                          children: [
                            _DetailChip(
                              icon: Icons.calendar_today_rounded,
                              label:
                                  '${r.checkIn.toString().split(' ')[0]} → ${r.checkOut.toString().split(' ')[0]}',
                            ),
                            _DetailChip(
                              icon: Icons.nights_stay_outlined,
                              label: '${r.nights} nights',
                            ),
                            _DetailChip(
                              icon: Icons.group_rounded,
                              label: '${r.members} travellers',
                            ),
                            _DetailChip(
                              icon: Icons.flight_rounded,
                              label: r.travelMode,
                            ),
                            if (r.memberName.isNotEmpty)
                              _DetailChip(
                                icon: Icons.person_outline_rounded,
                                label: r.memberName,
                              ),
                            if (r.adults > 0)
                              _DetailChip(
                                icon: Icons.person_rounded,
                                label: '${r.adults} adults, ${r.kids} kids',
                              ),
                          ],
                        ),

                        // Aadhaar view
                        if (r.aadharUrl != null) ...[
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () async {
                              final uri = Uri.parse(r.aadharUrl!);
                              if (await canLaunchUrl(uri))
                                await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: AppRadius.small,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.file_open_rounded,
                                    color: AppColors.primary,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'View Aadhaar',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Actions
                        Row(
                          children: [
                            if (r.status == 'pending')
                              Expanded(
                                child: AppButton(
                                  label: 'Approve',
                                  height: 40,
                                  icon: const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  onTap: () async => FirestoreService.instance
                                      .updateHotelRequestStatus(
                                        r.id,
                                        'approved',
                                      ),
                                ),
                              ),
                            if (r.status == 'pending') const SizedBox(width: 8),
                            Expanded(
                              child: AppOutlinedButton(
                                label: 'Upload Doc',
                                icon: const Icon(
                                  Icons.upload_file_rounded,
                                  color: AppColors.primary,
                                  size: 15,
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UploadUserDocumentScreen(
                                      userId: user.firebaseUid!,
                                      requestId: r.id,
                                      type: 'hotel',
                                      title: 'Hotel Confirmation',
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
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════
//  SERVICE REQUESTS LIST
//  Each service shows as a row with live pending count badge
//  Tap → AdminServiceDetailScreen
// ══════════════════════════════════════════════════════════════════
class _ServiceRequestsList extends StatelessWidget {
  final AppUser user;
  const _ServiceRequestsList({required this.user});

  static const _services = [
    {'title': 'swimming', 'label': 'Swimming Pool', 'icon': Icons.pool_rounded},
    {'title': 'gym', 'label': 'Gym', 'icon': Icons.fitness_center_rounded},
    {
      'title': 'resortPass',
      'label': 'Resort Pass',
      'icon': Icons.villa_rounded,
    },
    {
      'title': 'eventPass',
      'label': 'Event Pass',
      'icon': Icons.event_available_rounded,
    },
    {
      'title': 'banquetHall',
      'label': 'Banquet Hall',
      'icon': Icons.church_rounded,
    },
    {'title': 'insurance', 'label': 'Insurance', 'icon': Icons.shield_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    if (user.firebaseUid == null) {
      return AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          'Service requests unavailable — user has no Firebase UID.',
          style: AppTextStyles.bodySmall.copyWith(fontStyle: FontStyle.italic),
        ),
      );
    }

    return AppCard(
      child: Column(
        children: _services.asMap().entries.map((entry) {
          final i = entry.key;
          final svc = entry.value;
          final title = svc['title'] as String;
          final label = svc['label'] as String;
          final icon = svc['icon'] as IconData;
          final isLast = i == _services.length - 1;

          return _ServiceRow(
            userId: user.firebaseUid!,
            serviceType: title,
            label: label,
            icon: icon,
            isLast: isLast,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminServiceDetailScreen(
                  userId: user.firebaseUid!,
                  serviceType: title,
                  userName: user.name,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final String userId;
  final String serviceType;
  final String label;
  final IconData icon;
  final bool isLast;
  final VoidCallback onTap;
  const _ServiceRow({
    required this.userId,
    required this.serviceType,
    required this.label,
    required this.icon,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_requests')
          .where('userId', isEqualTo: userId)
          .where('serviceType', isEqualTo: serviceType)
          .snapshots(),
      builder: (context, snap) {
        final total = snap.data?.docs.length ?? 0;
        final pending =
            snap.data?.docs
                .where((d) => (d.data() as Map)['status'] == 'pending')
                .length ??
            0;

        return Column(
          children: [
            GestureDetector(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppRadius.small,
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 19),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (total > 0)
                            Text(
                              '$total request${total == 1 ? '' : 's'}',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                          if (total == 0)
                            Text(
                              'No requests',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Pending badge
                    if (pending > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$pending pending',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (pending == 0 && total > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Done',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            if (!isLast) const Divider(color: AppColors.divider, height: 1),
          ],
        );
      },
    );
  }
}
