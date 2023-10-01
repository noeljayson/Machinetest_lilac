import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:machine_test_lilac/login_screen.dart';

import 'home_screen.dart';

class AddDetailPage extends StatefulWidget {
  const AddDetailPage({Key? key}) : super(key: key);

  @override
  State<AddDetailPage> createState() => _AddDetailPageState();
}

class _AddDetailPageState extends State<AddDetailPage> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController dateinput = TextEditingController();

  String auth = ( FirebaseAuth.instance.currentUser!).uid;


  final picker = ImagePicker();
  File? _images;
  bool isclicked = true;
  FirebaseStorage _storage = FirebaseStorage.instance;

  String imageUrl = "";

  String image = "";
  String name = "";
  String email = "";

  final _form = GlobalKey<FormState>();

  String newfirstname = "";
  bool isedited = false;

  bool editable = false;

  @override
  void initState() {
    dateinput.text = ""; //set the initial value of text field
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Edit Profile'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        _showDialogSelectPhoto();
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 100,
                            height: 100,
                            child: CircleAvatar(
                              backgroundColor: Colors.green,
                              radius: 43,
                              child: Image.network(imageUrl),
                            ),
                          ),
                          Positioned(
                              bottom: 1,
                              right: 1,
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: const InkWell(
                                  //  onTap: _onAlertPress,
                                  child: Icon(
                                    Icons.add_a_photo,
                                    size: 15.0,
                                    color: Colors.blue,
                                  ),
                                ),
                              ))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: namecontroller,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter  name';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                            hintText: 'Enter first Name',
                            labelText: 'Name',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Colors.blue,
                            ),
                            errorStyle: TextStyle(fontSize: 12.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.0)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: emailcontroller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the email';
                          }

                          if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                            return "Please enter a valid email address";
                          }

                          return null;
                        },
                        decoration: const InputDecoration(
                            hintText: 'Email',
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.lightBlue,
                            ),
                            errorStyle: TextStyle(fontSize: 12.0),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(9.0)))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter dob';
                          }
                          return null;
                        },
                        controller: dateinput,
                        readOnly: true,
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2101));

                          if (pickedDate != null) {
                            print(pickedDate);
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(pickedDate);
                            print(
                                formattedDate);

                            setState(() {
                              dateinput.text =
                                  formattedDate;
                            });
                          } else {
                            print("Date is not selected");
                          }
                        },
                        decoration: const InputDecoration(
                            hintText: 'Enter dob',
                            labelText: 'DOB',
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
                            'Save',
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          ),
                          onPressed: ()async {
                            if (_formkey.currentState!.validate()) {
                              print('form submiitted');
                              adduserdetails();

                            }
                          },
                        ),
                      ),
                    )),

                  ],
                )),
          ),
        ));
  }

  void adduserdetails() {
    final data = {
      'name': namecontroller.text,
      'email': emailcontroller.text,
      'dob': dateinput.text
    };
    FirebaseFirestore.instance.collection('userdetail').doc(auth).set(data);

    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) =>  HomeScreen(vidlist: "",)));
    Fluttertoast.showToast(msg: "Profile details added");
  }

  _showDialogSelectPhoto() async {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(20), topLeft: Radius.circular(20))),
        builder: (builder) {
          return SizedBox(
              height: 115.0,
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.camera_alt,
                      color: Colors.blue,
                    ),
                    title: const Text("Camera",
                        style: TextStyle(
                            fontFamily: 'Corbel_Regular',
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                            color: Colors.black)),
                    onTap: () async {
                      Navigator.pop(context);

                      try {
                        XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 30);

                        if (image != null) {
                          setState(() {});
                          _images = File(image.path);

                          await uploadImageToFirebase(_images!);
                        }
                      } catch (e) {
                        print(e);
                      }
                      setState(() {});
                    },
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.image,
                      color: Colors.blue,
                    ),
                    title: const Text("Gallery",
                        style: TextStyle(
                            fontFamily: 'Corbel_Regular',
                            fontWeight: FontWeight.normal,
                            fontSize: 15,
                            color: Colors.black)),
                    onTap: () async {
                      Navigator.pop(context);

                      try {
                        XFile? image = (await picker.pickImage(
                            source: ImageSource.gallery, imageQuality: 30));
                        if (image != null) {
                          setState(() {});
                          _images = (File(image.path));

                          await uploadImageToFirebase(_images!);

                          setState(() {});
                        }
                      } catch (e) {
                        print(e);
                      }

                      setState(() {});
                    },
                  ),
                ],
              ));
        });
  }

  Future uploadImageToFirebase(File images) async {
    String fileName = path.basename(images.path);
    String userid = (FirebaseAuth.instance.currentUser!).uid;
    Reference reference =
        FirebaseStorage.instance.ref().child('profileImage/$userid.jpg');

    UploadTask uploadTask = reference.putFile(images);
    TaskSnapshot snapshot = await uploadTask;

    imageUrl = await snapshot.ref.getDownloadURL();
  }
}
