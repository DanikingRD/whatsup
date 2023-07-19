import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:whatsup/common/enum/message.dart';
import 'package:whatsup/common/providers.dart';
import 'package:whatsup/common/repositories/user.dart';
import 'package:whatsup/common/util/ext.dart';
import 'package:whatsup/features/chat/repository/chat_repository.dart';

final chatControllerProvider = Provider((ref) {
  return ChatController(
    chatRepository: ref.read(chatRepositoryProvider),
    ref: ref,
  );
});

final chatsStreamProvider = StreamProvider((ref) {
  return ref.watch(chatRepositoryProvider).chats;
});

final messagesStreamProvider = StreamProvider.family((ref, String chatId) {
  return ref.watch(chatRepositoryProvider).getChatMessages(chatId);
});

class ChatController {
  final ChatRepository chatRepository;
  final Ref ref;

  ChatController({
    required this.chatRepository,
    required this.ref,
  });

  void markMessageAsSeen({
    required String receiverId,
    required String messageId,
  }) {
    chatRepository.markMessageAsSeen(
      receiverId: receiverId,
      messageId: messageId,
    );
  }

  void sendText({
    required BuildContext context,
    required String text,
    required String receiverId,
  }) {
    ref.read(userFetchProvider).whenData((value) {
      if (value.isSome()) {
        chatRepository.sendTextMessage(
          sender: value.unwrap(),
          receiverId: receiverId,
          message: text,
          reply: ref.read(messageReplyProvider),
        );
        ref.read(messageReplyProvider.notifier).update((state) => const None());
      }
    });
  }

  void sendFile({
    required BuildContext context,
    required String receiverId,
    required File file,
    required ChatMessageType type,
  }) {
    ref.read(userFetchProvider).whenData((value) {
      if (value.isSome()) {
        chatRepository.sendFileMessage(
          file: file,
          receiverId: receiverId,
          sender: value.unwrap(),
          ref: ref,
          type: type,
          reply: ref.read(messageReplyProvider),
        );
        ref.read(messageReplyProvider.notifier).update((state) => const None());
      }
    });
  }
}