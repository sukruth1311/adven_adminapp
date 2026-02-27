import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════
//  ADMIN NOTIFICATIONS SCREEN
//  Shows all pending requests from:
//  • hotel_requests collection (holiday/hotel)
//  • service_requests collection (gym, pool, etc.)
//  Each shows: member UID, request type, date raised, status
// ══════════════════════════════════════════════════════════════════════
class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tab,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.hotel_rounded, size: 18),
              text: 'Hotel / Holiday',
            ),
            Tab(
              icon: Icon(Icons.miscellaneous_services_rounded, size: 18),
              text: 'Services',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [_HotelPendingList(), _ServicePendingList()],
      ),
    );
  }
}

// ── Hotel/Holiday pending requests ────────────────────────────────
class _HotelPendingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('hotel_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const AppLoadingIndicator();
        final docs = snap.data!.docs;
        if (docs.isEmpty)
          return _EmptyState(label: 'No pending hotel/holiday requests');

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final uid = d['userId'] ?? '—';
            final location = d['location'] ?? '—';
            final nights = d['nights'] ?? 0;
            final memberName = d['memberName'] ?? '';
            final createdAt = d['createdAt'] is Timestamp
                ? (d['createdAt'] as Timestamp).toDate()
                : DateTime.now();

            // Fetch user customUid for display
            return _NotifCard(
              firebaseUid: uid,
              title: 'Holiday & Hotel Request',
              subtitle:
                  '$location${memberName.isNotEmpty ? ' • $memberName' : ''} • $nights nights',
              date: createdAt,
              icon: Icons.hotel_rounded,
              iconColor: AppColors.primary,
            );
          },
        );
      },
    );
  }
}

// ── Service pending requests ──────────────────────────────────────
class _ServicePendingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_requests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) return const AppLoadingIndicator();
        final docs = snap.data!.docs;
        if (docs.isEmpty)
          return _EmptyState(label: 'No pending service requests');

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (ctx, i) {
            final d = docs[i].data() as Map<String, dynamic>;
            final uid = d['userId'] ?? '—';
            final serviceType = d['serviceType'] ?? 'service';
            final total =
                d['totalMembers'] ?? (d['members'] as List? ?? []).length;
            final createdAt = d['createdAt'] is Timestamp
                ? (d['createdAt'] as Timestamp).toDate()
                : DateTime.now();

            return _NotifCard(
              firebaseUid: uid,
              title: serviceType.toUpperCase(),
              subtitle: '$total member${total == 1 ? '' : 's'}',
              date: createdAt,
              icon: _serviceIcon(serviceType),
              iconColor: AppColors.accent,
            );
          },
        );
      },
    );
  }

  IconData _serviceIcon(String type) {
    switch (type.toLowerCase()) {
      case 'gym':
        return Icons.fitness_center_rounded;
      case 'swimming':
        return Icons.pool_rounded;
      case 'resortpass':
        return Icons.villa_rounded;
      case 'eventpass':
        return Icons.event_available_rounded;
      case 'banquethall':
        return Icons.church_rounded;
      case 'insurance':
        return Icons.shield_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }
}

// ── Notification card ─────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final String firebaseUid;
  final String title;
  final String subtitle;
  final DateTime date;
  final IconData icon;
  final Color iconColor;
  const _NotifCard({
    required this.firebaseUid,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.icon,
    required this.iconColor,
  });

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: AppRadius.small,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + time
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: AppTextStyles.headingSmall),
                    Text(
                      _timeAgo(date),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 8),

                // UID lookup
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .where('firebaseUid', isEqualTo: firebaseUid)
                      .limit(1)
                      .get(),
                  builder: (ctx, snap) {
                    String uid = firebaseUid.length > 12
                        ? '${firebaseUid.substring(0, 12)}…'
                        : firebaseUid;
                    String customUid = '';

                    if (snap.hasData && snap.data!.docs.isNotEmpty) {
                      final u =
                          snap.data!.docs.first.data() as Map<String, dynamic>;
                      customUid = u['customUid'] ?? '';
                    }

                    return Row(
                      children: [
                        const Icon(
                          Icons.badge_outlined,
                          size: 13,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          customUid.isNotEmpty
                              ? 'UID: $customUid'
                              : 'Firebase: $uid',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 8),

                // Pending badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.hourglass_top_rounded,
                        size: 12,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pending Review',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String label;
  const _EmptyState({required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: AppColors.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          Text('All Clear!', style: AppTextStyles.headingSmall),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}
