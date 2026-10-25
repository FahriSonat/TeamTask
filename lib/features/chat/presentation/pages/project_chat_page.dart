import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_context_extension.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../projects/presentation/bloc/project_bloc.dart';
import '../../../projects/presentation/bloc/project_state.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ProjectChatPage extends StatefulWidget {
  final String projectId;
  const ProjectChatPage({super.key, required this.projectId});

  @override
  State<ProjectChatPage> createState() => _ProjectChatPageState();
}

class _ProjectChatPageState extends State<ProjectChatPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(ChatMessagesLoadRequested(widget.projectId));
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) return;

    context.read<ChatBloc>().add(
      ChatMessageSent(
        projectId: widget.projectId,
        senderId: authState.user.id,
        senderName: authState.user.name,
        text: text,
      ),
    );

    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final currentUserId = authState is Authenticated ? authState.user.id : '';
    final projectState = context.watch<ProjectBloc>().state;
    final projectName = projectState is ProjectsLoaded
        ? (projectState.projects
                  .where((p) => p.id == widget.projectId)
                  .firstOrNull
                  ?.name ??
              'Proje Sohbeti')
        : 'Proje Sohbeti';

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(projectName, style: AppTextStyles.appBarTitle),
            Text(
              'Ekip Mesajlaşması',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  if (state is ChatLoading || state is ChatInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ChatError) {
                    return ErrorView(
                      message: state.message,
                      onRetry: () => context.read<ChatBloc>().add(
                        ChatMessagesLoadRequested(widget.projectId),
                      ),
                    );
                  }

                  if (state is ChatLoaded) {
                    if (state.messages.isEmpty) {
                      return const EmptyView(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'Henüz mesaj yok',
                        description: 'Ekip üyelerinle konuşmaya başlamak için ilk mesajı yaz.',
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(
                        AppSpacing.pagePaddingMobile,
                      ),
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final msg = state.messages[index];
                        final isMe = msg.senderId == currentUserId;
                        final timeStr = DateFormat('HH:mm')
                            .format(msg.createdAt.toLocal());

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            mainAxisAlignment: isMe
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (!isMe) ...[
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primaryTint,
                                  child: Text(
                                    msg.senderName.isNotEmpty
                                        ? msg.senderName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                              ],
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.sm,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColors.darkSurface
                                              : AppColors.surface),
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(
                                        AppSpacing.radiusColumn,
                                      ),
                                      topRight: const Radius.circular(
                                        AppSpacing.radiusColumn,
                                      ),
                                      bottomLeft: isMe
                                          ? const Radius.circular(
                                              AppSpacing.radiusColumn,
                                            )
                                          : Radius.zero,
                                      bottomRight: isMe
                                          ? Radius.zero
                                          : const Radius.circular(
                                              AppSpacing.radiusColumn,
                                            ),
                                    ),
                                    border: isMe
                                        ? null
                                        : Border.all(
                                            color: isDark
                                                ? AppColors.darkBorder
                                                : AppColors.divider,
                                          ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.04,
                                        ),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: isMe
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                    children: [
                                      if (!isMe)
                                        Text(
                                          msg.senderName,
                                          style: AppTextStyles.caption.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: context.primaryTextColor,
                                          ),
                                        ),
                                      const SizedBox(height: 2),
                                      Text(
                                        msg.text,
                                        style: AppTextStyles.body.copyWith(
                                          color: isMe
                                              ? Colors.white
                                              : context.inkColor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        timeStr,
                                        style: AppTextStyles.caption.copyWith(
                                          fontSize: 10,
                                          color: isMe
                                              ? Colors.white.withValues(
                                                  alpha: 0.7,
                                                )
                                              : context.inkMutedColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            // Mesaj Yazma Alanı
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.surface,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.divider,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Mesajınızı yazın...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.darkFieldBg
                            : AppColors.fieldBg,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.sm,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  IconButton.filled(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
