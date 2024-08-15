import 'package:chat/pages/aboutApp.dart';
import 'package:chat/services/chat/chatservice.dart';
import 'package:flutter/material.dart';

import '../services/auth/authgate.dart';
import 'deleteAcc.dart';

class Settings extends StatelessWidget {
  Settings({super.key});
  final ChatService chatService = ChatService();

  void delete() async{
    await chatService.deleteUserAccount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  padding: EdgeInsets.all(25),
                  margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => AboutApp()));
                    },
                    child: Text("About App",style: TextStyle(fontSize: 25,),//color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  padding: EdgeInsets.all(25),
                  margin: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                  child: GestureDetector(
                    onTap: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Delete Account"),
                            content: Text("Are you sure you want to delete your account? This action cannot be undone."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close the dialog
                                },
                                child: Text("Cancel" ,style: TextStyle(
                                    color: Colors.black87, // Customize text color
                          ),),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  delete(); // Execute the delete function
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthGate())); // Navigate to AuthGate page
                                },
                                child: Text("Delete", style: TextStyle(
                                  color: Colors.red, // Customize text color
                                ),),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Delete Account",style: TextStyle(fontSize: 25,),//color: Theme.of(context).colorScheme.tertiary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
