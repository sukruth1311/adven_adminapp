import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../data/models/hotel_request.dart';
import 'in_app_doc_viewer.dart';
import 'upload_document_screen.dart';

// ══════════════════════════════════════════════════════════════════════
//  ADMIN HOTEL REQUEST DETAIL SCREEN
//  Full detail view for a single hotel/holiday request
//  • All fields visible (location, dates, travellers, special request…)
//  • View Aadhaar opens IN-APP viewer (never launchUrl which often fails)
//  • Approve / Reject / Upload Doc actions
// ══════════════════════════════════════════════════════════════════════
class AdminHotelRequestDetailScreen extends StatefulWidget {
  final HotelRequest request;
  final String userId; // firebaseUid for upload doc

  const AdminHotelRequestDetailScreen({
    super.key,
    required this.request,
    required this.userId,
  });

  @override
  State<AdminHotelRequestDetailScreen> createState() =>
      _AdminHotelRequestDetailScreenState();
}

class _AdminHotelRequestDetailScreenState
    extends State<AdminHotelRequestDetailScreen> {
  bool _docUploaded = false;

  HotelRequest get r => widget.request;

  String _fmtDate(DateTime dt) {
    const mo = [
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
    return '${dt.day} ${mo[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          r.location.isNotEmpty ? r.location : 'Request Detail',
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UploadUserDocumentScreen(
                      userId: widget.userId,
                      requestId: r.id,
                      type: 'hotel',
                      title: 'Hotel Confirmation',
                    ),
                  ),
                );
                if (mounted) setState(() => _docUploaded = true);
              },
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
      // ── Live stream so status badge updates instantly ───────────────
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('hotel_requests')
            .doc(r.id)
            .snapshots(),
        builder: (context, snap) {
          final liveData = snap.hasData && snap.data!.exists
              ? snap.data!.data() as Map<String, dynamic>
              : null;
          final status = liveData?['status'] ?? r.status;
          final aadharUrl = liveData?['aadharUrl'] as String? ?? r.aadharUrl;
          final specialRequest =
              liveData?['specialRequest'] as String? ?? r.specialRequest ?? '';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Status banner ──────────────────────────────────────
                _StatusBanner(status: status),
                const SizedBox(height: 20),

                // ── Doc uploaded confirmation ──────────────────────────
                if (_docUploaded) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.08),
                      borderRadius: AppRadius.medium,
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
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

                // ── Destination ────────────────────────────────────────
                _SectionLabel('DESTINATION'),
                AppCard(
                  child: Column(
                    children: [
                      _Row(
                        icon: Icons.location_on_rounded,
                        label: 'Destination',
                        value: r.location,
                      ),
                      if (r.subDestination.isNotEmpty)
                        _Row(
                          icon: Icons.near_me_rounded,
                          label: 'Sub-Destination',
                          value: r.subDestination,
                        ),
                      if (r.memberName.isNotEmpty)
                        _Row(
                          icon: Icons.person_outline_rounded,
                          label: 'Primary Member',
                          value: r.memberName,
                          isLast: true,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Dates ──────────────────────────────────────────────
                _SectionLabel('DATES'),
                AppCard(
                  child: Column(
                    children: [
                      _Row(
                        icon: Icons.login_rounded,
                        label: 'Check-in',
                        value: _fmtDate(r.checkIn),
                      ),
                      _Row(
                        icon: Icons.logout_rounded,
                        label: 'Check-out',
                        value: _fmtDate(r.checkOut),
                      ),
                      _Row(
                        icon: Icons.nights_stay_outlined,
                        label: 'Nights',
                        value: '${r.nights} night${r.nights == 1 ? '' : 's'}',
                      ),
                      if (r.travelDate != null)
                        _Row(
                          icon: Icons.flight_takeoff_rounded,
                          label: 'Travel Date',
                          value: _fmtDate(r.travelDate!),
                          isLast: true,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Travellers ─────────────────────────────────────────
                _SectionLabel('TRAVELLERS'),
                AppCard(
                  child: Column(
                    children: [
                      _Row(
                        icon: Icons.group_rounded,
                        label: 'Total',
                        value:
                            '${r.members} traveller${r.members == 1 ? '' : 's'}',
                      ),
                      _Row(
                        icon: Icons.person_rounded,
                        label: 'Adults',
                        value: '${r.adults}',
                      ),
                      _Row(
                        icon: Icons.child_care_rounded,
                        label: 'Kids',
                        value: '${r.kids}',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Travel details ─────────────────────────────────────
                _SectionLabel('TRAVEL DETAILS'),
                AppCard(
                  child: Column(
                    children: [
                      _Row(
                        icon: Icons.flight_rounded,
                        label: 'Mode',
                        value: r.travelMode,
                      ),
                      _Row(
                        icon: Icons.public_rounded,
                        label: 'Type',
                        value: r.isInternational ? 'International' : 'Domestic',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Special request ────────────────────────────────────
                if (specialRequest.isNotEmpty) ...[
                  _SectionLabel('SPECIAL REQUEST'),
                  AppCard(
                    color: AppColors.accentLight,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            specialRequest,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Aadhaar ────────────────────────────────────────────
                _SectionLabel('AADHAAR DOCUMENT'),
                if (aadharUrl != null && aadharUrl.isNotEmpty)
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InAppDocViewer(
                          url: aadharUrl,
                          title:
                              '${r.memberName.isNotEmpty ? r.memberName : 'Member'} — Aadhaar',
                        ),
                      ),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: AppRadius.medium,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: AppRadius.small,
                            ),
                            child: const Icon(
                              Icons.description_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'View Aadhaar',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Tap to open document in-app',
                                  style: TextStyle(
                                    color: AppColors.textHint,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  AppCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.textHint,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'No Aadhaar document uploaded',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // ── Actions ────────────────────────────────────────────
                if (status == 'pending') ...[
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Approve',
                          height: 46,
                          icon: const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          onTap: () async {
                            await FirestoreService.instance
                                .updateHotelRequestStatus(r.id, 'approved');
                            if (context.mounted)
                              AppSnackbar.show(
                                context,
                                'Request approved!',
                                isSuccess: true,
                              );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppOutlinedButton(
                          label: 'Reject',
                          icon: const Icon(
                            Icons.close_rounded,
                            color: AppColors.error,
                            size: 16,
                          ),
                          onTap: () => _confirmReject(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

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
                          requestId: r.id,
                          type: 'hotel',
                          title: 'Hotel Confirmation',
                        ),
                      ),
                    );
                    if (mounted) setState(() => _docUploaded = true);
                  },
                ),
              ],
            ),
          );
        },
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
              await FirestoreService.instance.updateHotelRequestStatus(
                r.id,
                'rejected',
              );
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

// ── Status banner ─────────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg, textColor;
    IconData icon;
    String label;

    switch (status) {
      case 'approved':
        bg = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        icon = Icons.check_circle_rounded;
        label = 'Approved';
        break;
      case 'rejected':
        bg = AppColors.error.withOpacity(0.1);
        textColor = AppColors.error;
        icon = Icons.cancel_rounded;
        label = 'Rejected';
        break;
      default:
        bg = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        icon = Icons.hourglass_top_rounded;
        label = 'Pending Review';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.medium,
        border: Border.all(color: textColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: AppTextStyles.labelUppercase.copyWith(
        color: AppColors.textSecondary,
        fontSize: 11,
      ),
    ),
  );
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final bool isLast;
  const _Row({
    required this.icon,
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
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 10),
              SizedBox(
                width: 110,
                child: Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}
