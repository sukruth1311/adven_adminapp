// import 'package:admin_app/features/admin/admin_create_user_screen.dart';
// import 'package:admin_app/features/admin/admin_package_requests_screen.dart';
// import 'package:admin_app/features/admin/admin_users_screen.dart';
// import 'package:admin_app/features/admin/manage_doc.dart';
// import 'package:admin_app/features/admin/manage_offers.dart';
// import 'package:admin_app/features/admin/review_admin.dart';
// import 'package:admin_app/themes/app_theme.dart';
// import 'package:admin_app/themes/app_widgets.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';
// import '../../core/services/firestore_service.dart';

// import '../../data/models/app_user.dart';
// import 'admin_hotel_requests_screen.dart';
// import 'membership_requests_screen.dart';

// class AdminDashboard extends StatelessWidget {
//   const AdminDashboard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // ── Use MediaQuery for responsive sizing ──
//     final screenWidth = MediaQuery.of(context).size.width;
//     final hPad = screenWidth < 360 ? 14.0 : 20.0;

//     return Scaffold(
//       backgroundColor: AppColors.background,
//       body: StreamBuilder<List<AppUser>>(
//         stream: FirestoreService.instance.streamAllUsers(),
//         builder: (context, snapshot) {
//           final users = snapshot.data ?? [];
//           final totalUsers = users.length;
//           final activeMembers = users
//               .where((u) => u.membershipActive == true)
//               .length;
//           final inactiveMembers = totalUsers - activeMembers;

//           return CustomScrollView(
//             slivers: [
//               // ── App Bar ──────────────────────────────────────
//               SliverAppBar(
//                 backgroundColor: AppColors.surface,
//                 surfaceTintColor: Colors.transparent,
//                 shadowColor: Colors.black.withOpacity(0.06),
//                 elevation: 1,
//                 floating: true,
//                 snap: true,
//                 automaticallyImplyLeading: false,
//                 titleSpacing: hPad,
//                 title: Text("Dashboard", style: AppTextStyles.headingSmall),
//                 actions: [
//                   Padding(
//                     padding: EdgeInsets.only(right: hPad),
//                     child: GestureDetector(
//                       onTap: () async => await FirebaseAuth.instance.signOut(),
//                       child: Container(
//                         width: 38,
//                         height: 38,
//                         decoration: BoxDecoration(
//                           color: AppColors.accentLight,
//                           borderRadius: AppRadius.small,
//                         ),
//                         child: const Icon(
//                           Icons.logout_rounded,
//                           color: AppColors.accent,
//                           size: 18,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               // ── Body ─────────────────────────────────────────
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Greeting
//                       Text("Welcome Back,", style: AppTextStyles.bodyMedium),
//                       const SizedBox(height: 2),
//                       // Use FittedBox so long text never overflows on tiny screens
//                       FittedBox(
//                         fit: BoxFit.scaleDown,
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           "Administrator 👋",
//                           style: AppTextStyles.displayMedium,
//                         ),
//                       ),

//                       const SizedBox(height: 24),

//                       // ── Stats 2×2 grid ──────────────────────
//                       // Using LayoutBuilder so each card gets exactly half
//                       // the available width minus the gutter — never overflows.
//                       LayoutBuilder(
//                         builder: (ctx, constraints) {
//                           final cardW = (constraints.maxWidth - 12) / 2;
//                           return Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   SizedBox(
//                                     width: cardW,
//                                     child: _StatCard(
//                                       title: "Total Users",
//                                       value: totalUsers.toString(),
//                                       icon: Icons.people_rounded,
//                                       color: AppColors.primary,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   SizedBox(
//                                     width: cardW,
//                                     child: _StatCard(
//                                       title: "Active Members",
//                                       value: activeMembers.toString(),
//                                       icon: Icons.verified_rounded,
//                                       color: AppColors.success,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 12),
//                               Row(
//                                 children: [
//                                   SizedBox(
//                                     width: cardW,
//                                     child: _StatCard(
//                                       title: "Inactive",
//                                       value: inactiveMembers.toString(),
//                                       icon: Icons.person_off_rounded,
//                                       color: AppColors.warning,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 12),
//                                   SizedBox(
//                                     width: cardW,
//                                     child: const _StatCard(
//                                       title: "Pending",
//                                       value: "—",
//                                       icon: Icons.pending_actions_rounded,
//                                       color: AppColors.accent,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           );
//                         },
//                       ),

