import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:flutter/material.dart';
import '../../core/services/firestore_service.dart';

import '../../data/models/hotel_request.dart';

class AdminHotelRequestsScreen extends StatelessWidget {
  const AdminHotelRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Hotel Requests"),
        backgroundColor: AppColors.surface,
      ),
      body: StreamBuilder<List<HotelRequest>>(
        stream: FirestoreService.instance.streamAllHotelRequests(),
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
                    Icons.hotel_rounded,
                    size: 52,
                    color: AppColors.textHint,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "No hotel requests yet",
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Icons.location_on_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(r.location, style: AppTextStyles.headingSmall),
                          ],
                        ),
                        _StatusDropdown(request: r),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    _InfoPill("${r.nights} nights"),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _InfoPill(
                          "${r.checkIn.toString().split(' ')[0]} → ${r.checkOut.toString().split(' ')[0]}",
                        ),
                        const SizedBox(width: 8),
                        _InfoPill("${r.members} members"),
                        const SizedBox(width: 8),
                        _InfoPill(r.travelMode),
                      ],
                    ),
                    if (r.isInternational) ...[
                      const SizedBox(height: 6),
                      AppChip(
                        label: "International",
                        bgColor: AppColors.accentLight,
                        textColor: AppColors.accent,
                      ),
                    ],
                    if (r.specialRequest.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        "Note: ${r.specialRequest}",
                        style: AppTextStyles.bodySmall.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
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

class _StatusDropdown extends StatelessWidget {
  final HotelRequest request;
  const _StatusDropdown({required this.request});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (request.status) {
      case "approved":
        color = AppColors.success;
        break;
      case "rejected":
        color = AppColors.error;
        break;
      default:
        color = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: request.status,
          isDense: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 16),
          style: AppTextStyles.labelMedium.copyWith(color: color),
          items: ["pending", "approved", "rejected"]
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Text(s[0].toUpperCase() + s.substring(1)),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              FirestoreService.instance.updateHotelRequestStatus(
                request.id,
                value,
              );
            }
          },
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String text;
  const _InfoPill(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(text, style: AppTextStyles.bodySmall),
    );
  }
}
