import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_application_with_firebase/api/apis.dart';
import 'package:chat_application_with_firebase/screens/auth/login_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appbar
      appBar: AppBar(
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
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
        child: Column(
          children: [
            //for adding some space
            SizedBox(width: mq.width, height: mq.height * .03),

            //creating a profile pic of an user
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(mq.height * .1),
                  child: CachedNetworkImage(
                    width: mq.height * .2,
                    height: mq.height * .2,
                    fit: BoxFit.fill,
                    imageUrl: widget.user.image,
                    // placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const CircleAvatar(
                      child: Icon(CupertinoIcons.person),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: MaterialButton(
                    onPressed: () {},
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
              initialValue: widget.user.name,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person, color: Colors.blue),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "eg. Preet Patel",
                label: const Text("name*"),
              ),
            ),

            SizedBox(height: mq.height * .02),
            TextFormField(
              initialValue: widget.user.about,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.info_outline, color: Colors.blue),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                hintText: "eg. Feeling Happy",
                label: const Text("about*"),
              ),
            ),

            SizedBox(height: mq.height * .05),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    minimumSize: Size(mq.width * .5, mq.height * .06)),
                onPressed: () {},
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
    );
  }
}