//                       const SizedBox(height: 24),

//                       // ── Pie chart ───────────────────────────
//                       if (totalUsers > 0) ...[
//                         AppCard(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const SectionHeader(title: "Membership Overview"),
//                               const SizedBox(height: 20),
//                               // Fixed height, no unbounded width issues
//                               SizedBox(
//                                 height: 190,
//                                 child: Row(
//                                   children: [
//                                     // Chart takes remaining space
//                                     Expanded(
//                                       child: PieChart(
//                                         PieChartData(
//                                           sectionsSpace: 3,
//                                           centerSpaceRadius: 40,
//                                           startDegreeOffset: -90,
//                                           sections: [
//                                             PieChartSectionData(
//                                               value: activeMembers.toDouble(),
//                                               color: AppColors.primary,
//                                               title: activeMembers > 0
//                                                   ? "$activeMembers"
//                                                   : "",
//                                               titleStyle: const TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.white,
//                                               ),
//                                               radius: 54,
//                                             ),
//                                             PieChartSectionData(
//                                               value: inactiveMembers.toDouble(),
//                                               color: const Color(0xFFE5E7EB),
//                                               title: inactiveMembers > 0
//                                                   ? "$inactiveMembers"
//                                                   : "",
//                                               titleStyle: const TextStyle(
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: AppColors.textSecondary,
//                                               ),
//                                               radius: 54,
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),

//                                     // Legend — fixed width so it never overflows
//                                     SizedBox(
//                                       width: 90,
//                                       child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           _LegendItem(
//                                             color: AppColors.primary,
//                                             label: "Active",
//                                             count: activeMembers,
//                                           ),
//                                           const SizedBox(height: 14),
//                                           _LegendItem(
//                                             color: const Color(0xFFE5E7EB),
//                                             label: "Inactive",
//                                             count: inactiveMembers,
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 24),
//                       ],

//                       // ── Admin Actions grid ──────────────────
//                       const SectionHeader(title: "Admin Actions"),
//                       const SizedBox(height: 14),

//                       // LayoutBuilder again → no overflow on any screen size
//                       LayoutBuilder(
//                         builder: (ctx, constraints) {
//                           final cardW = (constraints.maxWidth - 12) / 2;
//                           final actions = _adminActions(context);
//                           final rows = <Widget>[];

//                           for (var i = 0; i < actions.length; i += 2) {
//                             final hasSecond = i + 1 < actions.length;
//                             rows.add(
//                               Row(
//                                 children: [
//                                   SizedBox(
//                                     width: cardW,
//                                     height: cardW * 0.85,
//                                     child: actions[i],
//                                   ),
//                                   const SizedBox(width: 12),
//                                   if (hasSecond)
//                                     SizedBox(
//                                       width: cardW,
//                                       height: cardW * 0.85,
//                                       child: actions[i + 1],
//                                     )
//                                   else
//                                     SizedBox(width: cardW),
//                                 ],
//                               ),
//                             );
//                             if (i + 2 < actions.length) {
//                               rows.add(const SizedBox(height: 12));
//                             }
//                           }

//                           return Column(children: rows);
//                         },
//                       ),

