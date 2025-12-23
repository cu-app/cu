import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'dart:math' as math;
import '../../config/cu_config_service.dart';

/// Completion screen - celebratory finish to onboarding
class CompletionScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const CompletionScreen({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen>
    with TickerProviderStateMixin {
  late AnimationController _confettiController;
  late AnimationController _checkmarkController;
  late Animation<double> _checkmarkAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final List<_ConfettiParticle> _particles = [];

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _checkmarkAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: const Interval(0, 0.6, curve: Curves.elasticOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: const Interval(0.3, 0.8, curve: Curves.elasticOut),
    ));

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _checkmarkController,
      curve: const Interval(0.5, 1, curve: Curves.easeIn),
    ));

    // Generate confetti particles
    _generateConfetti();

    // Start animations
    _checkmarkController.forward();
    _confettiController.repeat();
  }

  void _generateConfetti() {
    final random = math.Random();
    final colors = [
      CUColors.green500,
      CUColors.purple500,
      CUColors.red500,
      CUColors.teal500,
      CUColors.yellow500,
    ];

    for (int i = 0; i < 50; i++) {
      _particles.add(_ConfettiParticle(
        color: colors[random.nextInt(colors.length)],
        x: random.nextDouble(),
        y: random.nextDouble() * 0.5 - 0.5,
        size: random.nextDouble() * 10 + 5,
        speed: random.nextDouble() * 2 + 1,
        rotation: random.nextDouble() * 2 * math.pi,
      ));
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return Stack(
      children: [
        // Confetti animation
        AnimatedBuilder(
          animation: _confettiController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ConfettiPainter(
                particles: _particles,
                progress: _confettiController.value,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Main content
        Positioned.fill(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(CUSpacing.xl),
            child: Column(
              children: [
                SizedBox(height: CUSpacing.xl),
              // Animated checkmark
              AnimatedBuilder(
                animation: _checkmarkController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _checkmarkAnimation.value,
                    child: Container(
                      width: CUSize.xxxl,
                      height: CUSize.xxxl,
                      decoration: BoxDecoration(
                        color: CUColors.green500,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: CUColors.green500.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: CUIcon(
                        CUIcons.check,
                        size: CUIconSize.xxxl,
                        color: CUColors.white,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: CUSpacing.xl),

              // Success message
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      Text(
                        'You\'re All Set!',
                        style: CUTypography.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: CUSpacing.md),
                      Text(
                        'Welcome to your new banking experience',
                        style: CUTypography.bodyLarge.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: CUSpacing.xl),

                      // Quick tips
                      CUCard(
                        child: Padding(
                          padding: EdgeInsets.all(CUSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Tips to Get Started',
                                style: CUTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: CUSpacing.md),
                              _buildTip(
                                CUIcons.wallet,
                                'Add funds to your account to start',
                                CUColors.teal500,
                              ),
                              _buildTip(
                                CUIcons.creditCard,
                                'Create your first virtual card instantly',
                                CUColors.yellow500,
                              ),
                              _buildTip(
                                CUIcons.link,
                                'Connect your other bank accounts',
                                CUColors.purple500,
                              ),
                              _buildTip(
                                CUIcons.settings,
                                'Customize your experience in Settings',
                                CUColors.red500,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: CUSpacing.xl),

                      // Test account info
                      Container(
                        padding: EdgeInsets.all(CUSpacing.md),
                        decoration: BoxDecoration(
                          color: CUColors.green500.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(CURadius.md),
                          border: Border.all(
                            color: CUColors.green500.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Test Accounts Available',
                              style: CUTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: CUSpacing.sm),
                            Text(
                              'General: test.general@${CUConfigService().cuDomain}',
                              style: CUTypography.bodySmall.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Business: test.business@${CUConfigService().cuDomain}',
                              style: CUTypography.bodySmall.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Youth: test.youth@${CUConfigService().cuDomain}',
                              style: CUTypography.bodySmall.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              'Fiduciary: test.fiduciary@${CUConfigService().cuDomain}',
                              style: CUTypography.bodySmall.copyWith(
                                fontFamily: 'monospace',
                              ),
                            ),
                            SizedBox(height: CUSpacing.xs),
                            Text(
                              'Password: 123asdfghjkl;\'',
                              style: CUTypography.bodySmall.copyWith(
                                fontFamily: 'monospace',
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: CUSpacing.xl),

                      // Start button
                      CUButton(
                        onPressed: widget.onComplete,
                        child: Text('Start Banking', style: CUTypography.headlineSmall),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

  Widget _buildTip(IconData icon, String text, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: CUSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(CUSpacing.xs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(CURadius.sm),
            ),
            child: CUIcon(
              icon,
              color: color,
              size: CUIconSize.sm,
            ),
          ),
          SizedBox(width: CUSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: CUTypography.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  final Color color;
  final double x;
  final double y;
  final double size;
  final double speed;
  final double rotation;

  _ConfettiParticle({
    required this.color,
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.rotation,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(1 - progress * 0.5)
        ..style = PaintingStyle.fill;

      final y = (particle.y + progress * particle.speed) * size.height;
      final x = particle.x * size.width +
          math.sin(progress * 2 * math.pi + particle.rotation) * 50;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + progress * 2 * math.pi);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: particle.size,
        height: particle.size * 0.6,
      );

      canvas.drawRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) => true;
}
