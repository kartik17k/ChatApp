import 'package:chat/components/chatBubble.dart';
import 'package:chat/components/textfield.dart';
import 'package:chat/services/auth/authService.dart';
import 'package:chat/services/chat/chatservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../components/chatloder.dart';
import '../theme/colors.dart';

class Chat extends StatefulWidget {
  final String reciverEmail;
  final String reciverID;

  Chat({super.key, required this.reciverEmail, required this.reciverID});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController messageController = TextEditingController();
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final FocusNode myFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();



  @override
  void initState() {
    super.initState();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
              () => scrollDown(),
        );
      }
    });
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown());
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      await chatService.sendMessage(widget.reciverID, messageController.text);
      messageController.clear();
      scrollDown();
    }
  }

  void deleteMessage(String messageID) async {
    await chatService.deleteMessage(
        messageID, widget.reciverID, authService.getCurrentUser()!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reciverEmail,
          style: const TextStyle(color: Colors.white),
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
        elevation: 0, // No shadow under AppBar
      ),
      body: Container(
        color: const Color(0xFFFFF9F0), // Lighter cream background for the body
        child: Column(
          children: [
            Expanded(child: buildMessageList()),
            buildUserInput(),
          ],
        ),
      ),
    );
  }

  Widget buildMessageList() {
    String senderID = authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: chatService.getMessages(widget.reciverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Error loading messages.");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            itemCount: 5, // Display 5 skeleton loaders
            itemBuilder: (context, index) => ChatBubbleSkeleton(
              isCurrentUser: index % 2 == 0, // Alternate alignment for demo
            ),
          );
        }
        return ListView(
          controller: scrollController,
          children: snapshot.data!.docs
              .map((doc) => buildMessageItem(doc))
              .toList(),
        );
      },
    );
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == authService.getCurrentUser()!.uid;
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return GestureDetector(
      onLongPress: isCurrentUser
          ? () => showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Container(
              height: 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton.icon(
                      onPressed: () {
                        deleteMessage(doc.id);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      )
          : null,
      child: Container(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: isCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            ChatBubble(
              message: data["message"],
              isCurrentUser: isCurrentUser,
            )
          ],
        ),
      ),
    );
  }

  Widget buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextField(
              hinttext: "Type a message",
              obscuretext: false,
              controller: messageController,
              focusNode: myFocusNode,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 8.0, right: 16.0),
            decoration: const BoxDecoration(
              color: Color(0xFFF77F64), // Coral for the send button
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
