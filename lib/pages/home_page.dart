import 'package:conversation/viewmodel/user_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chat_homepage.dart';

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<UserViewModel>(context, listen: false).fetchUserData(widget.uid);
    });
  }
  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("Chat List"),
          actions: [
            IconButton(
              onPressed: () {
                Provider.of<UserViewModel>(context, listen: false).logoutUser(context);
              },
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: Consumer<UserViewModel>(
          builder: (context, userProvider, child) {
            if (userProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (userProvider.userData.isEmpty) {
              return Center(child: Text("No users found"));
            } else {
              return ListView.builder(
              itemCount: userProvider.userData.length,
              itemBuilder: (context, index) {
                var user = userProvider.userData[index];
                return InkWell(
                  onTap: () {
                    if (user.name != null && user.name!.isNotEmpty) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatHomePage(
                            otherUid: user.id.toString(),
                            otherName: user.name!,
                          ),
                        ),
                      );
                    } else {
                      print("User name is not available");
                    }
                  },

                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text("${user.name}"),
                      subtitle: Text("${user.email}"),
                    ),
                  ),
                );
              },
            );
          }
          },
        ),
        );
    }

}
