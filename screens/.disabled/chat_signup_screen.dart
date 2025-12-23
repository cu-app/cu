import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class ChatSignupScreen extends StatefulWidget {
  const ChatSignupScreen({super.key});

  @override
  State<ChatSignupScreen> createState() => _ChatSignupScreenState();
}

class _ChatSignupScreenState extends State<ChatSignupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _typingController;
  late Animation<double> _typingAnimation;

  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _isComplete = false;
  int _currentStep = 0;
  bool _showFormView = false;

  // Form data storage
  final Map<String, String> _formData = {
    'first_name': '',
    'last_name': '',
    'email': '',
    'phone': '',
    'purpose': '',
  };

  final List<Map<String, dynamic>> _signupSteps = [
    {
      'question':
          'Hi! I\'m here to help you get started with SUPAHYPER. What\'s your first name?',
      'field': 'first_name',
      'placeholder': 'Enter your first name',
      'quickActions': ['John', 'Sarah', 'Mike', 'Emma'],
    },
    {
      'question': 'Nice to meet you! What\'s your last name?',
      'field': 'last_name',
      'placeholder': 'Enter your last name',
      'quickActions': ['Smith', 'Johnson', 'Williams', 'Brown'],
    },
    {
      'question': 'Perfect! What\'s your email address?',
      'field': 'email',
      'placeholder': 'Enter your email',
      'quickActions': ['john@email.com', 'sarah@email.com', 'mike@email.com'],
    },
    {
      'question': 'Great! What\'s your phone number?',
      'field': 'phone',
      'placeholder': 'Enter your phone number',
      'quickActions': ['(555) 123-4567', '(555) 987-6543', '(555) 456-7890'],
    },
    {
      'question': 'Almost done! What would you like to use SUPAHYPER for?',
      'field': 'purpose',
      'placeholder': 'e.g., Personal banking, Business, etc.',
      'quickActions': [
        'Personal Banking',
        'Business',
        'Savings',
        'Investments'
      ],
    },
    {
      'question':
          'Excellent! I\'ve got everything I need. Let me set up your account...',
      'field': 'complete',
      'placeholder': '',
      'quickActions': [],
    },
  ];

  @override
  void initState() {
    super.initState();

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingController,
      curve: Curves.easeInOut,
    ));

    _startConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  void _startConversation() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    _addSupportMessage(_signupSteps[0]['question']);
  }

  void _addSupportMessage(String message) async {
    setState(() {
      _isTyping = true;
    });

    _typingController.forward();

    // Simulate typing delay
    await Future.delayed(const Duration(milliseconds: 2000));

    setState(() {
      _isTyping = false;
      _messages.add({
        'content': message,
        'sender': 'support',
        'timestamp': DateTime.now(),
      });
    });

    _scrollToBottom();
  }

  void _addUserMessage(String message) {
    setState(() {
      _messages.add({
        'content': message,
        'sender': 'user',
        'timestamp': DateTime.now(),
      });
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _isComplete) return;

    final message = _messageController.text.trim();
    _messageController.clear();

    // Haptic feedback
    SystemChannels.platform.invokeMethod('HapticFeedback.lightImpact');

    _addUserMessage(message);

    // Process the response
    _processUserInput(message);
  }

  void _processUserInput(String input) async {
    if (_currentStep < _signupSteps.length - 1) {
      // Store the user's input
      final currentField = _signupSteps[_currentStep]['field'];
      if (currentField != null) {
        _formData[currentField] = input;
      }

      _currentStep++;

      // Add delay before next question
      await Future.delayed(const Duration(milliseconds: 1500));

      if (_currentStep < _signupSteps.length - 1) {
        _addSupportMessage(_signupSteps[_currentStep]['question']);
      } else {
        // Final step - complete signup
        _addSupportMessage(_signupSteps[_currentStep]['question']);

        await Future.delayed(const Duration(milliseconds: 3000));

        setState(() {
          _isComplete = true;
        });

        _addSupportMessage(
            ' Welcome to SUPAHYPER! Your account is ready. You can now explore all our features and connect your bank account whenever you\'re ready.');

        await Future.delayed(const Duration(milliseconds: 2000));

        // Navigate to dashboard
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CUAppBar(
        title: const Text('Get Started'),
        backgroundColor: CUColors.transparent,
        leading: CUIconButton(
          icon: CUIcons.arrowBack,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          CUIconButton(
            icon: _showFormView ? CUIcons.message : CUIcons.list,
            onPressed: () {
              setState(() {
                _showFormView = !_showFormView;
              });
            },
          ),
        ],
      ),
      body: _showFormView ? _buildFormView() : _buildChatView(),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        // Chat messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.all(CUSpacing.lg),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length && _isTyping) {
                return _buildTypingIndicator();
              }

              final message = _messages[index];
              return _buildMessageBubble(message);
            },
          ),
        ),

        // Quick actions
        if (!_isComplete && _currentStep < _signupSteps.length)
          _buildQuickActions(),

        // Message input
        if (!_isComplete) _buildMessageInput(),
      ],
    );
  }

  Widget _buildFormView() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Information',
            style: CUTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.lg),
          ..._formData.entries
              .map((entry) => _buildFormField(entry.key, entry.value)),
          SizedBox(height: CUSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: CUButton(
              onPressed: _isComplete
                  ? null
                  : () {
                      // Complete signup manually
                      setState(() {
                        _isComplete = true;
                      });
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
              child: const Text('Complete Signup'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String key, String value) {
    final theme = CUTheme.of(context);

    final labels = {
      'first_name': 'First Name',
      'last_name': 'Last Name',
      'email': 'Email',
      'phone': 'Phone',
      'purpose': 'Purpose',
    };

    return Padding(
      padding: EdgeInsets.only(bottom: CUSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labels[key] ?? key,
            style: CUTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: CUSpacing.xs),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(CUSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(CURadius.md),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Text(
              value.isEmpty ? 'Not provided yet' : value,
              style: CUTypography.bodyLarge.copyWith(
                color: value.isEmpty
                    ? theme.colorScheme.onSurfaceVariant.withOpacity(0.6)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final theme = CUTheme.of(context);

    if (_currentStep >= _signupSteps.length) return const SizedBox.shrink();

    final quickActions =
        _signupSteps[_currentStep]['quickActions'] as List<String>?;
    if (quickActions == null || quickActions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CUSpacing.lg,
        vertical: CUSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick options:',
            style: CUTypography.bodySmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
          SizedBox(height: CUSpacing.xs),
          Wrap(
            spacing: CUSpacing.xs,
            runSpacing: CUSpacing.xs,
            children: quickActions
                .map((action) => _buildQuickActionChip(action))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionChip(String text) {
    final theme = CUTheme.of(context);

    return GestureDetector(
      onTap: () {
        SystemChannels.platform.invokeMethod('HapticFeedback.lightImpact');
        _messageController.text = text;
        _sendMessage();
      },
      child: CUChip(
        label: Text(text),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        labelStyle: CUTypography.bodyMedium.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final theme = CUTheme.of(context);
    final isUser = message['sender'] == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: CUSpacing.md),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(CUSpacing.md),
              decoration: BoxDecoration(
                color: isUser
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(CURadius.lg).copyWith(
                  bottomLeft: isUser
                      ? Radius.circular(CURadius.lg)
                      : Radius.circular(CURadius.xs),
                  bottomRight: isUser
                      ? Radius.circular(CURadius.xs)
                      : Radius.circular(CURadius.lg),
                ),
              ),
              child: Text(
                message['content'],
                style: CUTypography.bodyMedium.copyWith(
                  color: isUser
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SizedBox(height: CUSpacing.xxs),
            Text(
              _formatTime(message['timestamp']),
              style: CUTypography.bodySmall.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    final theme = CUTheme.of(context);

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: CUSpacing.md),
        padding: EdgeInsets.all(CUSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(CURadius.lg).copyWith(
            bottomLeft: Radius.circular(CURadius.xs),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _typingAnimation,
              builder: (context, child) {
                return Row(
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animationValue =
                        (_typingAnimation.value - delay).clamp(0.0, 1.0);
                    final scale = 0.5 +
                        (0.5 *
                            (1 - (animationValue - 0.5).abs() * 2)
                                .clamp(0.0, 1.0));

                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: CUSpacing.xxs),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: CUSize.iconXs,
                          height: CUSize.iconXs,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            SizedBox(width: CUSpacing.xs),
            Text(
              'Support is typing...',
              style: CUTypography.bodySmall.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    final theme = CUTheme.of(context);
    final currentStep =
        _currentStep < _signupSteps.length ? _signupSteps[_currentStep] : null;

    return Container(
      padding: EdgeInsets.all(CUSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CUTextField(
              controller: _messageController,
              hintText: currentStep?['placeholder'] ?? 'Type your message...',
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          SizedBox(width: CUSpacing.sm),
          CUIconButton(
            onPressed: _sendMessage,
            icon: CUIcons.send,
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: EdgeInsets.all(CUSpacing.sm),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else {
      return '${difference.inHours}h ago';
    }
  }
}
