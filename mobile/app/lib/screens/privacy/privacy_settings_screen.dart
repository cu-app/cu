import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return CUScacuold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CUAppBar(
        title: Text(
          'Privacy & Data',
          style: CUTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(CUIcons.arrowBack, color: theme.colorScheme.onPrimary),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 800 : double.infinity,
          ),
          child: CustomScrollView(
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(CUSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: CUSize.iconLarge * 2,
                        height: CUSize.iconLarge * 2,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(CURadius.lg),
                        ),
                        child: Icon(
                          CUIcons.shield,
                          size: CUSize.iconLarge,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: CUSpacing.md),
                      Text(
                        'Privacy & Data Rights',
                        style: CUTypography.headlineLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: CUSpacing.xs),
                      Text(
                        'Manage your data sharing preferences and exercise your rights under Section 1033.',
                        style: CUTypography.bodyLarge.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Main Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CUSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Data Management',
                        style: CUTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: CUSpacing.sm),
                      _PrivacyActionCard(
                        icon: CUIcons.apps,
                        iconColor: theme.colorScheme.primary,
                        title: 'Connected Apps',
                        description: 'Manage third-party access to your data',
                        badge: '3 active',
                        onTap: () => Navigator.of(context).pushNamed('/privacy/connected-apps'),
                      ),
                      SizedBox(height: CUSpacing.sm),
                      _PrivacyActionCard(
                        icon: CUIcons.download,
                        iconColor: CUColors.success,
                        title: 'Export Your Data',
                        description: 'Download your data in FDX, JSON, CSV, or QFX format',
                        onTap: () => Navigator.of(context).pushNamed('/privacy/data-export'),
                      ),
                      SizedBox(height: CUSpacing.sm),
                      _PrivacyActionCard(
                        icon: CUIcons.history,
                        iconColor: CUColors.purple,
                        title: 'Access History',
                        description: 'View when your data was accessed',
                        onTap: () => Navigator.of(context).pushNamed('/privacy/access-history'),
                      ),
                    ],
                  ),
                ),
              ),

              // Info Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(CUSpacing.lg, CUSpacing.xl, CUSpacing.lg, CUSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Data Rights',
                        style: CUTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: CUSpacing.sm),
                      CUOutlinedCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CUIcons.infoOutline,
                                  size: CUSize.iconSmall,
                                  color: theme.colorScheme.primary,
                                ),
                                SizedBox(width: CUSpacing.sm),
                                Expanded(
                                  child: Text(
                                    'Section 1033 Compliance',
                                    style: CUTypography.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: CUSpacing.sm),
                            Text(
                              'Under the Dodd-Frank Act Section 1033, you have the right to:',
                              style: CUTypography.bodyMedium.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: CUSpacing.sm),
                            const _RightItem(text: 'Access your financial data'),
                            const _RightItem(text: 'Export data in standardized formats'),
                            const _RightItem(text: 'Share data with authorized third parties'),
                            const _RightItem(text: 'Revoke access at any time'),
                            const _RightItem(text: 'View who accessed your data'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Security Info
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(CUSpacing.lg, 0, CUSpacing.lg, 100),
                  child: CUOutlinedCard(
                    child: Row(
                      children: [
                        Container(
                          width: CUSize.iconMedium * 1.25,
                          height: CUSize.iconMedium * 1.25,
                          decoration: BoxDecoration(
                            color: CUColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(CURadius.sm),
                          ),
                          child: Icon(
                            CUIcons.lock,
                            color: CUColors.success,
                            size: CUSize.iconSmall,
                          ),
                        ),
                        SizedBox(width: CUSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your data is protected',
                                style: CUTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: CUSpacing.xs),
                              Text(
                                'All data exports and transfers use bank-level encryption',
                                style: CUTypography.bodySmall.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PrivacyActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String? badge;
  final VoidCallback onTap;

  const _PrivacyActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUOutlinedCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: CUSize.iconLarge * 1.5,
            height: CUSize.iconLarge * 1.5,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(CURadius.md),
            ),
            child: Icon(icon, color: iconColor, size: CUSize.iconMedium),
          ),
          SizedBox(width: CUSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: CUTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      SizedBox(width: CUSpacing.xs),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: CUSpacing.xs,
                          vertical: CUSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: iconColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(CURadius.md),
                        ),
                        child: Text(
                          badge!,
                          style: CUTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: iconColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: CUSpacing.xxs),
                Text(
                  description,
                  style: CUTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: CUSpacing.sm),
          Icon(CUIcons.chevronRight, color: theme.colorScheme.outline),
        ],
      ),
    );
  }
}

class _RightItem extends StatelessWidget {
  final String text;

  const _RightItem({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: CUSpacing.xs),
      child: Row(
        children: [
          Icon(CUIcons.checkCircle, size: CUSize.iconSmall, color: CUColors.success),
          SizedBox(width: CUSpacing.xs),
          Expanded(
            child: Text(
              text,
              style: CUTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
