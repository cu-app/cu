import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import '../services/banking_service.dart';
import '../widgets/account_card.dart';
import '../widgets/animated_page.dart';

class PlaidDemoScreen extends StatefulWidget {
  const PlaidDemoScreen({super.key});

  @override
  State<PlaidDemoScreen> createState() => _PlaidDemoScreenState();
}

class _PlaidDemoScreenState extends State<PlaidDemoScreen> {
  final BankingService _bankingService = BankingService();
  bool _isLoading = false;
  String _status = 'Ready to connect';
  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _transactions = [];

  // Rich test data configurations
  final List<Map<String, dynamic>> _testConfigurations = [
    {
      'name': 'Simple Test (user_good)',
      'description': 'Basic sandbox test with standard credentials',
      'config': null, // Use simple method
    },
    {
      'name': 'John Doe - Full Portfolio',
      'description':
          'Complete financial profile with checking, savings, credit, and investments',
      'config': {
        'seed': 'john-doe-full-portfolio',
        'override_accounts': [
          {
            'type': 'depository',
            'subtype': 'checking',
            'starting_balance': 2500.00,
            'meta': {
              'name': 'Primary Checking',
              'official_name': 'Chase Total Checking',
              'mask': '0000'
            },
            'identity': {
              'names': ['John Doe'],
              'phone_numbers': [
                {'primary': true, 'type': 'mobile', 'data': '555-0123'}
              ],
              'emails': [
                {
                  'primary': true,
                  'type': 'primary',
                  'data': 'john.doe@email.com'
                }
              ],
              'addresses': [
                {
                  'primary': true,
                  'data': {
                    'city': 'San Francisco',
                    'region': 'CA',
                    'street': '123 Market Street',
                    'postal_code': '94105',
                    'country': 'US'
                  }
                }
              ]
            },
            'transactions': [
              {
                'date_transacted': '2024-01-15',
                'date_posted': '2024-01-15',
                'currency': 'USD',
                'amount': -89.99,
                'description': 'Netflix Subscription'
              },
              {
                'date_transacted': '2024-01-14',
                'date_posted': '2024-01-14',
                'currency': 'USD',
                'amount': -45.67,
                'description': 'Whole Foods Market'
              },
              {
                'date_transacted': '2024-01-13',
                'date_posted': '2024-01-13',
                'currency': 'USD',
                'amount': 3500.00,
                'description': 'Salary Deposit - Tech Corp'
              },
              {
                'date_transacted': '2024-01-12',
                'date_posted': '2024-01-12',
                'currency': 'USD',
                'amount': -120.00,
                'description': 'Electric Bill'
              },
              {
                'date_transacted': '2024-01-11',
                'date_posted': '2024-01-11',
                'currency': 'USD',
                'amount': -25.50,
                'description': 'Uber Ride'
              }
            ]
          },
          {
            'type': 'depository',
            'subtype': 'savings',
            'starting_balance': 15000.00,
            'meta': {
              'name': 'High Yield Savings',
              'official_name': 'Chase Premier Savings',
              'mask': '1111'
            },
            'transactions': [
              {
                'date_transacted': '2024-01-01',
                'date_posted': '2024-01-01',
                'currency': 'USD',
                'amount': 500.00,
                'description': 'Monthly Savings Transfer'
              }
            ]
          },
          {
            'type': 'credit',
            'subtype': 'credit card',
            'starting_balance': -2500.00,
            'meta': {
              'name': 'Chase Freedom Unlimited',
              'official_name': 'Chase Freedom Unlimited Credit Card',
              'mask': '2222',
              'limit': 10000.00
            },
            'liability': {
              'type': 'credit',
              'purchase_apr': 18.24,
              'balance_transfer_apr': 20.24,
              'cash_apr': 25.24,
              'special_apr': 0,
              'last_payment_amount': 300.00,
              'minimum_payment_amount': 75.00
            },
            'transactions': [
              {
                'date_transacted': '2024-01-10',
                'date_posted': '2024-01-10',
                'currency': 'USD',
                'amount': -150.00,
                'description': 'Amazon Purchase'
              },
              {
                'date_transacted': '2024-01-08',
                'date_posted': '2024-01-08',
                'currency': 'USD',
                'amount': -89.99,
                'description': 'Spotify Premium'
              }
            ]
          },
          {
            'type': 'investment',
            'subtype': 'brokerage',
            'starting_balance': 25000.00,
            'meta': {
              'name': 'Investment Account',
              'official_name': 'Chase Investment Services',
              'mask': '3333'
            },
            'holdings': [
              {
                'institution_price': 150.25,
                'institution_price_as_of': '2024-01-15',
                'cost_basis': 145.00,
                'quantity': 100,
                'currency': 'USD',
                'security': {
                  'ticker_symbol': 'AAPL',
                  'name': 'Apple Inc.',
                  'currency': 'USD'
                }
              },
              {
                'institution_price': 3200.00,
                'institution_price_as_of': '2024-01-15',
                'cost_basis': 3100.00,
                'quantity': 5,
                'currency': 'USD',
                'security': {
                  'ticker_symbol': 'GOOGL',
                  'name': 'Alphabet Inc.',
                  'currency': 'USD'
                }
              }
            ],
            'investment_transactions': [
              {
                'date': '2024-01-10',
                'name': 'Buy AAPL',
                'quantity': 10,
                'price': 150.25,
                'fees': 4.95,
                'type': 'buy',
                'currency': 'USD',
                'security': {'ticker_symbol': 'AAPL', 'currency': 'USD'}
              }
            ]
          }
        ]
      }
    },
    {
      'name': 'Sarah Johnson - Business Owner',
      'description':
          'Business banking with multiple accounts and business credit',
      'config': {
        'seed': 'sarah-johnson-business',
        'override_accounts': [
          {
            'type': 'depository',
            'subtype': 'business',
            'starting_balance': 45000.00,
            'meta': {
              'name': 'Business Checking',
              'official_name': 'Chase Business Complete Banking',
              'mask': '4444'
            },
            'identity': {
              'names': ['Sarah Johnson'],
              'emails': [
                {
                  'primary': true,
                  'type': 'primary',
                  'data': 'sarah@techstartup.com'
                }
              ]
            },
            'transactions': [
              {
                'date_transacted': '2024-01-15',
                'date_posted': '2024-01-15',
                'currency': 'USD',
                'amount': 15000.00,
                'description': 'Client Payment - TechCorp'
              },
              {
                'date_transacted': '2024-01-14',
                'date_posted': '2024-01-14',
                'currency': 'USD',
                'amount': -2500.00,
                'description': 'Payroll - Employee Salaries'
              },
              {
                'date_transacted': '2024-01-13',
                'date_posted': '2024-01-13',
                'currency': 'USD',
                'amount': -800.00,
                'description': 'Office Rent'
              }
            ]
          },
          {
            'type': 'credit',
            'subtype': 'credit card',
            'starting_balance': -5000.00,
            'meta': {
              'name': 'Business Credit Card',
              'official_name': 'Chase Ink Business Preferred',
              'mask': '5555',
              'limit': 25000.00
            },
            'liability': {
              'type': 'credit',
              'purchase_apr': 16.24,
              'balance_transfer_apr': 18.24,
              'cash_apr': 22.24,
              'special_apr': 0,
              'last_payment_amount': 500.00,
              'minimum_payment_amount': 150.00
            }
          }
        ]
      }
    },
    {
      'name': 'Mike Chen - Student',
      'description': 'Student with checking, savings, and student loans',
      'config': {
        'seed': 'mike-chen-student',
        'override_accounts': [
          {
            'type': 'depository',
            'subtype': 'checking',
            'starting_balance': 800.00,
            'meta': {
              'name': 'Student Checking',
              'official_name': 'Chase College Checking',
              'mask': '6666'
            },
            'identity': {
              'names': ['Mike Chen'],
              'emails': [
                {
                  'primary': true,
                  'type': 'primary',
                  'data': 'mike.chen@university.edu'
                }
              ]
            },
            'transactions': [
              {
                'date_transacted': '2024-01-15',
                'date_posted': '2024-01-15',
                'currency': 'USD',
                'amount': -15.99,
                'description': 'Spotify Student'
              },
              {
                'date_transacted': '2024-01-14',
                'date_posted': '2024-01-14',
                'currency': 'USD',
                'amount': -8.50,
                'description': 'Campus Coffee'
              },
              {
                'date_transacted': '2024-01-13',
                'date_posted': '2024-01-13',
                'currency': 'USD',
                'amount': 1200.00,
                'description': 'Part-time Job Paycheck'
              }
            ]
          },
          {
            'type': 'loan',
            'subtype': 'student',
            'starting_balance': -25000.00,
            'meta': {
              'name': 'Federal Student Loan',
              'official_name': 'Direct Subsidized Loan'
            },
            'liability': {
              'type': 'student',
              'origination_date': '2022-08-15',
              'principal': 25000.00,
              'nominal_apr': 4.99,
              'loan_name': 'Federal Direct Student Loan',
              'repayment_model': {
                'type': 'standard',
                'non_repayment_months': 36,
                'repayment_months': 120
              }
            }
          }
        ]
      }
    }
  ];

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CUAppBar(
        title: const Text('Plaid Demo'),
        backgroundColor: CUColors.transparent,
        leading: CUIconButton(
          icon: CUIcon(CUIcons.arrowBack),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedPage(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(CUSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              CustomAnimatedWidget(
                delay: const Duration(milliseconds: 100),
                child: _buildHeader(theme),
              ),
              SizedBox(height: CUSpacing.xl),

              // Test Configurations
              CustomAnimatedWidget(
                delay: const Duration(milliseconds: 200),
                child: _buildTestConfigurations(theme),
              ),
              SizedBox(height: CUSpacing.xl),

              // Status
              CustomAnimatedWidget(
                delay: const Duration(milliseconds: 300),
                child: _buildStatus(theme),
              ),
              SizedBox(height: CUSpacing.lg),

              // Accounts
              if (_accounts.isNotEmpty)
                CustomAnimatedWidget(
                  delay: const Duration(milliseconds: 400),
                  child: _buildAccounts(theme),
                ),

              // Transactions
              if (_transactions.isNotEmpty)
                CustomAnimatedWidget(
                  delay: const Duration(milliseconds: 500),
                  child: _buildTransactions(theme),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(CUThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plaid Sandbox Demo',
          style: CUTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: CUSpacing.xs),
        Text(
          'Connect with rich test data from Plaid\'s sandbox environment',
          style: CUTypography.bodyLarge.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTestConfigurations(CUThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Configurations',
          style: CUTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: CUSpacing.md),
        ..._testConfigurations.map((config) => _buildConfigCard(config, theme)),
      ],
    );
  }

  Widget _buildConfigCard(Map<String, dynamic> config, CUThemeData theme) {
    return CUCard(
      margin: EdgeInsets.only(bottom: CUSpacing.md),
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config['name'],
                        style: CUTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: CUSpacing.xxs),
                      Text(
                        config['description'],
                        style: CUTypography.bodyMedium.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: CUSpacing.md),
                CUButton(
                  onPressed:
                      _isLoading ? null : () => _connectWithConfig(config),
                  child: _isLoading
                      ? SizedBox(
                          width: CUSize.iconSm,
                          height: CUSize.iconSm,
                          child: CUProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Connect'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(CUThemeData theme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(CUSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(CURadius.md),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: CUTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: CUSpacing.xs),
          Text(
            _status,
            style: CUTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccounts(CUThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Connected Accounts',
          style: CUTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: CUSpacing.md),
        ..._accounts.map((account) => _buildAccountCard(account, theme)),
      ],
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account, CUThemeData theme) {
    final balance = account['balances']?['current'] ?? 0.0;
    final isNegative = balance < 0;

    return CUCard(
      margin: EdgeInsets.only(bottom: CUSpacing.sm),
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Row(
          children: [
            Container(
              width: CUSize.iconLg,
              height: CUSize.iconLg,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(CURadius.md),
              ),
              child: CUIcon(
                _getAccountIcon(account['type']),
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: CUSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account['name'] ?? 'Unknown Account',
                    style: CUTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${account['type']} • ${account['subtype']}',
                    style: CUTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${balance.abs().toStringAsFixed(2)}',
                  style: CUTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isNegative
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                  ),
                ),
                if (account['mask'] != null)
                  Text(
                    '•••• ${account['mask']}',
                    style: CUTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactions(CUThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Transactions',
          style: CUTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: CUSpacing.md),
        ..._transactions
            .take(10)
            .map((transaction) => _buildTransactionCard(transaction, theme)),
      ],
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction, CUThemeData theme) {
    final amount = transaction['amount'] ?? 0.0;
    final isNegative = amount < 0;

    return CUCard(
      margin: EdgeInsets.only(bottom: CUSpacing.xs),
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Row(
          children: [
            Container(
              width: CUSize.iconMd,
              height: CUSize.iconMd,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(CURadius.sm),
              ),
              child: CUIcon(
                _getTransactionIcon(transaction['description']),
                size: CUSize.iconSm,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(width: CUSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction['description'] ?? 'Unknown Transaction',
                    style: CUTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    _formatDate(transaction['date']),
                    style: CUTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${isNegative ? '-' : '+'}\$${amount.abs().toStringAsFixed(2)}',
              style: CUTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isNegative
                    ? theme.colorScheme.error
                    : CUColors.success,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getAccountIcon(String? type) {
    switch (type) {
      case 'depository':
        return CUIcons.accountBalance;
      case 'credit':
        return CUIcons.creditCard;
      case 'loan':
        return CUIcons.home;
      case 'investment':
        return CUIcons.trendingUp;
      default:
        return CUIcons.accountBalanceWallet;
    }
  }

  IconData _getTransactionIcon(String? description) {
    if (description == null) return CUIcons.receipt;

    final desc = description.toLowerCase();
    if (desc.contains('netflix') || desc.contains('spotify')) {
      return CUIcons.playCircle;
    }
    if (desc.contains('amazon') || desc.contains('purchase')) {
      return CUIcons.shoppingBag;
    }
    if (desc.contains('salary') || desc.contains('paycheck')) return CUIcons.work;
    if (desc.contains('uber') || desc.contains('ride')) {
      return CUIcons.directionsCar;
    }
    if (desc.contains('bill') || desc.contains('electric')) {
      return CUIcons.receiptLong;
    }
    if (desc.contains('food') || desc.contains('coffee')) {
      return CUIcons.restaurant;
    }

    return CUIcons.receipt;
  }

  String _formatDate(String? date) {
    if (date == null) return '';
    try {
      final parsed = DateTime.parse(date);
      return '${parsed.month}/${parsed.day}/${parsed.year}';
    } catch (e) {
      return date;
    }
  }

  Future<void> _connectWithConfig(Map<String, dynamic> config) async {
    setState(() {
      _isLoading = true;
      _status = 'Connecting with ${config['name']}...';
    });

    try {
      // Haptic feedback
      SystemChannels.platform.invokeMethod('HapticFeedback.lightImpact');

      // Create public token - use simple method if no config
      final publicToken = config['config'] == null
          ? await _bankingService.createSimpleSandboxToken()
          : await _bankingService.createSandboxPublicToken(
              config: config['config'],
            );

      setState(() {
        _status = 'Exchanging token...';
      });

      // Exchange for access token
      await _bankingService.exchangePublicToken(publicToken);

      setState(() {
        _status = 'Fetching accounts...';
      });

      // Get accounts
      final accounts = await _bankingService.getAccounts();

      setState(() {
        _status = 'Creating test transactions...';
      });

      // Create some test transactions for the sandbox item
      await _bankingService.createTestTransactions();

      setState(() {
        _status = 'Fetching transactions...';
      });

      // Get transactions (with error handling for PRODUCT_NOT_READY)
      List<Map<String, dynamic>> transactions = [];
      try {
        transactions = await _bankingService.getTransactions();
      } catch (e) {
        if (e.toString().contains('PRODUCT_NOT_READY')) {
          setState(() {
            _status =
                'Transactions not ready yet (normal for new sandbox items)';
          });
          // Wait a bit and try again
          await Future.delayed(const Duration(seconds: 2));
          try {
            transactions = await _bankingService.getTransactions();
          } catch (e2) {
            debugPrint('Transactions still not ready: $e2');
            transactions = [];
          }
        } else {
          rethrow;
        }
      }

      setState(() {
        _isLoading = false;
        _status = 'Successfully connected!';
        _accounts = accounts;
        _transactions = transactions;
      });

      // Success haptic
      SystemChannels.platform.invokeMethod('HapticFeedback.mediumImpact');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = 'Error: ${e.toString()}';
      });

      // Error haptic
      SystemChannels.platform.invokeMethod('HapticFeedback.heavyImpact');
    }
  }
}
