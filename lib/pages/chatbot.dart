import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../components/chatBubble.dart';

class Chatbot extends StatefulWidget {
  const Chatbot({Key? key}) : super(key: key);



  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  TextEditingController messageController = TextEditingController();
  List<Map<String, String>> messages = [];

  final primaryColor = const Color(0xFFF77F64);
  final secondaryColor = const Color(0xFFE5CFC0);
  final backgroundColor = const Color(0xFFFFF9F0);
  final textColor = const Color(0xFF2D3436);
  final accentColor = const Color(0xFFFFE8A3);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Chat screen background color
      appBar: AppBar(
        title: const Text(
          "ChatBot",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration:  BoxDecoration(
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
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              reverse: true, // Latest message at the bottom
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUserMessage = message['sender'] == 'user';

                return ChatBubble(
                  message: message['message']!,
                  isCurrentUser: isUserMessage,
                  userColor: const Color(0xFFF77F64), // Coral for user messages
                  botColor: const Color(0xFFE5CFC0), // Cream for bot messages
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: "Enter your message",
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white, // Text input background color
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: sendMessage,
                  backgroundColor: const Color(0xFFF77F64), // Send button color (coral)
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() async {
    final inputMessage = messageController.text;

    if (inputMessage.trim().isEmpty) return;

    // Add the user's message to the chat
    setState(() {
      messages.insert(0, {'sender': 'user', 'message': inputMessage});
      messageController.clear(); // Clear the input field
    });

    final url = Uri.parse("https://gpt4-tuf.onrender.com/api/v1/chat");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': inputMessage}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final botResponse = result['response'] ?? "No response message";

        // Add the bot's message to the chat
        setState(() {
          messages.insert(0, {'sender': 'bot', 'message': botResponse});
        });
      } else {
        setState(() {
          messages.insert(0, {'sender': 'bot', 'message': "Error: Unable to get response"});
        });
      }
    } catch (e) {
      setState(() {
        messages.insert(0, {'sender': 'bot', 'message': "Error: $e"});
      });
    }
  }
}
