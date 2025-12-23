import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import '../../services/feature_service.dart';

/// Membership selection screen with beautiful card-based UI
class MembershipSelectionScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const MembershipSelectionScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<MembershipSelectionScreen> createState() => _MembershipSelectionScreenState();
}

class _MembershipSelectionScreenState extends State<MembershipSelectionScreen>
    with TickerProviderStateMixin {
  MembershipType? _selectedMembership;
  late List<AnimationController> _cardAnimations;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  final List<_MembershipOption> _options = [
    _MembershipOption(
      type: MembershipType.general,
      title: 'Personal',
      subtitle: 'For individuals and families',
      icon: CUIcons.person,
      color: CUColors.teal500,
      features: [
        'Unlimited debit cards',
        'Mobile check deposit',
        'Bill pay & transfers',
        'Savings goals',
        'Spending analytics',
        'Investment accounts',
      ],
      price: 'Free',
    ),
    _MembershipOption(
      type: MembershipType.business,
      title: 'Business',
      subtitle: 'For companies and teams',
      icon: CUIcons.briefcase,
      color: CUColors.purple500,
      features: [
        'Everything in Personal, plus:',
        'Employee cards',
        'Bulk payments',
        'Higher limits',
        'Multi-user access',
        'Accounting integration',
        'Priority support',
      ],
      price: '\$29/mo',
      isRecommended: true,
    ),
    _MembershipOption(
      type: MembershipType.premium,
      title: 'Premium',
      subtitle: 'Exclusive benefits',
      icon: CUIcons.star,
      color: CUColors.yellow500,
      features: [
        'All features unlocked',
        'Unlimited everything',
        'Concierge service',
        'Premium rewards',
        'Travel benefits',
        'VIP support',
      ],
      price: '\$99/mo',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _cardAnimations = List.generate(
      _options.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 500 + (index * 100)),
        vsync: this,
      ),
    );

    _fadeAnimations = _cardAnimations.map((controller) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeIn,
      ));
    }).toList();

    _slideAnimations = _cardAnimations.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));
    }).toList();

    // Start animations
    for (var controller in _cardAnimations) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _cardAnimations) {
      controller.dispose();
    }
    super.dispose();
  }

  void _selectMembership(MembershipType type) {
    setState(() {
      _selectedMembership = type;
    });

    // Update feature service
    FeatureService().updateMembershipType(type);

    // Auto-advance after selection
    Future.delayed(const Duration(milliseconds: 500), widget.onNext);
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.all(CUSpacing.md),
      child: Column(
        children: [
          SizedBox(height: CUSpacing.xl),

          // Title
          Text(
            'Choose Your Plan',
            style: CUTypography.displaySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.xs),
          Text(
            'Select the membership that fits your needs',
            style: CUTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.xl),

          // Membership cards
          Expanded(
            child: ListView.builder(
              itemCount: _options.length,
              itemBuilder: (context, index) {
                final option = _options[index];

                return SlideTransition(
                  position: _slideAnimations[index],
                  child: FadeTransition(
                    opacity: _fadeAnimations[index],
                    child: _buildMembershipCard(option, index),
                  ),
                );
              },
            ),
          ),

          // Continue button
          AnimatedOpacity(
            opacity: _selectedMembership != null ? 1.0 : 0.3,
            duration: const Duration(milliseconds: 300),
            child: CUButton(
              onPressed: _selectedMembership != null ? widget.onNext : null,
              child: Text('Continue', style: CUTypography.bodyLarge),
            ),
          ),
          SizedBox(height: CUSpacing.md),
        ],
      ),
    );
  }

  Widget _buildMembershipCard(_MembershipOption option, int index) {
    final theme = CUTheme.of(context);
    final isSelected = _selectedMembership == option.type;

    return GestureDetector(
      onTap: () => _selectMembership(option.type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.only(bottom: CUSpacing.md),
        padding: EdgeInsets.all(CUSpacing.md),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [option.color, option.color.withOpacity(0.7)]
                : [theme.colorScheme.surfaceVariant, theme.colorScheme.surfaceVariant.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(CURadius.lg),
          border: Border.all(
            color: isSelected ? option.color : theme.colorScheme.outline,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // Recommended badge
            if (option.isRecommended)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: CUSpacing.sm,
                    vertical: CUSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: CUColors.green500,
                    borderRadius: BorderRadius.circular(CURadius.md),
                  ),
                  child: Text(
                    'RECOMMENDED',
                    style: CUTypography.labelSmall.copyWith(
                      color: CUColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(CUSpacing.sm),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? CUColors.white.withOpacity(0.2)
                            : option.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(CURadius.md),
                      ),
                      child: CUIcon(
                        option.icon,
                        color: isSelected ? CUColors.white : option.color,
                        size: CUIconSize.lg,
                      ),
                    ),
                    SizedBox(width: CUSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.title,
                            style: CUTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? CUColors.white : theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            option.subtitle,
                            style: CUTypography.bodyMedium.copyWith(
                              color: isSelected
                                  ? CUColors.white.withOpacity(0.9)
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          option.price,
                          style: CUTypography.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? CUColors.white : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (option.price != 'Free')
                          Text(
                            'per month',
                            style: CUTypography.bodySmall.copyWith(
                              color: isSelected
                                  ? CUColors.white.withOpacity(0.9)
                                  : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: CUSpacing.md),

                // Features list
                ...option.features.take(isSelected ? 10 : 3).map((feature) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: CUSpacing.xs),
                    child: Row(
                      children: [
                        CUIcon(
                          CUIcons.checkCircle,
                          size: CUIconSize.sm,
                          color: isSelected
                              ? CUColors.white.withOpacity(0.9)
                              : option.color.withOpacity(0.8),
                        ),
                        SizedBox(width: CUSpacing.xs),
                        Expanded(
                          child: Text(
                            feature,
                            style: CUTypography.bodyMedium.copyWith(
                              color: isSelected
                                  ? CUColors.white.withOpacity(0.9)
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                if (!isSelected && option.features.length > 3)
                  Padding(
                    padding: EdgeInsets.only(top: CUSpacing.xs),
                    child: Text(
                      '+ ${option.features.length - 3} more features',
                      style: CUTypography.bodyMedium.copyWith(
                        color: option.color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MembershipOption {
  final MembershipType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<String> features;
  final String price;
  final bool isRecommended;

  _MembershipOption({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.features,
    required this.price,
    this.isRecommended = false,
  });
}
