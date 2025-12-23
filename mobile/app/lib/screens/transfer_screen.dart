import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'package:flutter/services.dart';
import '../services/banking_service.dart';
import '../services/auth_service.dart';
import '../services/plaid_service.dart';
import '../services/transfers_service.dart';
import '../services/zelle_service.dart';
import '../services/security_service.dart';
import '../models/zelle_model.dart';
// import 'zelle_contacts_screen.dart'; // Disabled - needs CU widgets
import 'zelle_send_screen.dart';
import 'zelle_request_screen.dart';
import '../widgets/consistent_list_tile.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> with TickerProviderStateMixin {
  final BankingService _bankingService = BankingService();
  final AuthService _authService = AuthService();
  final PlaidService _plaidService = PlaidService();
  final TransfersService _transfersService = TransfersService();
  final ZelleService _zelleService = ZelleService();
  final SecurityService _securityService = SecurityService();
  final _internalFormKey = GlobalKey<FormState>();
  final _achFormKey = GlobalKey<FormState>();
  final _wireFormKey = GlobalKey<FormState>();
  final _zelleFormKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _accounts = [];
  String? _selectedFromAccountId;
  String? _selectedToAccountId;
  bool _isLoading = false;
  bool _isTransferring = false;
  String? _errorMessage;
  String? _successMessage;
  
  // Transfer type tabs
  late TabController _tabController;
  int _currentTabIndex = 0;
  
  // ACH Transfer fields
  final _recipientNameController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _confirmAccountNumberController = TextEditingController();
  String _achAccountType = 'checking';
  
  // Zelle fields
  final _zelleEmailController = TextEditingController();
  final _zelleNameController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    _tabController.dispose();
    _recipientNameController.dispose();
    _routingNumberController.dispose();
    _accountNumberController.dispose();
    _confirmAccountNumberController.dispose();
    _zelleEmailController.dispose();
    _zelleNameController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Try to load from Plaid first if connected
      if (_plaidService.hasLinkedAccounts) {
        final plaidAccounts = await _plaidService.getAccounts();
        setState(() {
          _accounts = plaidAccounts.map((account) => {
            'id': account['account_id'],
            'name': account['name'],
            'type': account['type'],
            'subtype': account['subtype'],
            'balance': account['balances']['current'] ?? 0.0,
            'available': account['balances']['available'] ?? 0.0,
            'institution': account['institution_name'] ?? 'Bank',
            'mask': account['mask'],
          }).toList();
          _isLoading = false;
        });
      } else {
        // Fallback to regular accounts
        final accounts = await _bankingService.getUserAccounts();
        setState(() {
          _accounts = accounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load accounts: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _initiateTransfer() async {
    // Get the current form key based on tab
    final formKey = _getCurrentFormKey();
    if (formKey.currentState != null && !formKey.currentState!.validate()) return;
    
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _errorMessage = 'Please enter a valid amount';
      });
      return;
    }

    // Check if biometric authentication is required for transactions
    final securitySettings = await _securityService.getSecuritySettings();
    if (securitySettings.biometricEnabled && securitySettings.biometricForTransactions) {
      final authenticated = await _authService.authenticateForOperation(
        'Authenticate to complete transfer',
      );
      
      if (!authenticated) {
        setState(() {
          _errorMessage = 'Authentication required to complete transfer';
        });
        return;
      }
    }

    setState(() {
      _isTransferring = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      // Haptic feedback
      HapticFeedback.lightImpact();
      
      Map<String, dynamic> result;
      
      switch (_currentTabIndex) {
        case 0: // Between accounts
          if (_selectedFromAccountId == null || _selectedToAccountId == null) {
            setState(() {
              _errorMessage = 'Please select both accounts';
              _isTransferring = false;
            });
            return;
          }
          
          result = await _transfersService.processInternalTransfer(
            fromAccountId: _selectedFromAccountId!,
            toAccountId: _selectedToAccountId!,
            amount: amount,
            memo: _descriptionController.text.trim(),
          );
          break;
          
        case 1: // ACH Transfer
          if (_selectedFromAccountId == null) {
            setState(() {
              _errorMessage = 'Please select a source account';
              _isTransferring = false;
            });
            return;
          }
          
          if (_accountNumberController.text != _confirmAccountNumberController.text) {
            setState(() {
              _errorMessage = 'Account numbers do not match';
              _isTransferring = false;
            });
            return;
          }
          
          // In production, this would use Plaid Transfer API
          result = await _transfersService.processExternalTransfer(
            fromAccountId: _selectedFromAccountId!,
            externalAccountNumber: _accountNumberController.text,
            externalRoutingNumber: _routingNumberController.text,
            externalBankName: _recipientNameController.text,
            amount: amount,
            memo: _descriptionController.text.trim(),
          );
          break;
          
        case 2: // Wire Transfer
          // Similar to ACH but with higher limits and fees
          if (_selectedFromAccountId == null) {
            setState(() {
              _errorMessage = 'Wire transfers coming soon!';
              _isTransferring = false;
            });
            return;
          }
          result = {'transfer_id': 'WIRE_DEMO_001', 'status': 'pending'};
          break;
          
        case 3: // Zelle
          if (_selectedFromAccountId == null) {
            setState(() {
              _errorMessage = 'Please select a source account';
              _isTransferring = false;
            });
            return;
          }
          
          result = await _transfersService.processZelleTransfer(
            fromAccountId: _selectedFromAccountId!,
            recipientEmail: _zelleEmailController.text,
            recipientName: _zelleNameController.text,
            amount: amount,
            memo: _descriptionController.text.trim(),
          );
          break;
          
        default:
          result = {'transfer_id': 'UNKNOWN', 'status': 'failed'};
      }

      setState(() {
        _successMessage = _getSuccessMessage(result);
        _isTransferring = false;
      });

      // Success haptic
      HapticFeedback.heavyImpact();

      // Clear form
      _clearForm();

      // Refresh accounts to show updated balances
      await _loadAccounts();
    } catch (e) {
      setState(() {
        _errorMessage = 'Transfer failed: ${e.toString()}';
        _isTransferring = false;
      });

      // Error haptic
      HapticFeedback.vibrate();
    }
  }
  
  String _getSuccessMessage(Map<String, dynamic> result) {
    final transferType = ['Between Accounts', 'ACH Transfer', 'Wire Transfer', 'Zelle'][_currentTabIndex];
    final status = result['status'] ?? 'completed';
    final transferId = result['transfer_id'] ?? result['id'] ?? 'N/A';
    
    if (status == 'pending') {
      return '$transferType initiated!\nTransfer ID: $transferId\nStatus: Processing (1-3 business days)';
    } else {
      return '$transferType completed successfully!\nTransfer ID: $transferId';
    }
  }
  
  GlobalKey<FormState> _getCurrentFormKey() {
    switch (_currentTabIndex) {
      case 0:
        return _internalFormKey;
      case 1:
        return _achFormKey;
      case 2:
        return _wireFormKey;
      case 3:
        return _zelleFormKey;
      default:
        return _internalFormKey;
    }
  }
  
  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    _selectedFromAccountId = null;
    _selectedToAccountId = null;
    _recipientNameController.clear();
    _routingNumberController.clear();
    _accountNumberController.clear();
    _confirmAccountNumberController.clear();
    _zelleEmailController.clear();
    _zelleNameController.clear();
  }

  Widget _buildAccountDropdown({
    required String label,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
    required List<Map<String, dynamic>> accounts,
    String? excludeAccountId,
  }) {
    final theme = CUTheme.of(context);
    final availableAccounts = accounts
        .where((account) =>
            excludeAccountId == null || account['id'] != excludeAccountId)
        .toList();

    final selectedAccount = availableAccounts.firstWhere(
      (account) => account['id'] == selectedValue,
      orElse: () => {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CUTypography.titleMedium.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showAccountSelectionBottomSheet(
            context,
            label,
            selectedValue,
            onChanged,
            availableAccounts,
          ),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: selectedValue != null
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: selectedValue != null
                  ? theme.colorScheme.primaryContainer.withOpacity(0.1)
                  : theme.colorScheme.surfaceVariant,
            ),
            child: Row(
              children: [
                Expanded(
                  child: selectedValue != null
                      ? _buildSelectedAccountDisplay(selectedAccount)
                      : Text(
                          'Select an account',
                          style: CUTypography.bodyLarge.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                ),
                CUIcon(Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedAccountDisplay(Map<String, dynamic> account) {
    final theme = CUTheme.of(context);
    final balance = account['balance'] ?? 0.0;
    final name = account['name'] ?? 'Unknown Account';
    final mask = account['mask'] ?? '****';
    final type = account['subtype'] ?? 'account';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: CUTypography.titleMedium.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                type.toUpperCase(),
                style: CUTypography.bodySmall.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '•••• $mask',
              style: CUTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Balance: \$${balance.toStringAsFixed(2)}',
          style: CUTypography.bodyLarge.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }

  void _showAccountSelectionBottomSheet(
    BuildContext context,
    String label,
    String? selectedValue,
    ValueChanged<String?> onChanged,
    List<Map<String, dynamic>> accounts,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: CUColors.transparent,
      builder: (context) => _AccountSelectionBottomSheet(
        label: label,
        selectedValue: selectedValue,
        onChanged: onChanged,
        accounts: accounts,
      ),
    );
  }

  Widget _buildOldTransferForm(BuildContext context) {
    final theme = CUTheme.of(context);
    return CUCard(
      elevation: 4,
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transfer Details',
              style: CUTypography.titleLarge.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
            ),
            const SizedBox(height: 24),

            // From Account
            _buildAccountDropdown(
              label: 'From Account',
              selectedValue: _selectedFromAccountId,
              onChanged: (value) {
                setState(() {
                  _selectedFromAccountId = value;
                });
              },
              accounts: _accounts,
              excludeAccountId: _selectedToAccountId,
            ),

            const SizedBox(height: 16),

            // To Account
            _buildAccountDropdown(
              label: 'To Account',
              selectedValue: _selectedToAccountId,
              onChanged: (value) {
                setState(() {
                  _selectedToAccountId = value;
                });
              },
              accounts: _accounts,
              excludeAccountId: _selectedFromAccountId,
            ),

            const SizedBox(height: 16),

            // Amount
            CUTextField(
              controller: _amountController,
              labelText: 'Amount',
              prefixText: '\$',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            CUTextField(
              controller: _descriptionController,
              labelText: 'Description (Optional)',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOldTransferButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: CUButton(
        onPressed: _isTransferring ? null : _initiateTransfer,
        text: _isTransferring ? 'Processing Transfer...' : 'Initiate Transfer',
        isLoading: _isTransferring,
      ),
    );
  }

  Widget _buildOldMessages(BuildContext context) {
    final theme = CUTheme.of(context);
    return Column(
      children: [
        if (_errorMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _errorMessage!,
              style: CUTypography.bodyLarge.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        if (_successMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _successMessage!,
              style: CUTypography.bodyLarge.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildOldTransferHistory(BuildContext context) {
    final theme = CUTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;
    return CUCard(
      elevation: 4,
      borderRadius: 16,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Transfers',
                  style: CUTypography.titleLarge.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to full transfer history
                  },
                  child: Text(
                    'View All',
                    style: CUTypography.bodyLarge.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // TODO: Add transfer history list
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  'No recent transfers',
                  style: CUTypography.bodyLarge.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return CUScaffold(
      backgroundColor: CUColors.white,
      appBar: CUAppBar(
        title: const Text('Transfer Money'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CULoadingSpinner(),
            )
          : Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isDesktop ? 1200 : double.infinity,
                ),
                child: Column(
                  children: [
                    // Tab bar
                    Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: CUColors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    controller: _tabController,
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                    indicatorColor: theme.colorScheme.primary,
                    indicatorWeight: 3,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Geist',
                    ),
                    tabs: const [
                      Tab(text: 'Between\nAccounts', height: 60),
                      Tab(text: 'ACH\nTransfer', height: 60),
                      Tab(text: 'Wire\nTransfer', height: 60),
                      Tab(text: 'Zelle', height: 60),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Between Accounts
                      _buildTransferTab(
                        child: _buildInternalTransferForm(context),
                      ),

                      // ACH Transfer
                      _buildTransferTab(
                        child: _buildACHTransferForm(context),
                      ),

                      // Wire Transfer
                      _buildTransferTab(
                        child: _buildWireTransferForm(context),
                      ),

                      // Zelle
                      _buildTransferTab(
                        child: _buildZelleTransferForm(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
              ),
            ),
    );
  }
  
  Widget _buildTransferTab({required Widget child}) {
    final theme = CUTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.surface,
            theme.colorScheme.surfaceVariant.withOpacity(0.3),
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isDesktop ? 600 : double.infinity,
            ),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        child,
                        const SizedBox(height: 24),
                        _buildMessages(context),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildInternalTransferForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTransferHeader(context, 'Transfer Between Accounts'),
        const SizedBox(height: 32),
        _buildAccountDropdown(
          label: 'From Account',
          selectedValue: _selectedFromAccountId,
          onChanged: (value) => setState(() => _selectedFromAccountId = value),
          accounts: _accounts,
          excludeAccountId: _selectedToAccountId,
        ),
        const SizedBox(height: 16),
        _buildAccountDropdown(
          label: 'To Account',
          selectedValue: _selectedToAccountId,
          onChanged: (value) => setState(() => _selectedToAccountId = value),
          accounts: _accounts,
          excludeAccountId: _selectedFromAccountId,
        ),
        const SizedBox(height: 24),
        _buildAmountField(context),
        const SizedBox(height: 16),
        _buildDescriptionField(context),
        const SizedBox(height: 32),
        _buildTransferButton(context),
      ],
    );
  }
  
  Widget _buildACHTransferForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTransferHeader(context, 'ACH Transfer'),
        const SizedBox(height: 32),
        _buildAccountDropdown(
          label: 'From Account',
          selectedValue: _selectedFromAccountId,
          onChanged: (value) => setState(() => _selectedFromAccountId = value),
          accounts: _accounts,
        ),
        const SizedBox(height: 24),
        CUTextField(
          controller: _recipientNameController,
          labelText: 'Recipient Name / Bank Name',
          prefixIcon: CUIcon(Icons.person),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        CUTextField(
          controller: _routingNumberController,
          labelText: 'Routing Number',
          prefixIcon: CUIcon(Icons.numbers),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Required';
            if (value!.length != 9) return 'Must be 9 digits';
            return null;
          },
        ),
        const SizedBox(height: 16),
        CUTextField(
          controller: _accountNumberController,
          labelText: 'Account Number',
          prefixIcon: CUIcon(Icons.account_balance),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        CUTextField(
          controller: _confirmAccountNumberController,
          labelText: 'Confirm Account Number',
          prefixIcon: CUIcon(Icons.account_balance),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Required';
            if (value != _accountNumberController.text) return 'Account numbers do not match';
            return null;
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _achAccountType,
          decoration: InputDecoration(
            labelText: 'Account Type',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: CUIcon(Icons.category),
          ),
          items: const [
            DropdownMenuItem(value: 'checking', child: Text('Checking')),
            DropdownMenuItem(value: 'savings', child: Text('Savings')),
          ],
          onChanged: (value) => setState(() => _achAccountType = value!),
        ),
        const SizedBox(height: 24),
        _buildAmountField(context),
        const SizedBox(height: 16),
        _buildDescriptionField(context),
        const SizedBox(height: 32),
        _buildTransferButton(context),
        const SizedBox(height: 16),
        _buildACHInfo(context),
      ],
    );
  }
  
  Widget _buildWireTransferForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTransferHeader(context, 'Wire Transfer'),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: CUColors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: CUColors.orange),
          ),
          child: Row(
            children: [
              CUIcon(Icons.info_outline, color: CUColors.orange),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Wire transfers are coming soon! For now, please visit a branch or call customer service.',
                  style: CUTypography.bodyMedium.copyWith(color: CUColors.orange.shade800),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildZelleTransferForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildTransferHeader(context, 'Send with Zelle®'),
        const SizedBox(height: 32),

        // Quick actions
        _buildZelleQuickActions(),
        const SizedBox(height: 24),

        // Recent recipients
        _buildRecentRecipients(),
        const SizedBox(height: 24),

        _buildAccountDropdown(
          label: 'From Account',
          selectedValue: _selectedFromAccountId,
          onChanged: (value) => setState(() => _selectedFromAccountId = value),
          accounts: _accounts,
        ),
        const SizedBox(height: 24),
        CUTextField(
          controller: _zelleEmailController,
          labelText: 'Recipient Email or Phone',
          prefixIcon: CUIcon(Icons.email),
          suffixIcon: IconButton(
            icon: CUIcon(Icons.contacts),
            onPressed: () => _selectZelleRecipient(),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        CUTextField(
          controller: _zelleNameController,
          labelText: 'Recipient Name',
          prefixIcon: CUIcon(Icons.person),
          validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
        ),
        const SizedBox(height: 24),
        _buildAmountField(context),
        const SizedBox(height: 16),
        _buildDescriptionField(context),
        const SizedBox(height: 32),
        _buildTransferButton(context),
        const SizedBox(height: 16),
        _buildZelleInfo(context),
      ],
    );
  }
  
  Widget _buildTransferHeader(BuildContext context, String title) {
    final theme = CUTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: CUTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _getTransferDescription(),
          style: CUTypography.bodyLarge.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
  
  String _getTransferDescription() {
    switch (_currentTabIndex) {
      case 0:
        return 'Transfer money instantly between your accounts';
      case 1:
        return 'Send money to external bank accounts (1-3 business days)';
      case 2:
        return 'Fast same-day transfers with higher limits';
      case 3:
        return 'Send money instantly to friends and family';
      default:
        return 'Select a transfer type to get started';
    }
  }
  
  Widget _buildAmountField(BuildContext context) {
    return CUTextField(
      controller: _amountController,
      labelText: 'Amount',
      prefixText: '\$ ',
      prefixIcon: CUIcon(Icons.attach_money),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please enter an amount';
        final amount = double.tryParse(value!);
        if (amount == null || amount <= 0) return 'Enter a valid amount';
        return null;
      },
    );
  }
  
  Widget _buildDescriptionField(BuildContext context) {
    return CUTextField(
      controller: _descriptionController,
      labelText: 'Description (Optional)',
      prefixIcon: CUIcon(Icons.description),
      maxLines: 2,
    );
  }
  
  Widget _buildTransferButton(BuildContext context) {
    return CUButton(
      onPressed: _isTransferring ? null : _initiateTransfer,
      text: _getTransferButtonText(),
      isLoading: _isTransferring,
    );
  }
  
  String _getTransferButtonText() {
    switch (_currentTabIndex) {
      case 0:
        return 'Transfer Now';
      case 1:
        return 'Send ACH Transfer';
      case 2:
        return 'Send Wire Transfer';
      case 3:
        return 'Send with Zelle';
      default:
        return 'Transfer';
    }
  }
  
  Widget _buildMessages(BuildContext context) {
    if (_errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CUColors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CUColors.red),
        ),
        child: Row(
          children: [
            CUIcon(Icons.error_outline, color: CUColors.red),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _errorMessage!,
                style: CUTypography.bodyMedium.copyWith(color: CUColors.red),
              ),
            ),
          ],
        ),
      );
    }

    if (_successMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: CUColors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: CUColors.green),
        ),
        child: Row(
          children: [
            CUIcon(Icons.check_circle_outline, color: CUColors.green),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                _successMessage!,
                style: CUTypography.bodyMedium.copyWith(color: CUColors.green),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
  
  Widget _buildACHInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CUColors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CUIcon(Icons.info_outline, color: CUColors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'ACH Transfer Information',
                style: CUTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CUColors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Processing time: 1-3 business days\n'
            '• Daily limit: \$5,000\n'
            '• Monthly limit: \$25,000\n'
            '• No fees for standard transfers',
            style: CUTypography.bodySmall.copyWith(
              color: CUColors.blue.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildZelleInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CUColors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CUIcon(Icons.flash_on, color: CUColors.purple.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Zelle® Information',
                style: CUTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: CUColors.purple.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Money sent in minutes\n'
            '• Daily limit: \$2,000\n'
            '• Monthly limit: \$10,000\n'
            '• No fees',
            style: CUTypography.bodySmall.copyWith(
              color: CUColors.purple.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildZelleQuickActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Zelle Contacts - Coming Soon')),
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => const ZelleContactsScreen(),
              //   ),
              // ).then((result) {
              //   if (result == true) {
              //     _loadAccounts(); // Refresh if needed
              //   }
              // });
            },
            icon: CUIcon(Icons.people),
            label: const Text('Contacts'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ZelleSendScreen(),
                ),
              );
            },
            icon: CUIcon(Icons.send),
            label: const Text('Send'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ZelleRequestScreen(),
                ),
              );
            },
            icon: CUIcon(Icons.request_page),
            label: const Text('Request'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildRecentRecipients() {
    final theme = CUTheme.of(context);
    return FutureBuilder<List<ZelleRecipient>>(
      future: _zelleService.getRecentRecipients(limit: 5),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final recipients = snapshot.data!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Recipients',
                  style: CUTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Zelle Contacts - Coming Soon')),
                    );
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const ZelleContactsScreen(),
                    //   ),
                    // );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: recipients.length,
                itemBuilder: (context, index) {
                  final recipient = recipients[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index < recipients.length - 1 ? 12 : 0,
                    ),
                    child: InkWell(
                      onTap: () => _selectRecentRecipient(recipient),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 80,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: theme.colorScheme.primaryContainer,
                              child: Text(
                                recipient.name[0].toUpperCase(),
                                style: CUTypography.bodyMedium.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recipient.name.split(' ').first,
                              style: CUTypography.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _selectZelleRecipient() async {
    final recipients = await _zelleService.getEnrolledRecipients();

    if (!mounted) return;

    final selected = await showModalBottomSheet<ZelleRecipient>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final theme = CUTheme.of(context);
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) => Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: CUColors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'Select Recipient',
                  style: CUTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: recipients.length,
                    itemBuilder: (context, index) {
                      final recipient = recipients[index];
                      return ConsistentListTile(
                        leading: ConsistentListTileLeading(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Text(
                            recipient.name[0].toUpperCase(),
                            style: CUTypography.bodyMedium.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: ConsistentListTileTitle(text: recipient.name),
                        subtitle: ConsistentListTileSubtitle(text: recipient.email),
                        trailing: recipient.isEnrolled
                            ? CUIcon(Icons.check_circle, color: CUColors.green)
                            : null,
                        onTap: () => Navigator.pop(context, recipient),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _zelleEmailController.text = selected.email;
        _zelleNameController.text = selected.name;
      });
    }
  }
  
  void _selectRecentRecipient(ZelleRecipient recipient) {
    setState(() {
      _zelleEmailController.text = recipient.email;
      _zelleNameController.text = recipient.name;
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Show selected indicator
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Selected ${recipient.name}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
}

class _AccountSelectionBottomSheet extends StatefulWidget {
  final String label;
  final String? selectedValue;
  final ValueChanged<String?> onChanged;
  final List<Map<String, dynamic>> accounts;

  const _AccountSelectionBottomSheet({
    required this.label,
    required this.selectedValue,
    required this.onChanged,
    required this.accounts,
  });

  @override
  State<_AccountSelectionBottomSheet> createState() => _AccountSelectionBottomSheetState();
}

class _AccountSelectionBottomSheetState extends State<_AccountSelectionBottomSheet>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideController.forward();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Container(
      height: isDesktop ? 400 : MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: CUColors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                CUIcon(
                  Icons.account_balance,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Select ${widget.label.toLowerCase()}',
                    style: CUTypography.headlineSmall.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: CUIcon(Icons.close),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Account list
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: widget.accounts.length,
                  itemBuilder: (context, index) {
                    final account = widget.accounts[index];
                    final isSelected = account['id'] == widget.selectedValue;

                    return _buildAccountCard(context, account, isSelected);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, Map<String, dynamic> account, bool isSelected) {
    final theme = CUTheme.of(context);
    final balance = account['balance'] ?? 0.0;
    final name = account['name'] ?? 'Unknown Account';
    final mask = account['mask'] ?? '****';
    final type = account['subtype'] ?? 'account';
    final institution = account['institution'] ?? 'Bank';

    return Hero(
      tag: 'account_${account['id']}',
      child: Material(
        color: CUColors.transparent,
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: InkWell(
            onTap: () {
              widget.onChanged(account['id']);
              Navigator.pop(context);
              HapticFeedback.lightImpact();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Account icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: CUIcon(
                      _getAccountIcon(type),
                      color: isSelected
                          ? CUColors.white
                          : theme.colorScheme.onPrimaryContainer,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Account details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: CUTypography.titleLarge.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onPrimaryContainer
                                    : theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          institution,
                          style: CUTypography.bodyMedium.copyWith(
                                color: isSelected
                                    ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                type.toUpperCase(),
                                style: CUTypography.bodySmall.copyWith(
                                      color: isSelected
                                          ? CUColors.white
                                          : theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•••• $mask',
                              style: CUTypography.bodyMedium.copyWith(
                                    color: isSelected
                                        ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Balance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${balance.toStringAsFixed(2)}',
                        style: CUTypography.headlineSmall.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.onPrimaryContainer
                                  : theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'SELECTED',
                            style: CUTypography.bodySmall.copyWith(
                              color: CUColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getAccountIcon(String type) {
    switch (type.toLowerCase()) {
      case 'checking':
        return Icons.account_balance;
      case 'savings':
        return Icons.savings;
      case 'credit card':
        return Icons.credit_card;
      case 'loan':
        return Icons.account_balance_wallet;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }
}
