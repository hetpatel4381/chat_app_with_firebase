import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application_with_firebase/api/apis.dart';
import 'package:chat_application_with_firebase/screens/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import '../helper/dialogs.dart';
import '../main.dart';
import '../models/chat_user.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        //appbar
        appBar: AppBar(
          automaticallyImplyLeading: true,
          title: const Text("Profile Screen"),
        ), //appbar completed

        //floating action button to add new user
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: FloatingActionButton.extended(
            backgroundColor: Colors.redAccent,
            onPressed: () async {
              Dialogs.showProgressBar(context);
              await APIs.auth.signOut().then((value) async {
                await GoogleSignIn().signOut().then((value) {
                  //for hiding progress dialog
                  Navigator.pop(context);

                  //for moving to home screen
                  Navigator.pop(context);

                  //replacing home screen with login screen
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
                });
              });
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
          //floating action button completed
        ),

        //actual body starts here.
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //for adding some space
                  SizedBox(width: mq.width, height: mq.height * .03),

                  //creating a profile pic of an user
                  Stack(
                    children: [
                      _image != null
                          ?
                          //local image.
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          :
                          //image from sever
                          ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: CachedNetworkImage(
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.fill,
                                imageUrl: widget.user.image,
                                // placeholder: (context, url) => CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          onPressed: () {
                            _showBottomSheet();
                          },
                          elevation: 1,
                          color: Colors.white,
                          shape: const CircleBorder(),
                          child: const Icon(Icons.edit, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),

                  //for adding some space
                  SizedBox(height: mq.height * .03),
                  Text(
                    widget.user.email,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),

                  SizedBox(height: mq.height * .05),
                  TextFormField(
                    onSaved: (val) => APIs.me.name = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty
                        ? null
                        : "Reqeuired Field",
                    initialValue: widget.user.name,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Colors.blue),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hintText: "eg. Preet Patel",
                      label: const Text("name*"),
                    ),
                  ),

                  SizedBox(height: mq.height * .02),
                  TextFormField(
                    onSaved: (val) => APIs.me.about = val ?? '',
                    validator: (val) => val != null && val.isNotEmpty
                        ? null
                        : "Reqeuired Field",
                    initialValue: widget.user.about,
                    decoration: InputDecoration(
                      prefixIcon:
                          const Icon(Icons.info_outline, color: Colors.blue),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      hintText: "eg. Feeling Happy",
                      label: const Text("about*"),
                    ),
                  ),

                  SizedBox(height: mq.height * .05),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          minimumSize: Size(mq.width * .5, mq.height * .06)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) => {
                                Dialogs.showSnackbar(
                                    context, "Profile Updated Successfully!")
                              });
                        }
                      },
                      icon: const Icon(
                        Icons.edit,
                        size: 28,
                      ),
                      label: const Text(
                        "UPDATE",
                        style: TextStyle(fontSize: 16),
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding:
                EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .05),
            children: [
              //pick profile picture.
              const Text(
                "Pick Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),

              //for adding some space.
              SizedBox(
                height: mq.height * .02,
              ),

              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button.
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
// Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                        if (image != null) {
                          print(
                              "Image Path : ${image.path} -- MimeType : ${image.mimeType}");

                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));

                          //for hiding bottom sheet.
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/Images/add_image.png')),

                  //take pictures from camera.
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: const CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
// Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          print("Image Path : ${image.path}");

                          setState(() {
                            _image = image.path;
                          });
                          APIs.updateProfilePicture(File(_image!));

                          //for hiding bottom sheet.
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('assets/Images/camera.png')),
                ],
              ),
            ],
          );
        });
  }
}
