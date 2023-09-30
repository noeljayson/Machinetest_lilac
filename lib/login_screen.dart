import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:machine_test_lilac/home_screen.dart';
import 'package:machine_test_lilac/otp.dart';
import 'package:machine_test_lilac/register_page.dart';
import 'package:machine_test_lilac/widgets/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String verificationId = "";

  bool showLoading = false;
  final phoneController = TextEditingController(text: "+91");
  final _formkey = GlobalKey<FormState>();


  bool _isValid = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final overlay = LoadingOverlay.of(context);
    var screenSize = MediaQuery.of(context).size;

    return Scaffold(

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Login'),
      ),
      body: SizedBox(
          height: screenSize.height,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Form(
                  key: _formkey,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: screenSize.height * 0.10,
                        ),
                        const Center(
                          child: Center(
                            child: Text(
                              'Please enter your ten digit phone number',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: screenSize.height * 0.05,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter mobile number';
                              }
                              return null;
                            },
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(13)
                            ],
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(
                                hintText: 'Mobile',
                                labelText: 'Mobile',
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color: Colors.blue,
                                ),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(9)))),
                          ),
                        ),
                        Center(
                            child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            height: 40,
                            child: ElevatedButton(
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 22),
                              ),
                              onPressed: () async{
                                setState(() {
                                  _isValid = _formkey.currentState!.validate();
                                });
                                if (_formkey.currentState!.validate()) {
                                  _formkey.currentState!.save();
                                  print('form submiitted');
                                  print("phonecc");
                                  print(phoneController.text);
                                  await _auth.verifyPhoneNumber(
                                    phoneNumber:
                                        phoneController.text,
                                    verificationCompleted:
                                        (phoneAuthCredential) async {
                                      setState(() {
                                        showLoading = false;
                                      });
                                    },
                                    verificationFailed:
                                        (verificationFailed) async {
                                      setState(() {
                                        showLoading = false;
                                      });

                                      SnackBar(
                                          content: Text(
                                              verificationFailed.message
                                                  .toString()));
                                    },
                                    codeSent: (verificationId,
                                        resendingToken) async {
                                      setState(() async {
                                        showLoading = false;

                                        this.verificationId =
                                            verificationId;

                                        print("verificationid");
                                        print(verificationId);
                                        print("resendingtoken");
                                        print(resendingToken);

                                        await overlay.during(
                                            Future.delayed(
                                                const Duration(
                                                    seconds: 3)));

                                        if (mounted) {}
                                        print("phonecc");
                                        print(phoneController.text);

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return  MyOtp(verifyid:verificationId,mobno:phoneController.text);
                                            },
                                          ),
                                        );
                                      });
                                    },
                                    codeAutoRetrievalTimeout:
                                        (verificationId) async {},
                                  );

                                }

                              },
                            ),
                          ),
                        )),

                        SizedBox(
                          height: screenSize.height * 0.03,
                        ),

                      ],
                    ),
                  )),
            ),
          )),
    );
  }
}


