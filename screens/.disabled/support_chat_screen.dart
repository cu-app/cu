import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

// Material Icons import for icon constants only
import 'package:flutter/material.dart' show Icons;

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _supabase = Supabase.instance.client;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  RealtimeChannel? _messageSubscription;
  bool _isLoading = true;
  bool _isSending = false;
  final bool _isConnected = false;
  String? _userId;
  String? _chatRoomId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageSubscription?.unsubscribe();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    try {
      // Get current user
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('No user authenticated');
        if (mounted) {
          setState(() => _isLoading = false);
        }
        return;
      }

      _userId = user.id;

      // Get or create chat room for this user
      final existingRoom = await _supabase
          .from('support_chat_rooms')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (existingRoom != null) {
        _chatRoomId = existingRoom['id'];
      } else {
        // Create new chat room
        final newRoom = await _supabase
            .from('support_chat_rooms')
            .insert({
              'user_id': user.id,
              'status': 'active',
              'created_at': DateTime.now().toIso8601String(),
            })
            .select()
            .single();

        _chatRoomId = newRoom['id'];
      }

      // Load existing messages
      await _loadMessages();

      // Subscribe to new messages
      _subscribeToMessages();

      if (mounted) {
        setState(() => _isLoading = false);
      }

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      debugPrint('Error initializing chat: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMessages() async {
    if (_chatRoomId == null) return;

    try {
      final messages = await _supabase
          .from('support_messages')
          .select()
          .eq('chat_room_id', _chatRoomId!)
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(List<Map<String, dynamic>>.from(messages));
        });
      }
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  void _subscribeToMessages() {
    if (_chatRoomId == null) return;

    _messageSubscription = _supabase
        .channel('support_messages:$_chatRoomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'support_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'chat_room_id',
            value: _chatRoomId,
          ),
          callback: (payload) {
            final newMessage = payload.newRecord;
            if (mounted) {
              setState(() {
                _messages.add(newMessage);
              });
              _scrollToBottom();
            }
          },
        )
        .subscribe();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _chatRoomId == null || _userId == null) return;

    setState(() => _isSending = true);

    try {
      await _supabase.from('support_messages').insert({
        'chat_room_id': _chatRoomId,
        'user_id': _userId,
        'message': text,
        'is_support': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      debugPrint('Error sending message: $e');
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: CUAnimation.normal),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return Container(
      color: theme.colorScheme.background,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(CUSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.onBackground.withOpacity(0.04),
                    blurRadius: CUElevation.low.toDouble(),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Row(
                      children: [
                        CUIcon(
                          Icons.arrow_back,
                          color: theme.colorScheme.primary,
                          size: CUSize.iconMedium,
                        ),
                        SizedBox(width: CUSpacing.sm),
                        Text(
                          'Back',
                          style: CUTypography.titleMedium.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: CUSpacing.lg),
                  Text(
                    'Support Chat',
                    style: CUTypography.headlineLarge.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: CUSpacing.xs),
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: CUAnimation.normal),
                        width: CUSpacing.sm,
                        height: CUSpacing.sm,
                        decoration: BoxDecoration(
                          color: _isConnected
                              ? theme.colorScheme.success
                              : theme.colorScheme.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: CUSpacing.sm),
                      Text(
                        _isConnected ? 'Connected' : 'Connecting...',
                        style: CUTypography.bodyMedium.copyWith(
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Messages
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CULoadingSpinner(
                        size: CUSize.iconLarge,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CUIcon(
                                Icons.chat_bubble_outline,
                                size: CUSize.iconExtraLarge,
                                color: theme.colorScheme.border,
                              ),
                              SizedBox(height: CUSpacing.md),
                              Text(
                                'Start a conversation',
                                style: CUTypography.titleLarge.copyWith(
                                  color: theme.colorScheme.onBackground,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: CUSpacing.sm),
                              Text(
                                'Our support team is here to help',
                                style: CUTypography.bodyMedium.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(CUSpacing.lg),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            final isSupport = message['is_support'] == true;
                            final timestamp = DateTime.parse(
                              message['created_at'] ?? DateTime.now().toIso8601String(),
                            );

                            return _buildMessageBubble(
                              message['message'] ?? '',
                              isSupport,
                              timestamp,
                              theme,
                            );
                          },
                        ),
            ),

            // Input
            Container(
              padding: EdgeInsets.all(CUSpacing.lg),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.onBackground.withOpacity(0.04),
                    blurRadius: CUElevation.low.toDouble(),
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: CUSpacing.md,
                        vertical: CUSpacing.sm + CUSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.background,
                        borderRadius: BorderRadius.circular(CURadius.full),
                        border: Border.all(
                          color: theme.colorScheme.border,
                          width: 1,
                        ),
                      ),
                      child: EditableText(
                        controller: _messageController,
                        focusNode: FocusNode(),
                        style: CUTypography.bodyLarge.copyWith(
                          color: theme.colorScheme.onBackground,
                        ),
                        cursorColor: theme.colorScheme.primary,
                        backgroundCursorColor: theme.colorScheme.border,
                        maxLines: null,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  SizedBox(width: CUSpacing.sm + CUSpacing.xs),
                  GestureDetector(
                    onTap: _isSending ? null : _sendMessage,
                    child: Container(
                      width: CUSize.buttonHeight,
                      height: CUSize.buttonHeight,
                      decoration: BoxDecoration(
                        color: _isSending
                            ? theme.colorScheme.border
                            : theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: _isSending
                            ? SizedBox(
                                width: CUSize.iconSmall,
                                height: CUSize.iconSmall,
                                child: CULoadingSpinner(
                                  size: CUSize.iconSmall,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              )
                            : CUIcon(
                                Icons.send,
                                color: theme.colorScheme.onPrimary,
                                size: CUSize.iconSmall,
                              ),
                      ),
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

  Widget _buildMessageBubble(
    String message,
    bool isSupport,
    DateTime timestamp,
    CUThemeData theme,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: CUSpacing.md),
      child: Row(
        mainAxisAlignment: isSupport ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isSupport) ...[
            Container(
              width: CUSize.avatarMedium,
              height: CUSize.avatarMedium,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CUIcon(
                  Icons.support_agent,
                  color: theme.colorScheme.onPrimary,
                  size: CUSize.iconSmall,
                ),
              ),
            ),
            SizedBox(width: CUSpacing.sm),
          ],
          Flexible(
            child: Container(
              padding: EdgeInsets.all(CUSpacing.md),
              decoration: BoxDecoration(
                color: isSupport ? theme.colorScheme.surface : theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(CURadius.md),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.onBackground.withOpacity(0.04),
                    blurRadius: CUElevation.low.toDouble(),
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: CUTypography.bodyLarge.copyWith(
                      color: isSupport
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onPrimary,
                    ),
                  ),
                  SizedBox(height: CUSpacing.sm),
                  Text(
                    DateFormat('h:mm a').format(timestamp),
                    style: CUTypography.bodySmall.copyWith(
                      color: isSupport
                          ? theme.colorScheme.secondary
                          : theme.colorScheme.onPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!isSupport) ...[
            SizedBox(width: CUSpacing.sm),
            Container(
              width: CUSize.avatarMedium,
              height: CUSize.avatarMedium,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CUIcon(
                  Icons.person,
                  color: theme.colorScheme.onPrimary,
                  size: CUSize.iconSmall,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
