import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/plaid_service.dart';
import '../services/supabase_realtime_service.dart';
import '../helpers/balance_helper.dart';
import '../services/auth_service.dart';

class SimpleDashboardScreen extends StatefulWidget {
  final ScrollController? scrollController;
  final Function(Map<String, dynamic>)? onAccountSelected;
  final Function(Map<String, dynamic>)? onTransactionSelected;

  const SimpleDashboardScreen({
    super.key,
    this.scrollController,
    this.onAccountSelected,
    this.onTransactionSelected,
  });

  @override
  State<SimpleDashboardScreen> createState() => _SimpleDashboardScreenState();
}

class _SimpleDashboardScreenState extends State<SimpleDashboardScreen> {
  final PlaidService _plaidService = PlaidService();
  final SupabaseRealtimeService _realtimeService = SupabaseRealtimeService();
  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;

  StreamSubscription? _accountsSubscription;
  StreamSubscription? _transactionsSubscription;

  @override
  void initState() {
    super.initState();
    _setupRealtimeListeners();
    _loadPlaidData();
  }

  @override
  void dispose() {
    _accountsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    super.dispose();
  }

  void _setupRealtimeListeners() {
    // Listen to real-time account updates
    _accountsSubscription = _realtimeService.accountsStream.listen((accounts) {
      if (mounted) {
        setState(() {
          _accounts = accounts;
        });
        debugPrint('Real-time: Received ${accounts.length} accounts');
      }
    });

    // Listen to real-time transaction updates
    _transactionsSubscription = _realtimeService.transactionsStream.listen((transactions) {
      if (mounted) {
        setState(() {
          _transactions = transactions;
        });
        debugPrint('Real-time: Received ${transactions.length} transactions');
      }
    });
  }

