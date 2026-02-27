import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════
//  ADMIN REVIEW SCREEN — styled, with approve/reject actions
// ══════════════════════════════════════════════════════════════════════
class ReviewAdmin extends StatelessWidget {
  const ReviewAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Client Reviews'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AppLoadingIndicator();
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
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
                      Icons.rate_review_outlined,
                      color: AppColors.primary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('No Reviews Yet', style: AppTextStyles.headingSmall),
                  const SizedBox(height: 6),
                  Text(
                    'Reviews submitted by members will appear here.',
                    style: AppTextStyles.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;
          final pending = docs
              .where((d) => (d.data() as Map)['isApproved'] != true)
              .toList();
          final approved = docs
              .where((d) => (d.data() as Map)['isApproved'] == true)
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              if (pending.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Pending Approval',
                  count: pending.length,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 12),
                ...pending.map((doc) => _ReviewCard(doc: doc, isPending: true)),
                const SizedBox(height: 24),
              ],
              if (approved.isNotEmpty) ...[
                _SectionHeader(
                  title: 'Approved',
                  count: approved.length,
                  color: AppColors.success,
                ),
                const SizedBox(height: 12),
                ...approved.map(
                  (doc) => _ReviewCard(doc: doc, isPending: false),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelUppercase.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Review card ───────────────────────────────────────────────────
class _ReviewCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;
  final bool isPending;
  const _ReviewCard({required this.doc, required this.isPending});

  @override
  Widget build(BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Member';
    final comment = data['comment'] ?? '';
    final rating = (data['rating'] ?? 5).toInt();
    final role = data['role'] ?? '';
    final company = data['company'] ?? '';
    final imageUrl = data['imageUrl'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stars row
            Row(
              children: [
                ...List.generate(
                  5,
                  (i) => Icon(
                    i < rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppColors.accent,
                    size: 18,
                  ),
                ),
                const Spacer(),
                // Status chip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isPending
                        ? AppColors.warning.withOpacity(0.1)
                        : AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPending ? 'PENDING' : 'APPROVED',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isPending ? AppColors.warning : AppColors.success,
                      fontWeight: FontWeight.w700,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Comment
            Text(
              comment,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.55,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            const Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: 14),

            // User info row
            Row(
              children: [
                // Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: AppColors.primarySurface,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          color: AppColors.primary,
                        ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (role.isNotEmpty)
                        Text(
                          role,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      if (company.isNotEmpty)
                        Text(
                          company,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),

                // Quote icon
                Text(
                  '"',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 40,
                    height: 0.9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            // Action buttons (only for pending)
            if (isPending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Approve',
                      height: 42,
                      icon: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      onTap: () async {
                        await FirebaseFirestore.instance
                            .collection('reviews')
                            .doc(doc.id)
                            .update({'isApproved': true});
                        if (context.mounted)
                          AppSnackbar.show(
                            context,
                            'Review approved!',
                            isSuccess: true,
                          );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppOutlinedButton(
                      label: 'Reject',
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.error,
                        size: 16,
                      ),
                      onTap: () => _confirmReject(context, doc.id),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmReject(BuildContext context, String docId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Review?'),
        content: const Text('This will permanently remove the review.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseFirestore.instance
                  .collection('reviews')
                  .doc(docId)
                  .delete();
              if (ctx.mounted)
                AppSnackbar.show(ctx, 'Review deleted', isError: true);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
