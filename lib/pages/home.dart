import 'package:chat/components/drawer.dart';
import 'package:chat/pages/chat.dart';
import 'package:chat/pages/chatbot.dart';
import 'package:chat/services/auth/authService.dart';
import 'package:chat/services/chat/chatservice.dart';
import 'package:flutter/material.dart';

import '../components/usertile.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //chat and auth services
  final AuthService auth = AuthService();
  final ChatService chat = ChatService();

  // search text controller
  TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Chatbot()),
          );
        },
        child: const Icon(Icons.chat),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search users...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.grey,
                    width: 1.0,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Colors.blue,
                    width: 2.0,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase(); // Update searchText
                });
              },
            ),
          ),
          Expanded(
            child: buildUserList(),
          ),
        ],
      ),
    );
  }

  //build user list for current logged in user
  Widget buildUserList() {
    return StreamBuilder(
      stream: chat.getUserStream(),
      builder: (context, snapshot) {
        // Error
        if (snapshot.hasError) {
          return const Center(child: Text("Error"));
        }

        // Loading..
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Filter users
        final filteredUsers = snapshot.data!.where((userData) {
          final userEmail = userData["email"].toLowerCase();
          return userEmail.contains(searchText) &&
              userData["email"] != auth.getCurrentUser()!.email;
        }).toList();

        // If no users found
        if (filteredUsers.isEmpty) {
          return const Center(child: Text("User not found"));
        }

        // Return filtered user list
        return ListView(
          children: filteredUsers
              .map<Widget>((userData) => buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  Widget buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    return UserTile(
      ontap: () {
        //go to chat page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(
              reciverEmail: userData["email"],
              reciverID: userData["uid"],
            ),
          ),
        );
      },
      text: userData["email"],
    );
  }
}
