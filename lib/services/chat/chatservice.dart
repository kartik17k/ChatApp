import 'dart:ui';
import 'package:chat/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/services/notification/notification_service.dart';
import 'dart:async';
import 'package:async/async.dart';
import 'package:rxdart/rxdart.dart';

class ChatService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  Stream<List<Map<String, dynamic>>> getUserStream() {
    return firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getUserStreamWithUnreadCount() {
    final currentUserID = auth.currentUser!.uid;
    
    return firestore.collection("Users").snapshots().flatMap((userSnapshot) {
      // Create a stream for each user that combines user data with their chat info
      final userStreams = userSnapshot.docs.where((doc) => doc.id != currentUserID).map((doc) {
        final user = {
          'email': doc.data()?['email'] ?? 'Unknown User',
          'uid': doc.id
        };
        
        // Create chat room ID
        List<String> ids = [currentUserID, doc.id];
        ids.sort();
        String chatRoomID = ids.join('_');
        
        // Create a stream that combines last message and unread count
        return firestore
            .collection("chat_rooms")
            .doc(chatRoomID)
            .collection("messages")
            .orderBy("timestamp", descending: true)
            .limit(1)
            .snapshots()
            .flatMap((messageSnapshot) {
              Map<String, dynamic>? lastMessage;
              
              if (messageSnapshot.docs.isNotEmpty) {
                final messageDoc = messageSnapshot.docs.first;
                lastMessage = {
                  'message': messageDoc.data()['message'],
                  'timestamp': messageDoc.data()['timestamp'],
                  'senderID': messageDoc.data()['senderID'],
                  'messageType': messageDoc.data()['messageType'],
                  'read': messageDoc.data()['read'],
                };
              }
              
              // Get unread count stream
              return firestore
                  .collection("chat_rooms")
                  .doc(chatRoomID)
                  .collection("messages")
                  .where("receiverID", isEqualTo: currentUserID)
                  .where("read", isEqualTo: false)
                  .snapshots()
                  .map((unreadSnapshot) {
                    return {
                      'user': user,
                      'unreadCount': unreadSnapshot.docs.length,
                      'lastMessage': lastMessage,
                      'chatRoomID': chatRoomID,
                    };
                  });
            });
      }).toList();
      
      // Combine all user streams into a single stream
      return Rx.combineLatest(userStreams, (List<Map<String, dynamic>> updates) => updates);
    });
  }

  Future<void> sendMessage(String receiverID, String message, {String messageType = 'text'}) async {
    final String currentUserID = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    DocumentSnapshot receiverDoc = await firestore.collection("Users").doc(receiverID).get();
    
    String? receiverToken;
    try {
      receiverToken = receiverDoc.get('fcmToken');
    } catch (e) {
      print('FCM token not found for user $receiverID: $e');
      receiverToken = null;
    }

    final messageData = {
      'senderID': currentUserID,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'messageType': messageType,
      'read': false,
    };

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    await firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(messageData);

    // Update last message in chat room
    await firestore.collection("chat_rooms").doc(chatRoomID).set({
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'lastMessageSender': currentUserID,
      'participants': [currentUserID, receiverID],
    }, SetOptions(merge: true));

    // Update unread count for other user
    final chatRoom = await firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .get();

    final members = (chatRoom.data()?['participants'] as List<dynamic>).cast<String>();
    final otherUserID = members.firstWhere((id) => id != currentUserID);

    await firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .set({
          'unreadCount.${otherUserID}': FieldValue.increment(1),
        }, SetOptions(merge: true));

    if (receiverToken != null) {
      await _notificationService.sendMessageNotification(
        receiverToken: receiverToken,
        senderName: currentUserEmail,
        message: message,
        chatId: chatRoomID,
        senderId: currentUserID,
        senderEmail: currentUserEmail,
      );
    }
  }

  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  String getChatRoomId(String userID1, String userID2) {
    List<String> ids = [userID1, userID2];
    ids.sort();
    return ids.join('_');
  }

  Stream<DocumentSnapshot> getChatRoomStream(String chatRoomID) {
    return firestore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .snapshots();
  }

  Stream<DocumentSnapshot> getChatRoom(String userID, String otherUserID) {
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .snapshots();
  }

