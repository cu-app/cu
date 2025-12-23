import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import '../models/zelle_model.dart';
import '../services/zelle_service.dart';
import '../services/banking_service.dart';
import '../services/transfers_service.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class ZelleSendScreen extends StatefulWidget {
  final ZelleRecipient? recipient;

  const ZelleSendScreen({
    super.key,
    this.recipient,
  });

  @override
  State<ZelleSendScreen> createState() => _ZelleSendScreenState();
}

class _ZelleSendScreenState extends State<ZelleSendScreen>
    with TickerProviderStateMixin {
  final ZelleService _zelleService = ZelleService();
  final BankingService _bankingService = BankingService();
  final TransfersService _transfersService = TransfersService();
  final LocalAuthentication _localAuth = LocalAuthentication();

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  final _recipientEmailController = TextEditingController();
  final _recipientNameController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  ZelleRecipient? _selectedRecipient;
  List<Map<String, dynamic>> _accounts = [];
  String? _selectedAccountId;
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  // Delivery speed
  final String _deliverySpeed = 'instant';

  @override
  void initState() {
    super.initState();
    _selectedRecipient = widget.recipient;
    if (_selectedRecipient != null) {
      _recipientEmailController.text = _selectedRecipient!.email;
      _recipientNameController.text = _selectedRecipient!.name;
    }
    _initializeAnimations();
    _loadAccounts();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    _recipientEmailController.dispose();
    _recipientNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);

    try {
      final accounts = await _bankingService.getUserAccounts();
      setState(() {
        _accounts = accounts;
        if (accounts.isNotEmpty) {
          _selectedAccountId = accounts.first['id'];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load accounts';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectRecipient() async {
    final recipients = await _zelleService.getEnrolledRecipients();

    if (!mounted) return;

    final theme = CUTheme.of(context);

    final selected = await showModalBottomSheet<ZelleRecipient>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(CUSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(CURadius.lg)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.only(bottom: CUSpacing.md),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(CURadius.xs),
                ),
              ),
              Text(
                'Select Recipient',
                style: CUTypography.h3.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: CUSpacing.md),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: recipients.length,
                  itemBuilder: (context, index) {
                    final recipient = recipients[index];
                    return CUListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          recipient.name[0].toUpperCase(),
                          style: CUTypography.body.copyWith(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(recipient.name),
                      subtitle: Text(recipient.email),
                      trailing: recipient.isEnrolled
                          ? CUIcon(
                              CUIcons.checkCircle,
                              color: CUColors.success,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, recipient),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedRecipient = selected;
        _recipientEmailController.text = selected.email;
        _recipientNameController.text = selected.name;
      });
    }
  }

  Future<void> _sendMoney() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    // Check if biometric authentication is required for large amounts
    if (amount >= 500) {
      final isAuthenticated = await _authenticateWithBiometrics();
      if (!isAuthenticated) {
        setState(() {
          _errorMessage = 'Authentication required for amounts over \$500';
        });
        return;
      }
    }

    setState(() {
      _isSending = true;
      _errorMessage = null;
    });

    try {
      // Verify recipient if not already selected
      if (_selectedRecipient == null) {
        // Add recipient
        final recipient = await _zelleService.addRecipient(
          name: _recipientNameController.text,
          email: _recipientEmailController.text,
        );
        _selectedRecipient = recipient;
      }

      if (_selectedRecipient == null) {
        throw Exception('Failed to add recipient');
      }

      // Verify recipient
      final verification = await _zelleService.verifyRecipient(_selectedRecipient!.id);
      if (!verification['verified']) {
        throw Exception(verification['message'] ?? 'Recipient verification failed');
      }

      // Show warning if recipient is not enrolled
      if (verification['warning'] != null && mounted) {
        final proceed = await _showWarningDialog(verification['warning']);

        if (proceed != true) {
          setState(() => _isSending = false);
          return;
        }
      }

      // Process the transfer
      final result = await _transfersService.processZelleTransfer(
        fromAccountId: _selectedAccountId!,
        recipientEmail: _selectedRecipient!.email,
        recipientName: _selectedRecipient!.name,
        recipientId: _selectedRecipient!.id,
        amount: amount,
        memo: _memoController.text.isEmpty ? null : _memoController.text,
      );

      // Create Zelle transaction record
      await _zelleService.sendMoney(
        recipientId: _selectedRecipient!.id,
        fromAccountId: _selectedAccountId!,
        amount: amount,
        memo: _memoController.text.isEmpty ? null : _memoController.text,
      );

      // Show success
      if (mounted) {
        HapticFeedback.heavyImpact();
        _showSuccessDialog(amount);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isSending = false;
      });
      HapticFeedback.vibrate();
    }
  }

  Future<bool> _authenticateWithBiometrics() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) return true; // Skip if not available

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to send large payment',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      return authenticated;
    } catch (e) {
      print('Biometric authentication error: $e');
      return false;
    }
  }

  Future<bool?> _showWarningDialog(String warning) async {
    final theme = CUTheme.of(context);

    return showDialog<bool>(
      context: context,
      builder: (context) => CUDialog(
        title: 'Recipient Not Enrolled',
        content: Text(
          warning,
          style: CUTypography.body.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          CUButton(
            text: 'Cancel',
            variant: CUButtonVariant.text,
            onPressed: () => Navigator.pop(context, false),
          ),
          CUButton(
            text: 'Send Anyway',
            variant: CUButtonVariant.filled,
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(double amount) {
    final theme = CUTheme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CUDialog(
        icon: CUIcon(
          CUIcons.checkCircle,
          color: CUColors.success,
          size: CUSize.iconLg,
        ),
        title: 'Payment Sent!',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: CUTypography.h1.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: CUSpacing.xs),
            Text(
              'Sent to ${_selectedRecipient!.name}',
              style: CUTypography.body.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (_deliverySpeed == 'instant')
              Text(
                'Available immediately',
                style: CUTypography.body.copyWith(
                  color: CUColors.success,
                ),
              ),
          ],
        ),
        actions: [
          CUButton(
            text: 'Done',
            variant: CUButtonVariant.text,
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // Return to previous screen
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final limits = _zelleService.getZelleLimits();

    return CUScaffold(
      appBar: CUAppBar(
        title: const Text('Send with Zelle'),
        actions: [
          CUIconButton(
            icon: CUIcons.history,
            onPressed: () {
              // Navigate to transaction history
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CULoadingIndicator())
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(CUSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Recipient section
                        _buildRecipientSection(),
                        SizedBox(height: CUSpacing.lg),

                        // Amount input
                        _buildAmountInput(),
                        SizedBox(height: CUSpacing.lg),

                        // Account selector
                        _buildAccountSelector(),
                        SizedBox(height: CUSpacing.lg),

                        // Memo field
                        _buildMemoField(),
                        SizedBox(height: CUSpacing.lg),

                        // Delivery speed (always instant for Zelle)
                        _buildDeliverySpeed(),
                        SizedBox(height: CUSpacing.lg),

                        // Limits info
                        _buildLimitsInfo(limits),
                        SizedBox(height: CUSpacing.lg),

                        // Error message
                        if (_errorMessage != null)
                          Container(
                            padding: EdgeInsets.all(CUSpacing.sm),
                            margin: EdgeInsets.only(bottom: CUSpacing.md),
                            decoration: BoxDecoration(
                              color: CUColors.error.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(CURadius.sm),
                              border: Border.all(color: CUColors.error),
                            ),
                            child: Row(
                              children: [
                                CUIcon(CUIcons.errorOutline, color: CUColors.error),
                                SizedBox(width: CUSpacing.xs),
                                Expanded(
                                  child: Text(
                                    _errorMessage!,
                                    style: CUTypography.body.copyWith(
                                      color: CUColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Send button
                        CUButton(
                          text: 'Send Money',
                          variant: CUButtonVariant.filled,
                          onPressed: _isSending ? null : _sendMoney,
                          isLoading: _isSending,
                          expand: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildRecipientSection() {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recipient',
              style: CUTypography.h4.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: CUSpacing.sm),
            if (_selectedRecipient != null) ...[
              CUListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _selectedRecipient!.name[0].toUpperCase(),
                    style: CUTypography.body.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  _selectedRecipient!.name,
                  style: CUTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                subtitle: Text(
                  _selectedRecipient!.email,
                  style: CUTypography.caption.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                trailing: CUButton(
                  text: 'Change',
                  variant: CUButtonVariant.text,
                  onPressed: _selectRecipient,
                ),
              ),
            ] else ...[
              CUTextField(
                controller: _recipientEmailController,
                labelText: 'Email or Phone',
                prefixIcon: CUIcons.email,
                suffixIcon: CUIconButton(
                  icon: CUIcons.contacts,
                  onPressed: _selectRecipient,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter recipient email or phone';
                  }
                  return null;
                },
              ),
              SizedBox(height: CUSpacing.sm),
              CUTextField(
                controller: _recipientNameController,
                labelText: 'Recipient Name',
                prefixIcon: CUIcons.person,
                textCapitalization: TextCapitalization.words,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter recipient name';
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    final theme = CUTheme.of(context);
    final limits = _zelleService.getZelleLimits();

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amount',
              style: CUTypography.h4.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: CUSpacing.sm),
            CUTextField(
              controller: _amountController,
              prefixText: '\$ ',
              hintText: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              style: CUTypography.h1.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value!);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                if (amount < limits['min_amount']) {
                  return 'Minimum amount is \$${limits['min_amount']}';
                }
                if (amount > limits['max_amount']) {
                  return 'Maximum amount is \$${limits['max_amount']}';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector() {
    if (_accounts.isEmpty) return const SizedBox.shrink();

    final theme = CUTheme.of(context);
    final selectedAccount = _accounts.firstWhere(
      (acc) => acc['id'] == _selectedAccountId,
      orElse: () => _accounts.first,
    );

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'From Account',
              style: CUTypography.h4.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: CUSpacing.sm),
            GestureDetector(
              onTap: () => _showAccountSelector(),
              child: Container(
                padding: EdgeInsets.all(CUSpacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: theme.colorScheme.outline),
                  borderRadius: BorderRadius.circular(CURadius.sm),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedAccount['name'] ?? 'Unknown Account',
                            style: CUTypography.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'Balance: \$${selectedAccount['balance']?.toStringAsFixed(2) ?? '0.00'}',
                            style: CUTypography.caption.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CUIcon(
                      CUIcons.arrowDropDown,
                      color: theme.colorScheme.onSurface,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountSelector() {
    final theme = CUTheme.of(context);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(CUSpacing.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(CURadius.lg)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Account',
              style: CUTypography.h3.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: CUSpacing.md),
            ..._accounts.map((account) => CUListTile(
                  leading: CUIcon(
                    CUIcons.accountBalance,
                    color: theme.colorScheme.onSurface,
                  ),
                  title: Text(
                    account['name'] ?? 'Unknown Account',
                    style: CUTypography.body.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    'Balance: \$${account['balance']?.toStringAsFixed(2) ?? '0.00'}',
                    style: CUTypography.caption.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  selected: account['id'] == _selectedAccountId,
                  onTap: () {
                    setState(() => _selectedAccountId = account['id']);
                    Navigator.pop(context);
                  },
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoField() {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Memo (Optional)',
              style: CUTypography.h4.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: CUSpacing.sm),
            CUTextField(
              controller: _memoController,
              hintText: 'What\'s this for?',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySpeed() {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delivery Speed',
              style: CUTypography.h4.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: CUSpacing.sm),
            Container(
              padding: EdgeInsets.all(CUSpacing.sm),
              decoration: BoxDecoration(
                color: CUColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(CURadius.sm),
                border: Border.all(color: CUColors.success),
              ),
              child: Row(
                children: [
                  CUIcon(CUIcons.flashOn, color: CUColors.success),
                  SizedBox(width: CUSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instant Delivery',
                          style: CUTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            color: CUColors.success,
                          ),
                        ),
                        Text(
                          'Money available in minutes',
                          style: CUTypography.caption.copyWith(
                            color: CUColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'No Fee',
                    style: CUTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: CUColors.success,
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

  Widget _buildLimitsInfo(Map<String, dynamic> limits) {
    final theme = CUTheme.of(context);

    return CUCard(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CUIcon(
                  CUIcons.infoOutline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: CUSpacing.xs),
                Text(
                  'Zelle Limits',
                  style: CUTypography.h4.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            Text(
              'Daily: \$${limits['daily_limit']?.toStringAsFixed(0)}\n'
              'Weekly: \$${limits['weekly_limit']?.toStringAsFixed(0)}\n'
              'Per transaction: \$${limits['max_amount']?.toStringAsFixed(0)}',
              style: CUTypography.body.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
