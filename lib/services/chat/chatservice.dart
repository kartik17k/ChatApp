import 'package:chat/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat/services/notification/notification_service.dart';

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

  Future<void> deleteUserAccount() async {
    final currentUser = auth.currentUser;

    if (currentUser != null) {
      await firestore.collection('Users').doc(currentUser.uid).delete();
      await currentUser.delete();
    }
  }
}
