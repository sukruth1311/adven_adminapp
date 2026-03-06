// import 'package:admin_app/themes/app_theme.dart';
// import 'package:admin_app/themes/app_widgets.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class CreateUserScreen extends ConsumerStatefulWidget {
//   const CreateUserScreen({super.key});

//   @override
//   ConsumerState<CreateUserScreen> createState() => _CreateUserScreenState();
// }

// class _CreateUserScreenState extends ConsumerState<CreateUserScreen> {
//   final _phoneController = TextEditingController();
//   bool isLoading = false;
//   String? _generatedUid;

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     super.dispose();
//   }

//   Future<void> _createUser() async {
//     final phone = _phoneController.text.trim();

//     if (phone.isEmpty || phone.length != 10) {
//       AppSnackbar.show(
//         context,
//         "Enter a valid 10-digit phone number",
//         isError: true,
//       );
//       return;
//     }

//     setState(() => isLoading = true);

//     try {
//       final now = DateTime.now();
//       final day = now.day.toString().padLeft(2, '0');
//       final startOfDay = DateTime(now.year, now.month, now.day);

//       final snapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
//           .get();

//       int countToday = snapshot.docs.length + 1;
//       if (countToday > 99) throw Exception("Daily user limit reached (99)");

//       final sequence = countToday.toString().padLeft(2, '0');
//       final customUid = "ADV$day$sequence";

//       await FirebaseFirestore.instance.collection('users').add({
//         'customUid': customUid,
//         'phone': phone,
//         'firebaseUid': null,
//         'isFirstLogin': true,
//         'membershipActive': false,
//         'allocatedPackages': [],
//         'createdAt': FieldValue.serverTimestamp(),
//       });

//       setState(() => _generatedUid = customUid);
//       _phoneController.clear();

//       AppSnackbar.show(
//         context,
//         "User created — UID: $customUid",
//         isSuccess: true,
//       );
//     } catch (e) {
//       AppSnackbar.show(context, "Error: $e", isError: true);
//     }

//     setState(() => isLoading = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: const Text("Create User"),
//         backgroundColor: AppColors.surface,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Info card
//             GradientBannerCard(
//               title: "Auto UID Generator",
//               subtitle:
//                   "UID is generated automatically based on today's date + sequence.",
//               colors: AppColors.memberGradient,
//               icon: Icons.badge_rounded,
//             ),

//             const SizedBox(height: 28),

//             AppTextField(
//               controller: _phoneController,
//               label: "Phone Number",
//               hint: "10-digit mobile number",
//               prefixIcon: Icons.phone_outlined,
//               keyboardType: TextInputType.phone,
//             ),

//             const SizedBox(height: 28),

//             AppButton(
//               label: "Generate UID & Create",
//               loading: isLoading,
//               onTap: _createUser,
//               icon: const Icon(
//                 Icons.person_add_rounded,
//                 color: Colors.white,
//                 size: 18,
//               ),
//             ),

//             if (_generatedUid != null) ...[
//               const SizedBox(height: 24),
//               AppCard(
//                 color: AppColors.primarySurface,
//                 child: Row(
//                   children: [
//                     const Icon(
//                       Icons.badge_rounded,
//                       color: AppColors.primary,
//                       size: 22,
//                     ),
//                     const SizedBox(width: 12),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "Generated UID",
//                           style: AppTextStyles.labelUppercase,
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           _generatedUid!,
//                           style: AppTextStyles.headingMedium.copyWith(
//                             color: AppColors.primary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_theme.dart';
import 'package:admin_app/themes/app_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class CreateUserScreen extends ConsumerStatefulWidget {
  const CreateUserScreen({super.key});

  @override
  ConsumerState<CreateUserScreen> createState() => _CreateUserScreenState();
}

