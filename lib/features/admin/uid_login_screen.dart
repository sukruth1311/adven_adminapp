import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UIDLoginScreen extends StatefulWidget {
  const UIDLoginScreen({super.key});

  @override
  State<UIDLoginScreen> createState() => _UIDLoginScreenState();
}

class _UIDLoginScreenState extends State<UIDLoginScreen> {
  final uidCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  bool loading = false;

  Future<void> verify() async {
    setState(() => loading = true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("customUid", isEqualTo: uidCtrl.text.trim())
          .where("phone", isEqualTo: phoneCtrl.text.trim())
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception("Invalid UID or phone");
      }

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneCtrl.text.trim(),
        verificationCompleted: (credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
        },
        verificationFailed: (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.message ?? "")));
        },
        codeSent: (id, token) {
          // Navigate to OTP screen
        },
        codeAutoRetrievalTimeout: (id) {},
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$e")));
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return _card(
      child: Column(
        children: [
          _field("Custom UID (ADVxxxx)", uidCtrl),
          _field("Phone Number (+91...)", phoneCtrl),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: loading ? null : verify,
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Verify & Login"),
          ),
        ],
      ),
    );
  }

  Widget _field(String hint, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(padding: const EdgeInsets.all(20), child: child),
      ),
    );
  }
}
