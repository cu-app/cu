import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import '../../services/plaid_service.dart';

class ConnectedAppsScreen extends StatefulWidget {
  const ConnectedAppsScreen({super.key});

  @override
  State<ConnectedAppsScreen> createState() => _ConnectedAppsScreenState();
}

class _ConnectedAppsScreenState extends State<ConnectedAppsScreen> {
  final PlaidService _plaidService = PlaidService();
  List<ConnectedApp> _connectedApps = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConnectedApps();
  }

  Future<void> _loadConnectedApps() async {
    setState(() => _isLoading = true);

    // Simulate loading connected apps with Plaid data
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _connectedApps = [
        ConnectedApp(
          id: '1',
          name: 'Plaid',
          description: 'Financial data aggregation',
          logoUrl: 'https://www.google.com/s2/favicons?domain=plaid.com&sz=128',
          connectedDate: DateTime.now().subtract(const Duration(days: 30)),
          lastAccessed: DateTime.now().subtract(const Duration(hours: 2)),
          permissions: [
            AppPermission(type: PermissionType.accounts, granted: true),
            AppPermission(type: PermissionType.transactions, granted: true),
            AppPermission(type: PermissionType.identity, granted: true),
            AppPermission(type: PermissionType.balances, granted: true),
          ],
          status: ConnectionStatus.active,
        ),
        ConnectedApp(
          id: '2',
          name: 'Mint',
          description: 'Budget tracking and financial planning',
          logoUrl: 'https://www.google.com/s2/favicons?domain=mint.com&sz=128',
          connectedDate: DateTime.now().subtract(const Duration(days: 15)),
          lastAccessed: DateTime.now().subtract(const Duration(days: 1)),
          permissions: [
            AppPermission(type: PermissionType.accounts, granted: true),
            AppPermission(type: PermissionType.transactions, granted: true),
            AppPermission(type: PermissionType.balances, granted: true),
          ],
          status: ConnectionStatus.active,
        ),
        ConnectedApp(
          id: '3',
          name: 'Personal Capital',
          description: 'Investment and wealth management',
          logoUrl: 'https://www.google.com/s2/favicons?domain=personalcapital.com&sz=128',
          connectedDate: DateTime.now().subtract(const Duration(days: 60)),
          lastAccessed: DateTime.now().subtract(const Duration(days: 7)),
          permissions: [
            AppPermission(type: PermissionType.accounts, granted: true),
            AppPermission(type: PermissionType.balances, granted: true),
          ],
          status: ConnectionStatus.needsReauth,
        ),
      ];
      _isLoading = false;
    });
  }

  Future<void> _showAppDetails(ConnectedApp app) async {
    await CUDialog.show(
      context: context,
      builder: (context) => _AppDetailsDialog(app: app, onRevoke: () => _revokeAccess(app)),
    );
  }

  Future<void> _revokeAccess(ConnectedApp app) async {
    final confirmed = await CUDialog.show<bool>(
      context: context,
      builder: (context) => _RevokeConfirmationDialog(appName: app.name),
    );

    if (confirmed == true) {
      setState(() {
        _connectedApps.removeWhere((a) => a.id == app.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return CUScacuold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CUAppBar(
        title: Text(
          'Connected Apps',
          style: CUTypography.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Icon(CUIcons.arrowBack, color: theme.colorScheme.onPrimary),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 800 : double.infinity,
          ),
          child: CustomScrollView(
            slivers: [
              // Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(CUSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Your Data Sharing',
                        style: CUTypography.headlineLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: CUSpacing.xs),
                      Text(
                        'Control which apps have access to your financial data. You can revoke access at any time.',
                        style: CUTypography.bodyLarge.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats Section
              if (_connectedApps.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: CUSpacing.lg, vertical: CUSpacing.xs),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: CUIcons.apps,
                            label: 'Active Apps',
                            value: '${_connectedApps.where((a) => a.status == ConnectionStatus.active).length}',
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: CUSpacing.sm),
                        Expanded(
                          child: _StatCard(
                            icon: CUIcons.warningRounded,
                            label: 'Need Attention',
                            value: '${_connectedApps.where((a) => a.status == ConnectionStatus.needsReauth).length}',
                            color: CUColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Connected Apps List
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CUProgressIndicator(),
                  ),
                )
              else if (_connectedApps.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CUIcons.security,
                          size: CUSize.iconLarge * 2,
                          color: theme.colorScheme.outline,
                        ),
                        SizedBox(height: CUSpacing.md),
                        Text(
                          'No Connected Apps',
                          style: CUTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: CUSpacing.xs),
                        Text(
                          'You haven\'t connected any third-party apps yet',
                          style: CUTypography.bodyMedium.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(CUSpacing.lg, CUSpacing.xs, CUSpacing.lg, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final app = _connectedApps[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: CUSpacing.sm),
                          child: _ConnectedAppCard(
                            app: app,
                            onTap: () => _showAppDetails(app),
                          ),
                        );
                      },
                      childCount: _connectedApps.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUOutlinedCard(
      child: Column(
        children: [
          Icon(icon, color: color, size: CUSize.iconMedium),
          SizedBox(height: CUSpacing.xs),
          Text(
            value,
            style: CUTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: CUSpacing.xxs),
          Text(
            label,
            style: CUTypography.labelSmall.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectedAppCard extends StatelessWidget {
  final ConnectedApp app;
  final VoidCallback onTap;

  const _ConnectedAppCard({required this.app, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final statusColor = app.status == ConnectionStatus.active
        ? CUColors.success
        : CUColors.warning;

    final statusText = app.status == ConnectionStatus.active
        ? 'Active'
        : 'Needs Reauth';

    return CUOutlinedCard(
      onTap: onTap,
      child: Row(
        children: [
          CUAvatar(
            text: app.name,
            size: CUSize.iconLarge * 1.5,
            imageUrl: app.logoUrl,
            icon: CUIcons.apps,
          ),
          SizedBox(width: CUSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.name,
                  style: CUTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: CUSpacing.xxs),
                Text(
                  app.description,
                  style: CUTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: CUSpacing.xs),
                Row(
                  children: [
                    Container(
                      width: CUSize.iconSmall / 2,
                      height: CUSize.iconSmall / 2,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: CUSpacing.xs),
                    Text(
                      statusText,
                      style: CUTypography.labelSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: CUSpacing.sm),
                    Icon(CUIcons.circle, size: CUSize.iconSmall / 4, color: theme.colorScheme.outline),
                    SizedBox(width: CUSpacing.xs),
                    Text(
                      _formatLastAccessed(app.lastAccessed),
                      style: CUTypography.labelSmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(CUIcons.chevronRight, color: theme.colorScheme.outline),
        ],
      ),
    );
  }

  String _formatLastAccessed(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _AppDetailsDialog extends StatelessWidget {
  final ConnectedApp app;
  final VoidCallback onRevoke;

  const _AppDetailsDialog({required this.app, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUDialog(
      maxWidth: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CUAvatar(
                text: app.name,
                size: CUSize.iconLarge * 1.75,
                imageUrl: app.logoUrl,
                icon: CUIcons.apps,
              ),
              SizedBox(width: CUSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      app.name,
                      style: CUTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: CUSpacing.xxs),
                    Text(
                      app.description,
                      style: CUTypography.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(CUIcons.close, color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          SizedBox(height: CUSpacing.xl),

          // Connection Info
          Text(
            'Connection Details',
            style: CUTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: CUSpacing.sm),
          _InfoRow(
            label: 'Connected',
            value: _formatDate(app.connectedDate),
          ),
          _InfoRow(
            label: 'Last Access',
            value: _formatDate(app.lastAccessed),
          ),
          SizedBox(height: CUSpacing.xl),

          // Permissions
          Text(
            'Data Access Permissions',
            style: CUTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: CUSpacing.sm),
          ...app.permissions.map((perm) => _PermissionRow(permission: perm)),
          SizedBox(height: CUSpacing.xl),

          // Actions
          Row(
            children: [
              Expanded(
                child: CUButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onRevoke();
                  },
                  variant: CUButtonVariant.secondary,
                  child: const Text('Revoke Access'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: CUSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: CUTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: CUTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  final AppPermission permission;

  const _PermissionRow({required this.permission});

  @override
  Widget build(BuildContext context) {
    final icon = _getPermissionIcon(permission.type);
    final label = _getPermissionLabel(permission.type);

    return Padding(
      padding: EdgeInsets.only(bottom: CUSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: CUSize.iconSmall, color: CUColors.success),
          SizedBox(width: CUSpacing.sm),
          Text(
            label,
            style: CUTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  IconData _getPermissionIcon(PermissionType type) {
    switch (type) {
      case PermissionType.accounts:
        return CUIcons.accountBalanceWallet;
      case PermissionType.transactions:
        return CUIcons.receiptLong;
      case PermissionType.identity:
        return CUIcons.person;
      case PermissionType.balances:
        return CUIcons.accountBalance;
    }
  }

  String _getPermissionLabel(PermissionType type) {
    switch (type) {
      case PermissionType.accounts:
        return 'Account Information';
      case PermissionType.transactions:
        return 'Transaction History';
      case PermissionType.identity:
        return 'Identity Verification';
      case PermissionType.balances:
        return 'Account Balances';
    }
  }
}

class _RevokeConfirmationDialog extends StatelessWidget {
  final String appName;

  const _RevokeConfirmationDialog({required this.appName});

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUDialog(
      maxWidth: 400,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CUIcons.warningRounded, size: CUSize.iconLarge * 1.5, color: CUColors.warning),
          SizedBox(height: CUSpacing.md),
          Text(
            'Revoke Access?',
            style: CUTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.sm),
          Text(
            'This will immediately revoke $appName\'s access to your financial data. The app will no longer be able to view your accounts, transactions, or balances.',
            textAlign: TextAlign.center,
            style: CUTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.xl),
          Row(
            children: [
              Expanded(
                child: CUButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  variant: CUButtonVariant.secondary,
                  child: const Text('Cancel'),
                ),
              ),
              SizedBox(width: CUSpacing.sm),
              Expanded(
                child: CUButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  variant: CUButtonVariant.secondary,
                  child: const Text('Revoke'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Models
class ConnectedApp {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final DateTime connectedDate;
  final DateTime lastAccessed;
  final List<AppPermission> permissions;
  final ConnectionStatus status;

  ConnectedApp({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    required this.connectedDate,
    required this.lastAccessed,
    required this.permissions,
    required this.status,
  });
}

class AppPermission {
  final PermissionType type;
  final bool granted;

  AppPermission({required this.type, required this.granted});
}

enum PermissionType { accounts, transactions, identity, balances }
enum ConnectionStatus { active, needsReauth, revoked }