//                       const SizedBox(height: 36),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   List<Widget> _adminActions(BuildContext context) => [
//     _ActionCard(
//       icon: Icons.people_rounded,
//       title: "All Users",
//       onTap: () => _push(context, const AdminUsersScreen()),
//     ),
//     _ActionCard(
//       icon: Icons.inventory_2_rounded,
//       title: "Package Requests",
//       onTap: () => _push(context, const AdminPackageRequestsScreen()),
//     ),
//     _ActionCard(
//       icon: Icons.hotel_rounded,
//       title: "Hotel Requests",
//       onTap: () => _push(context, const AdminHotelRequestsScreen()),
//     ),
//     _ActionCard(
//       icon: Icons.card_membership_rounded,
//       title: "Membership Requests",
//       onTap: () => _push(context, const MembershipRequestsScreen()),
//     ),
//     _ActionCard(
//       icon: Icons.person_add_rounded,
//       title: "Create User",
//       onTap: () => showDialog(
//         context: context,
//         builder: (_) => const Dialog(
//           insetPadding: EdgeInsets.all(20),
//           child: CreateUserScreen(),
//         ),
//       ),
//     ),
//     _ActionCard(
//       icon: Icons.folder_rounded,
//       title: "Documents",
//       onTap: () => _push(context, const ManageDocumentsScreen()),
//     ),
//     _ActionCard(
//       icon: Icons.reviews,
//       title: "Reviews",
//       onTap: () => _push(context, ReviewAdmin()),
//     ),
//     _ActionCard(
//       icon: Icons.local_offer_rounded,
//       title: "Offers",
//       onTap: () => _push(context, const ManageOffersScreen()),
//     ),
//   ];

//   void _push(BuildContext context, Widget screen) {
//     Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
//   }
// }

// // ─────────────────────────────────────────────
// // STAT CARD — uses Flexible/Expanded text to prevent overflow
// // ─────────────────────────────────────────────
// class _StatCard extends StatelessWidget {
//   final String title;
//   final String value;
//   final IconData icon;
//   final Color color;

//   const _StatCard({
//     required this.title,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: AppColors.surface,
//         borderRadius: AppRadius.large,
//         boxShadow: AppShadows.card,
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           // Icon box — fixed size, never shrinks
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.12),
//               borderRadius: AppRadius.small,
//             ),
//             child: Icon(icon, color: color, size: 19),
//           ),
//           const SizedBox(width: 10),

//           // Text — Expanded so it uses remaining space and wraps if needed
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Value — FittedBox scales down if value is long
//                 FittedBox(
//                   fit: BoxFit.scaleDown,
//                   alignment: Alignment.centerLeft,
//                   child: Text(
//                     value,
//                     style: AppTextStyles.headingMedium.copyWith(
//                       color: color,
//                       height: 1,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   title,
//                   style: AppTextStyles.bodySmall,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // LEGEND ITEM for pie chart
// // ─────────────────────────────────────────────
// class _LegendItem extends StatelessWidget {
//   final Color color;
//   final String label;
//   final int count;

//   const _LegendItem({
//     required this.color,
//     required this.label,
//     required this.count,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Container(
//           width: 10,
//           height: 10,
//           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//         ),
//         const SizedBox(width: 7),
//         // Flexible prevents legend text from pushing outside the SizedBox
//         Flexible(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: AppTextStyles.bodySmall,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // ACTION CARD — text uses Flexible to prevent overflow
// // ─────────────────────────────────────────────
// class _ActionCard extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final VoidCallback onTap;

//   const _ActionCard({
//     required this.icon,
//     required this.title,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: AppColors.surface,
//           borderRadius: AppRadius.large,
//           boxShadow: AppShadows.card,
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               width: 48,
//               height: 48,
//               decoration: BoxDecoration(
//                 color: AppColors.primarySurface,
//                 borderRadius: AppRadius.medium,
//               ),
//               child: Icon(icon, color: AppColors.primary, size: 22),
//             ),
//             const SizedBox(height: 10),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: AppTextStyles.bodySmall.copyWith(
//                   color: AppColors.textPrimary,
//                   fontWeight: FontWeight.w600,
//                   height: 1.3,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:admin_app/features/admin/admin_create_user_screen.dart';
import 'package:admin_app/features/admin/admin_package_requests_screen.dart';
import 'package:admin_app/features/admin/admin_users_screen.dart';
import 'package:admin_app/features/admin/manage_doc.dart';
import 'package:admin_app/features/admin/manage_offers.dart';
import 'package:admin_app/features/admin/review_admin.dart';
import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/services/firestore_service.dart';

