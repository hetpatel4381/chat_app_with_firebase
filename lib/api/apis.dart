import 'package:chat_application_with_firebase/models/chat_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class APIs {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for accessing firestore database
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

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
}
