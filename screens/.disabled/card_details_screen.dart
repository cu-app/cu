import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import '../models/card_model.dart';
import '../services/card_service.dart';
import '../widgets/card_widget.dart';
import 'card_controls_screen.dart';

class CardDetailsScreen extends StatefulWidget {
  final BankCard card;

  const CardDetailsScreen({
    super.key,
    required this.card,
  });

  @override
  State<CardDetailsScreen> createState() => _CardDetailsScreenState();
}

class _CardDetailsScreenState extends State<CardDetailsScreen>
    with SingleTickerProviderStateMixin {
  final CardService _cardService = CardService();
  late AnimationController _lockAnimationController;
  late Animation<double> _lockAnimation;
  late BankCard _currentCard;

  @override
  void initState() {
    super.initState();
    _currentCard = widget.card;
    _lockAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _lockAnimation = CurvedAnimation(
      parent: _lockAnimationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _lockAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return CUScaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 800 : double.infinity,
          ),
          child: CustomScrollView(
        slivers: [
          CUSliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          theme.colorScheme.primary.withOpacity(0.1),
                          theme.colorScheme.surface,
                        ],
                      ),
                    ),
                  ),


                  // Card
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        CUSpacing.md,
                        CUSpacing.xl + CUSpacing.lg,
                        CUSpacing.md,
                        CUSpacing.md,
                      ),
                      child: CardWidget(
                        card: _currentCard,
                        showDetails: true,
                        isHero: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              if (_currentCard.isVirtual)
                CUIconButton(
                  icon: CUIcon(CUIconsOutline.trash),
                  onPressed: _deleteVirtualCard,
                  tooltip: 'Delete Virtual Card',
                ),
              CUIconButton(
                icon: CUIcon(CUIconsOutline.moreVertical),
                onPressed: _showMoreOptions,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  _buildQuickActions(theme),

                  SizedBox(height: CUSpacing.lg),

                  // Card Info
                  _buildCardInfo(theme),

                  SizedBox(height: CUSpacing.lg),

                  // Spending Limits
                  _buildSpendingLimits(theme),

                  SizedBox(height: CUSpacing.lg),

                  // Card Controls
                  _buildCardControls(theme),

                  SizedBox(height: CUSpacing.lg),

                  // Recent Transactions (placeholder)
                  _buildRecentTransactions(theme),

                  SizedBox(height: CUSpacing.xl),
                ],
              ),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(CUThemeData theme) {
    return CUCard(
      padding: EdgeInsets.all(CUSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickActionButton(
            icon: _currentCard.controls.isLocked ? CUIconsOutline.lockOpen : CUIconsOutline.lock,
            label: _currentCard.controls.isLocked ? 'Unlock' : 'Lock',
            color: _currentCard.controls.isLocked ? CUColors.green : CUColors.orange,
            onTap: _toggleCardLock,
          ),
          if (!_currentCard.isVirtual)
            _buildQuickActionButton(
              icon: CUIconsOutline.key,
              label: 'View PIN',
              color: CUColors.blue,
              onTap: _viewPin,
            ),
          if (_currentCard.isVirtual)
            _buildQuickActionButton(
              icon: CUIconsOutline.copy,
              label: 'Copy Details',
              color: CUColors.blue,
              onTap: _copyCardDetails,
            ),
          _buildQuickActionButton(
            icon: CUIconsOutline.settings,
            label: 'Controls',
            color: CUColors.purple,
            onTap: _navigateToControls,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = CUTheme.of(context);

    return CUGestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.xs),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(CUSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(CURadius.md),
              ),
              child: CUIcon(
                icon,
                color: color,
                size: CUSize.iconMd,
              ),
            ),
            SizedBox(height: CUSpacing.xs),
            CUText(
              label,
              style: CUTypography.labelSmall.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardInfo(CUThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CUText(
          'Card Information',
          style: CUTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: CUSpacing.md),
        CUCard(
          padding: EdgeInsets.all(CUSpacing.md),
          child: Column(
            children: [
              _buildInfoRow('Card Type', _currentCard.type.name.toUpperCase()),
              CUDivider(height: CUSpacing.lg),
              _buildInfoRow('Status', _currentCard.status.name.toUpperCase(),
                  valueColor: _getStatusColor(_currentCard.status)),
              CUDivider(height: CUSpacing.lg),
              _buildInfoRow('Network', _currentCard.network.name.toUpperCase()),
              if (_currentCard.isVirtual) ...[
                CUDivider(height: CUSpacing.lg),
                _buildInfoRow('Purpose',
                    _currentCard.metadata?['purpose']?.toString().replaceAll('_', ' ').toUpperCase() ?? 'GENERAL USE'),
              ],
              if (_currentCard.metadata?['rewards_program'] != null) ...[
                CUDivider(height: CUSpacing.lg),
                _buildInfoRow('Rewards',
                    _currentCard.metadata!['rewards_program'].toString().toUpperCase()),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    final theme = CUTheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CUText(
          label,
          style: CUTypography.bodyMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        CUText(
          value,
          style: CUTypography.bodyMedium.copyWith(
            color: valueColor ?? theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSpendingLimits(CUThemeData theme) {
    final limits = _currentCard.limits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CUText(
              'Spending Limits',
              style: CUTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            CUTextButton(
              onPressed: _editLimits,
              child: CUText('Edit'),
            ),
          ],
        ),
        SizedBox(height: CUSpacing.md),
        CUCard(
          padding: EdgeInsets.all(CUSpacing.md),
          child: Column(
            children: [
              _buildLimitRow('Daily Spend', limits.dailySpendLimit),
              SizedBox(height: CUSpacing.md),
              _buildLimitRow('Daily ATM', limits.dailyATMLimit),
              SizedBox(height: CUSpacing.md),
              _buildLimitRow('Per Transaction', limits.singleTransactionLimit),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLimitRow(String label, double amount) {
    final theme = CUTheme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CUText(
          label,
          style: CUTypography.bodyMedium.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        CUText(
          '\$${amount.toStringAsFixed(2)}',
          style: CUTypography.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCardControls(CUThemeData theme) {
    final controls = _currentCard.controls;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CUText(
          'Card Controls',
          style: CUTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: CUSpacing.md),
        CUCard(
          padding: EdgeInsets.all(CUSpacing.xs),
          child: Column(
            children: [
              _buildControlTile(
                'Online Transactions',
                controls.onlineTransactions,
                CUIconsOutline.globe,
              ),
              _buildControlTile(
                'International Transactions',
                controls.internationalTransactions,
                CUIconsOutline.airplane,
              ),
              _buildControlTile(
                'ATM Withdrawals',
                controls.atmWithdrawals,
                CUIconsOutline.banknotes,
              ),
              _buildControlTile(
                'Contactless Payments',
                controls.contactlessPayments,
                CUIconsOutline.wifi,
              ),
              _buildControlTile(
                'Recurring Payments',
                controls.recurringPayments,
                CUIconsOutline.arrowPath,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlTile(String title, bool isEnabled, IconData icon) {
    final theme = CUTheme.of(context);

    return CUListTile(
      leading: CUIcon(
        icon,
        color: isEnabled ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
      ),
      title: CUText(title),
      trailing: CUSwitch(
        value: isEnabled,
        onChanged: null, // Disabled in details view, edit in controls screen
      ),
    );
  }

  Widget _buildRecentTransactions(CUThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CUText(
              'Recent Transactions',
              style: CUTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            CUTextButton(
              onPressed: () {
                // Navigate to transactions with filter for this card
              },
              child: CUText('View All'),
            ),
          ],
        ),
        SizedBox(height: CUSpacing.md),
        CUCard(
          padding: EdgeInsets.all(CUSpacing.md),
          child: Center(
            child: CUText(
              'No recent transactions',
              style: CUTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(CardStatus status) {
    switch (status) {
      case CardStatus.active:
        return CUColors.green;
      case CardStatus.locked:
        return CUColors.orange;
      case CardStatus.suspended:
        return CUColors.red;
      case CardStatus.expired:
        return CUColors.grey;
    }
  }

  void _toggleCardLock() async {
    _lockAnimationController.forward(from: 0);

    final success = await _cardService.toggleCardLock(_currentCard.id);

    if (success && mounted) {
      setState(() {
        _currentCard = _currentCard.copyWith(
          controls: _currentCard.controls.copyWith(
            isLocked: !_currentCard.controls.isLocked,
          ),
        );
      });

      CUSnackBar.show(
        context,
        message: _currentCard.controls.isLocked
            ? 'Card locked successfully'
            : 'Card unlocked successfully',
        type: _currentCard.controls.isLocked ? CUSnackBarType.warning : CUSnackBarType.success,
      );
    }
  }

  void _viewPin() {
    // Show PIN dialog
    showCUDialog(
      context: context,
      builder: (context) {
        final theme = CUTheme.of(context);

        return CUDialog(
          title: 'Card PIN',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CUText('Your PIN is:'),
              SizedBox(height: CUSpacing.md),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: CUSpacing.lg,
                  vertical: CUSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(CURadius.sm),
                ),
                child: CUText(
                  '1234',
                  style: CUTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'GeistMono',
                    letterSpacing: 8,
                  ),
                ),
              ),
              SizedBox(height: CUSpacing.md),
              CUText(
                'Never share your PIN with anyone',
                style: CUTypography.bodySmall.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          actions: [
            CUTextButton(
              onPressed: () => Navigator.pop(context),
              child: CUText('Close'),
            ),
          ],
        );
      },
    );
  }

  void _copyCardDetails() {
    if (_currentCard.isVirtual) {
      // For demo, we'll just show a message
      final details = '''
Card Number: ${_currentCard.displayCardNumber}
Expiry: ${_currentCard.expirationDate}
CVV: ${_currentCard.cvv}
''';

      Clipboard.setData(ClipboardData(text: details));

      CUSnackBar.show(
        context,
        message: 'Card details copied to clipboard',
        type: CUSnackBarType.success,
      );
    }
  }

  void _navigateToControls() {
    Navigator.push(
      context,
      CUPageRoute(
        builder: (context) => CardControlsScreen(card: _currentCard),
      ),
    ).then((updatedCard) {
      if (updatedCard != null && mounted) {
        setState(() {
          _currentCard = updatedCard;
        });
      }
    });
  }

  void _editLimits() {
    // Navigate to controls screen with limits tab selected
    Navigator.push(
      context,
      CUPageRoute(
        builder: (context) => CardControlsScreen(
          card: _currentCard,
          initialTab: 1, // Limits tab
        ),
      ),
    ).then((updatedCard) {
      if (updatedCard != null && mounted) {
        setState(() {
          _currentCard = updatedCard;
        });
      }
    });
  }

  void _deleteVirtualCard() async {
    final confirm = await showCUDialog<bool>(
      context: context,
      builder: (context) {
        return CUDialog(
          title: 'Delete Virtual Card',
          content: CUText(
            'Are you sure you want to delete this virtual card? This action cannot be undone.',
          ),
          actions: [
            CUTextButton(
              onPressed: () => Navigator.pop(context, false),
              child: CUText('Cancel'),
            ),
            CUTextButton(
              onPressed: () => Navigator.pop(context, true),
              variant: CUButtonVariant.destructive,
              child: CUText('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final success = await _cardService.deleteVirtualCard(_currentCard.id);

      if (success && mounted) {
        Navigator.pop(context);
        CUSnackBar.show(
          context,
          message: 'Virtual card deleted',
          type: CUSnackBarType.warning,
        );
      }
    }
  }

  void _showMoreOptions() {
    showCUModalBottomSheet(
      context: context,
      builder: (context) {
        final theme = CUTheme.of(context);

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!_currentCard.isVirtual)
                CUListTile(
                  leading: CUIcon(CUIconsOutline.arrowPath),
                  title: CUText('Replace Card'),
                  onTap: () {
                    Navigator.pop(context);
                    _requestReplacement();
                  },
                ),
              CUListTile(
                leading: CUIcon(CUIconsOutline.exclamationTriangle),
                title: CUText('Report Lost/Stolen'),
                onTap: () {
                  Navigator.pop(context);
                  _reportLostStolen();
                },
              ),
              if (!_currentCard.isPrimary)
                CUListTile(
                  leading: CUIcon(CUIconsOutline.star),
                  title: CUText('Set as Primary'),
                  onTap: () {
                    Navigator.pop(context);
                    _setAsPrimary();
                  },
                ),
              CUDivider(height: 1),
              CUListTile(
                leading: CUIcon(CUIconsOutline.xMark, color: theme.colorScheme.onSurfaceVariant),
                title: CUText('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _requestReplacement() {
    // Show replacement reason dialog
    showCUDialog(
      context: context,
      builder: (context) {
        String reason = 'damaged';

        return StatefulBuilder(
          builder: (context, setState) {
            return CUDialog(
              title: 'Request Card Replacement',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CUText('Why do you need a replacement?'),
                  SizedBox(height: CUSpacing.md),
                  CURadioListTile<String>(
                    title: CUText('Card Damaged'),
                    value: 'damaged',
                    groupValue: reason,
                    onChanged: (value) => setState(() => reason = value!),
                  ),
                  CURadioListTile<String>(
                    title: CUText('Card Not Working'),
                    value: 'not_working',
                    groupValue: reason,
                    onChanged: (value) => setState(() => reason = value!),
                  ),
                  CURadioListTile<String>(
                    title: CUText('Other'),
                    value: 'other',
                    groupValue: reason,
                    onChanged: (value) => setState(() => reason = value!),
                  ),
                ],
              ),
              actions: [
                CUTextButton(
                  onPressed: () => Navigator.pop(context),
                  child: CUText('Cancel'),
                ),
                CUButton(
                  onPressed: () async {
                    Navigator.pop(context);

                    final success = await _cardService.requestCardReplacement(
                      _currentCard.id,
                      reason,
                    );

                    if (success && mounted) {
                      setState(() {
                        _currentCard = _currentCard.copyWith(
                          status: CardStatus.suspended,
                        );
                      });

                      CUSnackBar.show(
                        context,
                        message: 'Replacement request submitted',
                        type: CUSnackBarType.success,
                      );
                    }
                  },
                  child: CUText('Request Replacement'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _reportLostStolen() {
    showCUDialog(
      context: context,
      builder: (context) {
        return CUDialog(
          title: 'Report Card Lost/Stolen',
          content: CUText(
            'This will immediately lock your card and prevent any unauthorized use. A replacement card will be sent to your registered address.',
          ),
          actions: [
            CUTextButton(
              onPressed: () => Navigator.pop(context),
              child: CUText('Cancel'),
            ),
            CUButton(
              onPressed: () async {
                Navigator.pop(context);

                // Lock the card
                await _cardService.toggleCardLock(_currentCard.id);

                // Request replacement
                await _cardService.requestCardReplacement(
                  _currentCard.id,
                  'lost_stolen',
                );

                if (mounted) {
                  setState(() {
                    _currentCard = _currentCard.copyWith(
                      status: CardStatus.suspended,
                      controls: _currentCard.controls.copyWith(isLocked: true),
                    );
                  });

                  CUSnackBar.show(
                    context,
                    message: 'Card reported and locked. Replacement on the way.',
                    type: CUSnackBarType.warning,
                  );
                }
              },
              variant: CUButtonVariant.destructive,
              child: CUText('Report & Lock Card'),
            ),
          ],
        );
      },
    );
  }

  void _setAsPrimary() {
    // In a real app, this would update the primary card status
    CUSnackBar.show(
      context,
      message: 'Card set as primary',
      type: CUSnackBarType.success,
    );
  }
}
