import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:provider/provider.dart';
import '../services/accessibility_service.dart';
import '../services/auth_service.dart';
import '../services/security_service.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class AccountDetailScreen extends StatefulWidget {
  final Map<String, dynamic> account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  final AuthService _authService = AuthService();
  final SecurityService _securityService = SecurityService();
  bool _isAuthenticated = false;
  bool _isLoading = false;
  bool _showSensitiveData = false;

  @override
  void initState() {
    super.initState();
    _checkSecuritySettings();
  }

  Future<void> _checkSecuritySettings() async {
    final settings = await _securityService.getSecuritySettings();
    if (settings.biometricEnabled && settings.biometricForSensitiveData) {
      // Require authentication for sensitive data
      setState(() {
        _showSensitiveData = false;
      });
    } else {
      // No biometric required, show all data
      setState(() {
        _showSensitiveData = true;
        _isAuthenticated = true;
      });
    }
  }

  Future<void> _authenticateForSensitiveData() async {
    setState(() => _isLoading = true);

    final authenticated = await _authService.authenticateForOperation(
      'Authenticate to view account details',
    );

    setState(() {
      _isLoading = false;
      _isAuthenticated = authenticated;
      _showSensitiveData = authenticated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;
    final theme = CUTheme.of(context);

    debugPrint('Building account detail screen for: ${account['name']}');
    debugPrint('Account data: $account');

    final balance = account['balance'] ?? 0.0;
    final name = account['name'] ?? 'Account';
    final type = account['type'] ?? 'checking';
    final lastFour = account['lastFour'] ?? account['mask'] ?? '****';
    final accountId = account['account_id'] ?? account['id'] ?? '${name}_$lastFour';

    final accessibilityService = context.watch<AccessibilityService>();
    final isDarkMode = theme.isDark;
    final balanceColor = accessibilityService.getBalanceColor(balance, isDarkMode: isDarkMode);

    return CUScaffold(
      appBar: CUAppBar(
        title: name,
        backgroundColor: theme.colorScheme.surface,
      ),
      body: CUListView(
        padding: EdgeInsets.all(CUSpacing.md),
        children: [
          // Account Card
          Container(
                padding: EdgeInsets.all(CUSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(CURadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: CUSize.iconLg,
                          height: CUSize.iconLg,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(CURadius.md),
                          ),
                          child: CUIcon(
                            _getAccountIcon(type),
                            color: theme.colorScheme.onSurfaceVariant,
                            size: CUSize.iconMd,
                          ),
                        ),
                        SizedBox(width: CUSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CUText(
                                name,
                                style: CUTypography.headingSmall.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              CUText(
                                '${type[0].toUpperCase()}${type.substring(1)} •••• $lastFour',
                                style: CUTypography.bodyMedium.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: CUSpacing.xl),
                    CUText(
                      'Current Balance',
                      style: CUTypography.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: CUSpacing.xs),
                    if (_showSensitiveData)
                      CUText(
                        '\$${_formatAmount(balance)}',
                        style: CUTypography.displaySmall.copyWith(
                          color: accessibilityService.useColorIndicators
                              ? balanceColor
                              : theme.colorScheme.onSurface,
                        ),
                        semanticsLabel: accessibilityService.getBalanceSemanticLabel(
                          balance,
                          _formatAmount(balance),
                        ),
                      )
                    else
                      Column(
                        children: [
                          CUText(
                            '••••••••',
                            style: CUTypography.displaySmall.copyWith(
                              letterSpacing: 4,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: CUSpacing.md),
                          if (_isLoading)
                            CUProgressIndicator()
                          else
                            CUButton.filled(
                              onPressed: _authenticateForSensitiveData,
                              label: 'Authenticate to View',
                              leadingIcon: CupertinoIcons.lock_fill,
                            ),
                        ],
                      ),
                  ],
                ),
          ),
          SizedBox(height: CUSpacing.xl),

          // Quick Actions
          CUText(
            'Quick Actions',
            style: CUTypography.headingSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: CUSpacing.md),
          _buildActionButton(
            context,
            icon: CupertinoIcons.arrow_right_arrow_left,
            label: 'Transfer',
            onPressed: () {
              // Navigate to transfer screen
            },
          ),
          SizedBox(height: CUSpacing.sm),
          _buildActionButton(
            context,
            icon: CupertinoIcons.money_dollar,
            label: 'Pay Bill',
            onPressed: () {
              // Navigate to bill pay
            },
          ),
          SizedBox(height: CUSpacing.sm),
          _buildActionButton(
            context,
            icon: CupertinoIcons.clock,
            label: 'Transaction History',
            onPressed: () {
              // Show transaction history
            },
          ),

          SizedBox(height: CUSpacing.xl),

          // Recent Transactions
          if (_showSensitiveData) ...[
            CUText(
              'Recent Transactions',
              style: CUTypography.headingSmall.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: CUSpacing.md),
            ..._buildDemoTransactions(context, accessibilityService, isDarkMode),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: CUButton.outlined(
        onPressed: onPressed,
        label: label,
        leadingIcon: icon,
      ),
    );
  }

  List<Widget> _buildDemoTransactions(
    BuildContext context,
    AccessibilityService accessibilityService,
    bool isDarkMode,
  ) {
    final theme = CUTheme.of(context);
    final transactions = [
      {'merchant': 'Coffee Shop', 'amount': -5.25, 'date': 'Today'},
      {'merchant': 'Salary Deposit', 'amount': 3500.00, 'date': 'Yesterday'},
      {'merchant': 'Electric Company', 'amount': -125.00, 'date': '2 days ago'},
      {'merchant': 'Online Transfer', 'amount': -200.00, 'date': '3 days ago'},
    ];

    return transactions.map((transaction) {
      final amount = transaction['amount'] as double;
      final amountColor = accessibilityService.getBalanceColor(amount, isDarkMode: isDarkMode);

      return CUCard(
        margin: EdgeInsets.only(bottom: CUSpacing.xs),
        child: CUListTile(
          leading: Container(
            width: CUSize.iconMd,
            height: CUSize.iconMd,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
            ),
            child: CUIcon(
              amount > 0 ? CupertinoIcons.add : CupertinoIcons.minus,
              color: theme.colorScheme.onSurfaceVariant,
              size: CUSize.iconSm,
            ),
          ),
          title: transaction['merchant'] as String,
          subtitle: transaction['date'] as String,
          trailing: CUText(
            '${amount > 0 ? '+' : ''}\$${amount.abs().toStringAsFixed(2)}',
            style: CUTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: accessibilityService.useColorIndicators
                  ? amountColor
                  : theme.colorScheme.onSurface,
            ),
            semanticsLabel: '${amount > 0 ? 'Credit' : 'Debit'} of ${amount.abs().toStringAsFixed(2)} dollars',
          ),
        ),
      );
    }).toList();
  }

  IconData _getAccountIcon(String type) {
    switch (type.toLowerCase()) {
      case 'savings':
        return CupertinoIcons.money_dollar_circle;
      case 'credit':
        return CupertinoIcons.creditcard;
      case 'investment':
        return CupertinoIcons.chart_bar_alt_fill;
      default:
        return CupertinoIcons.money_dollar;
    }
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(2);
    }
  }
}
