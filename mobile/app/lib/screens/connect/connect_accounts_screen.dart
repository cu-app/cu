import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import '../../services/plaid_service.dart';
import '../../services/banking_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConnectAccountsScreen extends StatefulWidget {
  const ConnectAccountsScreen({super.key});

  @override
  State<ConnectAccountsScreen> createState() => _ConnectAccountsScreenState();
}

class _ConnectAccountsScreenState extends State<ConnectAccountsScreen> {
  final PlaidService _plaidService = PlaidService();
  final BankingService _bankingService = BankingService();
  final _searchController = TextEditingController();
  bool _isLoading = false;
  List<ConnectedAccount> _connectedAccounts = [];
  List<Institution> _popularInstitutions = [];
  List<Institution> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _loadConnectedAccounts();
    _loadPopularInstitutions();
  }

  Future<void> _loadConnectedAccounts() async {
    setState(() => _isLoading = true);
    try {
      // Load connected accounts from Plaid
      final accounts = await _bankingService.getUserAccounts();
      setState(() {
        _connectedAccounts = accounts.map((acc) => ConnectedAccount(
          id: acc['id'] ?? '',
          institutionName: acc['institution'] ?? 'Unknown Bank',
          accountName: acc['name'] ?? 'Account',
          accountType: acc['subtype'] ?? 'checking',
          mask: acc['mask'] ?? '****',
          balance: (acc['balance'] ?? 0.0).toDouble(),
          lastSync: DateTime.now(),
          status: ConnectionStatus.healthy,
        )).toList();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _loadPopularInstitutions() {
    _popularInstitutions = [
      Institution(id: 'ins_3', name: 'Chase', logo: '', plaidId: 'ins_3'),
      Institution(id: 'ins_1', name: 'Bank of America', logo: '', plaidId: 'ins_1'),
      Institution(id: 'ins_4', name: 'Wells Fargo', logo: '', plaidId: 'ins_4'),
      Institution(id: 'ins_5', name: 'Citi', logo: '🌆', plaidId: 'ins_5'),
      Institution(id: 'ins_6', name: 'US Bank', logo: '🇺🇸', plaidId: 'ins_6'),
      Institution(id: 'ins_7', name: 'PNC', logo: '', plaidId: 'ins_7'),
      Institution(id: 'ins_8', name: 'Capital One', logo: '💳', plaidId: 'ins_8'),
      Institution(id: 'ins_9', name: 'TD Bank', logo: '🍁', plaidId: 'ins_9'),
    ];
  }

  Future<void> _connectInstitution(Institution institution) async {
    setState(() => _isLoading = true);
    try {
      // Create Plaid Link token
      final linkToken = await _plaidService.createLinkToken();

      // In production, this would launch Plaid Link
      // For now, create a sandbox connection
      final publicToken = await _plaidService.createSandboxPublicToken(
        institutionId: institution.plaidId,
        initialProducts: ['auth', 'transactions', 'identity', 'accounts_details_transactions'],
      );

      // Exchange for access token
      await _plaidService.exchangePublicToken(publicToken);

      // Show success
      if (mounted) {
        HapticFeedback.mediumImpact();
        CUToaster.show(
          context,
          title: 'Successfully connected to ${institution.name}',
          variant: CUToastVariant.success,
        );

        // Reload accounts
        await _loadConnectedAccounts();
      }
    } catch (e) {
      if (mounted) {
        CUToaster.show(
          context,
          title: 'Failed to connect: ${e.toString()}',
          variant: CUToastVariant.error,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _searchInstitutions(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    setState(() {
      _searchResults = _popularInstitutions
          .where((inst) => inst.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      appBar: CUAppBar(
        title: const Text('Connected Accounts'),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Connected Accounts Section
            if (_connectedAccounts.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(CUSpacing.md),
                  child: Text(
                    'Connected Accounts',
                    style: CUTypography.h2(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final account = _connectedAccounts[index];
                    return _buildConnectedAccountCard(account);
                  },
                  childCount: _connectedAccounts.length,
                ),
              ),
            ],

            // Add New Account Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(CUSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Account',
                      style: CUTypography.h2(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: CUSpacing.md),

                    // Search Bar
                    CUTextField(
                      controller: _searchController,
                      onChanged: _searchInstitutions,
                      placeholder: 'Search for your bank or credit union',
                      prefixIcon: CUIcon(icon: CUIcons.search),
                    ),
                  ],
                ),
              ),
            ),

            // Search Results or Popular Banks
            if (_searchResults.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: CUSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: CUSpacing.sm,
                    crossAxisSpacing: CUSpacing.sm,
                    childAspectRatio: 2.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final institution = _searchResults[index];
                      return _buildInstitutionCard(institution);
                    },
                    childCount: _searchResults.length,
                  ),
                ),
              )
            else ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(CUSpacing.md, CUSpacing.xs, CUSpacing.md, CUSpacing.md),
                  child: Text(
                    'Popular Banks',
                    style: CUTypography.bodyMedium(context).copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: CUSpacing.md),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: CUSpacing.sm,
                    crossAxisSpacing: CUSpacing.sm,
                    childAspectRatio: 2.5,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final institution = _popularInstitutions[index];
                      return _buildInstitutionCard(institution);
                    },
                    childCount: _popularInstitutions.length,
                  ),
                ),
              ),
            ],

            // Loading Overlay
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CULoadingSpinner(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectedAccountCard(ConnectedAccount account) {
    final theme = CUTheme.of(context);
    final statusColor = account.status == ConnectionStatus.healthy
        ? CUColors.success
        : account.status == ConnectionStatus.needsReauth
            ? CUColors.warning
            : CUColors.error;

    return CUCard(
      margin: EdgeInsets.symmetric(horizontal: CUSpacing.md, vertical: CUSpacing.xs),
      child: CUListTile(
        leading: Container(
          width: CUSize.iconLg,
          height: CUSize.iconLg,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(CURadius.sm),
          ),
          child: CUIcon(icon: CUIcons.accountBalance, size: CUSize.iconMd),
        ),
        title: Text(account.institutionName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${account.accountName} ••${account.mask}'),
            SizedBox(height: CUSpacing.xxs),
            Row(
              children: [
                Container(
                  width: CUSize.xs,
                  height: CUSize.xs,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: CUSpacing.xxs),
                Text(
                  account.status.name,
                  style: CUTypography.bodySmall(context).copyWith(
                    color: statusColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '\$${account.balance.toStringAsFixed(2)}',
                  style: CUTypography.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: CUDropdownButton(
          items: [
            CUDropdownItem(
              value: 'refresh',
              label: 'Refresh',
              icon: CUIcons.refresh,
            ),
            CUDropdownItem(
              value: 'remove',
              label: 'Remove',
              icon: CUIcons.delete,
              destructive: true,
            ),
          ],
          onChanged: (value) {
            if (value == 'refresh') {
              _loadConnectedAccounts();
            } else if (value == 'remove') {
              // Handle account removal
            }
          },
        ),
        onTap: () {
          // Navigate to account details
        },
      ),
    );
  }

  Widget _buildInstitutionCard(Institution institution) {
    final theme = CUTheme.of(context);

    return CUCard(
      onTap: () => _connectInstitution(institution),
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.sm),
        child: Row(
          children: [
            Text(
              institution.logo,
              style: TextStyle(fontSize: CUSize.iconMd),
            ),
            SizedBox(width: CUSpacing.xs),
            Expanded(
              child: Text(
                institution.name,
                style: CUTypography.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Data Models
class ConnectedAccount {
  final String id;
  final String institutionName;
  final String accountName;
  final String accountType;
  final String mask;
  final double balance;
  final DateTime lastSync;
  final ConnectionStatus status;

  ConnectedAccount({
    required this.id,
    required this.institutionName,
    required this.accountName,
    required this.accountType,
    required this.mask,
    required this.balance,
    required this.lastSync,
    required this.status,
  });
}

enum ConnectionStatus { healthy, needsReauth, error }

class Institution {
  final String id;
  final String name;
  final String logo;
  final String plaidId;

  Institution({
    required this.id,
    required this.name,
    required this.logo,
    required this.plaidId,
  });
}
