import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../models/check_deposit_model.dart';
import '../services/check_deposit_service.dart';
import '../services/banking_service.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class CheckReviewScreen extends StatefulWidget {
  final CheckDeposit deposit;

  const CheckReviewScreen({
    super.key,
    required this.deposit,
  });

  @override
  State<CheckReviewScreen> createState() => _CheckReviewScreenState();
}

class _CheckReviewScreenState extends State<CheckReviewScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _checkNumberController = TextEditingController();
  final _checkDepositService = CheckDepositService();
  final _bankingService = BankingService();

  bool _isProcessing = false;
  double? _ocrAmount;
  bool _isLoadingOCR = false;
  List<Map<String, dynamic>> _accounts = [];
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _selectedAccountId = widget.deposit.accountId;
    _checkNumberController.text = widget.deposit.checkNumber ?? '';
    if (widget.deposit.amount > 0) {
      _amountController.text = widget.deposit.amount.toStringAsFixed(2);
    }
    _loadAccounts();
    _performOCR();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _checkNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await _bankingService.getUserAccounts();
      // Filter to only show depository accounts
      final depositoryAccounts = accounts.where((account) {
        return account['type'] == 'depository';
      }).toList();

      setState(() {
        _accounts = depositoryAccounts;
      });
    } catch (e) {
      print('Error loading accounts: $e');
    }
  }

  Future<void> _performOCR() async {
    if (widget.deposit.frontImage == null) return;

    setState(() {
      _isLoadingOCR = true;
    });

    try {
      final amount = await _checkDepositService.extractAmountFromCheck(
        widget.deposit.frontImage!,
      );

      if (amount != null && mounted) {
        setState(() {
          _ocrAmount = amount;
          _amountController.text = amount.toStringAsFixed(2);
        });

        // Show OCR result
        CUSnackBar.show(
          context,
          message: 'Check amount detected: \$${amount.toStringAsFixed(2)}',
          action: CUSnackBarAction(
            label: 'Change',
            onPressed: () {
              _amountController.clear();
            },
          ),
        );
      }
    } catch (e) {
      print('OCR error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingOCR = false;
        });
      }
    }
  }

  Future<void> _submitDeposit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final amount = double.parse(_amountController.text);

      // Validate amount
      final error = await _checkDepositService.validateAmount(amount);
      if (error != null) {
        if (!mounted) return;
        _showError(error);
        return;
      }

      // Update deposit details
      final updatedDeposit = await _checkDepositService.updateDepositDetails(
        deposit: widget.deposit,
        amount: amount,
        checkNumber: _checkNumberController.text.trim(),
      );

      // Navigate to confirmation screen
      if (!mounted) return;
      final result = await Navigator.push<bool>(
        context,
        CUPageRoute(
          builder: (context) => CheckDepositConfirmationScreen(
            deposit: updatedDeposit.copyWith(accountId: _selectedAccountId ?? updatedDeposit.accountId),
          ),
        ),
      );

      if (result == true && mounted) {
        // Return to main screen
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to process deposit: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showError(String message) {
    final theme = CUTheme.of(context);
    CUSnackBar.show(
      context,
      message: message,
      type: CUSnackBarType.error,
    );
    setState(() {
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      appBar: CUAppBar(
        title: const Text('Review Check Details'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(CUSpacing.md),
          children: [
            // Check images preview
            CUCard(
              child: Padding(
                padding: EdgeInsets.all(CUSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check Images',
                      style: CUTypography.titleMedium(context),
                    ),
                    SizedBox(height: CUSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                height: CUSize.imagePreviewSmall,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline,
                                  ),
                                  borderRadius: BorderRadius.circular(CURadius.sm),
                                ),
                                child: widget.deposit.frontImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(CURadius.sm),
                                        child: Image.file(
                                          widget.deposit.frontImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: CUIcon(
                                          CUIcons.image,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                              ),
                              SizedBox(height: CUSpacing.xs),
                              Text(
                                'Front',
                                style: CUTypography.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: CUSpacing.md),
                        Expanded(
                          child: Column(
                            children: [
                              Container(
                                height: CUSize.imagePreviewSmall,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: theme.colorScheme.outline,
                                  ),
                                  borderRadius: BorderRadius.circular(CURadius.sm),
                                ),
                                child: widget.deposit.backImage != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(CURadius.sm),
                                        child: Image.file(
                                          widget.deposit.backImage!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Center(
                                        child: CUIcon(
                                          CUIcons.image,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                              ),
                              SizedBox(height: CUSpacing.xs),
                              Text(
                                'Back',
                                style: CUTypography.bodySmall(context),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: CUSpacing.md),

            // Account selection
            CUCard(
              child: Padding(
                padding: EdgeInsets.all(CUSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deposit To',
                      style: CUTypography.titleMedium(context),
                    ),
                    SizedBox(height: CUSpacing.md),
                    CUDropdownField<String>(
                      value: _selectedAccountId,
                      label: 'Select Account',
                      items: _accounts.map((account) {
                        return CUDropdownMenuItem<String>(
                          value: account['id'],
                          child: Text(
                            '${account['name']} - \$${(account['balance'] ?? 0.0).toStringAsFixed(2)}',
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedAccountId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select an account';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: CUSpacing.md),

            // Check details
            CUCard(
              child: Padding(
                padding: EdgeInsets.all(CUSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check Details',
                      style: CUTypography.titleMedium(context),
                    ),
                    SizedBox(height: CUSpacing.md),
                    CUTextField(
                      controller: _amountController,
                      label: 'Amount',
                      prefixText: '\$ ',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      suffixIcon: _isLoadingOCR
                          ? SizedBox(
                              width: CUSize.iconSm,
                              height: CUSize.iconSm,
                              child: Padding(
                                padding: EdgeInsets.all(CUSpacing.sm),
                                child: CULoadingIndicator(
                                  size: CULoadingIndicatorSize.small,
                                ),
                              ),
                            )
                          : null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the check amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    if (_ocrAmount != null)
                      Padding(
                        padding: EdgeInsets.only(top: CUSpacing.xs),
                        child: Text(
                          'Detected amount: \$${_ocrAmount!.toStringAsFixed(2)}',
                          style: CUTypography.bodySmall(context).copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    SizedBox(height: CUSpacing.md),
                    CUTextField(
                      controller: _checkNumberController,
                      label: 'Check Number (Optional)',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: CUSpacing.lg),

            // Submit button
            CUButton(
              text: 'Continue',
              onPressed: _isProcessing ? null : _submitDeposit,
              type: CUButtonType.primary,
              isLoading: _isProcessing,
              isFullWidth: true,
            ),

            SizedBox(height: CUSpacing.md),

            // Info text
            CUCard(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: EdgeInsets.all(CUSpacing.md),
                child: Row(
                  children: [
                    CUIcon(
                      CUIcons.info,
                      color: theme.colorScheme.primary,
                    ),
                    SizedBox(width: CUSpacing.sm),
                    Expanded(
                      child: Text(
                        'Funds are typically available within 1-2 business days.',
                        style: CUTypography.bodyMedium(context).copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
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
}

// Confirmation Screen
class CheckDepositConfirmationScreen extends StatefulWidget {
  final CheckDeposit deposit;

  const CheckDepositConfirmationScreen({
    super.key,
    required this.deposit,
  });

  @override
  State<CheckDepositConfirmationScreen> createState() => _CheckDepositConfirmationScreenState();
}

class _CheckDepositConfirmationScreenState extends State<CheckDepositConfirmationScreen> {
  final _checkDepositService = CheckDepositService();
  final _bankingService = BankingService();
  bool _isSubmitting = false;
  CheckDeposit? _completedDeposit;
  Map<String, dynamic>? _account;

  @override
  void initState() {
    super.initState();
    _loadAccountDetails();
  }

  Future<void> _loadAccountDetails() async {
    try {
      final account = await _bankingService.getAccountDetails(widget.deposit.accountId);
      setState(() {
        _account = account;
      });
    } catch (e) {
      print('Error loading account: $e');
    }
  }

  Future<void> _confirmDeposit() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final result = await _checkDepositService.submitDeposit(widget.deposit);

      setState(() {
        _completedDeposit = result;
        _isSubmitting = false;
      });

      if (result.status == CheckDepositStatus.completed) {
        _showSuccessDialog(result);
      } else {
        _showFailureDialog(result);
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Failed to submit deposit: $e');
    }
  }

  void _showSuccessDialog(CheckDeposit deposit) {
    final theme = CUTheme.of(context);

    showCUDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CUDialog(
        icon: CUIcon(
          CUIcons.checkCircle,
          color: CUColors.success,
          size: CUSize.iconLg,
        ),
        title: 'Deposit Successful',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '\$${deposit.amount.toStringAsFixed(2)}',
              style: CUTypography.headlineMedium(context),
            ),
            SizedBox(height: CUSpacing.xs),
            Text(
              'Reference: ${deposit.referenceNumber}',
              style: CUTypography.bodyMedium(context),
            ),
            SizedBox(height: CUSpacing.md),
            Text(
              'Your deposit is being processed. Funds will be available within 1-2 business days.',
              textAlign: TextAlign.center,
              style: CUTypography.bodyMedium(context),
            ),
          ],
        ),
        actions: [
          CUButton(
            text: 'Done',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            type: CUButtonType.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  void _showFailureDialog(CheckDeposit deposit) {
    final theme = CUTheme.of(context);

    showCUDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CUDialog(
        icon: CUIcon(
          CUIcons.error,
          color: theme.colorScheme.error,
          size: CUSize.iconLg,
        ),
        title: 'Deposit Failed',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              deposit.failureReason ?? 'An error occurred while processing your deposit.',
              textAlign: TextAlign.center,
              style: CUTypography.bodyMedium(context),
            ),
          ],
        ),
        actions: [
          CUButton(
            text: 'Try Again',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, false);
            },
            type: CUButtonType.secondary,
            isFullWidth: true,
          ),
          SizedBox(height: CUSpacing.sm),
          CUButton(
            text: 'Close',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            type: CUButtonType.primary,
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    CUSnackBar.show(
      context,
      message: message,
      type: CUSnackBarType.error,
    );
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      appBar: CUAppBar(
        title: const Text('Confirm Deposit'),
      ),
      body: ListView(
        padding: EdgeInsets.all(CUSpacing.md),
        children: [
          // Summary card
          CUCard(
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deposit Summary',
                    style: CUTypography.titleLarge(context),
                  ),
                  SizedBox(height: CUSpacing.md),
                  _buildSummaryRow(
                    context,
                    'Amount',
                    '\$${widget.deposit.amount.toStringAsFixed(2)}',
                    isHighlighted: true,
                  ),
                  CUDivider(),
                  _buildSummaryRow(
                    context,
                    'To Account',
                    _account?['name'] ?? 'Loading...',
                  ),
                  if (_account != null)
                    _buildSummaryRow(
                      context,
                      'Current Balance',
                      '\$${(_account!['balance'] ?? 0.0).toStringAsFixed(2)}',
                    ),
                  if (widget.deposit.checkNumber?.isNotEmpty == true) ...[
                    CUDivider(),
                    _buildSummaryRow(
                      context,
                      'Check Number',
                      widget.deposit.checkNumber!,
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: CUSpacing.md),

          // Check images
          CUCard(
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check Images',
                    style: CUTypography.titleMedium(context),
                  ),
                  SizedBox(height: CUSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.6,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(CURadius.sm),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(CURadius.sm),
                              child: Image.file(
                                widget.deposit.frontImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: CUSpacing.xs),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1.6,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(CURadius.sm),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(CURadius.sm),
                              child: Image.file(
                                widget.deposit.backImage!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: CUSpacing.lg),

          // Action buttons
          CUButton(
            text: 'Submit Deposit',
            onPressed: _isSubmitting ? null : _confirmDeposit,
            type: CUButtonType.primary,
            isLoading: _isSubmitting,
            isFullWidth: true,
          ),
          SizedBox(height: CUSpacing.sm),
          CUButton(
            text: 'Back to Edit',
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            type: CUButtonType.secondary,
            isFullWidth: true,
          ),

          SizedBox(height: CUSpacing.lg),

          // Terms
          CUCard(
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CUIcon(
                        CUIcons.security,
                        size: CUSize.iconSm,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: CUSpacing.xs),
                      Text(
                        'Terms & Security',
                        style: CUTypography.titleSmall(context),
                      ),
                    ],
                  ),
                  SizedBox(height: CUSpacing.xs),
                  Text(
                    'By submitting this deposit, you confirm that you are the payee or authorized to deposit this check. Funds are subject to verification and may be held according to our funds availability policy.',
                    style: CUTypography.bodySmall(context).copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value, {bool isHighlighted = false}) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: CUSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: CUTypography.bodyMedium(context),
          ),
          Text(
            value,
            style: isHighlighted
                ? CUTypography.titleLarge(context).copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    )
                : CUTypography.bodyLarge(context),
          ),
        ],
      ),
    );
  }
}
