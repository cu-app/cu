import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool)? onThemeToggle;
  final bool isDarkMode;

  const SettingsScreen({
    super.key,
    this.onThemeToggle,
    this.isDarkMode = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    setState(() {
      _isSigningOut = true;
    });

    try {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSigningOut = false;
        });
        // Show error using CU Design System (if available) or basic widget
        // Note: CU Design System may have CUSnackBar or similar - adjust as needed
        final overlay = Overlay.of(context);
        final overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            bottom: CUSpacing.lg,
            left: CUSpacing.md,
            right: CUSpacing.md,
            child: CUCard(
              backgroundColor: CUColors.red.shade600,
              child: Padding(
                padding: EdgeInsets.all(CUSpacing.md),
                child: Text(
                  'Error signing out: $e',
                  style: CUTypography.bodyMedium.copyWith(
                    color: CUColors.white,
                  ),
                ),
              ),
            ),
          ),
        );
        overlay.insert(overlayEntry);
        Future.delayed(const Duration(seconds: 3), () {
          overlayEntry.remove();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Container(
      color: CUColors.grey.shade50,
      child: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 800 : double.infinity,
          ),
          child: CustomScrollView(
            slivers: [
              // 1033 Export Banner
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                    CUSpacing.lg,
                    CUSpacing.xl * 2,
                    CUSpacing.lg,
                    CUSpacing.md,
                  ),
                  padding: EdgeInsets.all(CUSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(CURadius.md),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(CUSpacing.sm),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(CURadius.sm),
                        ),
                        child: CUIcon(
                          CUIconData.shield,
                          color: CUColors.white,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: CUSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Section 1033 Data Rights',
                              style: CUTypography.labelLarge.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: CUSpacing.xs),
                            Text(
                              'You can now export your financial data under federal consumer protection rules',
                              style: CUTypography.bodySmall.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Header
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.fromLTRB(
                    CUSpacing.lg,
                    0,
                    CUSpacing.lg,
                    CUSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: CUTypography.displaySmall.copyWith(
                          color: CUColors.grey.shade900,
                        ),
                      ),
                      SizedBox(height: CUSpacing.sm),
                      Text(
                        'Manage your account and preferences',
                        style: CUTypography.bodyLarge.copyWith(
                          color: CUColors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Account Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    CUSpacing.lg,
                    0,
                    CUSpacing.lg,
                    CUSpacing.md,
                  ),
                  child: Text(
                    'Account',
                    style: CUTypography.labelMedium.copyWith(
                      color: CUColors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CUSpacing.lg),
                  child: Column(
                    children: [
                      _SettingsCard(
                        icon: CUIconData.shield,
                        iconColor: theme.colorScheme.primary,
                        title: 'Privacy & Data Rights',
                        description: 'Manage connected apps, data access, and export',
                        badge: 'Section 1033',
                        onTap: () => Navigator.of(context).pushNamed('/privacy'),
                      ),
                      SizedBox(height: CUSpacing.sm),
                      _SettingsCard(
                        icon: CUIconData.accessibility,
                        iconColor: CUColors.purple.shade500,
                        title: 'Accessibility',
                        description: 'Customize display and interaction settings',
                        onTap: () => Navigator.of(context).pushNamed('/accessibility'),
                      ),
                    ],
                  ),
                ),
              ),

              // Appearance Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    CUSpacing.lg,
                    CUSpacing.xl,
                    CUSpacing.lg,
                    CUSpacing.md,
                  ),
                  child: Text(
                    'Appearance',
                    style: CUTypography.labelMedium.copyWith(
                      color: CUColors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CUSpacing.lg),
                  child: CUOutlinedCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: CUColors.orange.shade500.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(CURadius.sm),
                          ),
                          child: CUIcon(
                            widget.isDarkMode ? CUIconData.darkMode : CUIconData.lightMode,
                            color: CUColors.orange.shade500,
                            size: 20,
                          ),
                        ),
                        SizedBox(width: CUSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Theme',
                                style: CUTypography.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: CUSpacing.xs),
                              Text(
                                widget.isDarkMode ? 'Dark mode' : 'Light mode',
                                style: CUTypography.bodyMedium.copyWith(
                                  color: CUColors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        CUSwitch(
                          value: widget.isDarkMode,
                          onChanged: widget.onThemeToggle != null
                              ? (value) => widget.onThemeToggle!(value)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // About Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    CUSpacing.lg,
                    CUSpacing.xl,
                    CUSpacing.lg,
                    CUSpacing.md,
                  ),
                  child: Text(
                    'About',
                    style: CUTypography.labelMedium.copyWith(
                      color: CUColors.grey.shade600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CUSpacing.lg),
                  child: Column(
                    children: [
                      _SettingsCard(
                        icon: CUIconData.info,
                        iconColor: CUColors.blue.shade500,
                        title: 'App Version',
                        description: '1.0.0',
                        showChevron: false,
                        onTap: null,
                      ),
                      SizedBox(height: CUSpacing.sm),
                      _SettingsCard(
                        icon: CUIconData.description,
                        iconColor: CUColors.grey.shade500,
                        title: 'Terms of Service',
                        onTap: () {
                          // Navigate to terms
                        },
                      ),
                      SizedBox(height: CUSpacing.sm),
                      _SettingsCard(
                        icon: CUIconData.privacyTip,
                        iconColor: CUColors.grey.shade500,
                        title: 'Privacy Policy',
                        onTap: () {
                          // Navigate to privacy policy
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Sign Out Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    CUSpacing.lg,
                    CUSpacing.xl,
                    CUSpacing.lg,
                    100,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: CUButton(
                      onPressed: _isSigningOut ? null : _signOut,
                      variant: CUButtonVariant.secondary,
                      child: _isSigningOut
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CULoadingSpinner(),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CUIcon(
                                CUIconData.logout,
                                size: 20,
                                color: CUColors.red.shade600,
                              ),
                              SizedBox(width: CUSpacing.sm),
                              Text(
                                'Sign Out',
                                style: CUTypography.labelLarge.copyWith(
                                  color: CUColors.red.shade600,
                                ),
                              ),
                            ],
                          ),
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

class _SettingsCard extends StatelessWidget {
  final CUIconData icon;
  final Color iconColor;
  final String title;
  final String? description;
  final String? badge;
  final VoidCallback? onTap;
  final bool showChevron;

  const _SettingsCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.description,
    this.badge,
    this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUOutlinedCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(CURadius.sm),
            ),
            child: CUIcon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          SizedBox(width: CUSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: CUTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (badge != null) ...[
                      SizedBox(width: CUSpacing.sm),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: CUSpacing.sm,
                          vertical: CUSpacing.xs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(CURadius.xs),
                        ),
                        child: Text(
                          badge!,
                          style: CUTypography.labelSmall.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (description != null) ...[
                  SizedBox(height: CUSpacing.xs),
                  Text(
                    description!,
                    style: CUTypography.bodyMedium.copyWith(
                      color: CUColors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (showChevron && onTap != null) ...[
            SizedBox(width: CUSpacing.sm),
            CUIcon(
              CUIconData.chevronRight,
              color: CUColors.grey.shade400,
              size: 20,
            ),
          ],
        ],
      ),
    );
  }
}
