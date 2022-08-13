// ignore_for_file: non_constant_identifier_names, prefer_function_declarations_over_variables, unused_element
// **

// auth-controller(number, context:optional)
// @author Swaraj Kumar Singh
// version 1.0.0

// */

import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_auth_package/utils/utility.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class AuthController extends GetxController {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Using Getx Variables
  var userToken = "".obs;
  var statusCode = "".obs;
  var userData = "".obs;
  var userTokenFirebase = "".obs;
  var userInfo = "".obs;
  var vf = "".obs;
  var status_string = "welcome".obs;
  var code_sent = false.obs;
  var verification_id = "".obs;
  var isLoading = false.obs;

  // Performing getter, to simplify the accessibility
  String get result => status_string.value;
  String get userTokenFirebase_result => userTokenFirebase.value;
  String get userData_result => userData.value;
  String get statusCode_result => statusCode.value;
  String get userToken_result => userToken.value;
  String get userInfo_result => userInfo.value;
  String get verification_id_result => verification_id.value;
  bool get code_sent_result => isLoading.value;
  bool get isLoading_result => isLoading.value;

  verifyPhoneNumber({
    required String number,
  }) async {
    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      Utility.showToast(msg: authException.message.toString());
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
      code_sent.value = true;
      Utility.showToast(
        msg: "Please check your phone for the verification code.",
      );
      verification_id.value = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      verification_id.value = verificationId;
    };

    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {};

    await auth
        .verifyPhoneNumber(
          phoneNumber: "+91$number",
          timeout: const Duration(seconds: 5),
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        )
        .then((value) {})
        .catchError((onError) {
      Utility.showToast(msg: "Something went wrong, Try again later.");
    });
  }

  signInWithPhoneNumber(
      {required String otp, required BuildContext context}) async {
    if (await Utility.checkInternet() == false) {
      isLoading.value = false;
      Utility.showToast(msg: "No internet connection");
      return;
    }

    try {
      isLoading.value = true;
      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verification_id.toString(),
        smsCode: otp,
      );
      final User? user = (await auth.signInWithCredential(credential)).user;

      if (user != null) {
        // Firebase Verification ID
        userTokenFirebase.value = await user.getIdToken(false);

        final User? currentUser = auth.currentUser;

        if (currentUser != null) {
          assert(user.uid == currentUser.uid);
        }

        // ? [* You can end your process here and get firebase token(userTokenFirebase) *]
        // ? [* For sending the firebaseToken to backend for further verification cn continue *]

        // OnSuccess Run the Run your code below

        // Sending request to the backend (firebase token)
        // Calling the login function
        loginUser();
      }
    } catch (e) {
      isLoading.value = false;
      Utility.showToast(msg: e.toString());
    }
  }

  void loginUser() async {
    try {
      isLoading.value = true;

      // Options (Uri and Headers)
      String uri = "YourURI";
      var body = {"add": "headers"};

      // Send Request to backend
      http.Response response = await http.post(
        Uri.parse("$uri/auth/login/bike-dho"),
        body: body,
      );

      // Run The Code below if it is true
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Add token to local Storage
        final box = GetStorage();
        box.write(
          'x-auth-token',
          data["data"]["token"],
        );

        // Run Onsuccess Function
        Utility.showToast(msg: "Logged in SuccessFully");
        onSuccess();
      } else {
        // Status code not 200
        Utility.showToast(
          msg: "SomeThing went wrong, Try again later.",
        );
        isLoading.value = false;
      }
    } catch (e) {
      // Catch Error
      Utility.showToast(
        msg: "SomeThing went wrong, Try again later.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // succeeder  function to signInWithPhoneNumber
  verifyOtp(String otpText, BuildContext context) async {
    signInWithPhoneNumber(otp: otpText, context: context);
  }

  void onSuccess() {
    // OnSuccess Todo
    isLoading.value = false;
  }
}
