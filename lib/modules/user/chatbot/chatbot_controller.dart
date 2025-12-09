// lib/modules/chatbot/chatbot_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import 'chat_message_model.dart';

class ChatbotController extends GetxController {
  // daftar pesan untuk ditampilkan di area chat
  final messages = <ChatMessage>[].obs;

  // query ke Firestore untuk daftar pertanyaan
  late final Query chatQuery;

  @override
  void onInit() {
    super.onInit();

    // pesan awal dari bot
    messages.add(
      const ChatMessage(
        fromBot: true,
        text:
            'Halo! Aku Chatbot Villa.\nSilakan pilih salah satu pertanyaan di bawah, nanti aku jawab 😊',
      ),
    );

    // inisialisasi query koleksi "chatbot"
    chatQuery = FirebaseFirestore.instance
        .collection('chatbot')
        .orderBy('order', descending: false);
  }

  void sendQuestion(String question, String answer) {
    messages.add(ChatMessage(fromBot: false, text: question));
    messages.add(ChatMessage(fromBot: true, text: answer));
  }
}
