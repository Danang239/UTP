// lib/modules/chatbot/chatbot_view.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chatbot_controller.dart';

class ChatbotView extends GetView<ChatbotController> {
  const ChatbotView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      // ================= APP BAR =================
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        title: const Text('Chatbot'),
      ),

      body: Column(
        children: [
          // ================= CHAT AREA =================
          Expanded(
            child: Container(
              color: colors.surfaceVariant,
              child: Obx(
                () => ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];

                    final bool fromBot = msg.fromBot;
                    final Alignment align =
                        fromBot ? Alignment.centerLeft : Alignment.centerRight;

                    final Color bubbleBg = fromBot
                        ? colors.surface
                        : colors.primary;

                    final Color textColor = fromBot
                        ? colors.onSurface
                        : colors.onPrimary;

                    return Align(
                      alignment: align,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: bubbleBg,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow.withOpacity(0.15),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          Divider(height: 1, color: colors.outlineVariant),

          // ================= QUICK QUESTIONS =================
          Container(
            color: colors.surface,
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pertanyaan yang bisa dipilih:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),

                StreamBuilder<QuerySnapshot>(
                  stream: controller.chatQuery.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: colors.error),
                      );
                    }

                    if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const SizedBox(
                        height: 36,
                        child: Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    }

                    final docs = snapshot.data?.docs ?? [];

                    if (docs.isEmpty) {
                      return Text(
                        'Belum ada daftar pertanyaan.\n'
                        'Isi koleksi "chatbot" di Firestore.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.6),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: docs.map((doc) {
                          final data =
                              doc.data() as Map<String, dynamic>;
                          final question =
                              (data['question'] ?? '').toString().trim();
                          final answer =
                              (data['answer'] ?? '').toString().trim();

                          if (question.isEmpty || answer.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: colors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              onPressed: () => controller.sendQuestion(
                                question,
                                answer,
                              ),
                              child: Text(
                                question,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.primary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
