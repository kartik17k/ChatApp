import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String messageType;
  final bool read;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.message,
    required this.timestamp,
    this.messageType = 'text',
    this.read = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': senderEmail,
      'receiverID': receiverID,
      'message': message,
      'timestamp': timestamp,
      'messageType': messageType,
      'read': read,
    };
  }

  static Message fromMap(Map<String, dynamic> map) {
    return Message(
      senderID: map['senderID'],
      senderEmail: map['senderEmail'],
      receiverID: map['receiverID'],
      message: map['message'],
      timestamp: map['timestamp'],
      messageType: map['messageType'] ?? 'text',
      read: map['read'] ?? false,
    );
  }
}
