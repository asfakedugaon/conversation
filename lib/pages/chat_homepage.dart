import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatViewModel>().getChatList(cid: uId ?? "", otherId: widget.otherUid);
    });
  }

  Future<void> _pickImage() async {
    try {
      final image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        context.read<ChatViewModel>().sendImage(otherUid: widget.otherUid, imagePath: image.path);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
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
                      bool isSender = user.senderId == uId;
                      final formatedTime = user.dateTime != null
                    ? DateFormat('hh:mm a').format(user.dateTime!): 'No Time';

                    return Align(
                      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (user.isImage && user.imageUrl != null)
                            Image.asset(user.imageUrl!, height: 100, width: 100, fit: BoxFit.cover)
                          else
                            Container(
                              padding: const EdgeInsets.all(14),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.7,
                              ),
                              decoration: BoxDecoration(
                                color: isSender ? Colors.orange.shade400 : Colors.grey.shade200,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isSender ? 16 : 4),
                                  bottomRight: Radius.circular(isSender ? 4 : 16),
                                ),
                              ),
                              child: Text("${user.message}",
                                style: TextStyle(color: isSender ? Colors.white : Colors.black87),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(formatedTime, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                    );
                    }
                );
              },
            ),
          ),
          SizedBox(
              height: 110,
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.photo), onPressed: _pickImage),
                  Expanded(
                    child: TextField(
                      controller: viewModel.chatController,
                      maxLines: null,
                      decoration: InputDecoration(
                        hintText: viewModel.chatHint,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                SizedBox(width: 10,),
                GestureDetector(
                  onTap: () {
                    if(viewModel.chatController.text.trim().isNotEmpty) {
                      viewModel.sendChat(otherUid: widget.otherUid);
                    }
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.green.shade400,
                    child: Icon(Icons.send, color: Colors.white,),
                  ),
                )
                ],
              ),
            )
          ],
        ),

        );
    }
}
