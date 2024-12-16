import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String chatId = 'seller_chat'; // Идентификатор чата с продавцом

  Future<void> sendMessage(String text) async {
    try {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'text': text,
        'senderId': _auth.currentUser?.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Ошибка при отправке сообщения: $e');
    }
  }

  Stream<QuerySnapshot> getMessages() {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}