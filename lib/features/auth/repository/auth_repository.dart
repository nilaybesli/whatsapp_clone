import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/screens/otp_screen.dart';

final authRepositoryProvider = Provider(
      (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({
    required this.auth,
    required this.firestore,
  });

  Future<void> signInWithPhone(BuildContext context, String phoneNumber) async {
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {

           throw Exception(e.message);
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Navigate to OTP screen
          Navigator.pushNamed(
            context,
            OTPScreen.routeName,
            arguments: verificationId,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Handle auto retrieval timeout if needed
        },
      );
    } on FirebaseAuthException catch (e) {
      // Handle FirebaseAuthException
      showSnackBar(context: context, content: e.message!);
    } catch (e) {
      // Handle other exceptions
      showSnackBar(context: context, content: 'An unexpected error occurred.');
    }
  }
}
