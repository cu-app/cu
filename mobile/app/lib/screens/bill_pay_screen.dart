import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import '../services/bill_pay_service.dart';
import '../services/banking_service.dart';
import '../services/auth_service.dart';

class BillPayScreen extends StatefulWidget {
  const BillPayScreen({super.key});

  @override
  State<BillPayScreen> createState() => _BillPayScreenState();
}

class _BillPayScreenState extends State<BillPayScreen> with SingleTickerProviderStateMixin {
  final BillPayService _billPayService = BillPayService();
  final BankingService _bankingService = BankingService();
  final AuthService _authService = AuthService();

  List<Map<String, dynamic>> _payees = [];
  List<Map<String, dynamic>> _scheduledPayments = [];
  List<Map<String, dynamic>> _recentPayments = [];
  List<Map<String, dynamic>> _accounts = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBillPayData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBillPayData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load payees
      final payees = await _billPayService.getUserPayees();

      // Load scheduled payments
      final scheduledPayments = await _billPayService.getScheduledPayments();

      // Load recent payments (mock data for now)
      final recentPayments = [
        {'name': 'Netflix', 'amount': 15.99, 'date': DateTime.now().subtract(const Duration(days: 2))},
        {'name': 'Spotify', 'amount': 9.99, 'date': DateTime.now().subtract(const Duration(days: 5))},
        {'name': 'Electric Bill', 'amount': 125.50, 'date': DateTime.now().subtract(const Duration(days: 7))},
      ];

      // Load user accounts
      final accounts = await _bankingService.getUserAccounts();

