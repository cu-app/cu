import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

/// Feature overview screen - simplified single view
class FeatureOverviewScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const FeatureOverviewScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<FeatureOverviewScreen> createState() => _FeatureOverviewScreenState();
}

class _FeatureOverviewScreenState extends State<FeatureOverviewScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final _mainFeature = _Feature(
    title: 'Modern Banking',
    description: 'Everything you need in one place',
    icon: CUIcons.bank,
    details: [
      'Connect all your accounts',
      'Track spending instantly',
      'Create virtual cards',
      'Transfer money easily',
    ],
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _animationController.value,
          child: Padding(
            padding: EdgeInsets.all(CUSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  width: CUSize.xxl,
                  height: CUSize.xxl,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: CUIcon(
                    _mainFeature.icon,
                    size: CUIconSize.xxl,
                    color: theme.colorScheme.primary,
                  ),
                ),

                SizedBox(height: CUSpacing.xl),

                // Title
                Text(
                  _mainFeature.title,
                  style: CUTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: CUSpacing.md),

                // Description
                Text(
                  _mainFeature.description,
                  style: CUTypography.bodyLarge.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: CUSpacing.xl),

                // Feature list
                ...(_mainFeature.details.map((detail) => Padding(
                  padding: EdgeInsets.symmetric(vertical: CUSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CUIcon(
                        CUIcons.checkCircle,
                        size: CUIconSize.sm,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: CUSpacing.sm),
                      Text(
                        detail,
                        style: CUTypography.bodyMedium,
                      ),
                    ],
                  ),
                ))),

                const Spacer(),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  child: CUButton(
                    onPressed: widget.onNext,
                    child: Text('Continue', style: CUTypography.bodyLarge),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Feature {
  final String title;
  final String description;
  final IconData icon;
  final List<String> details;

  _Feature({
    required this.title,
    required this.description,
    required this.icon,
    required this.details,
  });
}
