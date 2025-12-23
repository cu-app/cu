import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class AccessibilitySettingsScreen extends StatelessWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final accessibilityService = context.watch<AccessibilityService>();
    final theme = CUTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      color: theme.colorScheme.surfaceContainerLowest,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 800 : double.infinity,
          ),
          child: CustomScrollView(
            slivers: [
              // Header with back button
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    CUSpacing.md,
                    CUSpacing.xxl * 1.5,
                    CUSpacing.md,
                    CUSpacing.xl
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Row(
                          children: [
                            CUIcon(
                              CupertinoIcons.back,
                              color: theme.colorScheme.primary,
                              size: CUSize.iconSm,
                            ),
                            SizedBox(width: CUSpacing.xs),
                            CUText(
                              'Back',
                              style: CUTypography.bodyLarge.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: CUSpacing.lg),
                      CUText(
                        'Accessibility Settings',
                        style: CUTypography.displaySmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: CUSpacing.xs),
                      CUText(
                        'Customize visual preferences and color settings',
                        style: CUTypography.bodyLarge.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Visual Preferences Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    CUSpacing.md,
                    0,
                    CUSpacing.md,
                    CUSpacing.md
                  ),
                  child: CUText(
                    'Visual Preferences',
                    style: CUTypography.labelMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CUSpacing.md),
                  child: Column(
                    children: [
                      _buildSwitchCard(
                        context,
                        theme: theme,
                        icon: CupertinoIcons.paintbrush,
                        iconColor: CUColors.info,
                        title: 'Use Color Indicators',
                        description: 'Show positive balances in green and negative in red',
                        value: accessibilityService.useColorIndicators,
                        onChanged: (value) => accessibilityService.setUseColorIndicators(value),
                      ),
                      SizedBox(height: CUSpacing.sm),
                      _buildSwitchCard(
                        context,
                        theme: theme,
                        icon: CupertinoIcons.circle_lefthalf_fill,
                        iconColor: CUColors.warning,
                        title: 'High Contrast Mode',
                        description: 'Increase contrast for better visibility',
                        value: accessibilityService.highContrastMode,
                        onChanged: (value) => accessibilityService.setHighContrastMode(value),
                      ),
                    ],
                  ),
                ),
              ),

              // Color Blindness Support Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    CUSpacing.md,
                    CUSpacing.xl,
                    CUSpacing.md,
                    CUSpacing.md
                  ),
                  child: CUText(
                    'Color Blindness Support',
                    style: CUTypography.labelMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CUSpacing.md),
                  child: Column(
                    children: [
                      _buildRadioCard(
                        context,
                        theme: theme,
                        title: 'None',
                        subtitle: 'Standard color scheme',
                        isSelected: accessibilityService.colorBlindnessType == ColorBlindnessType.none,
                        onTap: () => accessibilityService.setColorBlindnessType(ColorBlindnessType.none),
                      ),
                      SizedBox(height: CUSpacing.sm),
                      _buildRadioCard(
                        context,
                        theme: theme,
                        title: 'Protanopia',
                        subtitle: 'Red color blindness',
                        isSelected: accessibilityService.colorBlindnessType == ColorBlindnessType.protanopia,
                        onTap: () => accessibilityService.setColorBlindnessType(ColorBlindnessType.protanopia),
                      ),
                      SizedBox(height: CUSpacing.sm),
                      _buildRadioCard(
                        context,
                        theme: theme,
                        title: 'Deuteranopia',
                        subtitle: 'Green color blindness',
                        isSelected: accessibilityService.colorBlindnessType == ColorBlindnessType.deuteranopia,
                        onTap: () => accessibilityService.setColorBlindnessType(ColorBlindnessType.deuteranopia),
                      ),
                      SizedBox(height: CUSpacing.sm),
                      _buildRadioCard(
                        context,
                        theme: theme,
                        title: 'Tritanopia',
                        subtitle: 'Blue color blindness',
                        isSelected: accessibilityService.colorBlindnessType == ColorBlindnessType.tritanopia,
                        onTap: () => accessibilityService.setColorBlindnessType(ColorBlindnessType.tritanopia),
                      ),
                      SizedBox(height: CUSpacing.sm),
                      _buildRadioCard(
                        context,
                        theme: theme,
                        title: 'Monochromacy',
                        subtitle: 'Complete color blindness',
                        isSelected: accessibilityService.colorBlindnessType == ColorBlindnessType.monochromacy,
                        onTap: () => accessibilityService.setColorBlindnessType(ColorBlindnessType.monochromacy),
                      ),
                    ],
                  ),
                ),
              ),

              // Color Preview Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    CUSpacing.md,
                    CUSpacing.xl,
                    CUSpacing.md,
                    CUSpacing.md
                  ),
                  child: CUText(
                    'Color Preview',
                    style: CUTypography.labelMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    CUSpacing.md,
                    0,
                    CUSpacing.md,
                    CUSpacing.xxl * 2.5
                  ),
                  child: _buildColorPreview(context, accessibilityService, theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchCard(
    BuildContext context, {
    required CUThemeData theme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CUOutlinedCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(CURadius.xs),
            ),
            child: CUIcon(
              icon,
              color: iconColor,
              size: CUSize.iconSm,
            ),
          ),
          SizedBox(width: CUSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CUText(
                  title,
                  style: CUTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: CUSpacing.xxs),
                CUText(
                  description,
                  style: CUTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: CUSpacing.md),
          CUSwitch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildRadioCard(
    BuildContext context, {
    required CUThemeData theme,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return CUOutlinedCard(
      onTap: onTap,
      child: Row(
        children: [
          CURadio(
            value: isSelected,
            groupValue: true,
            onChanged: (_) => onTap(),
          ),
          SizedBox(width: CUSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CUText(
                  title,
                  style: CUTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: CUSpacing.xxs),
                CUText(
                  subtitle,
                  style: CUTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          CUIcon(
            CupertinoIcons.eye,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
            size: CUSize.iconSm,
          ),
        ],
      ),
    );
  }

  Widget _buildColorPreview(BuildContext context, AccessibilityService service, CUThemeData theme) {
    final isDarkMode = theme.isDark;

    const positiveBalance = 1234.56;
    const negativeBalance = -567.89;

    final positiveColor = service.getBalanceColor(positiveBalance, isDarkMode: isDarkMode);
    final negativeColor = service.getBalanceColor(negativeBalance, isDarkMode: isDarkMode);

    return CUOutlinedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CUText(
                'Positive Balance:',
                style: CUTypography.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              CUText(
                '\$1,234.56',
                style: CUTypography.bodyLarge.copyWith(
                  color: service.useColorIndicators ? positiveColor : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: CUSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CUText(
                'Negative Balance:',
                style: CUTypography.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              CUText(
                '-\$567.89',
                style: CUTypography.bodyLarge.copyWith(
                  color: service.useColorIndicators ? negativeColor : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: CUSpacing.lg),
          CUText(
            'Color Transformation Preview:',
            style: CUTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.sm),
          _buildColorSwatch(context, service, theme),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(BuildContext context, AccessibilityService service, CUThemeData theme) {
    final colors = [
      CUColors.error,
      CUColors.success,
      CUColors.info,
      theme.colorScheme.onSurface,
      theme.colorScheme.onSurfaceVariant,
      theme.colorScheme.surfaceContainer,
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: colors.map((color) {
        final transformedColor = service.transformColor(color);
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: transformedColor,
            borderRadius: BorderRadius.circular(CURadius.xs),
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
          ),
        );
      }).toList(),
    );
  }
}
