import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import '../services/banking_service.dart';
import '../services/auth_service.dart';

class ConnectAccountScreen extends StatefulWidget {
  const ConnectAccountScreen({super.key});

  @override
  State<ConnectAccountScreen> createState() => _ConnectAccountScreenState();
}

class _ConnectAccountScreenState extends State<ConnectAccountScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _floatAnimation;

  bool _isConnecting = false;
  final bool _isConnected = false;
  String _error = '';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _floatAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeOutCubic,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _floatController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _connectAccount() async {
    setState(() {
      _isConnecting = true;
    });

    try {
      // Haptic feedback
      SystemChannels.platform.invokeMethod('HapticFeedback.lightImpact');

      // Navigate to Plaid Link screen for real institution selection
      if (mounted) {
        Navigator.of(context).pushNamed('/plaid-link');
      }
    } catch (e) {
      // Error haptic
      SystemChannels.platform.invokeMethod('HapticFeedback.heavyImpact');

      setState(() {
        _isConnecting = false;
        _error = e.toString();
      });

      if (mounted) {
        final theme = CUTheme.of(context);
        // Note: CU Design System equivalent for SnackBar would be used here
        // For now, keeping Navigator-based error handling
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text('Connection Error'),
            content: Text('Failed to open Plaid Link: $e'),
            actions: [
              CupertinoDialogAction(
                child: Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      }
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CupertinoPageScaffold(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([_fadeAnimation, _floatAnimation]),
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _floatAnimation,
                child: Stack(
                  children: [
                    // Scrollable content
                    SingleChildScrollView(
                      padding: EdgeInsets.all(CUSpacing.x6),
                      child: Column(
                        children: [
                          // Header
                          _buildHeader(context),

                          SizedBox(height: CUSpacing.x8),

                          // Main content
                          _buildMainContent(context),

                          // Bottom padding to account for docked buttons
                          const SizedBox(height: 200),
                        ],
                      ),
                    ),

                    // Gradient overlay at bottom to indicate more content
                    Positioned(
                      bottom: 140,
                      left: 0,
                      right: 0,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0x00000000), // transparent
                              theme.colorScheme.surface,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Docked buttons at bottom with proper home indicator fill
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          CUSpacing.x6,
                          CUSpacing.x6,
                          CUSpacing.x6,
                          CUSpacing.x10,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                        ),
                        child: _buildConnectButton(context),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = CUTheme.of(context);

    return Column(
      children: [
        SizedBox(height: CUSpacing.x5),
        Text(
          'Connect Your Account',
          style: CUTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: CUSpacing.x3),
        Text(
          'Securely link your bank account to get started with SUPAHYPER',
          style: CUTypography.bodyLarge.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = CUTheme.of(context);

    return Column(
      children: [
        // Security badge
        Container(
          padding: EdgeInsets.all(CUSpacing.x6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(CURadius.medium),
          ),
          child: Column(
            children: [
              Icon(
                CupertinoIcons.lock_shield,
                size: CUSize.iconLarge,
                color: theme.colorScheme.onSurface,
              ),
              SizedBox(height: CUSpacing.x4),
              Text(
                'Military Grade Security',
                style: CUTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: CUSpacing.x2),
              Text(
                'For our members. Your data is encrypted and protected with the same security standards used by major banks.',
                style: CUTypography.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        SizedBox(height: CUSpacing.x8),

        // Features list
        _buildFeaturesList(context),
      ],
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      {
        'icon': CupertinoIcons.rocket,
        'title': 'Built in a Week',
        'description':
            'Simple app that leans heavy on design tokens and real-time subscriptions. All Flutter.',
      },
      {
        'icon': CupertinoIcons.link,
        'title': 'Legacy Bridge',
        'description':
            'Snaps right onto your Symitar/PowerOn legacy systems, acting as a bridge while providing full UX layer.',
      },
      {
        'icon': CupertinoIcons.checkmark_shield,
        'title': 'Real KYC & Ownership',
        'description':
            'You own your website, experiences, and fraud/UX behavioral tools tied to your organization goals.',
      },
      {
        'icon': CupertinoIcons.sparkles,
        'title': 'Better Than MX',
        'description':
            'Cleans transactions better than MX - superior data quality and categorization.',
      },
    ];

    return Column(
      children: features
          .map((feature) => _buildFeatureItem(context, feature))
          .toList(),
    );
  }

  Widget _buildFeatureItem(BuildContext context, Map<String, dynamic> feature) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: CUSpacing.x4),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(CUSpacing.x3),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(CURadius.small),
            ),
            child: Icon(
              feature['icon'],
              color: theme.colorScheme.onSurface,
              size: CUSize.iconMedium,
            ),
          ),
          SizedBox(width: CUSpacing.x4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature['title'],
                  style: CUTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: CUSpacing.x1),
                Text(
                  feature['description'],
                  style: CUTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton(BuildContext context) {
    final theme = CUTheme.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: CUButton(
            onPressed: _isConnecting ? null : _connectAccount,
            variant: CUButtonVariant.primary,
            size: CUButtonSize.large,
            child: _isConnecting
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CupertinoActivityIndicator(
                          color: CUColors.white,
                        ),
                      ),
                      SizedBox(width: CUSpacing.x3),
                      Text(
                        'Connecting...',
                        style: CUTypography.labelLarge.copyWith(
                          color: CUColors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Connect Account',
                    style: CUTypography.labelLarge.copyWith(
                      color: CUColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        SizedBox(height: CUSpacing.x3),
        SizedBox(
          width: double.infinity,
          child: CUButton(
            onPressed: _isConnecting ? null : _goToLogin,
            variant: CUButtonVariant.secondary,
            size: CUButtonSize.large,
            child: Text(
              'Log In',
              style: CUTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _goToLogin() async {
    // Haptic feedback
    SystemChannels.platform.invokeMethod('HapticFeedback.lightImpact');

    // Navigate to login
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
