
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';


class ProfileDisplayPage extends StatefulWidget {
  final String name,email,dob,imageurl;
  const ProfileDisplayPage({Key? key, required this.name, required this.email, required this.dob, required this. imageurl, }) : super(key: key);

  @override
  State<ProfileDisplayPage> createState() => _ProfileDisplayPageState();
}

class _ProfileDisplayPageState extends State<ProfileDisplayPage> {
  final _formkey = GlobalKey<FormState>();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController dateinput = TextEditingController();



  @override
  void initState() {
    dateinput.text = widget.dob;
    namecontroller.text=widget.name;
    emailcontroller.text=widget.email;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Profile'),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Form(
                key: _formkey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircleAvatar(

                        radius: 43,
                        child: Image.network(widget.imageurl),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: TextFormField(
                        controller: namecontroller,
                        readOnly: true,

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
                        readOnly: true,

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


                        controller: dateinput,
                        readOnly: true,

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


                  ],
                )),
          ),
        ));
  }




}
