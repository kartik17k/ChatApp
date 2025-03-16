import 'package:chat/components/drawer.dart';
import 'package:chat/pages/chat.dart';
import 'package:chat/pages/chatbot.dart';
import 'package:chat/services/auth/authService.dart';
import 'package:chat/services/chat/chatservice.dart';
import 'package:flutter/material.dart';
import '../components/skeletion.dart';
import '../theme/colors.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService auth = AuthService();
  final ChatService chat = ChatService();
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  bool isLoading = true;
  //
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Messages",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor,
                primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Chatbot()),
          );
        },
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      body: Container(
        color: backgroundColor,
        child: Column(
          children: [
            buildSearchBar(),
            const SizedBox(height: 16),
            Expanded(
              child: buildUserList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search messages...",
          hintStyle: TextStyle(
            color: textColor.withOpacity(0.5),
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: textColor.withOpacity(0.7),
            size: 22,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: primaryColor.withOpacity(0.5),
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchText = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chat.getUserStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Something went wrong",
              style: TextStyle(
                color: textColor,
                fontSize: 16,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: 5,
            itemBuilder: (context, index) => const SkeletonLoader(),
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          );
        }

        if (snapshot.hasData) {
          final filteredUsers = snapshot.data!.where((userData) {
            final userEmail = userData["email"].toLowerCase();
            return userEmail.contains(searchText) &&
                userEmail != auth.getCurrentUser()!.email;
          }).toList();

          if (filteredUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 48,
                    color: textColor.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No users found",
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final userData = filteredUsers[index];
              return buildUserListItem(userData, context);
            },
            separatorBuilder: (context, index) => const SizedBox(height: 12),
          );
        }

        return const Center(child: Text("No users available"));
      },
    );
  }

  Widget buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    String username = userData["email"].split('@')[0];
    String capitalizedUsername = username[0].toUpperCase() + username.substring(1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Chat(
                  reciverEmail: userData["email"],
                  reciverID: userData["uid"],
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      capitalizedUsername.substring(0, 1),
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        capitalizedUsername,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Tap to start chatting",
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: textColor.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}