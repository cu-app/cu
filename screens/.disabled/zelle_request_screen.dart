import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import '../models/zelle_model.dart';
import '../services/zelle_service.dart';

class ZelleRequestScreen extends StatefulWidget {
  final ZelleRecipient? recipient;
  final bool isSplitBill;

  const ZelleRequestScreen({
    super.key,
    this.recipient,
    this.isSplitBill = false,
  });

  @override
  State<ZelleRequestScreen> createState() => _ZelleRequestScreenState();
}

class _ZelleRequestScreenState extends State<ZelleRequestScreen>
    with SingleTickerProviderStateMixin {
  final ZelleService _zelleService = ZelleService();
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  late TabController _tabController;

  List<ZelleRecipient> _selectedRecipients = [];
  bool _isRequesting = false;
  String? _errorMessage;

  // Split bill options
  bool _equalSplit = true;
  final Map<String, TextEditingController> _customAmountControllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.isSplitBill ? 1 : 2,
      vsync: this,
    );

    if (widget.recipient != null) {
      _selectedRecipients = [widget.recipient!];
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    _tabController.dispose();
    _customAmountControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _selectRecipients() async {
    final recipients = await _zelleService.getAllRecipients();

    if (!mounted) return;

    final selected = await showDialog<List<ZelleRecipient>>(
      context: context,
      builder: (context) => _RecipientSelectionDialog(
        recipients: recipients,
        selectedRecipients: _selectedRecipients,
        multiple: widget.isSplitBill || _tabController.index == 1,
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedRecipients = selected;
        _updateCustomAmountControllers();
      });
    }
  }

  void _updateCustomAmountControllers() {
    // Remove controllers for deselected recipients
    _customAmountControllers.removeWhere((id, controller) {
      if (!_selectedRecipients.any((r) => r.id == id)) {
        controller.dispose();
        return true;
      }
      return false;
    });

    // Add controllers for new recipients
    for (final recipient in _selectedRecipients) {
      if (!_customAmountControllers.containsKey(recipient.id)) {
        _customAmountControllers[recipient.id] = TextEditingController();
      }
    }
  }

  Future<void> _requestMoney() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRecipients.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one recipient';
      });
      return;
    }

    setState(() {
      _isRequesting = true;
      _errorMessage = null;
    });

    try {
      if (widget.isSplitBill || _tabController.index == 1) {
        // Split bill
        final totalAmount = double.parse(_amountController.text);
        final customAmounts = <String, double>{};

        if (!_equalSplit) {
          // Validate custom amounts
          double customTotal = 0;
          for (final entry in _customAmountControllers.entries) {
            final amount = double.tryParse(entry.value.text) ?? 0;
            if (amount <= 0) {
              throw Exception('Please enter valid amounts for all recipients');
            }
            customAmounts[entry.key] = amount;
            customTotal += amount;
          }

          if ((customTotal - totalAmount).abs() > 0.01) {
            throw Exception('Individual amounts must add up to total amount');
          }
        }

        final requests = await _zelleService.splitBill(
          recipientIds: _selectedRecipients.map((r) => r.id).toList(),
          totalAmount: totalAmount,
          memo: _memoController.text.isEmpty ? null : _memoController.text,
          equalSplit: _equalSplit,
          customAmounts: _equalSplit ? null : customAmounts,
        );

        if (requests.isEmpty) {
          throw Exception('Failed to create payment requests');
        }

        if (mounted) {
          _showSuccessDialog(requests.length, totalAmount);
        }
      } else {
        // Single request
        final recipient = _selectedRecipients.first;
        final amount = double.parse(_amountController.text);

        final request = await _zelleService.requestMoney(
          recipientId: recipient.id,
          amount: amount,
          memo: _memoController.text.isEmpty ? null : _memoController.text,
        );

        if (request == null) {
          throw Exception('Failed to create payment request');
        }

        if (mounted) {
          _showSuccessDialog(1, amount);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isRequesting = false;
      });
      HapticFeedback.vibrate();
    }
  }

  void _showSuccessDialog(int requestCount, double amount) {
    final theme = CUTheme.of(context);
    final isSplit = requestCount > 1;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CUDialog(
        icon: Icon(
          CUIcons.check_circle,
          color: CUColors.success,
          size: CUSize.icon3XL,
        ),
        title: isSplit ? 'Split Bill Sent!' : 'Request Sent!',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSplit) ...[
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: CUTypography.heading2XL.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: CUSpacing.xs),
              Text(
                'Sent to $requestCount people',
                style: CUTypography.bodyMD,
              ),
              if (_equalSplit)
                Text(
                  '\$${(amount / requestCount).toStringAsFixed(2)} each',
                  style: CUTypography.bodyMD.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ] else ...[
              Text(
                '\$${amount.toStringAsFixed(2)}',
                style: CUTypography.heading3XL.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: CUSpacing.xs),
              Text(
                'Requested from ${_selectedRecipients.first.name}',
                style: CUTypography.bodyMD,
              ),
            ],
            SizedBox(height: CUSpacing.xs),
            Text(
              'Recipients will be notified',
              style: CUTypography.bodyMD.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          CUButton.text(
            label: 'Done',
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
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
        title: widget.isSplitBill ? 'Split Bill' : 'Request Money',
        bottom: widget.isSplitBill
            ? null
            : CUTabBar(
                controller: _tabController,
                tabs: const [
                  CUTab(text: 'Request'),
                  CUTab(text: 'Split Bill'),
                ],
              ),
      ),
      body: Form(
        key: _formKey,
        child: widget.isSplitBill
            ? _buildSplitBillContent()
            : TabBarView(
                controller: _tabController,
                children: [
                  _buildRequestContent(),
                  _buildSplitBillContent(),
                ],
              ),
      ),
    );
  }

  Widget _buildRequestContent() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Recipient
          _buildRecipientSection(multiple: false),
          SizedBox(height: CUSpacing.lg),

          // Amount
          _buildAmountInput(),
          SizedBox(height: CUSpacing.lg),

          // Memo
          _buildMemoField(),
          SizedBox(height: CUSpacing.lg),

          // Info
          _buildRequestInfo(),
          SizedBox(height: CUSpacing.lg),

          // Error message
          if (_errorMessage != null)
            Container(
              padding: EdgeInsets.all(CUSpacing.sm),
              margin: EdgeInsets.only(bottom: CUSpacing.md),
              decoration: BoxDecoration(
                color: CUColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(CURadius.md),
                border: Border.all(color: CUColors.error),
              ),
              child: Row(
                children: [
                  Icon(CUIcons.error_outline, color: CUColors.error),
                  SizedBox(width: CUSpacing.xs),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: CUTypography.bodyMD.copyWith(color: CUColors.error),
                    ),
                  ),
                ],
              ),
            ),

          // Request button
          CUButton.filled(
            label: 'Send Request',
            onPressed: _isRequesting ? null : _requestMoney,
            isLoading: _isRequesting,
          ),
        ],
      ),
    );
  }

  Widget _buildSplitBillContent() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total amount
          _buildAmountInput(label: 'Total Bill Amount'),
          SizedBox(height: CUSpacing.lg),

          // Recipients
          _buildRecipientSection(multiple: true),
          SizedBox(height: CUSpacing.lg),

          // Split type
          _buildSplitTypeSelector(),
          SizedBox(height: CUSpacing.lg),

          // Custom amounts (if not equal split)
          if (!_equalSplit) ...[
            _buildCustomAmounts(),
            SizedBox(height: CUSpacing.lg),
          ],

          // Memo
          _buildMemoField(),
          SizedBox(height: CUSpacing.lg),

          // Info
          _buildSplitBillInfo(),
          SizedBox(height: CUSpacing.lg),

          // Error message
          if (_errorMessage != null)
            Container(
              padding: EdgeInsets.all(CUSpacing.sm),
              margin: EdgeInsets.only(bottom: CUSpacing.md),
              decoration: BoxDecoration(
                color: CUColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(CURadius.md),
                border: Border.all(color: CUColors.error),
              ),
              child: Row(
                children: [
                  Icon(CUIcons.error_outline, color: CUColors.error),
                  SizedBox(width: CUSpacing.xs),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: CUTypography.bodyMD.copyWith(color: CUColors.error),
                    ),
                  ),
                ],
              ),
            ),

          // Split button
          CUButton.filled(
            label: 'Split & Request',
            onPressed: _isRequesting ? null : _requestMoney,
            isLoading: _isRequesting,
          ),
        ],
      ),
    );
  }

  Widget _buildRecipientSection({required bool multiple}) {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  multiple ? 'Recipients' : 'Request From',
                  style: CUTypography.bodyLG.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_selectedRecipients.isNotEmpty && multiple)
                  Text(
                    '${_selectedRecipients.length} selected',
                    style: CUTypography.bodyMD.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            if (_selectedRecipients.isEmpty) ...[
              CUButton.outlined(
                label: multiple ? 'Add Recipients' : 'Select Recipient',
                icon: CUIcons.add,
                onPressed: _selectRecipients,
              ),
            ] else ...[
              Wrap(
                spacing: CUSpacing.xs,
                runSpacing: CUSpacing.xs,
                children: _selectedRecipients.map((recipient) => CUChip(
                      label: recipient.name,
                      avatar: Text(recipient.name[0].toUpperCase()),
                      onDeleted: multiple
                          ? () {
                              setState(() {
                                _selectedRecipients.remove(recipient);
                                _updateCustomAmountControllers();
                              });
                            }
                          : null,
                    ))
                    .toList(),
              ),
              if (multiple) ...[
                SizedBox(height: CUSpacing.sm),
                CUButton.text(
                  label: 'Add More',
                  icon: CUIcons.add,
                  onPressed: _selectRecipients,
                ),
              ] else ...[
                SizedBox(height: CUSpacing.xs),
                CUButton.text(
                  label: 'Change',
                  onPressed: _selectRecipients,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput({String label = 'Amount'}) {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: CUTypography.bodyLG.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: CUSpacing.sm),
            CUTextField(
              controller: _amountController,
              prefix: const Text('\$ '),
              hintText: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              textStyle: CUTypography.heading3XL.copyWith(
                fontWeight: FontWeight.bold,
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value!);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            if (_tabController.index == 1 && _selectedRecipients.length > 1 && _equalSplit) ...[
              SizedBox(height: CUSpacing.xs),
              Text(
                'Each person will be charged: \$${_calculateSplitAmount()}',
                style: CUTypography.bodyMD.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _calculateSplitAmount() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount > 0 && _selectedRecipients.isNotEmpty) {
      return (amount / _selectedRecipients.length).toStringAsFixed(2);
    }
    return '0.00';
  }

  Widget _buildSplitTypeSelector() {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Split Type',
              style: CUTypography.bodyLG.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: CUSpacing.sm),
            CUSegmentedButton<bool>(
              segments: [
                CUSegment(
                  value: true,
                  label: 'Equal Split',
                  icon: CUIcons.format_align_center,
                ),
                CUSegment(
                  value: false,
                  label: 'Custom Amounts',
                  icon: CUIcons.edit,
                ),
              ],
              selected: _equalSplit,
              onSelectionChanged: (value) {
                setState(() {
                  _equalSplit = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAmounts() {
    final theme = CUTheme.of(context);
    final totalAmount = double.tryParse(_amountController.text) ?? 0;

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Individual Amounts',
              style: CUTypography.bodyLG.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: CUSpacing.sm),
            ..._selectedRecipients.map((recipient) {
              final controller = _customAmountControllers[recipient.id]!;
              return Padding(
                padding: EdgeInsets.only(bottom: CUSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        recipient.name,
                        style: CUTypography.bodyMD.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(width: CUSpacing.md),
                    Expanded(
                      child: CUTextField(
                        controller: controller,
                        prefix: const Text('\$ '),
                        isDense: true,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Required';
                          }
                          final amount = double.tryParse(value!);
                          if (amount == null || amount <= 0) {
                            return 'Invalid';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (totalAmount > 0) ...[
              CUDivider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: CUTypography.bodyMD.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${totalAmount.toStringAsFixed(2)}',
                    style: CUTypography.bodyMD.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMemoField() {
    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Memo (Optional)',
              style: CUTypography.bodyLG.copyWith(
                fontWeight: FontWeight.w600,
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

  Widget _buildRequestInfo() {
    final theme = CUTheme.of(context);
    final limits = _zelleService.getZelleLimits();

    return CUCard(
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  CUIcons.info_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: CUSpacing.xs),
                Text(
                  'Request Information',
                  style: CUTypography.bodyLG.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            Text(
              'Requests expire in ${limits['request_expiration_days']} days\n'
              'Recipients will receive an email notification\n'
              'You\'ll be notified when the request is paid',
              style: CUTypography.bodyMD.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplitBillInfo() {
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
                Icon(
                  CUIcons.info_outline,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: CUSpacing.xs),
                Text(
                  'Split Bill Information',
                  style: CUTypography.bodyLG.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            Text(
              'Each person will receive a separate payment request\n'
              'You can track individual payments in your activity\n'
              'Recipients have 7 days to pay their share',
              style: CUTypography.bodyMD.copyWith(
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

// Recipient selection dialog
class _RecipientSelectionDialog extends StatefulWidget {
  final List<ZelleRecipient> recipients;
  final List<ZelleRecipient> selectedRecipients;
  final bool multiple;

  const _RecipientSelectionDialog({
    required this.recipients,
    required this.selectedRecipients,
    required this.multiple,
  });

  @override
  State<_RecipientSelectionDialog> createState() => _RecipientSelectionDialogState();
}

class _RecipientSelectionDialogState extends State<_RecipientSelectionDialog> {
  late List<ZelleRecipient> _selected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = List.from(widget.selectedRecipients);
  }

  List<ZelleRecipient> get _filteredRecipients {
    if (_searchQuery.isEmpty) return widget.recipients;

    final query = _searchQuery.toLowerCase();
    return widget.recipients.where((recipient) {
      return recipient.name.toLowerCase().contains(query) ||
          recipient.email.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUDialog(
      title: widget.multiple ? 'Select Recipients' : 'Select Recipient',
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            CUTextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              hintText: 'Search contacts',
              prefixIcon: CUIcons.search,
            ),
            SizedBox(height: CUSpacing.md),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredRecipients.length,
                itemBuilder: (context, index) {
                  final recipient = _filteredRecipients[index];
                  final isSelected = _selected.contains(recipient);

                  return CUListTile(
                    leading: CUAvatar(
                      child: Text(recipient.name[0].toUpperCase()),
                    ),
                    title: recipient.name,
                    subtitle: recipient.email,
                    trailing: widget.multiple
                        ? CUCheckbox(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value ?? false) {
                                  _selected.add(recipient);
                                } else {
                                  _selected.remove(recipient);
                                }
                              });
                            },
                          )
                        : isSelected
                            ? Icon(CUIcons.check_circle, color: CUColors.success)
                            : null,
                    onTap: () {
                      if (widget.multiple) {
                        setState(() {
                          if (isSelected) {
                            _selected.remove(recipient);
                          } else {
                            _selected.add(recipient);
                          }
                        });
                      } else {
                        Navigator.pop(context, [recipient]);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        CUButton.text(
          label: 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        if (widget.multiple)
          CUButton.filled(
            label: 'Select (${_selected.length})',
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.pop(context, _selected),
          ),
      ],
    );
  }
}
