import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';

import '../../../data/models/package_request.dart';
import 'membership_allocation_screen.dart';

class AdminPackageRequestsScreen extends StatelessWidget {
  const AdminPackageRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Package Requests"),
        backgroundColor: AppColors.surface,
      ),
      body: StreamBuilder<List<PackageRequest>>(
        stream: FirestoreService.instance.streamPackageRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_rounded,
                    size: 52,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No package requests",
                    style: AppTextStyles.headingSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          final requests = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            itemCount: requests.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final r = requests[i];
              return AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            r.name,
                            style: AppTextStyles.headingSmall,
                          ),
                        ),
                        _StatusChip(status: r.status),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 1),
                    const SizedBox(height: 10),

                    // Details
                    _DetailRow("Package", r.packageType),
                    _DetailRow("Email", r.email),
                    _DetailRow("Phone", r.phone),

                    if (r.status == "pending") ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: "Allocate",
                              height: 44,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MembershipAllocationScreen(
                                    userId: r.userId,
                                    requestId: r.id,
                                    requestedPackage: r.packageType,
                                  ),
                                ),
                              ),
                              icon: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppButton(
                              label: "Reject",
                              height: 44,
                              backgroundColor: AppColors.error,
                              onTap: () async {
                                await FirestoreService.instance
                                    .updatePackageRequestStatus(
                                      requestId: r.id,
                                      status: "rejected",
                                    );
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(child: Text(value, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}

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
