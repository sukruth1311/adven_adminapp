import 'package:admin_app/core/services/firestore_service.dart';
import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/user_provider.dart';
import '../../../data/models/app_user.dart';

import 'admin_user_detail_screen.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("All Users"),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.bodyLarge,
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  hintText: "Search by name, UID or phone...",
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: usersAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              error: (e, _) => Center(
                child: Text("Error: $e", style: AppTextStyles.bodyMedium),
              ),
              data: (users) {
                final query = _searchCtrl.text.trim().toLowerCase();
                final filtered = query.isEmpty
                    ? users
                    : users.where((u) {
                        return (u.name).toLowerCase().contains(query) ||
                            (u.customUid ?? '').toLowerCase().contains(query) ||
                            (u.phone ?? '').toLowerCase().contains(query);
                      }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search_rounded,
                          size: 52,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "No users found",
                          style: AppTextStyles.headingSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) =>
                      _UserCard(user: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminUserDetailScreen(userId: user.id),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
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
                    size: 22,
                  )
                : null,
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name.isEmpty ? "Unnamed User" : user.name,
                  style: AppTextStyles.headingSmall,
                ),
                const SizedBox(height: 3),
                Text(user.phone ?? "No phone", style: AppTextStyles.bodySmall),
                if (user.customUid != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    "UID: ${user.customUid}",
                    style: AppTextStyles.labelUppercase.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Membership badge
          AppChip(
            label: user.membershipActive ? "Active" : "Inactive",
            bgColor: user.membershipActive
                ? AppColors.success.withOpacity(0.12)
                : AppColors.error.withOpacity(0.10),
            textColor: user.membershipActive
                ? AppColors.success
                : AppColors.error,
          ),
        ],
      ),
    );
  }
}
