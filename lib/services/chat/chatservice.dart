import 'package:chat/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/services/notification/notification_service.dart';
import 'dart:async';

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
    return firestore.collection("Users").snapshots().map((snapshot) {
      final currentUserID = auth.currentUser!.uid;
      List<Map<String, dynamic>> usersWithUnreadCount = [];

      for (var doc in snapshot.docs) {
        final user = doc.data();
        List<String> ids = [currentUserID, doc.id];
        ids.sort();
        String chatRoomID = ids.join('_');

        // Create a stream for unread messages in this specific chat
        Stream<int> unreadCountStream = firestore
            .collection("chat_rooms")
            .doc(chatRoomID)
            .collection("messages")
            .where('receiverID', isEqualTo: currentUserID)
            .where('read', isEqualTo: false)
            .snapshots()
            .map((unreadSnapshot) => unreadSnapshot.size);

        // Attach the unread count stream to the user data
        user['unreadCountStream'] = unreadCountStream;
        usersWithUnreadCount.add(user);
      }

      return usersWithUnreadCount;
    });
  }

  Future<void> sendMessage(String receiverID, String message, {String messageType = 'text'}) async {
    final String currentUserID = auth.currentUser!.uid;
    final String currentUserEmail = auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // Fetch receiver's token for notification
    DocumentSnapshot receiverDoc = await firestore.collection("Users").doc(receiverID).get();
    
    // Safely get FCM token, defaulting to null if not present
    String? receiverToken;
    try {
      receiverToken = receiverDoc.get('fcmToken');
    } catch (e) {
      print('FCM token not found for user $receiverID: $e');
      receiverToken = null;
    }

    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp,
      messageType: messageType,
      read: false,
    );

    List<String> ids = [currentUserID, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Send message to Firestore
    await firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .add(newMessage.toMap());

    // Send push notification if receiver token exists
    if (receiverToken != null) {
      await _notificationService.sendMessageNotification(
        receiverToken: receiverToken,
        senderName: currentUserEmail, // You might want to use a more user-friendly name
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
    } catch (e) {
      print(e);
    }
  }

  Future<void> markMessagesAsRead(String chatRoomID, String currentUserID) async {
    try {
      // Get all unread messages in this chat room for the current user
      QuerySnapshot unreadMessages = await firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .where('receiverID', isEqualTo: currentUserID)
          .where('read', isEqualTo: false)
          .get();

      // Batch update to mark all messages as read
      WriteBatch batch = firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'read': true});
      }

      await batch.commit();
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  Stream<int> getUnreadMessageCount(String currentUserID) {
    // Create a broadcast stream controller to manage the unread count
    StreamController<int> unreadCountController = StreamController<int>.broadcast();

    // Track and cancel stream subscriptions
    List<StreamSubscription> subscriptions = [];

    // Function to calculate total unread count
    void calculateTotalUnreadCount() {
      firestore
          .collection("chat_rooms")
          .snapshots()
          .listen((snapshot) {
        int totalUnreadCount = 0;
        
        // Track remaining streams to complete calculation
        int remainingStreams = snapshot.docs.length;

        for (var chatRoomDoc in snapshot.docs) {
          firestore
              .collection("chat_rooms")
              .doc(chatRoomDoc.id)
              .collection("messages")
              .where('receiverID', isEqualTo: currentUserID)
              .where('read', isEqualTo: false)
              .snapshots()
              .listen((unreadSnapshot) {
                totalUnreadCount += unreadSnapshot.size;
                remainingStreams--;

                // Add total count to stream when all streams are processed
                if (remainingStreams == 0) {
                  unreadCountController.add(totalUnreadCount);
                }
              });
        }
      });
    }

    // Start calculating unread count
    calculateTotalUnreadCount();

    return unreadCountController.stream;
  }

  Future<void> deleteUserAccount() async {
    final currentUser = auth.currentUser;

    if (currentUser != null) {
      await firestore.collection('Users').doc(currentUser.uid).delete();
      await currentUser.delete();
    }
  }
}
