import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_picker_dropdown.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase/Firebase/PostRealtimeDatabase.dart';
import 'package:flutter_firebase/Firebase/UserRealtimeDatabase.dart';
import 'package:flutter_firebase/Module/Screens/Home/homeController.dart';
import 'package:flutter_firebase/Module/Screens/Home/homeScreen.dart';
import 'package:flutter_firebase/Module/Screens/OTP/otpScreen.dart';
import 'package:flutter_firebase/utils/constant.dart';
import 'package:get/get.dart';

import '../../../Firebase/MessageRealtimeDatabase.dart';

class PhoneRegisterScreen extends StatefulWidget {
  PhoneRegisterScreen({super.key});

  @override
  State<PhoneRegisterScreen> createState() => _PhoneRegisterScreenState();
}

class _PhoneRegisterScreenState extends State<PhoneRegisterScreen> {
  String? code = "";

  String? phoneNumber = "";

  TextEditingController phonecontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  final UserControllerRealTimeDataBase userControllerRealTimeDataBase =
      Get.put(UserControllerRealTimeDataBase());
  final PostControllerRealTimeDataBase postControllerRealTimeDataBase =
      Get.put(PostControllerRealTimeDataBase());
  final MessageControllerRealTimeDataBase messageControllerRealTimeDataBase =
      Get.put(MessageControllerRealTimeDataBase());
  final HomeController homeController = Get.put(HomeController());

  @override
  void initState() {
    // TODO: implement initState
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        print('user.uid--------------------->${user.uid}');
        print('user.displayName--------------------->${user.displayName}');
        print('user.email--------------------->${user.email}');
        print('user.phoneNumber--------------------->${user.phoneNumber}');
        print('user.photoURL--------------------->${user.photoURL}');
        print('user.emailVerified--------------------->${user.emailVerified}');
        print('user.isAnonymous--------------------->${user.isAnonymous}');

        Get.to(HomeScreen());
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: Center(
      child: Container(
        height: MediaQuery.of(context).size.height / 2,
        width: MediaQuery.of(context).size.width / 1.1,
        decoration: decor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: decorinput,
                child: TextField(
                  controller: namecontroller,
                  keyboardType: TextInputType.name,
                  decoration: decorTextFiled('Name....'),
                  textAlign: TextAlign.center,
                ),
              ),
              Row(
                children: [
                  Container(
                    decoration: decorinput,
                    child: CountryPickerDropdown(
                      onTap: () {},

                      initialValue: 'AR',

                      itemBuilder: _buildDropdownItem,

                      //itemFilter:  ['AR', 'DE', 'GB', 'CN'].contains(c.isoCode),

                      priorityList: [
                        CountryPickerUtils.getCountryByIsoCode('GB'),
                        CountryPickerUtils.getCountryByIsoCode('CN'),
                      ],

                      sortComparator: (Country a, Country b) =>
                          a.isoCode.compareTo(b.isoCode),

                      onValuePicked: (Country country) {
                        code = country.phoneCode;
                        print(
                            "${country.name}${country.iso3Code}${country.isoCode}${country.phoneCode}");
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 2,
                  ),
                  Expanded(
                    child: Container(
                        decoration: decorinput,
                        child: TextField(
                          controller: phonecontroller,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '599......',
                          ),
                        )),
                  )
                ],
              ),
              Container(
                  decoration: decor,
                  child: TextButton(
                      onPressed: () async {
                        if (phonecontroller.text.isEmpty) {
                          Get.snackbar(
                              'لتسجيل الدخول', 'الرجاء إدخال رقم الهاتف');
                          return;
                        }
                        if (namecontroller.text.isEmpty) {
                          Get.snackbar('لتسجيل الدخول', 'الرجاء إدخال الإسم');
                          return;
                        }
                        if (namecontroller.text.isNotEmpty &&
                            phonecontroller.text.isNotEmpty) {
                          print('${code}${phonecontroller.text}');
                          await FirebaseAuth.instance.verifyPhoneNumber(
                            phoneNumber:
                                '+${code}${phonecontroller.text.toString()}',
                            verificationCompleted:
                                (PhoneAuthCredential credential) {

                                },
                            verificationFailed: (FirebaseAuthException e) {
                              print(
                                  'e.phoneNumber----------->${e.phoneNumber}');
                            },
                            codeSent:
                                (String verificationId, int? resendToken) {
                              print(
                                  'verificationId----------------->${verificationId}');
                              print('resendToken-------->${resendToken}');
                              Get.to(OtpScreen(
                                  verificationId: verificationId,
                                  name: namecontroller.text));
                            },
                            codeAutoRetrievalTimeout: (String verificationId) {
                              print(
                                  'verificationId------------->${verificationId}');
                            },
                            timeout: Duration(minutes: 1)
                          );
                        }
                      },
                      child: Text('تسجيل الدخول')))
            ],
          ),
        ),
      ),
    )));
  }

  Widget _buildDropdownItem(Country country) => Container(
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            SizedBox(
              width: 8.0,
            ),
            Text("+${country.phoneCode}(${country.isoCode})"),
          ],
        ),
      );
}
