import 'dart:async';

import 'package:chat/components/chatBubble.dart';
import 'package:chat/services/auth/authService.dart';
import 'package:chat/services/chat/chatservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/auth/authgate.dart';
import '../theme/theme.dart';

class Chat extends StatefulWidget {
  final String reciverEmail;
  final String reciverID;
  final bool allowBack;

  const Chat({
    super.key, 
    required this.reciverEmail, 
    required this.reciverID,
    this.allowBack = false
  });

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _fabAnimationController;
  bool _showScrollButton = false;
  String? _chatRoomID;

  void _scrollListener() {
    if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 300) {
      if (!_showScrollButton) {
        setState(() => _showScrollButton = true);
        _fabAnimationController.forward();
      }
    } else if (_showScrollButton) {
      setState(() => _showScrollButton = false);
      _fabAnimationController.reverse();
    }
  }

  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scrollController.addListener(_scrollListener);

    _chatRoomID = _chatService.getChatRoomId(
      _authService.getCurrentUser()!.uid,
      widget.reciverID,
    );

    Future.delayed(const Duration(milliseconds: 300), () => scrollDown());
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void scrollDown() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuad,
      );
    }
  }

  void _handleBack() {
    if (widget.allowBack) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthGate()), 
        (route) => false
      );
    }
  }

  void _sendMessage(String message) {
    if (message.trim().isEmpty) return;

    _chatService.sendMessage(
      widget.reciverID,
      message,
    );

    _messageController.clear();
    _focusNode.requestFocus();
  }

  void deleteMessage(String messageID) async {
    await _chatService.deleteMessage(
      messageID, widget.reciverID, _authService.getCurrentUser()!.uid
    );
  }

  void _showOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardTheme.color,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.block_outlined, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Block User',
                style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
              ),
              onTap: () {
                // Implement block functionality
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Clear Chat',
                style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
              ),
              onTap: () async {
                Navigator.pop(context);
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Theme.of(context).cardTheme.color,
                    title: Text(
                      'Clear Chat',
                      style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
                    ),
                    content: Text(
                      'Are you sure you want to clear all messages? This cannot be undone.',
                      style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Clear',
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await _chatService.clearChat(
                    _authService.getCurrentUser()!.uid,
                    widget.reciverID,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).cardTheme.color,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Theme.of(context).appBarTheme.iconTheme?.color, size: 20),
          onPressed: _handleBack,
        ),
        titleSpacing: 0,
        title: StreamBuilder<DocumentSnapshot>(
          stream: _chatService.getChatRoom(
            _authService.getCurrentUser()!.uid,
            widget.reciverID,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('Loading...');
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            
            // Get participants safely
            final participants = data['participants'] as List<dynamic>? ?? [];
            final currentUserID = _authService.getCurrentUser()!.uid;
            final otherUserID = participants.firstWhere(
              (id) => id != currentUserID,
              orElse: () => widget.reciverID,
            );
            
            return Row(
              children: [
                Hero(
                  tag: 'avatar_${widget.reciverID}_${_authService.getCurrentUser()!.uid}',
                  child: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      widget.reciverEmail.split('@')[0].split('').first,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 25
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.reciverEmail.split('@')[0],
                        style: TextStyle(
                          color: Theme.of(context).textTheme.titleMedium?.color,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          Expanded(child: buildMessageList()),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, -1),
                  blurRadius: 5,
                ),
              ],
            ),
            child: SafeArea(
              child: buildUserInput(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMessageList() {
    String senderID = _authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: _chatService.getMessages(widget.reciverID, senderID),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 12),
                Text(
                  "Couldn't load messages",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {});
                  },
                  child: Text(
                    "Try Again",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              strokeWidth: 3,
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 48,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(height: 12),
                Text(
                  "No messages yet",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Send a message to start chatting",
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return buildMessageItem(snapshot.data!.docs[index]);
          },
        );
      },
    );
  }

  Widget buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;
    String time = DateFormat('HH:mm').format(
      (data['timestamp'] as Timestamp).toDate(),
    );

    return Dismissible(
      key: Key(doc.id),
      direction: isCurrentUser ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
      ),
      confirmDismiss: (direction) async {
        if (isCurrentUser) {
          return await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              backgroundColor: Theme.of(context).cardTheme.color,
              title: Text(
                'Delete Message?',
                style: TextStyle(color: Theme.of(context).textTheme.titleMedium?.color),
              ),
              content: Text(
                'This action cannot be undone.',
                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(
                    'Delete',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            ),
          );
        }
        return false;
      },
      onDismissed: (direction) {
        if (isCurrentUser) {
          deleteMessage(doc.id);
        }
      },
      child: ChatBubble(
        message: data['message'],
        isCurrentUser: isCurrentUser,
        time: time,
        isRead: data['read'] ?? false,
        isDelivered: data['delivered'] ?? false,
      ),
    );
  }

  Widget buildUserInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20.0,),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.titleMedium?.color,
                        fontSize: 16,
                      ),
                      maxLines: null,
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _sendMessage(value);
                          _messageController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color:  Theme.of(context).scaffoldBackgroundColor,
              shape: BoxShape.circle
            ),
            child: GestureDetector(
              onTap: () {
                if (_messageController.text.trim().isNotEmpty) {
                  _sendMessage(_messageController.text);
                  _messageController.clear();
                }
              },
              child: Icon(
                   Icons.send,
                  color: Theme.of(context).primaryColor,
                  size: 35.0,
                ),
            ),
            ),
        ],
      ),
    );
  }
}
