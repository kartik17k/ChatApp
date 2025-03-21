import 'dart:async';

import 'package:chat/components/chatBubble.dart';
import 'package:chat/services/auth/authService.dart';
import 'package:chat/services/chat/chatservice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import '../services/auth/authgate.dart';

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
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final FocusNode _focusNode = FocusNode();
  late AnimationController _fabAnimationController;
  bool _showScrollButton = false;
  bool _isComposing = false;
  bool _isTyping = false;
  String? _chatRoomID;
  StreamSubscription? _typingSubscription;

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

    _chatRoomID = chatService.getChatRoomId(
      authService.getCurrentUser()!.uid,
      widget.reciverID,
    );

    _typingSubscription = chatService.getTypingStatusStream(_chatRoomID!).listen(
      (snapshot) {
        if (!snapshot.exists) {
          return;
        }

        final data = snapshot.data() as Map<String, dynamic>;
        final currentUserID = authService.getCurrentUser()!.uid;
        final participants = data['participants'] as List<dynamic>? ?? [];
        final otherUserID = participants.firstWhere(
          (id) => id != currentUserID,
          orElse: () => widget.reciverID,
        );
        
        setState(() {
          _isTyping = data['typing']?[otherUserID.toString()] ?? false;
        });
      },
    );

    _messageController.addListener(() {
      final text = _messageController.text;
      setState(() {
        _isComposing = text.isNotEmpty;
      });

      if (text.isNotEmpty && !_isTyping) {
        chatService.setTypingStatus(_chatRoomID!, authService.getCurrentUser()!.uid, true);
        setState(() => _isTyping = true);
      } else if (text.isEmpty && _isTyping) {
        chatService.setTypingStatus(_chatRoomID!, authService.getCurrentUser()!.uid, false);
        setState(() => _isTyping = false);
      }
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    });
    
    Future.delayed(const Duration(milliseconds: 300), () => scrollDown());
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    _focusNode.dispose();
    _typingSubscription?.cancel();
    if (_isTyping) {
      chatService.setTypingStatus(_chatRoomID!, authService.getCurrentUser()!.uid, false);
    }
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    setState(() {
      _isComposing = false;
    });

    chatService.setTypingStatus(_chatRoomID!, authService.getCurrentUser()!.uid, false);
    setState(() => _isTyping = false);

    chatService.sendMessage(
      widget.reciverID,
      _messageController.text,
    );

    _messageController.clear();
    _focusNode.requestFocus();
  }

  void deleteMessage(String messageID) async {
    await chatService.deleteMessage(
      messageID, widget.reciverID, authService.getCurrentUser()!.uid
    );
  }

  void _showOptionsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
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
                color: dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.block_outlined, color: errorColor),
              title: Text(
                'Block User',
                style: TextStyle(color: textColor),
              ),
              onTap: () {
                // Implement block functionality
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_outline_rounded, color: errorColor),
              title: Text(
                'Clear Chat',
                style: TextStyle(color: textColor),
              ),
              onTap: () async {
                Navigator.pop(context);
                bool? confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: surfaceColor,
                    title: Text(
                      'Clear Chat',
                      style: TextStyle(color: textColor),
                    ),
                    content: Text(
                      'Are you sure you want to clear all messages? This cannot be undone.',
                      style: TextStyle(color: subtleTextColor),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: subtleTextColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          'Clear',
                          style: TextStyle(color: errorColor),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await chatService.clearChat(
                    authService.getCurrentUser()!.uid,
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20),
          onPressed: _handleBack,
        ),
        titleSpacing: 0,
        title: StreamBuilder<DocumentSnapshot>(
          stream: chatService.getChatRoom(
            authService.getCurrentUser()!.uid,
            widget.reciverID,
          ),
          builder: (context, snapshot) {
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text('Loading...');
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            
            // Get participants safely
            final participants = data['participants'] as List<dynamic>? ?? [];
            final currentUserID = authService.getCurrentUser()!.uid;
            final otherUserID = participants.firstWhere(
              (id) => id != currentUserID,
              orElse: () => widget.reciverID,
            );
            
            // Get typing status safely
            bool isOtherUserTyping = false;
            if (data['typing'] is Map) {
              final typingMap = data['typing'] as Map<String, dynamic>;
              isOtherUserTyping = typingMap[otherUserID.toString()] ?? false;
            }

            return Row(
              children: [
                Hero(
                  tag: 'avatar_${widget.reciverID}_${authService.getCurrentUser()!.uid}',
                  child: CircleAvatar(
                    backgroundColor: primaryColor,
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isOtherUserTyping)
                        Text(
                          'typing...',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
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
            color: dividerColor,
          ),
          Expanded(child: buildMessageList()),
          Container(
            decoration: BoxDecoration(
              color: surfaceColor,
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
    String senderID = authService.getCurrentUser()!.uid;
    return StreamBuilder(
      stream: chatService.getMessages(widget.reciverID, senderID),
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
                  "Couldn't load messages",
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
                  child: Text(
                    "Try Again",
                    style: TextStyle(
                      color: primaryColor,
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
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
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
                  color: subtleTextColor,
                ),
                const SizedBox(height: 12),
                Text(
                  "No messages yet",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Send a message to start chatting",
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
    bool isCurrentUser = data['senderID'] == authService.getCurrentUser()!.uid;
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
          color: errorColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline, color: errorColor),
      ),
      confirmDismiss: (direction) async {
        if (isCurrentUser) {
          return await showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              backgroundColor: surfaceColor,
              title: Text(
                'Delete Message?',
                style: TextStyle(color: textColor),
              ),
              content: Text(
                'This action cannot be undone.',
                style: TextStyle(color: subtleTextColor),
              ),
              actions: [
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: subtleTextColor),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                ),
                TextButton(
                  child: Text(
                    'Delete',
                    style: TextStyle(color: errorColor),
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
                color: backgroundColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  SizedBox(width: 20.0,),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: subtleTextColor),
                      controller: _messageController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(color: subtleTextColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 12,
                        ),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color:  backgroundColor,
              shape: BoxShape.circle
            ),
            child: GestureDetector(
              onTap: _sendMessage,
              child: Icon(
                   Icons.send,
                  color: primaryColor,
                  size: 35.0,
                ),
            ),
            ),
        ],
      ),
    );
  }
}
