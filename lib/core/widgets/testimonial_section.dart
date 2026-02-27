// import 'package:flutter/material.dart';

// class TestimonialSection extends StatelessWidget {
//   const TestimonialSection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final testimonials = [
//       Testimonial(
//         name: "Rahul Sharma",
//         company: "Tech Solutions",
//         imageUrl: "https://randomuser.me/api/portraits/men/32.jpg",
//         message: "The entire process was seamless and incredibly professional.",
//         rating: 5,
//       ),
//       Testimonial(
//         name: "Priya Mehta",
//         company: "Travel Blogger",
//         imageUrl: "https://randomuser.me/api/portraits/women/44.jpg",
//         message: "Exceptional service and premium hospitality experience.",
//         rating: 5,
//       ),
//       Testimonial(
//         name: "Arjun Rao",
//         company: "Entrepreneur",
//         imageUrl: "https://randomuser.me/api/portraits/men/65.jpg",
//         message: "Highly recommend for stress-free luxury travel planning.",
//         rating: 4,
//       ),
//     ];

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           "What Our Members Say",
//           style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           height: 220,
//           child: ListView.builder(
//             scrollDirection: Axis.horizontal,
//             itemCount: testimonials.length,
//             itemBuilder: (context, index) {
//               final t = testimonials[index];
//               return _TestimonialCard(testimonial: t);
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _TestimonialCard extends StatelessWidget {
//   final Testimonial testimonial;

//   const _TestimonialCard({required this.testimonial});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 300,
//       margin: const EdgeInsets.only(right: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ⭐ Rating
//           Row(
//             children: List.generate(
//               testimonial.rating,
//               (index) => const Icon(Icons.star, color: Colors.amber, size: 18),
//             ),
//           ),

//           const SizedBox(height: 12),

//           // 💬 Message
//           Text(
//             "\"${testimonial.message}\"",
//             style: const TextStyle(fontSize: 14, height: 1.5),
//           ),

//           const Spacer(),

//           // 👤 User Info
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 22,
//                 backgroundImage: NetworkImage(testimonial.imageUrl),
//               ),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     testimonial.name,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     testimonial.company,
//                     style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
