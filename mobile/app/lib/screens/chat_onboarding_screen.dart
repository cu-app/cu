import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class ChatOnboardingScreen extends StatefulWidget {
  const ChatOnboardingScreen({super.key});

  @override
  State<ChatOnboardingScreen> createState() => _ChatOnboardingScreenState();
}

class _ChatOnboardingScreenState extends State<ChatOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to CU.APPGPT',
      subtitle: 'Your Intelligent Banking Assistant',
      description: 'Get instant answers to your financial questions, insights about your spending, and personalized assistance with your banking needs.',
      icon: CupertinoIcons.chat_bubble,
      gradientColors: [CUColors.blue400, CUColors.purple400],
    ),
    OnboardingPage(
      title: 'Powered by teachamericaAI.COM',
      subtitle: 'Premium & Free AI Platform for Teachers',
      description: 'Built by the same team that controls your finances. teachamericaAI.COM provides cutting-edge AI tools for educators worldwide.',
      icon: CupertinoIcons.book,
      gradientColors: [CUColors.green400, CUColors.teal400],
    ),
    OnboardingPage(
      title: 'Advanced AI Technology',
      subtitle: 'Secure, Fast, and Intelligent',
      description: 'Experience the power of advanced AI that understands your financial needs while maintaining the highest security standards.',
      icon: CupertinoIcons.lightbulb,
      gradientColors: [CUColors.orange400, CUColors.red400],
    ),
    OnboardingPage(
      title: 'Ready to Get Started?',
      subtitle: 'Your Financial AI Assistant Awaits',
      description: 'Ask questions, get insights, and take control of your finances with the power of artificial intelligence.',
      icon: CupertinoIcons.rocket,
      gradientColors: [CUColors.indigo400, CUColors.blue600],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage(BuildContext context) {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Go to chat screen or close onboarding
      Navigator.of(context).pop();
      CUSnackBar.show(
        context,
        message: 'CU.APPGPT chat coming soon!',
        type: CUSnackBarType.success,
      );
    }
  }

  void _skipOnboarding(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with skip button
            Padding(
              padding: EdgeInsets.all(CUSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CU.APPGPT',
                    style: CUTypography.h5.copyWith(
                      color: theme.colorScheme.onBackground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  CUButton(
                    onPressed: () => _skipOnboarding(context),
                    variant: CUButtonVariant.ghost,
                    size: CUButtonSize.sm,
                    child: Text(
                      'Skip',
                      style: CUTypography.body.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: CUSpacing.md),
              child: Row(
                children: List.generate(
                  _pages.length,
                  (index) => Expanded(
                    child: Container(
                      height: CUSize.xxs,
                      margin: EdgeInsets.symmetric(horizontal: CUSpacing.xxs),
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? theme.colorScheme.onBackground
                            : theme.colorScheme.onBackground.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(CURadius.xs),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(theme, _pages[index]);
                },
              ),
            ),

            // Bottom buttons
            Padding(
              padding: EdgeInsets.all(CUSpacing.lg),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: CUButton(
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        variant: CUButtonVariant.outlined,
                        size: CUButtonSize.lg,
                        child: Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) SizedBox(width: CUSpacing.md),
                  Expanded(
                    flex: _currentPage > 0 ? 2 : 1,
                    child: CUButton(
                      onPressed: () => _nextPage(context),
                      variant: CUButtonVariant.primary,
                      size: CUButtonSize.lg,
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Get Started' : 'Continue',
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

  Widget _buildPage(CUThemeData theme, OnboardingPage page) {
    return Padding(
      padding: EdgeInsets.all(CUSpacing.lg),
      child: Column(
        children: [
          const Spacer(),

          // Icon with gradient background
          Container(
            width: CUSize.xxxl * 2,
            height: CUSize.xxxl * 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: page.gradientColors,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: CUSize.xxxl,
              color: theme.colorScheme.onPrimary,
            ),
          ),

          SizedBox(height: CUSpacing.xl),

          // Title
          Text(
            page.title,
            style: CUTypography.h3.copyWith(
              color: theme.colorScheme.onBackground,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: CUSpacing.md),

          // Subtitle
          Text(
            page.subtitle,
            style: CUTypography.h6.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: CUSpacing.lg),

          // Description
          Text(
            page.description,
            style: CUTypography.body.copyWith(
              color: theme.colorScheme.onBackground.withOpacity(0.7),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(flex: 2),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });
}
