import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';

import '../../../data/models/app_user.dart';

class AdminUserHistoryScreen extends ConsumerWidget {
  final AppUser user;
  const AdminUserHistoryScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("User History"),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // User header card
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: AppCard(
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: AppRadius.medium,
                      image: user.profileImage != null
                          ? DecorationImage(
                              image: NetworkImage(user.profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user.profileImage == null
                        ? const Icon(
                            Icons.person_rounded,
                            color: AppColors.primary,
                            size: 26,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name.isEmpty ? "Unnamed User" : user.name,
                          style: AppTextStyles.headingSmall,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user.phone ?? "No phone",
                          style: AppTextStyles.bodySmall,
                        ),
                        if (user.customUid != null)
                          Text(
                            "UID: ${user.customUid}",
                            style: AppTextStyles.labelUppercase.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionHeader(title: "Request History"),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder<List<QueryDocumentSnapshot>>(
              stream: FirestoreService.instance.streamAllUserRequests(user.id),
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
                          Icons.history_rounded,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No requests yet",
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  );
                }

                final requests = snapshot.data!;

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final data = requests[index].data() as Map<String, dynamic>;
                    final serviceType = data['serviceType'] ?? "Service";
                    final status = data['status'] ?? "pending";
                    final createdAt = (data['createdAt'] as Timestamp?)
                        ?.toDate();

                    Color statusBg, statusText;
                    switch (status) {
                      case "approved":
                        statusBg = AppColors.success.withOpacity(0.12);
                        statusText = AppColors.success;
                        break;
                      case "rejected":
                        statusBg = AppColors.error.withOpacity(0.12);
                        statusText = AppColors.error;
                        break;
                      default:
                        statusBg = AppColors.warning.withOpacity(0.12);
                        statusText = AppColors.warning;
                    }

                    return AppCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: AppRadius.small,
                            ),
                            child: Icon(
                              _serviceIcon(serviceType),
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
                                  serviceType.toUpperCase(),
                                  style: AppTextStyles.headingSmall,
                                ),
                                if (createdAt != null)
                                  Text(
                                    createdAt.toLocal().toString().split(
                                      '.',
                                    )[0],
                                    style: AppTextStyles.bodySmall,
                                  ),
                              ],
                            ),
                          ),
                          AppChip(
                            label: status.toUpperCase(),
                            bgColor: statusBg,
                            textColor: statusText,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _serviceIcon(String type) {
    switch (type.toLowerCase()) {
      case "holiday":
        return Icons.beach_access_rounded;
      case "hotel":
        return Icons.hotel_rounded;
      case "gym":
        return Icons.fitness_center_rounded;
      case "swimming pool":
        return Icons.pool_rounded;
      case "resort pass":
        return Icons.villa_rounded;
      default:
        return Icons.miscellaneous_services_rounded;
    }
  }
}
