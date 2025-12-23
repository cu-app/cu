import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'feature_overview_screen.dart';
import 'personalization_screen.dart';
import 'completion_screen.dart';

/// Simplified onboarding flow
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late PageController _pageController;
  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    // Navigate directly to the end
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: EdgeInsets.all(CUSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  AnimatedOpacity(
                    opacity: _currentPage > 0 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: CUIconButton(
                      icon: CUIcon(CUIcons.arrowLeft),
                      onPressed: _currentPage > 0 ? _previousPage : null,
                    ),
                  ),

                  // Progress dots
                  Row(
                    children: List.generate(_totalPages, (index) {
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: CUSpacing.xxs),
                        width: CUSize.xs,
                        height: CUSize.xs,
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),

                  // Skip button
                  CUTextButton(
                    onPressed: _skipOnboarding,
                    child: Text('Skip', style: CUTypography.bodyMedium),
                  ),
                ],
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _WelcomeScreen(onNext: _nextPage),
                  FeatureOverviewScreen(
                    onNext: _nextPage,
                    onBack: _previousPage,
                  ),
                  PersonalizationScreen(
                    onNext: _nextPage,
                    onBack: _previousPage,
                  ),
                  CompletionScreen(
                    onComplete: widget.onComplete,
                    onBack: _previousPage,
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

/// Welcome screen
class _WelcomeScreen extends StatelessWidget {
  final VoidCallback onNext;

  const _WelcomeScreen({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.all(CUSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: CUSize.xxl,
            height: CUSize.xxl,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: CUIcon(
              CUIcons.bank,
              size: CUIconSize.xxl,
              color: theme.colorScheme.primary,
            ),
          ),

          SizedBox(height: CUSpacing.xl),

          Text(
            'Welcome to Banking',
            style: CUTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: CUSpacing.md),

          Text(
            'Let\'s get you set up',
            style: CUTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            child: CUButton(
              onPressed: onNext,
              child: Text('Get Started', style: CUTypography.bodyLarge),
            ),
          ),
        ],
      ),
    );
  }
}
