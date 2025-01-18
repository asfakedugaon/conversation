import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import '../model/chat_model.dart';
import '../model/user_model.dart';

class ChatViewModel with ChangeNotifier {

  final TextEditingController chatController = TextEditingController();
  final String chatHint = "Enter message";
  var chatList = <ChatModel>[];
  var userList = <UserModel>[];
  var uid = FirebaseAuth.instance.currentUser?.uid ?? "";

  void getChatList({required String cid, required String otherId}) {
    var chatId = getChatId(cid: cid, otherId: otherId);

    FirebaseDatabase.instance.ref('messages/$chatId').onValue.listen((event) {
      chatList.clear();
      for (var element in event.snapshot.children) {
        var chat = ChatModel(
          senderId: element.child("senderId").value.toString(),
          receiverId: element.child("receiverId").value.toString(),
          message: element.child("message").value.toString(),
          status: element.child("status").value.toString(),
          dateTime: element.child("dateTime").value != null
              ? DateTime.parse(element.child("dateTime").value.toString())
              : null,
        );
        chatList.add(chat);
      }
      notifyListeners();
    });
  }

  void sendChat({required String otherUid}) {
    var chatId = getChatId(cid: uid, otherId: otherUid);
    var timestamp = DateTime.now().toIso8601String();

    var chatMessage = {
      'senderId': uid,
      'receiverId': otherUid,
      'message': chatController.text,
      'status': 'sent',
      'dateTime': timestamp,
      'isImage': false,
      'imageUrl': null,
    };

    FirebaseDatabase.instance.ref('messages/$chatId').push().set(chatMessage);

    chatController.clear();
    notifyListeners();
  }

  Future<void> sendImage({required String otherUid, required String imagePath}) async {
    try {
      var chatId = getChatId(cid: uid, otherId: otherUid);
      var timestamp = DateTime.now().toIso8601String();


      String fileName = "chat_images/${generateRandomString(10)}.jpg";
      UploadTask uploadTask = FirebaseStorage.instance
          .ref(fileName)
          .putFile(File(imagePath));

      TaskSnapshot snapshot = await uploadTask;
      String imageUrl = await snapshot.ref.getDownloadURL();

      var chatMessage = {
        'senderId': uid,
        'receiverId': otherUid,
        'message': "",
        'status': 'sent',
        'dateTime': timestamp,
        'isImage': true,
        'imageUrl': imageUrl,
      };

      FirebaseDatabase.instance.ref('messages/$chatId').push().set(chatMessage);
    } catch (e) {
      print("Error sending image: $e");
    }
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
  }
  void getUserList() {
    FirebaseDatabase.instance.ref('users').onValue.listen((event) {
      userList.clear();
      for (var element in event.snapshot.children) {
        var user = UserModel(
          id: element.child("id").value.toString(),
          name: element.child("name").value.toString(),
          email: element.child("email").value.toString(),
        );
        userList.add(user);
      }
      notifyListeners();
    });
  }

  String getChatId({required String cid, required String otherId}) {
    var id = "";
    if (cid.compareTo(otherId) > 0) {
      id = "${cid}_$otherId";
    } else {
      id = "${otherId}_$cid";
    }

    FirebaseDatabase.instance.ref('messages').child(id).get().then((value) {
      if (value.exists) {
      } else {
        var chatId =
        FirebaseDatabase.instance.ref().child("messages").child(id).set(id);
        print(chatId);
      }
    });
    return id;
    }
}
