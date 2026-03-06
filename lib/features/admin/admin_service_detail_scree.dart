import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'in_app_doc_viewer.dart';
import 'upload_document_screen.dart';

// ══════════════════════════════════════════════════════════════════════
//  ADMIN SERVICE DETAIL SCREEN
//  Handles all service types including banquetHall (flat fields, no members)
// ══════════════════════════════════════════════════════════════════════
class AdminServiceDetailScreen extends StatelessWidget {
  final String userId;
  final String serviceType;
  final String? userName;

  const AdminServiceDetailScreen({
    super.key,
    required this.userId,
    required this.serviceType,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_labelFor(serviceType)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UploadUserDocumentScreen(
                    userId: userId,
                    requestId: '${serviceType}_general',
                    type: serviceType,
                    title: '${_labelFor(serviceType)} Document',
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.small,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.upload_file_rounded,
                      color: AppColors.primary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Upload Doc',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // ✅ Query service_requests collection, filter by userId + serviceType
        stream: FirebaseFirestore.instance
            .collection('service_requests')
            .where('userId', isEqualTo: userId)
            .where('serviceType', isEqualTo: serviceType)
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) return const AppLoadingIndicator();

          final docs = snap.data!.docs;

          if (docs.isEmpty) {
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
                      Icons.inbox_rounded,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('No requests found', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 6),
                  Text(
                    'No ${_labelFor(serviceType)} requests from this member.',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (context, index) => _ServiceRequestCard(
              docId: docs[index].id,
              data: docs[index].data() as Map<String, dynamic>,
              userId: userId,
              serviceType: serviceType,
            ),
          );
        },
      ),
    );
  }

  static String _labelFor(String type) {
    switch (type) {
      case 'banquetHall':
        return 'AC Banquet Hall';
      case 'gym':
        return 'Gym';
      case 'swimming_pool':
      case 'swimming':
        return 'Swimming Pool';
      case 'resortPass':
      case 'resort_passes':
        return 'Resort Passes';
      case 'eventPass':
      case 'event_passes':
        return 'Event Passes';
      case 'insurance':
        return 'Insurance';
      default:
        return type.toUpperCase();
    }
  }
}

// ══════════════════════════════════════════════════════════════════
//  SERVICE REQUEST CARD
//  Handles:
//  • Member-based services (gym, pool, insurance, event/resort passes)
//  • Banquet hall (flat fields: area, pincode, capacity, date)
// ══════════════════════════════════════════════════════════════════
class _ServiceRequestCard extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;
  final String userId;
  final String serviceType;

  const _ServiceRequestCard({
    required this.docId,
    required this.data,
    required this.userId,
    required this.serviceType,
  });

  @override
  State<_ServiceRequestCard> createState() => _ServiceRequestCardState();
}

class _ServiceRequestCardState extends State<_ServiceRequestCard> {
  bool _expanded = false;
  bool _docUploaded = false;

  bool get _isBanquet => widget.serviceType == 'banquetHall';

