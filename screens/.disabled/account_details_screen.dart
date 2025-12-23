import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import '../services/plaid_service.dart';

class AccountDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> account;

  const AccountDetailsScreen({
    super.key,
    required this.account,
  });

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  final PlaidService _plaidService = PlaidService();
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    try {
      final allTransactions = await _plaidService.getTransactions();
      final accountId = widget.account['account_id'] ?? widget.account['id'];

      if (mounted) {
        setState(() {
          _transactions = allTransactions
              .where((tx) => tx['account_id'] == accountId)
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _exportHistory() {
    // Navigate to export screen with this account's transactions
    Navigator.of(context).pushNamed(
      '/privacy/data-export',
      arguments: {
        'accountId': widget.account['account_id'] ?? widget.account['id'],
        'accountName': widget.account['name'],
        'transactions': _transactions,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final balance = (widget.account['balances']?['current'] ??
                     widget.account['balance'] ??
                     0.0) as num;
    final accountName = widget.account['name'] ?? 'Account';
    final mask = widget.account['mask'] ?? '****';
    final subtype = widget.account['subtype'] ?? 'checking';
    final isDesktop = MediaQuery.of(context).size.width > 800;

    // Different colors for account types
    Color accountColor;
    IconData iconData;
    switch (subtype.toLowerCase()) {
      case 'savings':
        accountColor = theme.colorScheme.success;
        iconData = CupertinoIcons.money_dollar_circle;
        break;
      case 'credit':
        accountColor = theme.colorScheme.info;
        iconData = CupertinoIcons.creditcard;
        break;
      default:
        accountColor = theme.colorScheme.primary;
        iconData = CupertinoIcons.money_dollar;
    }

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
                child: SafeArea(
                  bottom: false,
                  child: Container(
                    padding: EdgeInsets.fromLTRB(
                      CUSpacing.md,
                      CUSpacing.md,
                      CUSpacing.md,
                      CUSpacing.lg
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
                      ],
                    ),
                  ),
                ),
              ),

              // Account Card
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                    CUSpacing.md,
                    0,
                    CUSpacing.md,
                    CUSpacing.lg
                  ),
                  padding: EdgeInsets.all(CUSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accountColor,
                        accountColor.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(CURadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: accountColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CUIcon(
                            iconData,
                            color: CUColors.white,
                            size: CUSize.iconMd,
                          ),
                          SizedBox(width: CUSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CUText(
                                  accountName,
                                  style: CUTypography.bodyLarge.copyWith(
                                    color: CUColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                CUText(
                                  '•••• $mask',
                                  style: CUTypography.bodyMedium.copyWith(
                                    color: CUColors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: CUSpacing.lg),
                      CUText(
                        'Available Balance',
                        style: CUTypography.bodyMedium.copyWith(
                          color: CUColors.white.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: CUSpacing.xs),
                      CUText(
                        '\$${balance.toStringAsFixed(2)}',
                        style: CUTypography.displayMedium.copyWith(
                          color: CUColors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                    CUSpacing.md,
                    0,
                    CUSpacing.md,
                    CUSpacing.xl
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildQuickAction(
                          'Export',
                          CupertinoIcons.arrow_down_doc,
                          _exportHistory,
                        ),
                      ),
                      SizedBox(width: CUSpacing.sm),
                      Expanded(
                        child: Opacity(
                          opacity: 0.4,
                          child: _buildQuickAction(
                            'Transfer',
                            CupertinoIcons.arrow_right,
                            () {},
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Transactions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    CUSpacing.md,
                    0,
                    CUSpacing.md,
                    CUSpacing.md
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CUText(
                        'Transactions',
                        style: CUTypography.headingMedium.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      CUText(
                        '${_transactions.length} total',
                        style: CUTypography.bodyMedium.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Loading State
              if (_isLoading)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(CUSpacing.xxl),
                      child: CUProgressIndicator(),
                    ),
                  ),
                )
              // Transactions List
              else if (_transactions.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(CUSpacing.md),
                    padding: EdgeInsets.all(CUSpacing.xxl),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(CURadius.lg),
                    ),
                    child: Column(
                      children: [
                        CUIcon(
                          CupertinoIcons.doc_text,
                          size: CUSize.iconLg,
                          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                        ),
                        SizedBox(height: CUSpacing.md),
                        CUText(
                          'No transactions yet',
                          style: CUTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: CUSpacing.xs),
                        CUText(
                          'Transactions will appear here',
                          style: CUTypography.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index >= _transactions.length) return null;
                      final transaction = _transactions[index];
                      return _buildTransactionItem(transaction);
                    },
                    childCount: _transactions.length,
                  ),
                ),

              SliverPadding(padding: EdgeInsets.only(bottom: CUSpacing.xxl * 3)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return CUButton.filled(
      onPressed: onTap,
      label: label,
      leadingIcon: icon,
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final theme = CUTheme.of(context);
    final amount = (transaction['amount'] ?? 0.0) as num;
    final isPositive = amount < 0; // Plaid: negative = credit
    final displayAmount = amount.abs().toDouble();
    final merchantName = transaction['merchant_name'] ??
                        transaction['name'] ??
                        'Transaction';
    final date = transaction['date'] ?? '';
    final category = (transaction['category'] as List?)?.firstOrNull ?? 'Other';

    // Generate logo URL for merchants
    final logo = transaction['logo_url'];
    String? logoUrl;
    if (logo != null && logo.isNotEmpty) {
      logoUrl = logo;
    } else if (merchantName.isNotEmpty) {
      final cleanName = merchantName.toLowerCase().replaceAll(' ', '');
      logoUrl = 'https://logo.clearbit.com/$cleanName.com';
    }

    return CUCard(
      margin: EdgeInsets.only(
        left: CUSpacing.md,
        right: CUSpacing.md,
        bottom: CUSpacing.sm
      ),
      onTap: () {
        _showTransactionDetails(transaction);
      },
      child: Row(
        children: [
          Container(
            width: CUSize.iconMd,
            height: CUSize.iconMd,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceContainerLow,
            ),
            child: logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(CURadius.full),
                    child: Image.network(
                      logoUrl,
                      width: CUSize.iconMd,
                      height: CUSize.iconMd,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return CUIcon(
                          CupertinoIcons.building_2_fill,
                          size: CUSize.iconSm,
                          color: theme.colorScheme.onSurfaceVariant,
                        );
                      },
                    ),
                  )
                : CUIcon(
                    CupertinoIcons.building_2_fill,
                    size: CUSize.iconSm,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
          SizedBox(width: CUSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CUText(
                  merchantName,
                  style: CUTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: CUSpacing.xxs),
                CUText(
                  '$category • $date',
                  style: CUTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          CUText(
            '${isPositive ? '+' : ''}\$${displayAmount.toStringAsFixed(2)}',
            style: CUTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isPositive ? CUColors.success : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    final theme = CUTheme.of(context);
    final amount = (transaction['amount'] ?? 0.0) as num;
    final isPositive = amount < 0;
    final displayAmount = amount.abs().toDouble();
    final merchantName = transaction['merchant_name'] ??
                        transaction['name'] ??
                        'Transaction';
    final date = transaction['date'] ?? '';
    final categories = (transaction['category'] as List?)?.join(', ') ?? 'Uncategorized';
    final pending = transaction['pending'] ?? false;

    showCUModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(CUSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(CURadius.xs),
                ),
              ),
            ),
            SizedBox(height: CUSpacing.lg),
            CUText(
              'Transaction Details',
              style: CUTypography.headingMedium.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: CUSpacing.lg),
            _buildDetailRow('Merchant', merchantName),
            _buildDetailRow('Amount', '\$${displayAmount.toStringAsFixed(2)}'),
            _buildDetailRow('Type', isPositive ? 'Credit' : 'Debit'),
            _buildDetailRow('Date', date),
            _buildDetailRow('Category', categories),
            _buildDetailRow('Status', pending ? 'Pending' : 'Posted'),
            SizedBox(height: CUSpacing.lg),
            CUButton.filled(
              onPressed: () => Navigator.of(context).pop(),
              label: 'Close',
              fullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: CUSpacing.md),
      child: Row(
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
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
