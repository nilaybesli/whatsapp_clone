import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whatsapp_clone/common/repositories/common_firebase_Storage_repository.dart';
import 'package:whatsapp_clone/common/utils/utils.dart';
import 'package:whatsapp_clone/features/auth/screens/otp_screen.dart';
import 'package:whatsapp_clone/models/user_model.dart';
import 'package:whatsapp_clone/screens/mobile_layout_screen.dart';

import '../screens/user_information_screen.dart';

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

  Future<UserModel?> getCurrentUserData() async {
    var userData =
        await firestore.collection('users').doc(auth.currentUser?.uid).get();
    UserModel? user;
    if (userData.data() != null) {
      user = UserModel.fromMap(userData.data()!);
    }
    return user;
  }

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
          Navigator.pushNamed(
            context,
            OTPScreen.routeName,
            arguments: verificationId,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    } catch (e) {
      showSnackBar(context: context, content: 'An unexpected error occurred.');
    }
  }

  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      await auth.signInWithCredential(credential);
      Navigator.pushNamedAndRemoveUntil(
          context, UserInformationScreen.routeName, (route) => false);
    } on FirebaseAuthException catch (e) {
      showSnackBar(context: context, content: e.message!);
    }
  }

  void saveUserDataToFirebase({
    required String name,
    required File? profilePic,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl =
          'https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg';

      if (profilePic != null) {
        photoUrl = await ref
            .read(commonFirebaseStorageRepositoryProvider)
            .storeFileToFirebase('profilePic/$uid', profilePic);
      }

      var user = UserModel(
        name: name,
        uid: uid,
        profilePic: photoUrl,
        phoneNumber: auth.currentUser!.phoneNumber!,
        isOnline: true,
        groupId: [],
      );

      await firestore.collection('users').doc(uid).set(
            user.toMap(),
          );
      Navigator.pushNamedAndRemoveUntil(
          context, MobileLayoutScreen.routeName, (route) => false);
    } catch (e) {
      showSnackBar(context: context, content: e.toString());
    }
  }

 Stream<UserModel> userData(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(event.data()!),
        );
  }
}