  @override
  Widget build(BuildContext context) {
    final status = widget.data['status'] ?? 'pending';
    final createdAt = widget.data['createdAt'] is Timestamp
        ? (widget.data['createdAt'] as Timestamp).toDate()
        : DateTime.now();

    // ── Member-based fields ───────────────────────────────────────────────
    final members =
        (widget.data['members'] as List?)
            ?.map((m) => Map<String, dynamic>.from(m as Map))
            .toList() ??
        (widget.data['passes'] as List?)
            ?.map((m) => Map<String, dynamic>.from(m as Map))
            .toList() ??
        [];

    // ── Banquet-specific fields ───────────────────────────────────────────
    final area = widget.data['area'] as String? ?? '';
    final pincode = widget.data['pincode'] as String? ?? '';
    final capacity = widget.data['capacity'];
    final eventDate = widget.data['date'] is Timestamp
        ? (widget.data['date'] as Timestamp).toDate()
        : null;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.small,
                ),
                child: Icon(
                  _isBanquet
                      ? Icons.meeting_room_rounded
                      : Icons.people_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isBanquet
                          ? (area.isNotEmpty ? area : 'Banquet Request')
                          : '${members.length} Member${members.length == 1 ? '' : 's'}',
                      style: AppTextStyles.headingSmall,
                    ),
                    Text(
                      '${createdAt.day.toString().padLeft(2, '0')}-'
                      '${createdAt.month.toString().padLeft(2, '0')}-'
                      '${createdAt.year}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: status),
            ],
          ),

          // ── Doc uploaded confirmation ─────────────────────────────────────
          if (_docUploaded) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.08),
                borderRadius: AppRadius.small,
                border: Border.all(color: AppColors.success.withOpacity(0.25)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Document uploaded successfully',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          // ════════════════════════════════════════════════════
          //  BANQUET HALL — flat detail view
          // ════════════════════════════════════════════════════
          if (_isBanquet) ...[
            _BanquetDetails(
              area: area,
              pincode: pincode,
              capacity: capacity?.toString() ?? '—',
              eventDate: eventDate,
            ),
          ]
          // ════════════════════════════════════════════════════
          //  MEMBER-BASED SERVICES — expandable list
          // ════════════════════════════════════════════════════
          else if (members.isNotEmpty) ...[
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Text(
                    '${_expanded ? 'Hide' : 'View'} Members',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ),
            ),

            if (_expanded) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              ...members.asMap().entries.map((entry) {
                final i = entry.key;
                final m = entry.value;
                final name = (m['name'] as String?) ?? '';
                final aadharUrl = m['aadharUrl'] as String?;
                final isChild = (m['isChild'] as bool?) ?? false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Index badge
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isChild
                              ? AppColors.accentLight
                              : AppColors.primarySurface,
                          borderRadius: AppRadius.small,
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: isChild
                                  ? AppColors.accent
                                  : AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    name.isNotEmpty ? name : '—',
                                    style: AppTextStyles.labelMedium,
                                  ),
                                ),
                                if (isChild) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'Child',
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.accent,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (aadharUrl != null && aadharUrl.isNotEmpty)
                              GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => InAppDocViewer(
                                      url: aadharUrl,
                                      title:
                                          '${name.isNotEmpty ? name : 'Member'} — Aadhaar',
                                    ),
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primarySurface,
                                    borderRadius: AppRadius.small,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.visibility_rounded,
                                        color: AppColors.primary,
                                        size: 14,
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
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.border.withOpacity(0.3),
                                  borderRadius: AppRadius.small,
                                ),
                                child: Text(
                                  'No Aadhaar uploaded',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textHint,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],

          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          // ── Action buttons ────────────────────────────────────────────────
          if (status == 'pending')
            _ActionButtons(
              onApprove: () async {
                await FirebaseFirestore.instance
                    .collection('service_requests')
                    .doc(widget.docId)
                    .update({'status': 'approved'});
                if (context.mounted)
                  AppSnackbar.show(
                    context,
                    'Request approved!',
                    isSuccess: true,
                  );
              },
              onReject: () => _confirmReject(context),
              onUploadDoc: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UploadUserDocumentScreen(
                      userId: widget.userId,
                      requestId: widget.docId,
                      type: widget.serviceType,
                      title:
                          '${AdminServiceDetailScreen._labelFor(widget.serviceType)} Document',
                    ),
                  ),
                );
                if (mounted) setState(() => _docUploaded = true);
              },
            )
          else
            AppOutlinedButton(
              label: 'Upload Document',
              icon: const Icon(
                Icons.upload_file_rounded,
                color: AppColors.primary,
                size: 16,
              ),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UploadUserDocumentScreen(
                      userId: widget.userId,
                      requestId: widget.docId,
                      type: widget.serviceType,
                      title:
                          '${AdminServiceDetailScreen._labelFor(widget.serviceType)} Document',
                    ),
                  ),
                );
                if (mounted) setState(() => _docUploaded = true);
              },
            ),
        ],
      ),
    );
  }

  void _confirmReject(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Request?'),
        content: const Text('This will mark the request as rejected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('service_requests')
                  .doc(widget.docId)
                  .update({'status': 'rejected'});
              if (ctx.mounted)
                AppSnackbar.show(ctx, 'Request rejected', isError: true);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
//  BANQUET DETAIL WIDGET  — shows flat venue fields
// ══════════════════════════════════════════════════════════════════
class _BanquetDetails extends StatelessWidget {
  final String area;
  final String pincode;
  final String capacity;
  final DateTime? eventDate;

  const _BanquetDetails({
    required this.area,
    required this.pincode,
    required this.capacity,
    required this.eventDate,
  });

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _fmt(DateTime dt) => '${dt.day} ${_months[dt.month - 1]} ${dt.year}';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Row(icon: Icons.location_on_outlined, label: 'Area', value: area),
        const SizedBox(height: 8),
        _Row(icon: Icons.pin_drop_outlined, label: 'Pincode', value: pincode),
        const SizedBox(height: 8),
        _Row(
          icon: Icons.people_rounded,
          label: 'Capacity',
          value: '$capacity persons',
        ),
        const SizedBox(height: 8),
        _Row(
          icon: Icons.calendar_month_rounded,
          label: 'Event Date',
          value: eventDate != null ? _fmt(eventDate!) : '—',
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _Row({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 8),
      Text(
        '$label: ',
        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
      ),
      Expanded(
        child: Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}

// ── 3-button layout ───────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onUploadDoc;
  const _ActionButtons({
    required this.onApprove,
    required this.onReject,
    required this.onUploadDoc,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Approve',
                height: 42,
                icon: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 15,
                ),
                onTap: onApprove,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AppOutlinedButton(
                label: 'Reject',
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.error,
                  size: 15,
                ),
                onTap: onReject,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AppOutlinedButton(
          label: 'Upload Document',
          icon: const Icon(
            Icons.upload_file_rounded,
            color: AppColors.primary,
            size: 15,
          ),
          onTap: onUploadDoc,
        ),
      ],
    );
  }
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
