// import 'package:admin_app/features/admin/upload_document_screen.dart';
// import 'package:admin_app/themes/app_theme.dart';
// import 'package:admin_app/themes/app_widgets.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class AdminServiceDetailScreen extends StatelessWidget {
//   final String userId;
//   final String serviceType;

//   const AdminServiceDetailScreen({
//     super.key,
//     required this.userId,
//     required this.serviceType,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text(serviceType.toUpperCase()),
//         backgroundColor: AppColors.surface,
//       ),
//       body: StreamBuilder<QuerySnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection("service_requests")
//             .where("userId", isEqualTo: userId)
//             .orderBy("createdAt", descending: true)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const CircularProgressIndicator();
//           }

//           final requests = snapshot.data!.docs;

//           if (requests.isEmpty) {
//             return const Text("No Service Requests");
//           }

//           return Column(
//             children: requests.map((doc) {
//               final data = doc.data() as Map<String, dynamic>;

//               return Card(
//                 margin: const EdgeInsets.symmetric(vertical: 8),
//                 child: ExpansionTile(
//                   title: Text(data["serviceType"] ?? ""),
//                   subtitle: Text("Status: ${data["status"]}"),
//                   children: [
//                     if (data["members"] != null)
//                       ...List.generate(data["members"].length, (index) {
//                         final member = data["members"][index];
//                         return ListTile(
//                           title: Text(member["name"] ?? ""),
//                           subtitle: member["aadharUrl"] != null
//                               ? Image.network(member["aadharUrl"], height: 80)
//                               : const Text("No Aadhar"),
//                         );
//                       }),
//                     if (data["status"] == "pending")
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           ElevatedButton(
//                             onPressed: () async {
//                               await FirebaseFirestore.instance
//                                   .collection("service_requests")
//                                   .doc(doc.id)
//                                   .update({"status": "approved"});
//                             },
//                             child: const Text("Approve"),
//                           ),
//                           ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.red,
//                             ),
//                             onPressed: () async {
//                               await FirebaseFirestore.instance
//                                   .collection("service_requests")
//                                   .doc(doc.id)
//                                   .update({"status": "rejected"});
//                             },
//                             child: const Text("Reject"),
//                           ),
//                         ],
//                       ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           );
//         },
//       ),
//     );
//   }

//   Future<void> _approveService(
//     BuildContext context,
//     String requestId,
//     Map<String, dynamic> data,
//   ) async {
//     final int requestedDays = data['totalDays'] ?? 0;
//     final String realUserId = data['userId'];

//     final query = await FirebaseFirestore.instance
//         .collection('users')
//         .where('firebaseUid', isEqualTo: realUserId)
//         .limit(1)
//         .get();

//     if (query.docs.isEmpty) {
//       AppSnackbar.show(context, "User document not found", isError: true);
//       return;
//     }

//     final userDoc = query.docs.first;
//     final userData = userDoc.data();
//     int remaining = userData['remainingHolidays'] ?? 0;
//     int used = userData['usedHolidays'] ?? 0;

//     if (serviceType == "holiday" && remaining < requestedDays) {
//       AppSnackbar.show(context, "Insufficient holiday balance", isError: true);
//       return;
//     }

//     await FirebaseFirestore.instance
//         .collection('service_requests')
//         .doc(requestId)
//         .update({"status": "approved"});

//     if (serviceType == "holiday") {
//       await userDoc.reference.update({
//         "usedHolidays": used + requestedDays,
//         "remainingHolidays": remaining - requestedDays,
//       });
//     }

//     AppSnackbar.show(context, "Request approved!", isSuccess: true);
//   }
// }

// class _StatusChip extends StatelessWidget {
//   final String status;
//   const _StatusChip({required this.status});

//   @override
//   Widget build(BuildContext context) {
//     Color bg, text;
//     switch (status) {
//       case "approved":
//         bg = AppColors.success.withOpacity(0.12);
//         text = AppColors.success;
//         break;
//       case "rejected":
//         bg = AppColors.error.withOpacity(0.12);
//         text = AppColors.error;
//         break;
//       default:
//         bg = AppColors.warning.withOpacity(0.12);
//         text = AppColors.warning;
//     }
//     return AppChip(label: status.toUpperCase(), bgColor: bg, textColor: text);
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminServiceDetailScreen extends StatelessWidget {
  final String userId;
  final String serviceType;

  const AdminServiceDetailScreen({
    super.key,
    required this.userId,
    required this.serviceType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(serviceType)),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("service_requests")
            .where("userId", isEqualTo: userId)
            .where("serviceType", isEqualTo: serviceType.toLowerCase())
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No Requests Found"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(12),
                child: ExpansionTile(
                  title: Text("Status: ${data["status"]}"),
                  children: [
                    if (data["members"] is List)
                      ...List.generate((data["members"] as List).length, (i) {
                        final member = (data["members"] as List)[i];
                        return ListTile(
                          title: Text(member["name"] ?? ""),
                          subtitle: member["aadharUrl"] != null
                              ? Image.network(member["aadharUrl"], height: 80)
                              : const Text("No Aadhar"),
                        );
                      }),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("service_requests")
                                .doc(docs[index].id)
                                .update({"status": "approved"});
                          },
                          child: const Text("Approve"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            FirebaseFirestore.instance
                                .collection("service_requests")
                                .doc(docs[index].id)
                                .update({"status": "rejected"});
                          },
                          child: const Text("Reject"),
                        ),
                      ],
                    ),
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
