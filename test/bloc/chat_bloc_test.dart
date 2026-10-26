import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:team_task/core/errors/result.dart';
import 'package:team_task/features/chat/domain/entities/chat_message.dart';
import 'package:team_task/features/chat/domain/repositories/chat_repository.dart';
import 'package:team_task/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:team_task/features/chat/presentation/bloc/chat_event.dart';
import 'package:team_task/features/chat/presentation/bloc/chat_state.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository mockChatRepository;
  late ChatBloc chatBloc;

  final testMessage = ChatMessage(
    id: 'm1',
    projectId: 'p1',
    senderId: 'u1',
    senderName: 'Esra',
    text: 'Test mesajı',
    createdAt: DateTime.utc(2026, 10, 1),
  );

  setUp(() {
    mockChatRepository = MockChatRepository();
    chatBloc = ChatBloc(chatRepository: mockChatRepository);
  });

  tearDown(() {
    chatBloc.close();
  });

  group('ChatBloc Test', () {
    test('initial state is ChatInitial', () {
      expect(chatBloc.state, const ChatInitial());
    });

    blocTest<ChatBloc, ChatState>(
      'emits [ChatLoading, ChatLoaded] when messages are loaded successfully',
      build: () {
        when(
          () => mockChatRepository.getMessages('p1'),
        ).thenAnswer((_) async => Result.success([testMessage]));
        return chatBloc;
      },
      act: (bloc) => bloc.add(const ChatMessagesLoadRequested('p1')),
      expect: () => [
        const ChatLoading(),
        ChatLoaded(messages: [testMessage]),
      ],
    );

    blocTest<ChatBloc, ChatState>(
      'appends message to list on ChatMessageSent success',
      build: () {
        when(
          () => mockChatRepository.sendMessage(
            projectId: 'p1',
            senderId: 'u1',
            senderName: 'Esra',
            text: 'Yeni mesaj',
          ),
        ).thenAnswer(
          (_) async => Result.success(
            ChatMessage(
              id: 'm2',
              projectId: 'p1',
              senderId: 'u1',
              senderName: 'Esra',
              text: 'Yeni mesaj',
              createdAt: DateTime.utc(2026, 10, 2),
            ),
          ),
        );
        return chatBloc;
      },
      seed: () => ChatLoaded(messages: [testMessage]),
      act: (bloc) => bloc.add(
        const ChatMessageSent(
          projectId: 'p1',
          senderId: 'u1',
          senderName: 'Esra',
          text: 'Yeni mesaj',
        ),
      ),
      expect: () => [
        ChatLoaded(
          messages: [
            testMessage,
            ChatMessage(
              id: 'm2',
              projectId: 'p1',
              senderId: 'u1',
              senderName: 'Esra',
              text: 'Yeni mesaj',
              createdAt: DateTime.utc(2026, 10, 2),
            ),
          ],
        ),
      ],
    );
  });
}