// ✅ FIX: extends ConsumerState<CreateUserScreen> (not plain State)
class _CreateUserScreenState extends ConsumerState<CreateUserScreen> {
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _isLoading = false;
  bool _emailSent = false;
  String? _generatedUid;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email.trim());
  }

  Future<void> _createUser() async {
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();

    if (phone.isEmpty || phone.length != 10) {
      AppSnackbar.show(
        context,
        'Enter a valid 10-digit phone number',
        isError: true,
      );
      return;
    }
    if (email.isEmpty || !_isValidEmail(email)) {
      AppSnackbar.show(context, 'Enter a valid email address', isError: true);
      return;
    }

    // Check duplicate email
    final emailCheck = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (emailCheck.docs.isNotEmpty) {
      if (mounted)
        AppSnackbar.show(
          context,
          'A user with this email already exists',
          isError: true,
        );
      return;
    }

    setState(() {
      _isLoading = true;
      _emailSent = false;
      _generatedUid = null;
    });

    try {
      final now = DateTime.now();
      final day = now.day.toString().padLeft(2, '0');
      final startOfDay = DateTime(now.year, now.month, now.day);

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .get();

      int countToday = snapshot.docs.length + 1;
      if (countToday > 99) throw Exception('Daily user limit reached (99)');

      final sequence = countToday.toString().padLeft(2, '0');
      final customUid = 'ADV$day$sequence';

      await FirebaseFirestore.instance.collection('users').add({
        'customUid': customUid,
        'phone': phone,
        'email': email,
        'firebaseUid': null,
        'isFirstLogin': true,
        'membershipActive': false,
        'allocatedPackages': [],
        'createdAt': FieldValue.serverTimestamp(),
      });

      bool emailSuccess = false;
      try {
        await _sendWelcomeEmail(toEmail: email);
        emailSuccess = true;
      } catch (emailErr) {
        debugPrint('Email send error: $emailErr');
      }

      _phoneCtrl.clear();
      _emailCtrl.clear();

      if (mounted) {
        setState(() {
          _generatedUid = customUid;
          _emailSent = emailSuccess;
        });

        AppSnackbar.show(
          context,
          emailSuccess
              ? 'User created — UID sent to $email'
              : 'User created (UID: $customUid) — email could not be sent',
          isSuccess: emailSuccess,
          isError: !emailSuccess,
        );
      }
    } catch (e) {
      if (mounted) AppSnackbar.show(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendWelcomeEmail({required String toEmail}) async {
    // ── Configure your SMTP credentials here ──────────────────────────────
    // ⚠️  For production: use Firebase Cloud Functions or a backend API
    //     so credentials are never shipped inside the Flutter app.
    const String senderEmail = 'sukruth321@gmail.com'; // ← change
    const String senderPassword = 'ddrxmeuzqsmqneom'; // ← use App Password
    const String appName = 'Adventra Privilege';
    // ─────────────────────────────────────────────────────────────────────

    final smtpServer = gmail(senderEmail, senderPassword);

    final message = Message()
      ..from = Address(senderEmail, appName)
      ..recipients.add(toEmail)
      ..subject = 'Welcome To the Family Of Adventra Privilege Services'
      ..html = _buildEmailHtml(appName);

    await send(message, smtpServer);
  }

  String _buildEmailHtml(String appName) {
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body style="margin:0;padding:0;background:#F7F9F8;font-family:Arial,sans-serif;">
  <table width="100%" cellpadding="0" cellspacing="0" style="background:#F7F9F8;padding:32px 0;">
    <tr>
      <td align="center">
        <table width="540" cellpadding="0" cellspacing="0"
          style="background:#ffffff;border-radius:20px;overflow:hidden;box-shadow:0 4px 24px rgba(0,0,0,0.07);">

          <!-- Header -->
          <tr>
            <td style="background:linear-gradient(135deg,#1A6B5A,#2E8B74);padding:36px 40px;text-align:center;">
              <p style="margin:0;font-size:13px;color:rgba(255,255,255,0.7);letter-spacing:1px;text-transform:uppercase;">Welcome to</p>
              <h1 style="margin:8px 0 0;font-size:28px;color:#ffffff;letter-spacing:-0.5px;">$appName</h1>
            </td>
          </tr>
          <!-- Body -->
          <tr>
            <td style="padding:36px 40px;">
              <p style="margin:0 0 8px;font-size:15px;color:#6B7280;"><strong>Welcome To the Family Of Adventra Privilege Services to</strong></p>
              <p style="margin:0 0 24px;font-size:18px;color:#1A1A1A;font-weight:700;">Mr &amp; Mrs Pulluri Manideep &amp; V.Anudeepika</p>
              <p style="margin:0 0 20px;font-size:15px;color:#6B7280;line-height:1.6;">
                Thank you For joining at Adventra Privilege Services LLP, We Believe in excellence in providing top of the line Holiday &amp; Real Estate services for our Valued customers.
              </p>
              <p style="margin:0 0 20px;font-size:15px;color:#6B7280;line-height:1.6;">
                Holidays can be avail anywhere in the world but request should be sent before 20 days for Domestic &amp; for international 30-45 days prior and maintenance will be applicable only when requested for more than ONE room i.e ( 9000 for domestic and 12000/- for International )
              </p>
              <p style="margin:0 0 20px;font-size:15px;color:#6B7280;line-height:1.6;">
                Any Further queries please send us Email to <a href="mailto:cc@adventraservices.com" style="color:#1A6B5A;text-decoration:none;">cc@adventraservices.com</a> or WhatsApp on 9381862483, Our Virtual Customer Care Team will Contact you within 24hours to resolve your queries.
              </p>
              <p style="margin:0 0 16px;font-size:15px;color:#374151;line-height:1.6;">
                Wishing you a very Happy Holidaying.....
              </p>
              <div style="padding-top:8px;border-top:1px solid #E5E7EB;">
                <p style="margin:0;font-size:15px;color:#1A1A1A;line-height:1.6;">
                  Thanks &amp; Regards,<br>
                  Team Adventra Privilege Services LLP
                </p>
              </div>
            </td>
          </tr>

          <!-- Footer -->
          <tr>
            <td style="background:#F7F9F8;padding:20px 40px;text-align:center;border-top:1px solid #E5E7EB;">
              <p style="margin:0;font-size:12px;color:#9CA3AF;">
                This email was sent by $appName admin. If you did not expect this, please ignore it.
              </p>
              <p style="margin:8px 0 0;font-size:12px;color:#9CA3AF;">
                © ${DateTime.now().year} $appName. All rights reserved.
              </p>
            </td>
          </tr>

        </table>
      </td>
    </tr>
  </table>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Create User'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info banner
            GradientBannerCard(
              title: 'Auto UID Generator',
              subtitle:
                  'Enter phone & email — UID is generated automatically and emailed to the user.',
              colors: AppColors.memberGradient,
              icon: Icons.badge_rounded,
            ),

            const SizedBox(height: 28),

            AppTextField(
              controller: _phoneCtrl,
              label: 'Phone Number',
              hint: '10-digit mobile number',
              prefixIcon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            AppTextField(
              controller: _emailCtrl,
              label: 'Email Address',
              hint: 'user@example.com',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: AppRadius.medium,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.mail_outline_rounded,
                    color: AppColors.accent,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'The generated UID and app download link will be automatically emailed to this address.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            AppButton(
              label: 'Generate UID & Send Email',
              loading: _isLoading,
              onTap: _createUser,
              icon: const Icon(
                Icons.person_add_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),

            if (_generatedUid != null) ...[
              const SizedBox(height: 24),
              AppCard(
                color: AppColors.primarySurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.badge_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Generated UID',
                              style: AppTextStyles.labelUppercase,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _generatedUid!,
                              style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.primary,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 14),

                    // Email status
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _emailSent
                                ? AppColors.success.withOpacity(0.12)
                                : AppColors.error.withOpacity(0.12),
                            borderRadius: AppRadius.small,
                          ),
                          child: Icon(
                            _emailSent
                                ? Icons.mark_email_read_rounded
                                : Icons.email_outlined,
                            color: _emailSent
                                ? AppColors.success
                                : AppColors.error,
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _emailSent
                                ? 'Welcome email sent with UID & download link'
                                : 'Email could not be sent — share UID manually',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _emailSent
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}






