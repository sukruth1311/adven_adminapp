import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';

import '../../data/models/membership_request.dart';

class MembershipRequestsScreen extends StatelessWidget {
  const MembershipRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Membership Requests"),
        backgroundColor: AppColors.surface,
      ),
      body: StreamBuilder<List<MembershipRequest>>(
        stream: FirestoreService.instance.streamMembershipRequests(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final requests = snapshot.data!;

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.card_membership_rounded,
                    size: 52,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No membership requests",
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final req = requests[i];
              return _MembershipRequestCard(request: req);
            },
          );
        },
      ),
    );
  }
}

class _MembershipRequestCard extends StatefulWidget {
  final MembershipRequest request;
  const _MembershipRequestCard({required this.request});

  @override
  State<_MembershipRequestCard> createState() => _MembershipRequestCardState();
}

class _MembershipRequestCardState extends State<_MembershipRequestCard> {
  bool _loading = false;

  Future<void> _approve() async {
    setState(() => _loading = true);
    try {
      await FirestoreService.instance.approveMembership(
        userId: widget.request.userId,
        requestId: widget.request.id,
        membershipId: widget.request.requestedPlanId,
        immunities: {"insurance": true, "priorityBooking": true},
      );
      if (mounted) {
        AppSnackbar.show(context, "Request approved!", isSuccess: true);
      }
    } catch (e) {
      if (mounted) AppSnackbar.show(context, "Error: $e", isError: true);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.small,
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.request.userId,
                      style: AppTextStyles.headingSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Plan: ${widget.request.requestedPlanId}",
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          AppButton(
            label: "Approve Request",
            loading: _loading,
            onTap: _approve,
            height: 44,
            icon: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}
