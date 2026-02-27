import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewAdmin extends StatelessWidget {
  const ReviewAdmin({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Reviews")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reviews')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Reviews Found"));
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final doc = reviews[index];
              final data = doc.data() as Map<String, dynamic>;

              final comment = data['comment'] ?? '';
              final rating = data['rating'] ?? 0;
              final name = data['name'] ?? "User";
              final imageUrl = data['imageUrl'];
              final isApproved = data['isApproved'] ?? false;

              return Card(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    /// REVIEW TILE
                    ListTile(
                      leading: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              width: 60,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 40),
                            )
                          : const Icon(Icons.person, size: 40),

                      title: Text(name),
                      subtitle: Text(comment),
                      trailing: Text("$rating ⭐"),
                    ),

                    /// APPROVAL BUTTONS
                    if (isApproved == false)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('reviews')
                                    .doc(doc.id)
                                    .update({'isApproved': true});
                              },
                              child: const Text("Approve"),
                            ),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () async {
                                await FirebaseFirestore.instance
                                    .collection('reviews')
                                    .doc(doc.id)
                                    .delete();
                              },
                              child: const Text("Reject"),
                            ),
                          ],
                        ),
                      ),

                    /// APPROVED LABEL
                    if (isApproved == true)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Text(
                          "Approved",
                          style: TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