  Future<void> _loadPlaidData() async {
    try {
      final accounts = await _plaidService.getAccounts();
      final transactions = await _plaidService.getTransactions();

      // Sync Plaid data to Supabase for real-time broadcasting
      await _realtimeService.syncPlaidToSupabase(
        accounts: accounts,
        transactions: transactions,
      );

      if (mounted) {
        setState(() {
          _accounts = accounts;
          _transactions = transactions;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading Plaid data: $e');
      // Load mock data when Plaid fails
      if (mounted) {
        setState(() {
          _accounts = [
            {
              'account_id': '1',
              'id': '1',
              'name': 'Cash Account',
              'subtype': 'checking',
              'type': 'depository',
              'mask': '0929',
              'balance': 10.34,
              'available': 10.34,
              'balances': {'current': 10.34},
              'currency': 'USD',
              'institution': 'Mock Bank',
            },
            {
              'account_id': '2',
              'id': '2',
              'name': 'Savings',
              'subtype': 'savings',
              'type': 'depository',
              'mask': '8765',
              'balance': 2.84,
              'available': 2.84,
              'balances': {'current': 2.84},
              'currency': 'USD',
              'institution': 'Mock Bank',
            },
            {
              'account_id': '3',
              'id': '3',
              'name': 'Credit Card',
              'subtype': 'credit',
              'type': 'credit',
              'mask': '2341',
              'balance': 500.00,
              'available': 500.00,
              'balances': {'current': 500.00},
              'currency': 'USD',
              'institution': 'Mock Bank',
            },
          ];
          _transactions = [
            {
              'transaction_id': '1',
              'id': '1',
              'account_id': '1',
              'name': 'Whole Foods',
              'merchant_name': 'Whole Foods Market',
              'amount': 127.43,
              'date': '2024-11-04',
              'category': ['Food', 'Groceries'],
              'type': 'transaction',
              'pending': false,
            },
            {
              'transaction_id': '2',
              'id': '2',
              'account_id': '1',
              'name': 'Apple',
              'merchant_name': 'Apple',
              'amount': 999.00,
              'date': '2024-11-03',
              'category': ['Shopping', 'Electronics'],
              'type': 'transaction',
              'pending': false,
            },
          ];
          _isLoading = false;

          // Try to sync mock data to Supabase too
          _realtimeService.syncPlaidToSupabase(
            accounts: _accounts,
            transactions: _transactions,
          ).catchError((e) {
            debugPrint('Failed to sync mock data: $e');
          });
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$${formatter.format(amount)}';
  }

  Future<Map<String, dynamic>?> _getUserProfile() async {
    try {
      final authService = AuthService();
      return await authService.getUserProfile();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      return null;
    }
  }

  Widget _buildInitialsAvatar(String? firstName, String? lastName, CUThemeData theme) {
    String initials = '';
    if (firstName != null && firstName.isNotEmpty) {
      initials += firstName[0].toUpperCase();
    }
    if (lastName != null && lastName.isNotEmpty) {
      initials += lastName[0].toUpperCase();
    }
    if (initials.isEmpty) {
      initials = 'M';
    }

    return Container(
      width: CUSize.iconLarge,
      height: CUSize.iconLarge,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: CUTypography.titleMedium.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final now = DateTime.now();
    final timeStr = '${now.hour % 12 == 0 ? 12 : now.hour % 12}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}';
    final dateStr = _formatDate(now);

    // Calculate total balance from all accounts using helper
    final balanceHelper = BalanceHelper();
    final totalBalance = balanceHelper.calculateTotalBalance(_accounts);

    return Container(
      color: theme.colorScheme.background,
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          // User Avatar Header
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: FutureBuilder<Map<String, dynamic>?>(
                future: _getUserProfile(),
                builder: (context, snapshot) {
                  final profile = snapshot.data;
                  final avatarUrl = profile?['avatar_url'] as String?;
                  final firstName = profile?['first_name'] as String? ?? 'Member';
                  final lastName = profile?['last_name'] as String?;
                  final displayName = lastName != null ? '$firstName $lastName' : firstName;

                  return Container(
                    margin: EdgeInsets.fromLTRB(
                      CUSpacing.lg,
                      CUSpacing.lg,
                      CUSpacing.lg,
                      CUSpacing.md,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // TODO: Navigate to profile/avatar edit
                          },
                          child: Container(
                            width: CUSize.iconLarge,
                            height: CUSize.iconLarge,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.shadow.withOpacity(0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: avatarUrl != null && avatarUrl.isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      avatarUrl,
                                      width: CUSize.iconLarge,
                                      height: CUSize.iconLarge,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return _buildInitialsAvatar(firstName, lastName, theme);
                                      },
                                    ),
                                  )
                                : _buildInitialsAvatar(firstName, lastName, theme),
                          ),
                        ),
                        SizedBox(width: CUSpacing.sm),
                        Expanded(
                          child: Text(
                            displayName,
                            style: CUTypography.titleLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onBackground,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Total Balance Card
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.fromLTRB(
                CUSpacing.lg,
                0,
                CUSpacing.lg,
                CUSpacing.xl,
              ),
              padding: EdgeInsets.all(CUSpacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(CURadius.lg),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Balance',
                    style: CUTypography.bodyLarge.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: CUSpacing.sm),
                  _isLoading
                      ? Container(
                          width: 200,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(CURadius.sm),
                          ),
                        )
                      : Text(
                          _formatCurrency(totalBalance),
                          style: CUTypography.displayLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                            height: 1.0,
                            letterSpacing: -1.5,
                          ),
                        ),
                  SizedBox(height: CUSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: _buildBalanceActionButton(
                          'Transfer',
                          CUIcons.arrowForward,
                          true,
                          theme,
                        ),
                      ),
                      SizedBox(width: CUSpacing.sm),
                      Expanded(
                        child: _buildBalanceActionButton(
                          'Accounts',
                          CUIcons.accountBalance,
                          false,
                          theme,
                        ),
                      ),
                    ],
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
                  padding: EdgeInsets.all(CUSpacing.xxl * 2),
                  child: CUCircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            )
          else ...[
            // All Accounts Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  CUSpacing.lg,
                  0,
                  CUSpacing.lg,
                  CUSpacing.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All Accounts',
                      style: CUTypography.headlineMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                    Text(
                      'Manage',
                      style: CUTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onBackground,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // All Accounts List
            if (_accounts.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  CUSpacing.lg,
                  0,
                  CUSpacing.lg,
                  0,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final account = _accounts[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: CUSpacing.md),
                        child: _buildSecondaryCard(account, theme),
                      );
                    },
                    childCount: _accounts.length,
                  ),
                ),
              ),

            // Recent Activity Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  CUSpacing.lg,
                  CUSpacing.xxl,
                  CUSpacing.lg,
                  CUSpacing.md,
                ),
                child: Text(
                  'Recent Activity',
                  style: CUTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onBackground,
                  ),
                ),
              ),
            ),

            // Recent Activity List
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= _transactions.length) return null;
                  final transaction = _transactions[index];

                  // Calculate running balance (balance before this transaction)
                  double runningBalance = 0.0;
                  final accountId = transaction['account_id'];
                  final account = _accounts.firstWhere(
                    (acc) => acc['account_id'] == accountId || acc['id'] == accountId,
                    orElse: () => {},
                  );

                  if (account.isNotEmpty) {
                    runningBalance = ((account['balances']?['current'] ?? 0.0) as num).toDouble();
                    // Add back all previous transactions to get balance before this one
                    for (int i = 0; i <= index; i++) {
                      if (_transactions[i]['account_id'] == accountId) {
                        final amt = (_transactions[i]['amount'] ?? 0.0) as num;
                        runningBalance += amt.toDouble();
                      }
                    }
                  }

                  return _buildActivityItem(transaction, runningBalance, theme);
                },
                childCount: _transactions.length,
              ),
            ),

            SliverPadding(padding: EdgeInsets.only(bottom: CUSpacing.xxl * 5)),
          ],
        ],
      ),
    );
  }

  Widget _buildBalanceActionButton(String label, IconData icon, bool isPrimary, CUThemeData theme) {
    return Opacity(
      opacity: 0.4,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: CUSpacing.md),
        decoration: BoxDecoration(
          color: isPrimary ? theme.colorScheme.onSurface : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(CURadius.full),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CUIcon(
              icon,
              size: CUSize.iconSmall,
              color: isPrimary ? theme.colorScheme.surface : theme.colorScheme.onSurface,
            ),
            SizedBox(width: CUSpacing.xs),
            Text(
              label,
              style: CUTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isPrimary ? theme.colorScheme.surface : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(Map<String, dynamic> account, CUThemeData theme) {
    final balance = (account['balances']?['current'] ?? 0.0) as num;
    final mask = account['mask'] ?? '0000';
    final name = account['name'] ?? 'Cash Account';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(CURadius.lg),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CURadius.lg),
        child: Column(
          children: [
            // Colored card header
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    CUColors.lime,
                    CUColors.limeAccent,
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: CUSpacing.lg,
                    left: CUSpacing.lg,
                    child: Row(
                      children: [
                        CUIcon(
                          CUIcons.creditCard,
                          size: CUSize.iconSmall,
                          color: theme.colorScheme.onSurface,
                        ),
                        SizedBox(width: CUSpacing.xs),
                        Text(
                          '•• $mask',
                          style: CUTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Card artwork placeholder
                  Positioned(
                    right: CUSpacing.lg,
                    bottom: CUSpacing.lg,
                    child: Container(
                      width: 80,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(CURadius.sm),
                        color: theme.colorScheme.shadow.withOpacity(0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // White body
            Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(CURadius.lg),
                  bottomRight: Radius.circular(CURadius.lg),
                ),
              ),
              padding: EdgeInsets.all(CUSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name balance',
                    style: CUTypography.bodyLarge.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: CUSpacing.xs),
                  Text(
                    _formatCurrency(balance.toDouble()),
                    style: CUTypography.displayLarge.copyWith(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      height: 1.0,
                      letterSpacing: -2,
                    ),
                  ),
                  SizedBox(height: CUSpacing.sm),
                  Text(
                    'Account ••${mask.substring(mask.length - 4)} › ',
                    style: CUTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: CUSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton('Add money', CUIcons.add, theme),
                      ),
                      SizedBox(width: CUSpacing.sm),
                      Expanded(
                        child: _buildActionButton('Withdraw', CUIcons.arrowUpward, theme),
                      ),
                    ],
                  ),
                  SizedBox(height: CUSpacing.md),
                  Container(
                    padding: EdgeInsets.all(CUSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.background,
                      borderRadius: BorderRadius.circular(CURadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Earnings',
                          style: CUTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          '\$0 in Nov',
                          style: CUTypography.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryCard(Map<String, dynamic> account, CUThemeData theme) {
    final currentBalance = (account['balances']?['current'] ?? 0.0) as num;
    final availableBalance = (account['balances']?['available'] ?? account['available'] ?? currentBalance) as num;
    final name = account['name'] ?? 'Account';
    final subtype = account['subtype'] ?? 'checking';

    // Different colors for account types
    Color cardColor;
    IconData iconData;
    switch (subtype.toLowerCase()) {
      case 'savings':
        cardColor = theme.colorScheme.success;
        iconData = CUIcons.savings;
        break;
      case 'credit':
        cardColor = theme.colorScheme.info;
        iconData = CUIcons.creditCard;
        break;
      default:
        cardColor = theme.colorScheme.primary;
        iconData = CUIcons.accountBalanceWallet;
    }

    return GestureDetector(
      onTap: () {
        if (widget.onAccountSelected != null) {
          widget.onAccountSelected!(account);
        }
        // Navigate to account details screen
        Navigator.of(context).pushNamed(
          '/account-details',
          arguments: account,
        );
        debugPrint('Account tapped: ${account['name']}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(CURadius.lg),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(CUSpacing.lg),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: CUTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: CUSpacing.xs),
                  Text(
                    _formatCurrency(currentBalance.toDouble()),
                    style: CUTypography.displaySmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      height: 1.0,
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: CUSpacing.xxs),
                  Text(
                    'Current Balance',
                    style: CUTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: CUSpacing.xs),
                  Text(
                    '${_formatCurrency(availableBalance.toDouble())} Available',
                    style: CUTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: CUSize.iconLarge + CUSpacing.xs,
              height: CUSize.iconLarge + CUSpacing.xs,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cardColor.withOpacity(0.1),
              ),
              child: CUIcon(
                iconData,
                size: CUSize.iconMedium,
                color: cardColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, CUThemeData theme) {
    return GestureDetector(
      onTap: () {
        // Handle action
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: CUSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.background,
          borderRadius: BorderRadius.circular(CURadius.md),
        ),
        child: Center(
          child: Text(
            label,
            style: CUTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> transaction, double previousBalance, CUThemeData theme) {
    final amount = (transaction['amount'] ?? 0.0) as num;
    final isPositive = amount < 0; // Plaid: negative = credit
    final displayAmount = amount.abs().toDouble();
    final merchantName = transaction['merchant_name'] ?? transaction['name'] ?? 'Activity';
    final date = transaction['date'] ?? '';
    final category = (transaction['category'] as List?)?.firstOrNull ?? 'Other';

    // Generate logo URL for merchants
    final logo = transaction['logo_url'];
    String? logoUrl;
    if (logo != null && logo.isNotEmpty) {
      logoUrl = logo;
    } else if (merchantName.isNotEmpty) {
      // Generate clearbit logo URL
      final cleanName = merchantName.toLowerCase().replaceAll(' ', '');
      logoUrl = 'https://logo.clearbit.com/$cleanName.com';
    }

    return GestureDetector(
      onTap: () {
        if (widget.onTransactionSelected != null) {
          widget.onTransactionSelected!(transaction);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            bottom: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: CUSpacing.lg,
          vertical: CUSpacing.md,
        ),
        child: Row(
        children: [
          Container(
            width: CUSize.iconMedium + CUSpacing.sm,
            height: CUSize.iconMedium + CUSpacing.sm,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceVariant,
            ),
            child: logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(CURadius.full),
                    child: Image.network(
                      logoUrl,
                      width: CUSize.iconMedium + CUSpacing.sm,
                      height: CUSize.iconMedium + CUSpacing.sm,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return CUIcon(
                          CUIcons.store,
                          size: CUSize.iconSmall,
                          color: theme.colorScheme.onSurfaceVariant,
                        );
                      },
                    ),
                  )
                : CUIcon(
                    CUIcons.store,
                    size: CUSize.iconSmall,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
          ),
          SizedBox(width: CUSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  merchantName,
                  style: CUTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: CUSpacing.xxs),
                Text(
                  '$category • $date',
                  style: CUTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: CUSpacing.xxs),
                Text(
                  'Previous balance: ${_formatCurrency(previousBalance)}',
                  style: CUTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : '-'}${_formatCurrency(displayAmount)}',
            style: CUTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: isPositive ? theme.colorScheme.success : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
