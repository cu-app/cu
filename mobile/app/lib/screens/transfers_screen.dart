import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import '../services/transfers_service.dart';
import '../services/banking_service.dart';
import '../services/auth_service.dart';
import '../services/widget_journey_logger.dart';

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  final TransfersService _transfersService = TransfersService();
  final BankingService _bankingService = BankingService();
  final AuthService _authService = AuthService();
  final WidgetJourneyLogger _logger = WidgetJourneyLogger();

  List<Map<String, dynamic>> _accounts = [];
  List<Map<String, dynamic>> _recentTransfers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _logger.logView('transfers_screen');
    _loadTransferData();
  }

  Future<void> _loadTransferData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final accounts = await _bankingService.getUserAccounts();
      final transfers = await _transfersService.getTransferHistory();

      if (mounted) {
        setState(() {
          _accounts = accounts;
          _recentTransfers = transfers;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CUScaffold(
      body: _isLoading
          ? const Center(child: CUProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(CUSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        SizedBox(height: CUSpacing.lg),
                        _buildNewTransferSection(context),
                        SizedBox(height: CUSpacing.md),
                        _buildRecentTransfers(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = CUTheme.of(context);
    final user = _authService.currentUser;
    final firstName = user?.userMetadata?['first_name'] ?? 'User';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CUText(
          'Transfers, $firstName',
          style: CUTextStyle.h1,
        ),
        SizedBox(height: CUSpacing.sm),
        CUText(
          'Move money between accounts or send to others',
          style: CUTextStyle.bodyLarge.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildNewTransferSection(BuildContext context) {
    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CUText(
              'New Transfer',
              style: CUTextStyle.h3,
            ),
            SizedBox(height: CUSpacing.md),
            Row(
              children: [
                Expanded(
                  child: CUButton(
                    onPressed: () {
                      _logger.logInteraction('transfer_internal_button_tapped');
                      _showInternalTransferDialog(context);
                    },
                    text: 'Between My Accounts',
                    icon: CupertinoIcons.arrow_right_arrow_left,
                    type: CUButtonType.primary,
                  ),
                ),
                SizedBox(width: CUSpacing.sm),
                Expanded(
                  child: CUButton(
                    onPressed: () {
                      _logger.logInteraction('transfer_external_button_tapped');
                      _showExternalTransferDialog(context);
                    },
                    text: 'To External Bank',
                    icon: CupertinoIcons.paperplane,
                    type: CUButtonType.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransfers(BuildContext context) {
    if (_recentTransfers.isEmpty) {
      return CUCard(
        child: Padding(
          padding: EdgeInsets.all(CUSpacing.md),
          child: Center(
            child: CUText(
              'No recent transfers',
              style: CUTextStyle.bodyMedium,
            ),
          ),
        ),
      );
    }

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CUText(
              'Recent Transfers',
              style: CUTextStyle.h3,
            ),
            SizedBox(height: CUSpacing.md),
            ..._recentTransfers.take(5).map(
                  (transfer) => _buildTransferItem(context, transfer),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransferItem(
      BuildContext context, Map<String, dynamic> transfer) {
    final theme = CUTheme.of(context);
    final amount = transfer['amount'] ?? 0.0;
    final type = transfer['type'] ?? '';
    final status = transfer['status'] ?? '';

    return CUListTile(
      leading: CUAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          _getTransferIcon(type),
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: _getTransferDescription(transfer),
      subtitle: '${_formatTransferType(type)} • ${_formatDate(DateTime.parse(transfer['created_at'] ?? DateTime.now().toIso8601String()))}',
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CUText(
            '\$${amount.toStringAsFixed(2)}',
            style: CUTextStyle.h4,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: CUSpacing.sm, vertical: CUSpacing.xxs),
            decoration: BoxDecoration(
              color: _getStatusColor(status),
              borderRadius: BorderRadius.circular(CURadius.md),
            ),
            child: CUText(
              status.toUpperCase(),
              style: CUTextStyle.caption.copyWith(
                color: CUColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTransferIcon(String type) {
    switch (type) {
      case 'internal_transfer':
        return CupertinoIcons.arrow_right_arrow_left;
      case 'external_transfer':
        return CupertinoIcons.paperplane;
      case 'zelle_transfer':
        return CupertinoIcons.bolt_fill;
      default:
        return CupertinoIcons.arrow_right_arrow_left;
    }
  }

  String _formatTransferType(String type) {
    switch (type) {
      case 'internal_transfer':
        return 'Internal';
      case 'external_transfer':
        return 'External';
      case 'zelle_transfer':
        return 'Zelle';
      default:
        return 'Transfer';
    }
  }

  String _getTransferDescription(Map<String, dynamic> transfer) {
    final type = transfer['type'] ?? '';
    switch (type) {
      case 'internal_transfer':
        return 'Transfer between accounts';
      case 'external_transfer':
        return 'Transfer to ${transfer['external_bank_name'] ?? 'External Bank'}';
      case 'zelle_transfer':
        return 'Zelle to ${transfer['recipient_name'] ?? 'Recipient'}';
      default:
        return 'Transfer';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return CUColors.success;
      case 'pending':
        return CUColors.warning;
      case 'cancelled':
        return CUColors.error;
      default:
        return CUColors.textSecondary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  void _showInternalTransferDialog(BuildContext context) {
    if (_accounts.length < 2) {
      _showErrorDialog(
          context, 'You need at least 2 accounts to make internal transfers.');
      return;
    }

    String? fromAccountId;
    String? toAccountId;
    final amountController = TextEditingController();
    final memoController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (context) => CUAlertDialog(
        title: 'Internal Transfer',
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CUDropdown<String>(
                value: fromAccountId,
                hint: 'From Account',
                items: _accounts.map((account) {
                  return CUDropdownItem<String>(
                    value: account['id'],
                    label: '${account['name']} (\$${(account['balance'] ?? 0.0).toStringAsFixed(2)})',
                  );
                }).toList(),
                onChanged: (value) => fromAccountId = value,
              ),
              SizedBox(height: CUSpacing.md),
              CUDropdown<String>(
                value: toAccountId,
                hint: 'To Account',
                items: _accounts.map((account) {
                  return CUDropdownItem<String>(
                    value: account['id'],
                    label: '${account['name']} (\$${(account['balance'] ?? 0.0).toStringAsFixed(2)})',
                  );
                }).toList(),
                onChanged: (value) => toAccountId = value,
              ),
              SizedBox(height: CUSpacing.md),
              CUTextField(
                controller: amountController,
                hintText: 'Amount',
                prefixText: '\$',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: CUSpacing.md),
              CUTextField(
                controller: memoController,
                hintText: 'Memo (Optional)',
              ),
            ],
          ),
        ),
        actions: [
          CUButton(
            onPressed: () => Navigator.pop(context),
            text: 'Cancel',
            type: CUButtonType.text,
          ),
          CUButton(
            onPressed: () async {
              if (fromAccountId == null ||
                  toAccountId == null ||
                  amountController.text.isEmpty) {
                _showErrorDialog(
                    context, 'Please fill in all required fields.');
                return;
              }

              if (fromAccountId == toAccountId) {
                _showErrorDialog(
                    context, 'From and To accounts must be different.');
                return;
              }

              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                _showErrorDialog(context, 'Please enter a valid amount.');
                return;
              }

              Navigator.pop(context);
              await _processInternalTransfer(
                  fromAccountId!, toAccountId!, amount, memoController.text);
            },
            text: 'Transfer',
            type: CUButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showExternalTransferDialog(BuildContext context) {
    String? fromAccountId;
    final amountController = TextEditingController();
    final memoController = TextEditingController();
    final accountNumberController = TextEditingController();
    final routingNumberController = TextEditingController();
    final bankNameController = TextEditingController();

    showCupertinoDialog(
      context: context,
      builder: (context) => CUAlertDialog(
        title: 'External Transfer',
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CUDropdown<String>(
                value: fromAccountId,
                hint: 'From Account',
                items: _accounts.map((account) {
                  return CUDropdownItem<String>(
                    value: account['id'],
                    label: '${account['name']} (\$${(account['balance'] ?? 0.0).toStringAsFixed(2)})',
                  );
                }).toList(),
                onChanged: (value) => fromAccountId = value,
              ),
              SizedBox(height: CUSpacing.md),
              CUTextField(
                controller: bankNameController,
                hintText: 'Bank Name',
              ),
              SizedBox(height: CUSpacing.md),
              CUTextField(
                controller: accountNumberController,
                hintText: 'Account Number',
              ),
              SizedBox(height: CUSpacing.md),
              CUTextField(
                controller: routingNumberController,
                hintText: 'Routing Number',
              ),
              SizedBox(height: CUSpacing.md),
              CUTextField(
                controller: amountController,
                hintText: 'Amount',
                prefixText: '\$',
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: CUSpacing.md),
              CUTextField(
                controller: memoController,
                hintText: 'Memo (Optional)',
              ),
            ],
          ),
        ),
        actions: [
          CUButton(
            onPressed: () => Navigator.pop(context),
            text: 'Cancel',
            type: CUButtonType.text,
          ),
          CUButton(
            onPressed: () async {
              if (fromAccountId == null ||
                  amountController.text.isEmpty ||
                  bankNameController.text.isEmpty ||
                  accountNumberController.text.isEmpty ||
                  routingNumberController.text.isEmpty) {
                _showErrorDialog(
                    context, 'Please fill in all required fields.');
                return;
              }

              final amount = double.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                _showErrorDialog(context, 'Please enter a valid amount.');
                return;
              }

              Navigator.pop(context);
              await _processExternalTransfer(
                fromAccountId!,
                accountNumberController.text,
                routingNumberController.text,
                bankNameController.text,
                amount,
                memoController.text,
              );
            },
            text: 'Transfer',
            type: CUButtonType.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _processInternalTransfer(String fromAccountId,
      String toAccountId, double amount, String memo) async {
    _showLoadingDialog(context, 'Processing transfer...');

    try {
      await _transfersService.processInternalTransfer(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        memo: memo.isNotEmpty ? memo : null,
      );

      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog(context, 'Transfer completed successfully!');
        _loadTransferData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, 'Transfer failed: ${e.toString()}');
      }
    }
  }

  Future<void> _processExternalTransfer(
      String fromAccountId,
      String accountNumber,
      String routingNumber,
      String bankName,
      double amount,
      String memo) async {
    _showLoadingDialog(context, 'Processing external transfer...');

    try {
      await _transfersService.processExternalTransfer(
        fromAccountId: fromAccountId,
        externalAccountNumber: accountNumber,
        externalRoutingNumber: routingNumber,
        externalBankName: bankName,
        amount: amount,
        memo: memo.isNotEmpty ? memo : null,
      );

      if (mounted) {
        Navigator.pop(context);
        _showSuccessDialog(
            context, 'External transfer initiated successfully!');
        _loadTransferData();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showErrorDialog(context, 'Transfer failed: ${e.toString()}');
      }
    }
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CUAlertDialog(
        content: Row(
          children: [
            const CUProgressIndicator(),
            SizedBox(width: CUSpacing.md),
            CUText(message),
          ],
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CUAlertDialog(
        title: 'Success',
        content: CUText(message),
        actions: [
          CUButton(
            onPressed: () => Navigator.pop(context),
            text: 'OK',
            type: CUButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CUAlertDialog(
        title: 'Error',
        content: CUText(message),
        actions: [
          CUButton(
            onPressed: () => Navigator.pop(context),
            text: 'OK',
            type: CUButtonType.primary,
          ),
        ],
      ),
    );
  }
}
