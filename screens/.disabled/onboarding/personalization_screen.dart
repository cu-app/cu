import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'package:flutter/cupertino.dart';

/// Personalization screen with settings preferences
class PersonalizationScreen extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const PersonalizationScreen({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<PersonalizationScreen> createState() => _PersonalizationScreenState();
}

class _PersonalizationScreenState extends State<PersonalizationScreen>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  // Preferences
  bool _enableNotifications = true;
  bool _enableBiometric = true;
  bool _enableLocationServices = false;
  bool _enableDataSync = true;
  bool _enableMarketingEmails = false;
  final String _selectedTheme = 'auto';
  final String _selectedCurrency = 'USD';

  final List<_SettingSection> _sections = [
    _SettingSection(
      title: 'Security & Privacy',
      icon: CUIcons.shield,
      color: CUColors.purple500,
      settings: [
        _SettingItem(
          title: 'Biometric Authentication',
          subtitle: 'Use Face ID or Touch ID to sign in',
          icon: CUIcons.fingerprint,
          type: _SettingType.toggle,
          key: 'biometric',
        ),
        _SettingItem(
          title: 'Transaction Notifications',
          subtitle: 'Get alerts for all account activity',
          icon: CUIcons.notification,
          type: _SettingType.toggle,
          key: 'notifications',
        ),
        _SettingItem(
          title: 'Location Services',
          subtitle: 'Enhanced security based on location',
          icon: CUIcons.location,
          type: _SettingType.toggle,
          key: 'location',
        ),
      ],
    ),
    _SettingSection(
      title: 'Display & Preferences',
      icon: CUIcons.palette,
      color: CUColors.teal500,
      settings: [
        _SettingItem(
          title: 'App Theme',
          subtitle: 'Choose your preferred appearance',
          icon: CUIcons.moon,
          type: _SettingType.selection,
          key: 'theme',
          options: ['Light', 'Dark', 'Auto'],
        ),
        _SettingItem(
          title: 'Currency',
          subtitle: 'Set your default currency',
          icon: CUIcons.dollarSign,
          type: _SettingType.selection,
          key: 'currency',
          options: ['USD', 'EUR', 'GBP', 'CAD'],
        ),
      ],
    ),
    _SettingSection(
      title: 'Data & Sync',
      icon: CUIcons.sync,
      color: CUColors.red500,
      settings: [
        _SettingItem(
          title: 'Auto-sync Accounts',
          subtitle: 'Keep your connected accounts updated',
          icon: CUIcons.cloudSync,
          type: _SettingType.toggle,
          key: 'datasync',
        ),
        _SettingItem(
          title: 'Marketing Communications',
          subtitle: 'Receive offers and updates',
          icon: CUIcons.mail,
          type: _SettingType.toggle,
          key: 'marketing',
        ),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _sections.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 500 + (index * 100)),
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      ));
    }).toList();

    // Start animations
    for (var controller in _controllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return Column(
      children: [
        SizedBox(height: CUSpacing.xl),

        // Title
        Text(
          'Personalize Your Experience',
          style: CUTypography.headlineLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: CUSpacing.xs),
        Text(
          'You can change these anytime in Settings',
          style: CUTypography.bodyMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: CUSpacing.xs),

        // Settings tip
        Container(
          margin: EdgeInsets.symmetric(horizontal: CUSpacing.xl),
          padding: EdgeInsets.all(CUSpacing.sm),
          decoration: BoxDecoration(
            color: CUColors.green500.withOpacity(0.1),
            borderRadius: BorderRadius.circular(CURadius.md),
            border: Border.all(
              color: CUColors.green500.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              CUIcon(
                CUIcons.infoCircle,
                color: CUColors.green500,
                size: CUIconSize.sm,
              ),
              SizedBox(width: CUSpacing.xs),
              Expanded(
                child: Text(
                  'Access Settings from your profile icon in the top-right corner',
                  style: CUTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: CUSpacing.lg),

        // Settings sections
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: CUSpacing.md),
            itemCount: _sections.length,
            itemBuilder: (context, index) {
              return FadeTransition(
                opacity: _animations[index],
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_animations[index]),
                  child: _buildSettingSection(_sections[index]),
                ),
              );
            },
          ),
        ),

        // Continue button
        Padding(
          padding: EdgeInsets.all(CUSpacing.md),
          child: CUButton(
            onPressed: widget.onNext,
            child: Text('Continue', style: CUTypography.bodyLarge),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingSection(_SettingSection section) {
    final theme = CUTheme.of(context);

    return CUCard(
      margin: EdgeInsets.only(bottom: CUSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: EdgeInsets.all(CUSpacing.md),
            decoration: BoxDecoration(
              color: section.color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(CURadius.md),
                topRight: Radius.circular(CURadius.md),
              ),
            ),
            child: Row(
              children: [
                CUIcon(
                  section.icon,
                  color: section.color,
                  size: CUIconSize.lg,
                ),
                SizedBox(width: CUSpacing.sm),
                Text(
                  section.title,
                  style: CUTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Settings items
          ...section.settings.map((setting) {
            return _buildSettingItem(setting, section.color);
          }),
        ],
      ),
    );
  }

  Widget _buildSettingItem(_SettingItem item, Color color) {
    final theme = CUTheme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: CUSpacing.md,
        vertical: CUSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.onSurface.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(CUSpacing.xs),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(CURadius.sm),
            ),
            child: CUIcon(
              item.icon,
              color: color,
              size: CUIconSize.sm,
            ),
          ),
          SizedBox(width: CUSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: CUTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  item.subtitle,
                  style: CUTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: CUSpacing.md),
          _buildSettingControl(item),
        ],
      ),
    );
  }

  Widget _buildSettingControl(_SettingItem item) {
    final theme = CUTheme.of(context);

    switch (item.type) {
      case _SettingType.toggle:
        bool value = false;
        switch (item.key) {
          case 'biometric':
            value = _enableBiometric;
            break;
          case 'notifications':
            value = _enableNotifications;
            break;
          case 'location':
            value = _enableLocationServices;
            break;
          case 'datasync':
            value = _enableDataSync;
            break;
          case 'marketing':
            value = _enableMarketingEmails;
            break;
        }

        return CupertinoSwitch(
          value: value,
          activeColor: theme.colorScheme.primary,
          onChanged: (newValue) {
            setState(() {
              switch (item.key) {
                case 'biometric':
                  _enableBiometric = newValue;
                  break;
                case 'notifications':
                  _enableNotifications = newValue;
                  break;
                case 'location':
                  _enableLocationServices = newValue;
                  break;
                case 'datasync':
                  _enableDataSync = newValue;
                  break;
                case 'marketing':
                  _enableMarketingEmails = newValue;
                  break;
              }
            });
          },
        );

      case _SettingType.selection:
        String value = '';
        switch (item.key) {
          case 'theme':
            value = _selectedTheme;
            break;
          case 'currency':
            value = _selectedCurrency;
            break;
        }

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: CUSpacing.sm,
            vertical: CUSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(CURadius.full),
          ),
          child: Row(
            children: [
              Text(
                value.toUpperCase(),
                style: CUTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: CUSpacing.xxs),
              CUIcon(
                CUIcons.chevronDown,
                size: CUIconSize.sm,
              ),
            ],
          ),
        );
    }
  }
}

class _SettingSection {
  final String title;
  final IconData icon;
  final Color color;
  final List<_SettingItem> settings;

  _SettingSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.settings,
  });
}

class _SettingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final _SettingType type;
  final String key;
  final List<String>? options;

  _SettingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.type,
    required this.key,
    this.options,
  });
}

enum _SettingType { toggle, selection }
