import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../viewmodel/chat_viewmodel.dart';
import 'home_page.dart';


class ChatHomePage extends StatefulWidget {
  final String otherUid;
  final String otherName;

  const ChatHomePage({super.key, required this.otherUid, required this.otherName});

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final uId=FirebaseAuth.instance.currentUser?.uid;
  ScrollController controller = ScrollController();

  @override
  void initState() {
    super.initState();
    var uid= FirebaseAuth.instance.currentUser?.uid ??"";
    Future.delayed(Duration(seconds: 2),() async{
      var viewModel = Provider.of<ChatViewModel>(context, listen: false);
      var chatRoomId = await viewModel.getChatList(cid: uid, otherId: widget.otherUid);
    },);
  }
  @override
  Widget build(BuildContext context) {
    var viewModel = Provider.of<ChatViewModel>(context,listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.otherName),
          leading: IconButton(onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage(uid: FirebaseAuth.instance.currentUser?.uid?? ""),));
          }, icon: Icon(Icons.arrow_back)),
        ),
        body: Column(
          children: [
            Container(
            height: MediaQuery.of(context).size.height - 210 -
                MediaQuery.of(context).viewInsets.bottom,
            child: Consumer<ChatViewModel>(
              builder: (context, value, child) {
                if (value.chatList.isEmpty) {
                  return Center(
                      child: Text("No messages yet!"));
                }
                return ListView.builder(
                  controller: controller,
                  itemCount: value.chatList.length,
                  itemBuilder: (context, index) {
                    var user = value.chatList[index];
                    if (user.message_type.toString() == "image") {
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: user.senderId == uId
                              ? Align(
                              alignment: Alignment.topRight,
                              child: Image.network("${user.photo_url}",  height: 150, width: 150,))
                              : Align(
                              alignment: Alignment.topLeft,
                              child: Image.network("${user.photo_url}", height: 100, width: 100,))
                      );

                    }else {
                      bool isSender = user.senderId == uId;
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                              alignment: isSender
                                  ? Alignment.topRight
                                  : Alignment.topLeft,
                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                      color: isSender
                                          ? Colors.green[200]
                                          : Colors.grey[300],
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10)
                                      )
                                  ),
                                  child: Text(
                                    "${user.message}",
                                    style: TextStyle(color: Colors.black),
                                  ))));
                    }
                  },
                );
              },
            ),
          ),
          SizedBox(
              height: 110,
              child: Row(
                children: [
                  Expanded(child: TextField(
                    controller: viewModel.chatController,
                    decoration: InputDecoration(hintText: "massage",border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
                  )),
                  IconButton(onPressed: () {
                    viewModel.sendChat(otherUid: widget.otherUid);
                    Future.delayed(Duration(milliseconds: 500),() {
                      controller.jumpTo(controller.position.maxScrollExtent);
                    });
                  }, icon: Icon(Icons.send))
                ],
              ),
            )
          ],
        ),

        );
    }
}
