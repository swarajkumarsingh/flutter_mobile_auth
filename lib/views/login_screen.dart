import 'package:flutter/material.dart';
import 'package:flutter_auth_package/controller/auth_controller.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  // Auth Variables
  final number = TextEditingController();
  final enteredOtp = TextEditingController();

  // Form Keys
  final formKeyNumber = GlobalKey<FormState>();
  final formKeyOTP = GlobalKey<FormState>();

  // Auth-Controller
  final AuthController authController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Screen"),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            const Text("First Enter Mobile Number and then OTP"),
            Form(
              key: formKeyOTP,
              child: TextFormField(
                validator: (value) {
                  if (value!.isNotEmpty && value.length == 10) {
                    return null;
                  } else if (value.isEmpty) {
                    return "Please Enter a Number";
                  } else if (int.tryParse(value)! < 10) {
                    return "Please Enter 10 digits Number";
                  } else if (int.tryParse(value)! > 10) {
                    return "Please Enter 10 digits NUmber";
                  } else {
                    return "Please Enter a valid Number";
                  }
                },
                controller: enteredOtp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter the Number",
                  filled: true,
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              child: const Text("Enter Number"),
              onPressed: () async {
                if (!formKeyNumber.currentState!.validate()) {
                  return;
                }

                // _verifyPhoneNumber();
                await authController.verifyPhoneNumber(
                  number: number.text,
                );
              },
            ),
            const SizedBox(height: 20),
            Form(
              key: formKeyOTP,
              child: TextFormField(
                validator: (value) {
                  // Validating
                  if (value!.isNotEmpty && value.length == 6) {
                    return null;
                  } else if (value.isEmpty) {
                    return "Please Enter the OTP";
                  } else if (int.tryParse(value)! < 6) {
                    return "Please Enter 6 digits OTP";
                  } else if (int.tryParse(value)! > 6) {
                    return "Please Enter 6 digits OTP";
                  } else {
                    return "Please Enter a valid OTP";
                  }
                },
                controller: enteredOtp,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Enter the OTP",
                  filled: true,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              child: const Text("Enter OTP"),
              onPressed: () async {
                if (!formKeyOTP.currentState!.validate()) {
                  return;
                }
                await authController.verifyOtp(enteredOtp.text, context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