  Future<void> deleteMessage(String messageID, String userID, String otherUserID) async {
    try {
      List<String> ids = [userID, otherUserID];
      ids.sort();
      String chatRoomID = ids.join('_');

      DocumentReference messageDoc = firestore
          .collection('chat_rooms')
          .doc(chatRoomID)
          .collection('messages')
          .doc(messageID);

      await messageDoc.delete();

      // Update last message if this was the last message
      QuerySnapshot lastMessage = await firestore
          .collection('chat_rooms')
          .doc(chatRoomID)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (lastMessage.docs.isNotEmpty) {
        await firestore.collection("chat_rooms").doc(chatRoomID).update({
          'lastMessage': lastMessage.docs.first.get('message'),
          'lastMessageTime': lastMessage.docs.first.get('timestamp'),
          'lastMessageSender': lastMessage.docs.first.get('senderID'),
        });
      } else {
        await firestore.collection("chat_rooms").doc(chatRoomID).update({
          'lastMessage': null,
          'lastMessageTime': null,
          'lastMessageSender': null,
        });
      }
    } catch (e) {
      print('Error deleting message: $e');
    }
  }

  Future<void> markMessagesAsRead(String otherUserId) async {
    final currentUserID = auth.currentUser!.uid;
    List<String> ids = [currentUserID, otherUserId];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Get all unread messages
    final unreadMessages = await firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .where("receiverID", isEqualTo: currentUserID)
        .where("read", isEqualTo: false)
        .get();

    // Create a batch to update all messages at once
    final batch = firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'read': true});
    }

    // Commit the batch
    await batch.commit();
  }

  Stream<int> getUnreadMessageCount(String currentUserID) {
    StreamController<int> unreadCountController = StreamController<int>.broadcast();
    List<StreamSubscription> subscriptions = [];

    void calculateTotalUnreadCount() {
      firestore
          .collection("chat_rooms")
          .where('participants', arrayContains: currentUserID)
          .snapshots()
          .listen((snapshot) {
        int totalUnreadCount = 0;
        int remainingStreams = snapshot.docs.length;

        if (remainingStreams == 0) {
          unreadCountController.add(0);
          return;
        }

        for (var chatRoomDoc in snapshot.docs) {
          var subscription = firestore
              .collection("chat_rooms")
              .doc(chatRoomDoc.id)
              .collection("messages")
              .where('receiverID', isEqualTo: currentUserID)
              .where('read', isEqualTo: false)
              .snapshots()
              .listen((unreadSnapshot) {
                totalUnreadCount += unreadSnapshot.size;
                remainingStreams--;

                if (remainingStreams == 0) {
                  unreadCountController.add(totalUnreadCount);
                }
              });

          subscriptions.add(subscription);
        }
      });
    }

    calculateTotalUnreadCount();

    unreadCountController.onCancel = () {
      for (var subscription in subscriptions) {
        subscription.cancel();
      }
    };

    return unreadCountController.stream;
  }

  Future<void> clearChat(String userID, String otherUserID) async {
    try {
      List<String> ids = [userID, otherUserID];
      ids.sort();
      String chatRoomID = ids.join('_');

      QuerySnapshot messages = await firestore
          .collection('chat_rooms')
          .doc(chatRoomID)
          .collection('messages')
          .get();

      WriteBatch batch = firestore.batch();
      for (var doc in messages.docs) {
        batch.delete(doc.reference);
      }

      batch.update(firestore.collection('chat_rooms').doc(chatRoomID), {
        'lastMessage': null,
        'lastMessageTime': null,
        'lastMessageSender': null,
        'unreadCount.${userID}': 0,
        'unreadCount.${otherUserID}': 0,
      });

      await batch.commit();
    } catch (e) {
      print('Error clearing chat: $e');
    }
  }

  Future<void> deleteUserAccount() async {
    final currentUser = auth.currentUser;

    if (currentUser != null) {
      // Delete all chat rooms where user is a participant
      QuerySnapshot chatRooms = await firestore
          .collection('chat_rooms')
          .where('participants', arrayContains: currentUser.uid)
          .get();

      WriteBatch batch = firestore.batch();
      
      for (var chatRoom in chatRooms.docs) {
        // Delete all messages in the chat room
        QuerySnapshot messages = await chatRoom.reference
            .collection('messages')
            .get();
        
        for (var message in messages.docs) {
          batch.delete(message.reference);
        }
        
        // Delete the chat room itself
        batch.delete(chatRoom.reference);
      }

      // Delete user document
      batch.delete(firestore.collection('Users').doc(currentUser.uid));
      
      await batch.commit();
      await currentUser.delete();
    }
  }
}
