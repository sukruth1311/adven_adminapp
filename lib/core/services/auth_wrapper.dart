import 'package:admin_app/features/admin/admin_create_user_screen.dart';
import 'package:admin_app/features/admin/admin_dashboard.dart';
import 'package:admin_app/features/admin/admin_login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({super.key});

//   @override
//   State<AuthWrapper> createState() => _AuthWrapperState();
// }

// class _AuthWrapperState extends State<AuthWrapper> {
//   int selectedIndex = 1;

//   @override
//   Widget build(BuildContext context) {
//     final screens = [
//       const AdminLoginScreen(),
//       const UIDLoginScreen(),
//       const NormalLoginScreen(),
//     ];

//     return Scaffold(
//       backgroundColor: const Color(0xffF4F6FB),
//       body: Column(
//         children: [
//           const SizedBox(height: 60),

//           const Text(
//             "ADV Club System",
//             style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//           ),

//           const SizedBox(height: 30),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [_tab("Admin", 0), _tab("Member", 1), _tab("Public", 2)],
//           ),

//           const SizedBox(height: 20),

//           Expanded(child: screens[selectedIndex]),
//         ],
//       ),
//     );
//   }

//   Widget _tab(String title, int index) {
//     final isSelected = selectedIndex == index;

//     return GestureDetector(
//       onTap: () => setState(() => selectedIndex = index),
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(20),
//           color: isSelected ? Colors.indigo : Colors.white,
//         ),
//         child: Text(
//           title,
//           style: TextStyle(color: isSelected ? Colors.white : Colors.black),
//         ),
//       ),
//     );
//   }
// }
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Logged In
        if (snapshot.hasData) {
          return const AdminDashboard();
        }

        // Not logged in
        return const AdminLoginScreen();
      },
    );
  }
}