      setState(() {
        _payees = payees;
        _scheduledPayments = scheduledPayments;
        _recentPayments = recentPayments;
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      appBar: CUAppBar(
        title: 'Payments',
        leading: CUIconButton(
          icon: CUIcon(CUIcons.arrowLeft),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          CUIconButton(
            icon: CUIcon(CUIcons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CULoadingIndicator())
          : Column(
              children: [
                _buildPaymentTabs(context),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Send tab
                      SingleChildScrollView(
                        padding: EdgeInsets.all(CUSpacing.lg),
                        child: Column(
                          children: [
                            if (_payees.isNotEmpty) ...[
                              _buildQuickPaySection(context),
                              SizedBox(height: CUSpacing.xl),
                            ],
                            _buildRecentPayments(context),
                            SizedBox(height: CUSpacing.xl),
                            _buildZelleSection(context),
                            SizedBox(height: CUSpacing.xl),
                            _buildPayeesList(context),
                          ],
                        ),
                      ),
                      // Request tab
                      SingleChildScrollView(
                        padding: EdgeInsets.all(CUSpacing.lg),
                        child: _buildRequestSection(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildPaymentTabs(BuildContext context) {
    final theme = CUTheme.of(context);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: theme.colorScheme.onSurface,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
          indicatorColor: theme.colorScheme.primary,
          indicatorWeight: CUSize.xs,
          tabs: const [
            Tab(text: 'Send'),
            Tab(text: 'Request'),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPaySection(BuildContext context) {
    final theme = CUTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Pay',
          style: CUTypography.headingMd.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: CUSpacing.lg),
        _buildQuickPayForm(context),
      ],
    );
  }

  Widget _buildQuickPayForm(BuildContext context) {
    final theme = CUTheme.of(context);
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedAccount;
    String? selectedPayee;

    return Form(
      key: formKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedAccount,
                  decoration: InputDecoration(
                    hintText: 'From Account',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(CURadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _accounts
                      .map((account) => DropdownMenuItem<String>(
                            value: account['id'],
                            child: Text(
                                '${account['name']} - \$${(account['balance'] ?? 0.0).toStringAsFixed(2)}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAccount = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) return 'Please select an account';
                    return null;
                  },
                ),
              ),
              SizedBox(width: CUSpacing.md),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedPayee,
                  decoration: InputDecoration(
                    hintText: 'Select Payee',
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(CURadius.md),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Select Payee'),
                    ),
                    ..._payees.map((payee) => DropdownMenuItem<String>(
                          value: payee['id'],
                          child: Text(payee['name']),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPayee = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) return 'Please select a payee';
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: CUSpacing.lg),
          Row(
            children: [
              Expanded(
                child: CUTextField(
                  controller: amountController,
                  label: 'Amount',
                  prefix: Text('\$', style: CUTypography.bodyMd),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: CUSpacing.md),
              Expanded(
                child: CUTextField(
                  controller: descriptionController,
                  label: 'Description',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: CUSpacing.lg),
          Row(
            children: [
              Expanded(
                child: CUButton(
                  onPressed: () => _processQuickPayment(
                    context,
                    formKey,
                    selectedAccount,
                    selectedPayee,
                    amountController.text,
                    descriptionController.text,
                  ),
                  label: 'Pay Now',
                  icon: CUIcon(CUIcons.payment),
                  variant: CUButtonVariant.filled,
                ),
              ),
              SizedBox(width: CUSpacing.md),
              Expanded(
                child: CUButton(
                  onPressed: () => _schedulePayment(
                    context,
                    formKey,
                    selectedAccount,
                    selectedPayee,
                    amountController.text,
                    descriptionController.text,
                  ),
                  label: 'Schedule',
                  icon: CUIcon(CUIcons.schedule),
                  variant: CUButtonVariant.outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledPayments(BuildContext context) {
    final theme = CUTheme.of(context);

    if (_scheduledPayments.isEmpty) {
      return CUCard(
        child: Padding(
          padding: EdgeInsets.all(CUSpacing.lg),
          child: Center(
            child: Column(
              children: [
                CUIcon(
                  CUIcons.schedule,
                  size: CUSize.xxl,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: CUSpacing.lg),
                Text(
                  'No Scheduled Payments',
                  style: CUTypography.headingSm.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: CUSpacing.sm),
                Text(
                  'Schedule payments to avoid late fees',
                  style: CUTypography.bodyMd.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scheduled Payments',
                  style: CUTypography.headingMd.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                CUButton(
                  onPressed: () => _showScheduledPaymentsDialog(context),
                  label: 'View All',
                  icon: CUIcon(CUIcons.visibility),
                  variant: CUButtonVariant.text,
                ),
              ],
            ),
            SizedBox(height: CUSpacing.lg),
            ..._scheduledPayments.take(3).map(
                  (payment) => _buildScheduledPaymentItem(context, payment),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledPaymentItem(
    BuildContext context,
    Map<String, dynamic> payment,
  ) {
    final theme = CUTheme.of(context);
    final amount = payment['amount'] ?? 0.0;
    final nextPaymentDate = DateTime.parse(
        payment['next_payment_date'] ?? DateTime.now().toIso8601String());
    final frequency = payment['frequency'] ?? 'monthly';

    return CUListTile(
      leading: CUAvatar(
        child: CUIcon(
          CUIcons.schedule,
          color: theme.colorScheme.onPrimaryContainer,
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      title: Text(
        payment['payee_name'] ?? 'Payee',
        style: CUTypography.bodySm.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        'Next: ${_formatDate(nextPaymentDate)} • $frequency',
        style: CUTypography.bodyXs.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: CUTypography.bodySm.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          CUButton(
            onPressed: () => _cancelScheduledPayment(context, payment['id']),
            label: 'Cancel',
            variant: CUButtonVariant.text,
          ),
        ],
      ),
    );
  }

  Widget _buildPayeesList(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Payees',
                  style: CUTypography.headingMd.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                CUButton(
                  onPressed: () => _showAddPayeeDialog(context),
                  label: 'Add Payee',
                  icon: CUIcon(CUIcons.add),
                  variant: CUButtonVariant.text,
                ),
              ],
            ),
            SizedBox(height: CUSpacing.lg),
            if (_payees.isEmpty)
              Center(
                child: Column(
                  children: [
                    CUIcon(
                      CUIcons.person,
                      size: CUSize.xxl,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: CUSpacing.lg),
                    Text(
                      'No Payees Added',
                      style: CUTypography.headingSm.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: CUSpacing.sm),
                    Text(
                      'Add payees to make bill payments easier',
                      style: CUTypography.bodyMd.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ..._payees.map((payee) => _buildPayeeItem(context, payee)),
          ],
        ),
      ),
    );
  }

  Widget _buildPayeeItem(BuildContext context, Map<String, dynamic> payee) {
    final theme = CUTheme.of(context);

    return CUListTile(
      leading: CUAvatar(
        child: CUIcon(
          CUIcons.person,
          color: theme.colorScheme.onPrimaryContainer,
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      title: Text(
        payee['name'] ?? 'Payee',
        style: CUTypography.bodyMd.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        payee['account_number'] ?? 'No account number',
        style: CUTypography.bodyXs.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _editPayee(context, payee);
              break;
            case 'delete':
              _deletePayee(context, payee['id']);
              break;
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                CUIcon(CUIcons.edit),
                SizedBox(width: CUSpacing.sm),
                Text('Edit', style: CUTypography.bodyMd),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                CUIcon(CUIcons.delete),
                SizedBox(width: CUSpacing.sm),
                Text('Delete', style: CUTypography.bodyMd),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Future<void> _processQuickPayment(
    BuildContext context,
    GlobalKey<FormState> formKey,
    String? accountId,
    String? payeeId,
    String amount,
    String description,
  ) async {
    if (!formKey.currentState!.validate()) return;

    try {
      await _billPayService.processImmediatePayment(
        accountId: accountId!,
        payeeId: payeeId!,
        amount: double.parse(amount),
        memo: description,
      );

      if (mounted) {
        CUSnackBar.show(
          context,
          message: 'Payment processed successfully!',
          variant: CUSnackBarVariant.success,
        );
        _loadBillPayData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        CUSnackBar.show(
          context,
          message: 'Payment failed: $e',
          variant: CUSnackBarVariant.error,
        );
      }
    }
  }

  Future<void> _schedulePayment(
    BuildContext context,
    GlobalKey<FormState> formKey,
    String? accountId,
    String? payeeId,
    String amount,
    String description,
  ) async {
    if (!formKey.currentState!.validate()) return;

    // Show frequency selection dialog
    final frequency = await showDialog<String>(
      context: context,
      builder: (context) => CUDialog(
        title: 'Select Payment Frequency',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CUListTile(
              title: Text('One-time', style: CUTypography.bodyMd),
              onTap: () => Navigator.pop(context, 'one-time'),
            ),
            CUListTile(
              title: Text('Monthly', style: CUTypography.bodyMd),
              onTap: () => Navigator.pop(context, 'monthly'),
            ),
            CUListTile(
              title: Text('Quarterly', style: CUTypography.bodyMd),
              onTap: () => Navigator.pop(context, 'quarterly'),
            ),
            CUListTile(
              title: Text('Annually', style: CUTypography.bodyMd),
              onTap: () => Navigator.pop(context, 'annually'),
            ),
          ],
        ),
      ),
    );

    if (frequency != null) {
      try {
        await _billPayService.schedulePayment(
          payeeId: payeeId!,
          accountId: accountId!,
          amount: double.parse(amount),
          nextPaymentDate: DateTime.now(),
          frequency: frequency,
          memo: description,
        );

        if (mounted) {
          CUSnackBar.show(
            context,
            message: 'Payment scheduled successfully!',
            variant: CUSnackBarVariant.success,
          );
          _loadBillPayData(); // Refresh data
        }
      } catch (e) {
        if (mounted) {
          CUSnackBar.show(
            context,
            message: 'Failed to schedule payment: $e',
            variant: CUSnackBarVariant.error,
          );
        }
      }
    }
  }

  Future<void> _cancelScheduledPayment(
      BuildContext context, String paymentId) async {
    try {
      await _billPayService.cancelScheduledPayment(paymentId);

      if (mounted) {
        CUSnackBar.show(
          context,
          message: 'Payment cancelled successfully!',
          variant: CUSnackBarVariant.success,
        );
        _loadBillPayData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        CUSnackBar.show(
          context,
          message: 'Failed to cancel payment: $e',
          variant: CUSnackBarVariant.error,
        );
      }
    }
  }

  void _showScheduledPaymentsDialog(BuildContext context) {
    final theme = CUTheme.of(context);

    showDialog(
      context: context,
      builder: (context) => CUDialog(
        title: 'All Scheduled Payments',
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _scheduledPayments.length,
            itemBuilder: (context, index) {
              final payment = _scheduledPayments[index];
              return CUListTile(
                title: Text(
                  payment['payee_name'] ?? 'Payee',
                  style: CUTypography.bodyMd,
                ),
                subtitle: Text(
                  '\$${(payment['amount'] ?? 0.0).toStringAsFixed(2)}',
                  style: CUTypography.bodyXs,
                ),
                trailing: Text(
                  _formatDate(DateTime.parse(
                      payment['next_payment_date'] ??
                          DateTime.now().toIso8601String())),
                  style: CUTypography.bodyXs,
                ),
              );
            },
          ),
        ),
        actions: [
          CUButton(
            onPressed: () => Navigator.pop(context),
            label: 'Close',
            variant: CUButtonVariant.text,
          ),
        ],
      ),
    );
  }

  void _showAddPayeeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CUDialog(
        title: 'Add New Payee',
        content: Text(
          'Contact SUPAHYPER to add new payees.',
          style: CUTypography.bodyMd,
        ),
        actions: [
          CUButton(
            onPressed: () => Navigator.pop(context),
            label: 'OK',
            variant: CUButtonVariant.text,
          ),
        ],
      ),
    );
  }

  void _editPayee(BuildContext context, Map<String, dynamic> payee) {
    showDialog(
      context: context,
      builder: (context) => CUDialog(
        title: 'Edit ${payee['name']}',
        content: Text(
          'Payee editing feature coming soon!',
          style: CUTypography.bodyMd,
        ),
        actions: [
          CUButton(
            onPressed: () => Navigator.pop(context),
            label: 'OK',
            variant: CUButtonVariant.text,
          ),
        ],
      ),
    );
  }

  Future<void> _deletePayee(BuildContext context, String payeeId) async {
    try {
      await _billPayService.deletePayee(payeeId);

      if (mounted) {
        CUSnackBar.show(
          context,
          message: 'Payee deleted successfully!',
          variant: CUSnackBarVariant.success,
        );
        _loadBillPayData(); // Refresh data
      }
    } catch (e) {
      if (mounted) {
        CUSnackBar.show(
          context,
          message: 'Failed to delete payee: $e',
          variant: CUSnackBarVariant.error,
        );
      }
    }
  }

  Widget _buildRecentPayments(BuildContext context) {
    final theme = CUTheme.of(context);

    if (_recentPayments.isEmpty) {
      return Container();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent',
          style: CUTypography.headingMd.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: CUSpacing.lg),
        ...(_recentPayments.map((payment) {
          return Container(
            margin: EdgeInsets.only(bottom: CUSpacing.md),
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(CUSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(CURadius.md),
                ),
                child: Row(
                  children: [
                    CUAvatar(
                      size: CUSize.xl,
                      backgroundColor: theme.colorScheme.surfaceContainerHigh,
                      child: CUIcon(
                        CUIcons.payment,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: CUSize.md,
                      ),
                    ),
                    SizedBox(width: CUSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payment['name'] ?? '',
                            style: CUTypography.bodyMd.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            _formatDate(payment['date']),
                            style: CUTypography.bodySm.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '-\$${(payment['amount'] ?? 0).toStringAsFixed(2)}',
                      style: CUTypography.bodyMd.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildZelleSection(BuildContext context) {
    final theme = CUTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: CUSpacing.md,
                vertical: CUSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: CUColors.purple700,
                borderRadius: BorderRadius.circular(CURadius.full),
              ),
              child: Text(
                'Zelle®',
                style: CUTypography.bodySm.copyWith(
                  color: CUColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: CUSpacing.sm),
            Text(
              'Send money with Zelle',
              style: CUTypography.bodyMd.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: CUSpacing.md),
        GestureDetector(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(CUSpacing.lg),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(CURadius.md),
            ),
            child: Row(
              children: [
                CUIcon(
                  CUIcons.personAdd,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: CUSpacing.md),
                Expanded(
                  child: Text(
                    'Send to a new recipient',
                    style: CUTypography.bodyMd.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                CUIcon(
                  CUIcons.chevronRight,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: CUSize.sm,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestSection(BuildContext context) {
    final theme = CUTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(CUSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(CURadius.md),
          ),
          child: Column(
            children: [
              Text(
                'Share your payment link',
                style: CUTypography.bodyLg.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: CUSpacing.sm),
              Text(
                'supahyper.com/pay/username',
                style: CUTypography.bodySm.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: CUSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CUIconButton(
                    icon: CUIcon(CUIcons.copy),
                    onPressed: () {},
                    tooltip: 'Copy link',
                  ),
                  CUIconButton(
                    icon: CUIcon(CUIcons.share),
                    onPressed: () {},
                    tooltip: 'Share',
                  ),
                  CUIconButton(
                    icon: CUIcon(CUIcons.qrCode),
                    onPressed: () {},
                    tooltip: 'QR Code',
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: CUSpacing.xl),
        Text(
          'Request from contacts',
          style: CUTypography.headingMd.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: CUSpacing.lg),
        Center(
          child: Column(
            children: [
              CUIcon(
                CUIcons.people,
                size: CUSize.xxxl,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: CUSpacing.lg),
              Text(
                'No contacts yet',
                style: CUTypography.bodyMd.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: CUSpacing.sm),
              CUButton(
                onPressed: () {},
                label: 'Import contacts',
                variant: CUButtonVariant.text,
              ),
            ],
          ),
        ),
      ],
    );
  }

}
