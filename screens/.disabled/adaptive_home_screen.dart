import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'package:provider/provider.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../src/one_two_transition.dart';
import 'simple_dashboard_screen.dart';
import 'transactions_screen.dart';
import 'transfer_screen.dart';
import 'services_screen.dart';
import 'settings_screen.dart';
import 'profile_switcher_screen.dart';
import 'account_details_screen.dart';
import 'cards_screen.dart';

class AdaptiveHomeScreen extends StatefulWidget {
  final Function(bool) onThemeToggle;

  const AdaptiveHomeScreen({super.key, required this.onThemeToggle});

  @override
  State<AdaptiveHomeScreen> createState() => _AdaptiveHomeScreenState();
}

class _AdaptiveHomeScreenState extends State<AdaptiveHomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _profileAnimationController;
  late CurvedAnimation _railAnimation;
  late CurvedAnimation _profileAnimation;

  bool _showMediumLayout = false;
  bool _showLargeLayout = false;
  bool _showProfileSwitcher = false;

  int _selectedIndex = 0;
  Map<String, dynamic>? _selectedAccount;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Screen definitions
  late final List<_NavigationItem> _navigationItems = [
    _NavigationItem(
      label: 'Dashboard',
      labelEs: 'Inicio',
      icon: CUIconData(0xe1a4), // dashboard_outlined
      selectedIcon: CUIconData(0xe1a3), // dashboard
    ),
    _NavigationItem(
      label: 'Cards',
      labelEs: 'Tarjetas',
      icon: CUIconData(0xe870), // credit_card_outlined
      selectedIcon: CUIconData(0xe870), // credit_card
    ),
    _NavigationItem(
      label: 'Transactions',
      labelEs: 'Transacciones',
      icon: CUIconData(0xf02d), // receipt_long_outlined
      selectedIcon: CUIconData(0xf02d), // receipt_long
    ),
    _NavigationItem(
      label: 'Transfer',
      labelEs: 'Transferir',
      icon: CUIconData(0xe8d4), // swap_horiz_outlined
      selectedIcon: CUIconData(0xe8d4), // swap_horiz
    ),
    _NavigationItem(
      label: 'Services',
      labelEs: 'Servicios',
      icon: CUIconData(0xe9b3), // grid_view_outlined
      selectedIcon: CUIconData(0xe9b3), // grid_view
    ),
    _NavigationItem(
      label: 'Settings',
      labelEs: 'Configuración',
      icon: CUIconData(0xe8b9), // settings_outlined
      selectedIcon: CUIconData(0xe8b8), // settings
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _profileAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _railAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0),
    );

    _profileAnimation = CurvedAnimation(
      parent: _profileAnimationController,
      curve: Curves.easeInOut,
    );

    // Initialize profile service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileService>().initialize();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _profileAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = MediaQuery.of(context).size.width;
    const mediumBreakpoint = 800.0;
    const largeBreakpoint = 1200.0;

    if (width >= largeBreakpoint) {
      _showMediumLayout = false;
      _showLargeLayout = true;
      _controller.forward();
    } else if (width >= mediumBreakpoint) {
      _showMediumLayout = true;
      _showLargeLayout = false;
      _controller.forward();
    } else {
      _showMediumLayout = false;
      _showLargeLayout = false;
      _controller.reverse();
    }
  }

  void _toggleProfileSwitcher() {
    setState(() {
      _showProfileSwitcher = !_showProfileSwitcher;
      if (_showProfileSwitcher) {
        _profileAnimationController.forward();
      } else {
        _profileAnimationController.reverse();
      }
    });
  }

  Widget _buildProfileHeader(ProfileService profileService) {
    final theme = CUTheme.of(context);
    final currentProfile = profileService.currentProfile;
    if (currentProfile == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: _toggleProfileSwitcher,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: CUSpacing.md,
          vertical: CUSpacing.sm,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CURadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: CUSize.iconLg * 1.5,
              height: CUSize.iconLg * 1.5,
              decoration: BoxDecoration(
                color: _getProfileColor(currentProfile.type, theme),
                borderRadius: BorderRadius.circular(CURadius.full),
              ),
              child: Center(
                child: Text(
                  currentProfile.displayName.substring(0, 1).toUpperCase(),
                  style: CUTypography.headlineSmall.copyWith(
                    color: CUColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: CUSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentProfile.displayName,
                    style: CUTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    currentProfile.type.displayName,
                    style: CUTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: _showProfileSwitcher ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: CUIcon(
                CUIconData(0xe5cf), // expand_more
                color: theme.colorScheme.onSurfaceVariant,
                size: CUSize.iconMd,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProfileColor(ProfileType type, CUThemeData theme) {
    switch (type) {
      case ProfileType.personal:
        return theme.colorScheme.primary;
      case ProfileType.business:
        return CUColors.green;
      case ProfileType.youth:
        return CUColors.orange;
      case ProfileType.fiduciary:
        return CUColors.purple;
    }
  }

  Widget _buildNavigationRail() {
    final theme = CUTheme.of(context);

    return NavigationRail(
      extended: _showLargeLayout,
      backgroundColor: theme.colorScheme.surface,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) {
        setState(() {
          _selectedIndex = index;
          _showProfileSwitcher = false;
        });
      },
      selectedIconTheme: IconThemeData(
        color: theme.colorScheme.onSurface,
        size: CUSize.iconMd,
      ),
      unselectedIconTheme: IconThemeData(
        color: theme.colorScheme.onSurfaceVariant,
        size: CUSize.iconMd,
      ),
      selectedLabelTextStyle: CUTypography.labelMedium.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelTextStyle: CUTypography.labelMedium.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.normal,
      ),
      leading: null,
      destinations: _navigationItems
          .map((item) => NavigationRailDestination(
                icon: CUIcon(item.icon, size: CUSize.iconMd),
                selectedIcon: CUIcon(item.selectedIcon, size: CUSize.iconMd),
                label: Text(item.label),
              ))
          .toList(),
    );
  }

  Widget _buildBottomNavigationBar() {
    final theme = CUTheme.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedFontSize: CUTypography.labelSmall.fontSize!,
        unselectedFontSize: CUTypography.labelSmall.fontSize!,
        selectedItemColor: theme.colorScheme.onSurface,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant,
        backgroundColor: theme.colorScheme.surface,
        items: _navigationItems
            .map((item) => BottomNavigationBarItem(
                  icon: SizedBox(
                    width: CUSize.iconLg * 1.5,
                    height: CUSize.iconLg * 1.5,
                    child: Center(
                      child: CUIcon(
                        item.icon,
                        size: CUSize.iconLg,
                      ),
                    ),
                  ),
                  activeIcon: SizedBox(
                    width: CUSize.iconLg * 1.5,
                    height: CUSize.iconLg * 1.5,
                    child: Center(
                      child: CUIcon(
                        item.selectedIcon,
                        size: CUSize.iconLg,
                      ),
                    ),
                  ),
                  label: item.labelEs,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildBody() {
    final theme = CUTheme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    final Widget screen = switch (_selectedIndex) {
      0 => SimpleDashboardScreen(
          scrollController: ScrollController(),
          onAccountSelected: (account) {
            setState(() {
              _selectedAccount = account;
            });
          },
        ),
      1 => const CardsScreen(),
      2 => const TransactionsScreen(),
      3 => const TransferScreen(),
      4 => const ServicesScreen(),
      5 => SettingsScreen(
          currentTheme: isDarkMode,
          onThemeToggle: widget.onThemeToggle,
        ),
      _ => const SizedBox.shrink(),
    };

    if (_showMediumLayout || _showLargeLayout) {
      // Desktop layout with panels
      return Row(
        children: [
          if (_showProfileSwitcher)
            AnimatedBuilder(
              animation: _profileAnimation,
              builder: (context, child) {
                return Container(
                  width: 300 * _profileAnimation.value,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    border: Border(
                      right: BorderSide(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  child: _profileAnimation.value > 0.1
                      ? FadeTransition(
                          opacity: _profileAnimation,
                          child: ProfileSwitcherScreen(
                            onProfileSelected: (profile) async {
                              final profileService = context.read<ProfileService>();
                              await profileService.switchProfile(profile);
                              _toggleProfileSwitcher();
                            },
                          ),
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
          Expanded(
            child: _selectedAccount != null && _selectedIndex == 0
                ? OneTwoTransition(
                    animation: _railAnimation,
                    one: screen,
                    two: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerLow,
                        border: Border(
                          left: BorderSide(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      child: _buildDetailPanel(),
                    ),
                  )
                : screen,
          ),
        ],
      );
    } else {
      // Mobile layout - Navigate to account details
      if (_selectedAccount != null && _selectedIndex == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            CUPageRoute(
              builder: (context) => AccountDetailsScreen(account: _selectedAccount!),
            ),
          ).then((_) {
            setState(() {
              _selectedAccount = null;
            });
          });
        });
      }
      return screen;
    }
  }

  Widget _buildDetailPanel() {
    final theme = CUTheme.of(context);

    // Show account details if an account is selected on desktop
    if (_selectedAccount != null && _selectedIndex == 0) {
      return AccountDetailsScreen(account: _selectedAccount!);
    }

    // Otherwise show placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CUIcon(
            CUIconData(0xe88f), // info_outline
            size: CUSize.iconXl * 2,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: CUSpacing.md),
          Text(
            'Select an account to view details',
            style: CUTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: _showMediumLayout || _showLargeLayout ? AppBar(
            title: Text(
              _navigationItems[_selectedIndex].label,
              style: CUTypography.titleLarge,
            ),
            backgroundColor: theme.colorScheme.surface,
            foregroundColor: theme.colorScheme.onSurface,
            elevation: 0,
            centerTitle: false,
            actions: [
              Consumer<ProfileService>(
                builder: (context, profileService, child) {
                  final currentProfile = profileService.currentProfile;
                  if (currentProfile == null) return const SizedBox.shrink();

                  return Padding(
                    padding: EdgeInsets.only(right: CUSpacing.md),
                    child: GestureDetector(
                      onTap: _toggleProfileSwitcher,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: CUSpacing.sm,
                          vertical: CUSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(CURadius.md),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: CUSize.iconLg,
                              height: CUSize.iconLg,
                              decoration: BoxDecoration(
                                color: _getProfileColor(currentProfile.type, theme),
                                borderRadius: BorderRadius.circular(CURadius.full),
                              ),
                              child: Center(
                                child: Text(
                                  currentProfile.displayName.substring(0, 1).toUpperCase(),
                                  style: CUTypography.labelMedium.copyWith(
                                    color: CUColors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: CUSpacing.xs),
                            Text(
                              currentProfile.displayName,
                              style: CUTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ) : null,
          body: Row(
            children: [
              if (_showMediumLayout || _showLargeLayout)
                _buildNavigationRail(),
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
          bottomNavigationBar: !_showMediumLayout && !_showLargeLayout
              ? _buildBottomNavigationBar()
              : null,
        );
      },
    );
  }
}

class _NavigationItem {
  final String label;
  final String labelEs; // Spanish label
  final CUIconData icon;
  final CUIconData selectedIcon;

  _NavigationItem({
    required this.label,
    required this.labelEs,
    required this.icon,
    required this.selectedIcon,
  });
}
