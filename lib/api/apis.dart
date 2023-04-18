import 'dart:io';
import 'package:chat_application_with_firebase/models/chat_user.dart';
import 'package:chat_application_with_firebase/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class APIs {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for accessing firestore database
  static FirebaseStorage storage = FirebaseStorage.instance;

  //for getting self info.
  static late ChatUser me;

  //to return current user
  static User get user => auth.currentUser!;
  //checking if the user exist or not?
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for getting current user info.
  static Future<void> getSelfInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .get()
        .then((user) async => {
              if (user.exists)
                {me = ChatUser.fromJson(user.data()!)}
              else
                {await createUser().then((value) => getSelfInfo())}
            });
  }

  //for creating a new user
  static Future<void> createUser() async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();

    final chatUser = ChatUser(
      id: user.uid,
      name: user.displayName.toString(),
      email: user.email.toString(),
      about: 'Hey, I am using Zoto Chat!',
      image: user.photoURL.toString(),
      createdAt: time,
      isOnline: false,
      lastActive: time,
      pushToken: '',
    );
    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //for getting all users from firestore database.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return APIs.firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

  //for updating user information.
  static Future<void> updateUserInfo() async {
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.name, 'about': me.about});
  }

  //update profile picture of user.
  static Future<void> updateProfilePicture(File file) async {
    //getting image file extension.
    final ext = file.path.split('.').last;
    print('Extension: $ext');

    //storage file referrence with path
    final ref = storage.ref().child('profile_picture/${user.uid}.$ext');

    //uploading image.
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      print('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firebase database.
    me.image = await ref.getDownloadURL();
    await firestore
        .collection('users')
        .doc(user.uid)
        .update({'name': me.image});
  }

  ///****************** Chat Screen Related APIs ******************/
  // useful for getting conversation id
  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  /////for getting all users from firestore database.
  /////for getting all messages of a specific conversation from firestore database.
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return APIs.firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .snapshots();
  }

  //chats (collection) --> conversation_id (doc) --> messages (collection) --> messages (doc).
  //for sending message
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    //msg sending time (also used as id)
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    //message to send
    final Message message = Message(
        toId: chatUser.id,
        msg: msg,
        formId: user.uid,
        read: '',
        type: Type.text,
        sent: time);

    final ref =
        firestore.collection('chats/${getConversationID(user.uid)}/messages/');
    await ref.doc(time).set(message.toJson());
  }
}
