import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chatbot extends StatefulWidget {
  const Chatbot({Key? key}) : super(key: key);

  @override
  _ChatbotState createState() => _ChatbotState();
}

class _ChatbotState extends State<Chatbot> {
  TextEditingController messageController = TextEditingController();
  List<Map<String, String>> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background color for the chat screen
      appBar: AppBar(
        title: const Text("ChatBot"),
        backgroundColor: Colors.transparent, // Transparent AppBar background
        elevation: 0,
        centerTitle: true,// No shadow under AppBar
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

                return Align(
                  alignment: isUserMessage
                      ? Alignment.centerRight
                      : Alignment.centerLeft, // Align messages based on sender
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(
                        vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Colors.greenAccent // User message color
                          : Colors.grey[300], // Bot message color
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      message['message']!,
                      style: TextStyle(
                        color: isUserMessage
                            ? Colors.white // User message text color
                            : Colors.black, // Bot message text color
                        fontSize: 16,
                      ),
                    ),
                  ),
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
                      fillColor: Colors.white, // Background color for text input
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: sendMessage,
                  backgroundColor: Colors.redAccent, // Send button color
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
