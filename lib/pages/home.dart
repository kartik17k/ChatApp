import 'package:chat/components/drawer.dart';
import 'package:chat/pages/chat.dart';
import 'package:chat/services/auth/authService.dart';
import 'package:chat/services/chat/chatservice.dart';
import 'package:chat/components/usertile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../components/skeletion.dart';
import '../theme/colors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService auth = AuthService();
  final ChatService chat = ChatService();
  final TextEditingController searchController = TextEditingController();
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          "Messages",
          style: TextStyle(
            color: textColor,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded, color: textColor),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const MyDrawer(),
      body: Column(
        children: [
          buildSearchBar(),
          Expanded(
            child: buildUserList(),
          ),
        ],
      ),
    );
  }

  Widget buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      color: surfaceColor,
      child: Column(
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: "Search messages...",
              hintStyle: TextStyle(
                color: subtleTextColor,
                fontSize: 16,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: subtleTextColor,
                size: 22,
              ),
              filled: true,
              fillColor: backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: dividerColor,
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
          Container(
            height: 1,
            margin: const EdgeInsets.only(top: 8),
            color: dividerColor,
          ),
        ],
      ),
    );
  }

  Widget buildUserList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: chat.getUserStreamWithUnreadCount(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: accentColor,
                ),
                const SizedBox(height: 12),
                Text(
                  "Something went wrong",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {});
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                  ),
                  child: const Text(
                    "Try Again",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
            final userEmail = userData["user"]?["email"]?.toLowerCase() ?? '';
            return userEmail.contains(searchText) &&
                userEmail != auth.getCurrentUser()!.email;
          }).toList();

          if (filteredUsers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    searchText.isEmpty ? Icons.chat_bubble_outline_rounded : Icons.search_off_rounded,
                    size: 48,
                    color: subtleTextColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    searchText.isEmpty 
                      ? "Start a conversation" 
                      : "No users found",
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    searchText.isEmpty 
                      ? "Connect with others and start chatting"
                      : "Try a different search",
                    style: TextStyle(
                      color: subtleTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: filteredUsers.length,
            itemBuilder: (context, index) {
              final data = filteredUsers[index];
              final user = data['user'] as Map<String, dynamic>? ?? {};
              final lastMessage = data['lastMessage'] as Map<String, dynamic>? ?? {};
              final currentUserId = auth.getCurrentUser()!.uid;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: UserTile(
                  text: user['email'] ?? 'Unknown User',
                  ontap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chat(
                          reciverID: user['uid'] ?? '',
                          reciverEmail: user['email'] ?? 'Unknown User',
                        ),
                      ),
                    );
                  },
                  userId: user['uid'] ?? '',
                  currentUserId: currentUserId,
                  unreadCount: data['unreadCount'] ?? 0,
                  lastMessage: lastMessage['text'] ?? '',
                  lastMessageTime: lastMessage['timestamp'] != null
                      ? DateTime.fromMillisecondsSinceEpoch(
                          lastMessage['timestamp'] as int,
                        )
                      : null,
                  isOwnMessage: user['uid'] == currentUserId,
                ),
              );
            },
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: subtleTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                "No users available",
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildUserListItem(Map<String, dynamic> userData, BuildContext context) {
    String username = userData["user"]?["email"]?.split('@')?.first ?? 'Unknown User';
    final currentUserId = auth.getCurrentUser()!.uid;
    
    return UserTile(
      text: userData["user"]?["email"] ?? 'Unknown User',
      ontap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(
              reciverID: userData["user"]?["uid"] ?? '',
              reciverEmail: userData["user"]?["email"] ?? 'Unknown User',
            ),
          ),
        );
      },
      userId: userData["user"]?["uid"] ?? '',
      currentUserId: currentUserId,
      unreadCount: 0,
      lastMessage: '',
      lastMessageTime: null,
      isOwnMessage: userData["user"]?["uid"] == currentUserId,
    );
  }
}