import '../../data/models/app_user.dart';
import 'admin_hotel_requests_screen.dart';
import 'membership_requests_screen.dart';
import 'admin_notifications_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    // ── Use MediaQuery for responsive sizing ──
    final screenWidth = MediaQuery.of(context).size.width;
    final hPad = screenWidth < 360 ? 14.0 : 20.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<AppUser>>(
        stream: FirestoreService.instance.streamAllUsers(),
        builder: (context, snapshot) {
          final users = snapshot.data ?? [];
          final totalUsers = users.length;
          final activeMembers = users
              .where((u) => u.membershipActive == true)
              .length;
          final inactiveMembers = totalUsers - activeMembers;

          return CustomScrollView(
            slivers: [
              // ── App Bar ──────────────────────────────────────
              SliverAppBar(
                backgroundColor: AppColors.surface,
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.black.withOpacity(0.06),
                elevation: 1,
                floating: true,
                snap: true,
                automaticallyImplyLeading: false,
                titleSpacing: hPad,
                title: Text("Dashboard", style: AppTextStyles.headingSmall),
                actions: [
                  // Notifications bell
                  _NotificationBell(hPad: hPad),
                  const SizedBox(width: 8),
                  Padding(
                    padding: EdgeInsets.only(right: hPad),
                    child: GestureDetector(
                      onTap: () async => await FirebaseAuth.instance.signOut(),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: AppRadius.small,
                        ),
                        child: const Icon(
                          Icons.logout_rounded,
                          color: AppColors.accent,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ── Body ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Text("Welcome Back,", style: AppTextStyles.bodyMedium),
                      const SizedBox(height: 2),
                      // Use FittedBox so long text never overflows on tiny screens
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Administrator 👋",
                          style: AppTextStyles.displayMedium,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Stats 2×2 grid ──────────────────────
                      // Using LayoutBuilder so each card gets exactly half
                      // the available width minus the gutter — never overflows.
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          final cardW = (constraints.maxWidth - 12) / 2;
                          return Column(
                            children: [
                              Row(
                                children: [
                                  SizedBox(
                                    width: cardW,
                                    child: _StatCard(
                                      title: "Total Users",
                                      value: totalUsers.toString(),
                                      icon: Icons.people_rounded,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: cardW,
                                    child: _StatCard(
                                      title: "Active Members",
                                      value: activeMembers.toString(),
                                      icon: Icons.verified_rounded,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  SizedBox(
                                    width: cardW,
                                    child: _StatCard(
                                      title: "Inactive",
                                      value: inactiveMembers.toString(),
                                      icon: Icons.person_off_rounded,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: cardW,
                                    child: const _StatCard(
                                      title: "Pending",
                                      value: "—",
                                      icon: Icons.pending_actions_rounded,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // ── Pie chart ───────────────────────────
                      if (totalUsers > 0) ...[
                        AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SectionHeader(title: "Membership Overview"),
                              const SizedBox(height: 20),
                              // Fixed height, no unbounded width issues
                              SizedBox(
                                height: 190,
                                child: Row(
                                  children: [
                                    // Chart takes remaining space
                                    Expanded(
                                      child: PieChart(
                                        PieChartData(
                                          sectionsSpace: 3,
                                          centerSpaceRadius: 40,
                                          startDegreeOffset: -90,
                                          sections: [
                                            PieChartSectionData(
                                              value: activeMembers.toDouble(),
                                              color: AppColors.primary,
                                              title: activeMembers > 0
                                                  ? "$activeMembers"
                                                  : "",
                                              titleStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              radius: 54,
                                            ),
                                            PieChartSectionData(
                                              value: inactiveMembers.toDouble(),
                                              color: const Color(0xFFE5E7EB),
                                              title: inactiveMembers > 0
                                                  ? "$inactiveMembers"
                                                  : "",
                                              titleStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textSecondary,
                                              ),
                                              radius: 54,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Legend — fixed width so it never overflows
                                    SizedBox(
                                      width: 90,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          _LegendItem(
                                            color: AppColors.primary,
                                            label: "Active",
                                            count: activeMembers,
                                          ),
                                          const SizedBox(height: 14),
                                          _LegendItem(
                                            color: const Color(0xFFE5E7EB),
                                            label: "Inactive",
                                            count: inactiveMembers,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Admin Actions grid ──────────────────
                      const SectionHeader(title: "Admin Actions"),
                      const SizedBox(height: 14),

                      // LayoutBuilder again → no overflow on any screen size
                      LayoutBuilder(
                        builder: (ctx, constraints) {
                          final cardW = (constraints.maxWidth - 12) / 2;
                          final actions = _adminActions(context);
                          final rows = <Widget>[];

                          for (var i = 0; i < actions.length; i += 2) {
                            final hasSecond = i + 1 < actions.length;
                            rows.add(
                              Row(
                                children: [
                                  SizedBox(
                                    width: cardW,
                                    height: cardW * 0.85,
                                    child: actions[i],
                                  ),
                                  const SizedBox(width: 12),
                                  if (hasSecond)
                                    SizedBox(
                                      width: cardW,
                                      height: cardW * 0.85,
                                      child: actions[i + 1],
                                    )
                                  else
                                    SizedBox(width: cardW),
                                ],
                              ),
                            );
                            if (i + 2 < actions.length) {
                              rows.add(const SizedBox(height: 12));
                            }
                          }

                          return Column(children: rows);
                        },
                      ),

                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Widget> _adminActions(BuildContext context) => [
    _ActionCard(
      icon: Icons.people_rounded,
      title: "All Users",
      onTap: () => _push(context, const AdminUsersScreen()),
    ),
    _ActionCard(
      icon: Icons.inventory_2_rounded,
      title: "Package Requests",
      onTap: () => _push(context, const AdminPackageRequestsScreen()),
    ),
    _ActionCard(
      icon: Icons.hotel_rounded,
      title: "Hotel Requests",
      onTap: () => _push(context, const AdminHotelRequestsScreen()),
    ),
    _ActionCard(
      icon: Icons.card_membership_rounded,
      title: "Membership Requests",
      onTap: () => _push(context, const MembershipRequestsScreen()),
    ),
    _ActionCard(
      icon: Icons.person_add_rounded,
      title: "Create User",
      onTap: () => showDialog(
        context: context,
        builder: (_) => const Dialog(
          insetPadding: EdgeInsets.all(20),
          child: CreateUserScreen(),
        ),
      ),
    ),
    _ActionCard(
      icon: Icons.folder_rounded,
      title: "Documents",
      onTap: () => _push(context, const ManageDocumentsScreen()),
    ),
    _ActionCard(
      icon: Icons.reviews,
      title: "Reviews",
      onTap: () => _push(context, ReviewAdmin()),
    ),
    _ActionCard(
      icon: Icons.local_offer_rounded,
      title: "Offers",
      onTap: () => _push(context, const ManageOffersScreen()),
    ),
  ];

  void _push(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// ─────────────────────────────────────────────
// STAT CARD — uses Flexible/Expanded text to prevent overflow
// ─────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        boxShadow: AppShadows.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon box — fixed size, never shrinks
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: AppRadius.small,
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),

          // Text — Expanded so it uses remaining space and wraps if needed
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Value — FittedBox scales down if value is long
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: AppTextStyles.headingMedium.copyWith(
                      color: color,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// LEGEND ITEM for pie chart
// ─────────────────────────────────────────────
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        // Flexible prevents legend text from pushing outside the SizedBox
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ACTION CARD — text uses Flexible to prevent overflow
// ─────────────────────────────────────────────
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.large,
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: AppRadius.medium,
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  NOTIFICATION BELL WIDGET — shows live count badge
// ══════════════════════════════════════════════════════════════════════
class _NotificationBell extends StatelessWidget {
  final double hPad;
  const _NotificationBell({required this.hPad});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _allPendingRequests(),
      builder: (context, snap) {
        final count = snap.data?.docs.length ?? 0;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminNotificationsScreen()),
          ),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: AppRadius.small,
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              if (count > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        count > 99 ? '99+' : '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // All pending requests from hotel + service
  Stream<QuerySnapshot> _allPendingRequests() {
    return FirebaseFirestore.instance
        .collection('hotel_requests')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }
}
