import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import '../models/card_model.dart';
import '../services/card_service.dart';
import '../widgets/particle_animation.dart';

class CardControlsScreen extends StatefulWidget {
  final BankCard card;
  final int initialTab;

  const CardControlsScreen({
    super.key,
    required this.card,
    this.initialTab = 0,
  });

  @override
  State<CardControlsScreen> createState() => _CardControlsScreenState();
}

class _CardControlsScreenState extends State<CardControlsScreen>
    with SingleTickerProviderStateMixin {
  final CardService _cardService = CardService();
  late TabController _tabController;
  late BankCard _card;
  late CardControls _controls;
  late CardLimits _limits;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab,
    );
    _card = widget.card;
    _controls = _card.controls;
    _limits = _card.limits;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          final shouldPop = await _showUnsavedChangesDialog();
          if (shouldPop && mounted) {
            Navigator.pop(context, _card);
          }
          return false;
        }
        Navigator.pop(context, _card);
        return false;
      },
      child: CUScaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: CUAppBar(
          title: Text('Card Controls', style: CUTypography.titleLarge),
          backgroundColor: theme.colorScheme.surface,
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(child: Text('General', style: CUTypography.labelLarge)),
              Tab(child: Text('Limits', style: CUTypography.labelLarge)),
              Tab(child: Text('Security', style: CUTypography.labelLarge)),
              Tab(child: Text('Restrictions', style: CUTypography.labelLarge)),
            ],
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorColor: theme.colorScheme.primary,
          ),
          actions: [
            if (_hasChanges)
              CUButton.text(
                onPressed: _saveChanges,
                child: Text('Save', style: CUTypography.labelLarge),
              ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildGeneralTab(),
            _buildLimitsTab(),
            _buildSecurityTab(),
            _buildRestrictionsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralTab() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Lock Status
          CUCard(
            padding: EdgeInsets.all(CUSpacing.md),
            backgroundColor: _controls.isLocked
                ? CUColors.warning.withOpacity(0.1)
                : CUColors.success.withOpacity(0.1),
            borderColor: _controls.isLocked ? CUColors.warning : CUColors.success,
            borderWidth: 1,
            child: Row(
              children: [
                CUIcon(
                  _controls.isLocked ? Icons.lock : Icons.lock_open,
                  color: _controls.isLocked ? CUColors.warning : CUColors.success,
                  size: CUSize.iconLg,
                ),
                SizedBox(width: CUSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _controls.isLocked ? 'Card is Locked' : 'Card is Active',
                        style: CUTypography.titleMedium.copyWith(
                          color: _controls.isLocked ? CUColors.warning : CUColors.success,
                        ),
                      ),
                      SizedBox(height: CUSpacing.xs),
                      Text(
                        _controls.isLocked
                            ? 'All transactions are blocked'
                            : 'Card can be used for transactions',
                        style: CUTypography.bodyMedium.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                CUSwitch(
                  value: !_controls.isLocked,
                  onChanged: (value) {
                    setState(() {
                      _controls = _controls.copyWith(isLocked: !value);
                      _hasChanges = true;
                    });
                  },
                  activeColor: CUColors.success,
                ),
              ],
            ),
          ),

          SizedBox(height: CUSpacing.xl),

          Text(
            'Transaction Types',
            style: CUTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: CUSpacing.md),

          // Transaction controls
          _buildControlTile(
            'Online Transactions',
            'Allow purchases from websites and apps',
            Icons.language,
            _controls.onlineTransactions,
            (value) => setState(() {
              _controls = _controls.copyWith(onlineTransactions: value);
              _hasChanges = true;
            }),
          ),
          _buildControlTile(
            'ATM Withdrawals',
            'Allow cash withdrawals from ATMs',
            Icons.atm,
            _controls.atmWithdrawals,
            (value) => setState(() {
              _controls = _controls.copyWith(atmWithdrawals: value);
              _hasChanges = true;
            }),
          ),
          _buildControlTile(
            'Contactless Payments',
            'Allow tap-to-pay transactions',
            Icons.wifi,
            _controls.contactlessPayments,
            (value) => setState(() {
              _controls = _controls.copyWith(contactlessPayments: value);
              _hasChanges = true;
            }),
          ),
          _buildControlTile(
            'Recurring Payments',
            'Allow subscription and recurring charges',
            Icons.repeat,
            _controls.recurringPayments,
            (value) => setState(() {
              _controls = _controls.copyWith(recurringPayments: value);
              _hasChanges = true;
            }),
          ),

          SizedBox(height: CUSpacing.xl),

          // Notifications
          Text(
            'Notifications',
            style: CUTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: CUSpacing.md),

          _buildControlTile(
            'Transaction Alerts',
            'Get notified for every transaction',
            Icons.notifications,
            _controls.notificationsEnabled,
            (value) => setState(() {
              _controls = _controls.copyWith(notificationsEnabled: value);
              _hasChanges = true;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitsTab() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ParticleAnimation(
            particleColor: theme.colorScheme.primary.withOpacity(0.05),
            numberOfParticles: 10,
            speedFactor: 0.2,
            child: CUCard(
              padding: EdgeInsets.all(CUSpacing.md),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primaryContainer,
                  theme.colorScheme.primaryContainer.withOpacity(0.5),
                ],
              ),
              child: Column(
                children: [
                  CUIcon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: CUSize.iconLg,
                  ),
                  SizedBox(height: CUSpacing.sm),
                  Text(
                    'Spending limits help you stay within budget and add an extra layer of security',
                    textAlign: TextAlign.center,
                    style: CUTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: CUSpacing.xl),

          _buildLimitSlider(
            'Daily Spending Limit',
            _limits.dailySpendLimit,
            0,
            10000,
            (value) => setState(() {
              _limits = _limits.copyWith(dailySpendLimit: value);
              _hasChanges = true;
            }),
          ),

          _buildLimitSlider(
            'Daily ATM Limit',
            _limits.dailyATMLimit,
            0,
            2000,
            (value) => setState(() {
              _limits = _limits.copyWith(dailyATMLimit: value);
              _hasChanges = true;
            }),
          ),

          _buildLimitSlider(
            'Single Transaction Limit',
            _limits.singleTransactionLimit,
            0,
            5000,
            (value) => setState(() {
              _limits = _limits.copyWith(singleTransactionLimit: value);
              _hasChanges = true;
            }),
          ),

          SizedBox(height: CUSpacing.xl),

          Text(
            'Category Limits',
            style: CUTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: CUSpacing.sm),
          Text(
            'Set spending limits for specific categories',
            style: CUTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.md),

          ...SpendingCategory.all.map((category) {
            final limit = _limits.categoryLimits[category] ?? 0.0;
            return _buildCategoryLimit(category, limit);
          }),

          SizedBox(height: CUSpacing.xl),

          // Transaction count limit
          CUListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Daily Transaction Count', style: CUTypography.bodyLarge),
            subtitle: Text(
              'Maximum transactions per day: ${_limits.dailyTransactionCount}',
              style: CUTypography.bodyMedium,
            ),
            trailing: SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CUButton.icon(
                    icon: CUIcon(Icons.remove, size: CUSize.iconMd),
                    onPressed: _limits.dailyTransactionCount > 1
                        ? () => setState(() {
                              _limits = _limits.copyWith(
                                dailyTransactionCount: _limits.dailyTransactionCount - 1,
                              );
                              _hasChanges = true;
                            })
                        : null,
                  ),
                  Text(
                    '${_limits.dailyTransactionCount}',
                    style: CUTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CUButton.icon(
                    icon: CUIcon(Icons.add, size: CUSize.iconMd),
                    onPressed: () => setState(() {
                      _limits = _limits.copyWith(
                        dailyTransactionCount: _limits.dailyTransactionCount + 1,
                      );
                      _hasChanges = true;
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTab() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'International Usage',
            style: CUTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: CUSpacing.md),

          _buildControlTile(
            'International Transactions',
            'Allow usage outside your home country',
            Icons.flight,
            _controls.internationalTransactions,
            (value) => setState(() {
              _controls = _controls.copyWith(internationalTransactions: value);
              _hasChanges = true;
            }),
          ),

          SizedBox(height: CUSpacing.xl),

          Text(
            'Allowed Countries',
            style: CUTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: CUSpacing.sm),
          Text(
            'Select countries where this card can be used',
            style: CUTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.md),

          Wrap(
            spacing: CUSpacing.sm,
            runSpacing: CUSpacing.sm,
            children: [
              'US', 'CA', 'UK', 'FR', 'DE', 'JP', 'AU'
            ].map((country) {
              final isSelected = _controls.allowedCountries.contains(country);
              return FilterChip(
                label: Text(country, style: CUTypography.labelMedium),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final countries = List<String>.from(_controls.allowedCountries);
                    if (selected) {
                      countries.add(country);
                    } else {
                      countries.remove(country);
                    }
                    _controls = _controls.copyWith(allowedCountries: countries);
                    _hasChanges = true;
                  });
                },
              );
            }).toList(),
          ),

          SizedBox(height: CUSpacing.xxl),

          Text(
            'Additional Security',
            style: CUTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: CUSpacing.md),

          CUListTile(
            contentPadding: EdgeInsets.zero,
            leading: CUCard(
              padding: EdgeInsets.all(CUSpacing.sm),
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: CUIcon(
                Icons.security,
                color: theme.colorScheme.secondary,
                size: CUSize.iconMd,
              ),
            ),
            title: Text('Change PIN', style: CUTypography.bodyLarge),
            subtitle: Text('Update your card PIN', style: CUTypography.bodyMedium),
            trailing: CUIcon(Icons.arrow_forward_ios, size: CUSize.iconSm),
            onTap: _changePin,
          ),

          if (_card.isVirtual)
            CUListTile(
              contentPadding: EdgeInsets.zero,
              leading: CUCard(
                padding: EdgeInsets.all(CUSpacing.sm),
                backgroundColor: theme.colorScheme.tertiaryContainer,
                child: CUIcon(
                  Icons.refresh,
                  color: theme.colorScheme.tertiary,
                  size: CUSize.iconMd,
                ),
              ),
              title: Text('Regenerate CVV', style: CUTypography.bodyLarge),
              subtitle: Text('Get a new security code', style: CUTypography.bodyMedium),
              trailing: CUIcon(Icons.arrow_forward_ios, size: CUSize.iconSm),
              onTap: _regenerateCvv,
            ),
        ],
      ),
    );
  }

  Widget _buildRestrictionsTab() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Blocked Categories',
            style: CUTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: CUSpacing.sm),
          Text(
            'Prevent transactions in these categories',
            style: CUTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.md),

          Wrap(
            spacing: CUSpacing.sm,
            runSpacing: CUSpacing.sm,
            children: [
              'Gambling',
              'Adult Content',
              'Cryptocurrency',
              'Gaming',
              'Alcohol',
              'Tobacco',
            ].map((category) {
              final isBlocked = _controls.blockedCategories.contains(category);
              return FilterChip(
                label: Text(category, style: CUTypography.labelMedium),
                selected: isBlocked,
                selectedColor: CUColors.error.withOpacity(0.2),
                onSelected: (selected) {
                  setState(() {
                    final categories = List<String>.from(_controls.blockedCategories);
                    if (selected) {
                      categories.add(category);
                    } else {
                      categories.remove(category);
                    }
                    _controls = _controls.copyWith(blockedCategories: categories);
                    _hasChanges = true;
                  });
                },
              );
            }).toList(),
          ),

          SizedBox(height: CUSpacing.xxl),

          Text(
            'Blocked Merchants',
            style: CUTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: CUSpacing.sm),
          Text(
            'Add specific merchants to block',
            style: CUTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.md),

          if (_controls.blockedMerchants.isEmpty)
            CUCard(
              padding: EdgeInsets.all(CUSpacing.xxl),
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: Column(
                  children: [
                    CUIcon(
                      Icons.block,
                      size: CUSize.iconXl,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                    ),
                    SizedBox(height: CUSpacing.sm),
                    Text(
                      'No blocked merchants',
                      style: CUTypography.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...List.generate(_controls.blockedMerchants.length, (index) {
              final merchant = _controls.blockedMerchants[index];
              return CUListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(merchant, style: CUTypography.bodyLarge),
                trailing: CUButton.icon(
                  icon: CUIcon(Icons.remove_circle_outline, color: CUColors.error),
                  onPressed: () {
                    setState(() {
                      final merchants = List<String>.from(_controls.blockedMerchants);
                      merchants.removeAt(index);
                      _controls = _controls.copyWith(blockedMerchants: merchants);
                      _hasChanges = true;
                    });
                  },
                ),
              );
            }),

          SizedBox(height: CUSpacing.md),

          CUButton.outlined(
            onPressed: _addBlockedMerchant,
            icon: CUIcon(Icons.add, size: CUSize.iconMd),
            child: Text('Add Blocked Merchant', style: CUTypography.labelLarge),
          ),
        ],
      ),
    );
  }

  Widget _buildControlTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: CUSpacing.md),
      child: CUCard(
        padding: EdgeInsets.all(CUSpacing.md),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        child: Row(
          children: [
            CUCard(
              padding: EdgeInsets.all(CUSpacing.sm),
              backgroundColor: value
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.surfaceContainer,
              child: CUIcon(
                icon,
                color: value
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                size: CUSize.iconMd,
              ),
            ),
            SizedBox(width: CUSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CUTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: CUSpacing.xs),
                  Text(
                    subtitle,
                    style: CUTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CUSwitch(
              value: value,
              onChanged: _controls.isLocked ? null : onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: CUSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: CUTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '\$${value.toStringAsFixed(0)}',
                style: CUTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: CUSpacing.sm),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: theme.colorScheme.primary,
              inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
              thumbColor: theme.colorScheme.primary,
              overlayColor: theme.colorScheme.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max ~/ 100).toInt(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryLimit(String category, double limit) {
    final theme = CUTheme.of(context);

    return CUListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(category, style: CUTypography.bodyLarge),
      subtitle: limit > 0
          ? Text(
              '\$${limit.toStringAsFixed(0)} daily limit',
              style: CUTypography.bodyMedium,
            )
          : Text(
              'No limit set',
              style: CUTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
      trailing: CUButton.outlined(
        onPressed: () => _setCategoryLimit(category),
        child: Text(limit > 0 ? 'Edit' : 'Set', style: CUTypography.labelMedium),
      ),
    );
  }

  void _setCategoryLimit(String category) {
    final currentLimit = _limits.categoryLimits[category] ?? 0.0;
    final controller = TextEditingController(
      text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        final theme = CUTheme.of(context);
        return AlertDialog(
          title: Text('Set $category Limit', style: CUTypography.titleLarge),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Daily limit',
              prefixText: '\$',
              hintText: '0',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          actions: [
            CUButton.text(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: CUTypography.labelLarge),
            ),
            CUButton.filled(
              onPressed: () {
                final newLimit = double.tryParse(controller.text) ?? 0;
                setState(() {
                  final categoryLimits = Map<String, double>.from(_limits.categoryLimits);
                  if (newLimit > 0) {
                    categoryLimits[category] = newLimit;
                  } else {
                    categoryLimits.remove(category);
                  }
                  _limits = _limits.copyWith(categoryLimits: categoryLimits);
                  _hasChanges = true;
                });
                Navigator.pop(context);
              },
              child: Text('Save', style: CUTypography.labelLarge),
            ),
          ],
        );
      },
    );
  }

  void _addBlockedMerchant() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final theme = CUTheme.of(context);
        return AlertDialog(
          title: Text('Block Merchant', style: CUTypography.titleLarge),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Merchant name',
              hintText: 'e.g., Store Name',
            ),
          ),
          actions: [
            CUButton.text(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: CUTypography.labelLarge),
            ),
            CUButton.filled(
              onPressed: () {
                final merchant = controller.text.trim();
                if (merchant.isNotEmpty) {
                  setState(() {
                    final merchants = List<String>.from(_controls.blockedMerchants);
                    merchants.add(merchant);
                    _controls = _controls.copyWith(blockedMerchants: merchants);
                    _hasChanges = true;
                  });
                }
                Navigator.pop(context);
              },
              child: Text('Block', style: CUTypography.labelLarge),
            ),
          ],
        );
      },
    );
  }

  void _changePin() {
    // Show PIN change dialog
    showDialog(
      context: context,
      builder: (context) {
        final theme = CUTheme.of(context);
        return AlertDialog(
          title: Text('Change PIN', style: CUTypography.titleLarge),
          content: Text(
            'You will receive instructions via SMS to change your PIN.',
            style: CUTypography.bodyMedium,
          ),
          actions: [
            CUButton.text(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: CUTypography.labelLarge),
            ),
            CUButton.filled(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'PIN change instructions sent via SMS',
                      style: CUTypography.bodyMedium.copyWith(color: CUColors.onSuccess),
                    ),
                    backgroundColor: CUColors.success,
                  ),
                );
              },
              child: Text('Send Instructions', style: CUTypography.labelLarge),
            ),
          ],
        );
      },
    );
  }

  void _regenerateCvv() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = CUTheme.of(context);
        return AlertDialog(
          title: Text('Regenerate CVV', style: CUTypography.titleLarge),
          content: Text(
            'This will generate a new security code for your virtual card. The old code will no longer work.',
            style: CUTypography.bodyMedium,
          ),
          actions: [
            CUButton.text(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: CUTypography.labelLarge),
            ),
            CUButton.filled(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'New CVV generated successfully',
                      style: CUTypography.bodyMedium.copyWith(color: CUColors.onSuccess),
                    ),
                    backgroundColor: CUColors.success,
                  ),
                );
              },
              child: Text('Regenerate', style: CUTypography.labelLarge),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _showUnsavedChangesDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) {
        final theme = CUTheme.of(context);
        return AlertDialog(
          title: Text('Unsaved Changes', style: CUTypography.titleLarge),
          content: Text(
            'You have unsaved changes. Do you want to save them?',
            style: CUTypography.bodyMedium,
          ),
          actions: [
            CUButton.text(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Discard', style: CUTypography.labelLarge),
            ),
            CUButton.filled(
              onPressed: () async {
                await _saveChanges();
                if (mounted) Navigator.pop(context, true);
              },
              child: Text('Save', style: CUTypography.labelLarge),
            ),
          ],
        );
      },
    ) ?? false;
  }

  Future<void> _saveChanges() async {
    // Show saving indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = CUTheme.of(context);
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              SizedBox(width: CUSpacing.md),
              Text('Saving changes...', style: CUTypography.bodyMedium),
            ],
          ),
        );
      },
    );

    // Update controls
    if (_controls != _card.controls) {
      await _cardService.updateCardControls(_card.id, _controls);
    }

    // Update limits
    if (_limits != _card.limits) {
      await _cardService.updateCardLimits(_card.id, _limits);
    }

    // Update card
    setState(() {
      _card = _card.copyWith(
        controls: _controls,
        limits: _limits,
      );
      _hasChanges = false;
    });

    // Close saving dialog
    if (mounted) Navigator.pop(context);

    // Show success
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Changes saved successfully',
          style: CUTypography.bodyMedium.copyWith(color: CUColors.onSuccess),
        ),
        backgroundColor: CUColors.success,
      ),
    );
  }
}
