import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'dart:async';

class AutoSetupScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const AutoSetupScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<AutoSetupScreen> createState() => _AutoSetupScreenState();
}

class _AutoSetupScreenState extends State<AutoSetupScreen>
    with TickerProviderStateMixin {
  final List<SetupStep> _steps = [
    SetupStep('Connecting to servers', [
      'Establishing secure connection...',
      'Authenticating credentials...',
      'Loading user profile...',
      'Syncing account data...',
      'Connection established ✓',
    ]),
    SetupStep('Setting up accounts', [
      'Creating checking account...',
      'Creating savings account...',
      'Setting up virtual cards...',
      'Configuring spending limits...',
      'Accounts ready ✓',
    ]),
    SetupStep('Configuring transfers', [
      'Enabling instant transfers...',
      'Setting up ACH routing...',
      'Configuring wire transfers...',
      'Adding Zelle integration...',
      'Transfers enabled ✓',
    ]),
    SetupStep('Enabling features', [
      'Activating spending insights...',
      'Setting up bill pay...',
      'Enabling mobile deposit...',
      'Configuring notifications...',
      'Features activated ✓',
    ]),
    SetupStep('Finalizing setup', [
      'Applying security settings...',
      'Enabling biometric login...',
      'Setting up 2FA...',
      'Creating backup codes...',
      'Setup complete ✓',
    ]),
  ];

  int _currentStepIndex = 0;
  int _currentLineIndex = 0;
  final List<AnimatedLine> _animatedLines = [];
  late Timer _autoPlayTimer;
  late AnimationController _fadeController;
  late AnimationController _shimmerController;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _fadeController.forward();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer.cancel();
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_currentStepIndex >= _steps.length) {
        timer.cancel();
        _completeSetup();
        return;
      }

      setState(() {
        final currentStep = _steps[_currentStepIndex];

        if (_currentLineIndex < currentStep.lines.length) {
          _animatedLines.add(AnimatedLine(
            text: currentStep.lines[_currentLineIndex],
            isComplete: _currentLineIndex == currentStep.lines.length - 1,
            stepTitle: _currentLineIndex == 0 ? currentStep.title : null,
          ));
          _currentLineIndex++;
        } else {
          _currentStepIndex++;
          _currentLineIndex = 0;
        }

        // Keep only last 15 lines visible
        if (_animatedLines.length > 15) {
          _animatedLines.removeAt(0);
        }
      });
    });
  }

  void _completeSetup() async {
    setState(() {
      _isComplete = true;
    });

    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      await _fadeController.reverse();
      widget.onComplete();
    }
  }

  void _skip() async {
    _autoPlayTimer.cancel();
    await _fadeController.reverse();
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      body: FadeTransition(
        opacity: _fadeController,
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.05),
                    theme.colorScheme.surface,
                  ],
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(CUSpacing.md),
                      child: CUTextButton(
                        onPressed: _skip,
                        child: Text('Skip', style: CUTypography.bodyMedium),
                      ),
                    ),
                  ),

                  // Logo
                  Container(
                    width: CUSize.xxxl,
                    height: CUSize.xxxl,
                    margin: EdgeInsets.only(top: CUSpacing.xl),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: CUIcon(
                      CUIcons.bank,
                      size: CUIconSize.xl,
                      color: theme.colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: CUSpacing.xl),

                  // Animated lines
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: CUSpacing.xl),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ..._animatedLines.map((line) => _buildAnimatedLine(line)),

                            if (_isComplete)
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 500),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.scale(
                                      scale: 0.8 + (0.2 * value),
                                      child: Container(
                                        margin: EdgeInsets.only(top: CUSpacing.xl),
                                        padding: EdgeInsets.symmetric(
                                          horizontal: CUSpacing.lg,
                                          vertical: CUSpacing.sm,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary,
                                          borderRadius: BorderRadius.circular(CURadius.full),
                                        ),
                                        child: Text(
                                          'Welcome to your account!',
                                          style: CUTypography.bodyMedium.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Progress bar
                  Container(
                    height: 4,
                    margin: EdgeInsets.all(CUSpacing.xl),
                    child: CUProgressIndicator(
                      value: (_currentStepIndex + (_currentLineIndex / 5)) / _steps.length,
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

  Widget _buildAnimatedLine(AnimatedLine line) {
    final theme = CUTheme.of(context);

    return TweenAnimationBuilder<double>(
      key: ValueKey(line.text),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: CUSpacing.xxs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (line.stepTitle != null)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: CUSpacing.xs,
                        top: CUSpacing.md,
                      ),
                      child: Text(
                        line.stepTitle!,
                        style: CUTypography.bodyMedium.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      if (!line.isComplete)
                        SizedBox(
                          width: CUSize.sm,
                          height: CUSize.sm,
                          child: CUProgressIndicator(),
                        )
                      else
                        CUIcon(
                          CUIcons.checkCircle,
                          size: CUIconSize.sm,
                          color: CUColors.green500,
                        ),
                      SizedBox(width: CUSpacing.sm),
                      Expanded(
                        child: AnimatedBuilder(
                          animation: _shimmerController,
                          builder: (context, child) {
                            return ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  colors: line.isComplete
                                      ? [
                                          theme.colorScheme.onSurface,
                                          theme.colorScheme.onSurface,
                                        ]
                                      : [
                                          theme.colorScheme.onSurface,
                                          theme.colorScheme.primary,
                                          theme.colorScheme.onSurface,
                                        ],
                                  stops: line.isComplete
                                      ? [0, 1]
                                      : [
                                          0,
                                          _shimmerController.value,
                                          1,
                                        ],
                                ).createShader(bounds);
                              },
                              child: Text(
                                line.text,
                                style: CUTypography.bodySmall.copyWith(
                                  color: line.isComplete
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class SetupStep {
  final String title;
  final List<String> lines;

  SetupStep(this.title, this.lines);
}

class AnimatedLine {
  final String text;
  final bool isComplete;
  final String? stepTitle;

  AnimatedLine({
    required this.text,
    required this.isComplete,
    this.stepTitle,
  });
}
