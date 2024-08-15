import 'package:chat/components/chatBubble.dart';
import 'package:chat/components/textfield.dart';
import 'package:chat/services/auth/authService.dart';
import 'package:chat/services/chat/chatservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Chat extends StatefulWidget {
  final String reciverEmail;
  final String reciverID;

  Chat({super.key,required this.reciverEmail,required this.reciverID});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController messageController =TextEditingController();

  //chat and auth services
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();


  //for textfield focus
  FocusNode myFocusNode = FocusNode();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    //add listner to focus node
    myFocusNode.addListener((){
      if(myFocusNode.hasFocus){
        //cause a delay to appear keyboard
        //calculate remaining space
        //then scroll down
        Future.delayed(
          const Duration(milliseconds: 500),
              ()=> scrollDown(),
        );
      }
    });

    //wait for listview to build then scroll down
    Future.delayed(const Duration(milliseconds: 500), ()=> scrollDown());
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  //scroll controller
  final ScrollController scrollController = ScrollController();

  void scrollDown(){
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async{
    //send message only if there is text no empty message
    if(messageController.text.isNotEmpty){
      await chatService.sendMessage(widget.reciverID, messageController.text);

      //clear contoller
      messageController.clear();
    }
    scrollDown();
  }

  void deleteMessage(String messageID) async{
    await chatService.deleteMessage(messageID, widget.reciverID, authService.getCurrentUser()!.uid);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reciverEmail),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          //display all message
          Expanded(
            child: buildMessageList(),
          ),

          //user input
          buildUserInput(),
        ],
      ),
    );
  }

  //message list
  Widget buildMessageList(){
    String senderID = authService.getCurrentUser()!.uid;
    return StreamBuilder(
        stream: chatService.getMessages(widget.reciverID, senderID),
        builder: (context,snapshot){
          //error
          if(snapshot.hasError){
            return const Text("error");
          }

          //loading
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          //return list view
          return ListView(
            controller: scrollController,
            children: snapshot.data!.docs.map((doc) => buildMessageItem(doc)).toList(),
          );
        }
    );
  }

  Widget buildMessageItem(DocumentSnapshot doc){
    Map<String,dynamic> data = doc.data() as Map<String,dynamic>;

    //current user
    bool isCurrentUser = data['senderID'] == authService.getCurrentUser()!.uid;

    //align left and right to 1user and 2user
    var alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;


    return GestureDetector(
      onLongPress: isCurrentUser? () => showDialog(
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
                      icon: Icon(Icons.delete),
                      label: Text('Delete'),
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
      ) :null,
      child: Container(
          alignment: alignment,
          child: Column(
            crossAxisAlignment: isCurrentUser? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ChatBubble(message: data["message"], isCurrentUser: isCurrentUser)
            ],
          )
      ),
    );
  }

  Widget buildUserInput(){
    return Padding(
      padding: const EdgeInsets.only(bottom :50.0),
      child: Row(
        children: [
          Expanded(child: MyTextField(
            hinttext: "Type a message",
            obscuretext: false,
            controller: messageController,
            focusNode: myFocusNode,
          ),
          ),
          Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              margin: EdgeInsets.only(right: 25),
              child: IconButton(onPressed: sendMessage, icon: Icon(Icons.arrow_upward,color: Colors.white,))
          ),
        ],
      ),
    );
  }
}