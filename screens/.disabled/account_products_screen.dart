import 'package:flutter/widgets.dart';
import '../services/account_products_service.dart';
import '../services/sound_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/consistent_list_tile.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class AccountProductsScreen extends StatefulWidget {
  final Map<String, dynamic>? userProfile;
  final Map<String, dynamic>? biometricSettings;

  const AccountProductsScreen({
    super.key,
    this.userProfile,
    this.biometricSettings,
  });

  @override
  State<AccountProductsScreen> createState() => _AccountProductsScreenState();
}

class _AccountProductsScreenState extends State<AccountProductsScreen>
    with TickerProviderStateMixin {
  final AccountProductsService _productsService = AccountProductsService();

  late TabController _tabController;
  List<AccountProduct> _allProducts = [];
  List<AccountProduct> _recommendedProducts = [];
  List<AccountProduct> _bankingProducts = [];
  List<AccountProduct> _creditProducts = [];
  List<AccountProduct> _investmentProducts = [];

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load all available products
      _allProducts = await _productsService.getAvailableProducts();

      // Get recommendations if user profile is provided
      if (widget.userProfile != null) {
        _recommendedProducts = await _productsService.getRecommendedProducts(
          userProfile: widget.userProfile!,
        );
      } else {
        _recommendedProducts = _allProducts
            .where((p) => p.isRecommended)
            .toList();
      }

      // Categorize products
      _bankingProducts = _allProducts
          .where((p) => p.category == ProductCategory.banking)
          .toList();
      _creditProducts = _allProducts
          .where((p) => p.category == ProductCategory.credit)
          .toList();
      _investmentProducts = _allProducts
          .where((p) => p.category == ProductCategory.investment)
          .toList();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      appBar: CUAppBar(
        title: 'Account Products',
        backgroundColor: theme.colorScheme.surface,
      ),
      body: Column(
        children: [
          CUTabBar(
            controller: _tabController,
            tabs: const [
              'Recommended',
              'Banking',
              'Credit',
              'Investments',
            ],
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CUProgressIndicator())
                : _error != null
                    ? _buildErrorState()
                    : CUTabBarView(
                        controller: _tabController,
                        children: [
                          _buildProductsList(_recommendedProducts, isRecommended: true),
                          _buildProductsList(_bankingProducts),
                          _buildProductsList(_creditProducts),
                          _buildProductsList(_investmentProducts),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = CUTheme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CUIcon(
            CupertinoIcons.exclamationmark_triangle,
            size: CUSize.iconLg,
            color: theme.colorScheme.error,
          ),
          SizedBox(height: CUSpacing.md),
          CUText(
            'Failed to load products',
            style: CUTypography.headingSmall.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: CUSpacing.xs),
          CUText(
            _error ?? 'Unknown error',
            style: CUTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: CUSpacing.lg),
          CUButton.filled(
            onPressed: _loadProducts,
            label: 'Retry',
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(
    List<AccountProduct> products, {
    bool isRecommended = false,
  }) {
    final theme = CUTheme.of(context);

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CUIcon(
              CupertinoIcons.tray,
              size: CUSize.iconLg,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            SizedBox(height: CUSpacing.md),
            CUText(
              'No products available',
              style: CUTypography.bodyLarge.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: CUSpacing.xs),
            CUText(
              'Check back later for new product offerings',
              style: CUTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return CUListView(
      padding: EdgeInsets.all(CUSpacing.md),
      children: products.map((product) {
        return _buildProductCard(product, isRecommended: isRecommended);
      }).toList(),
    );
  }

  Widget _buildProductCard(AccountProduct product, {bool isRecommended = false}) {
    final theme = CUTheme.of(context);

    return CUCard(
      margin: EdgeInsets.only(bottom: CUSpacing.xs),
      onTap: () => _showProductDetails(product),
      child: CUListTile(
        leading: Container(
          width: CUSize.iconMd,
          height: CUSize.iconMd,
          decoration: BoxDecoration(
            color: _getProductColor(product.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(CURadius.sm),
          ),
          child: CUIcon(
            _getProductIcon(product.type),
            color: _getProductColor(product.type),
            size: CUSize.iconSm,
          ),
        ),
        title: product.name,
        subtitle: '${product.institution} • ${_getAccountTypeName(product.type)}\n${product.description}',
        trailing: CUButton.filled(
          onPressed: () => _createAccount(product),
          label: product.isPlaidSupported ? 'Connect' : 'Open',
          size: CUButtonSize.small,
        ),
        badge: product.isRecommended
            ? Container(
                padding: EdgeInsets.symmetric(
                  horizontal: CUSpacing.xxs,
                  vertical: CUSpacing.xxxs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(CURadius.xs),
                ),
                child: CUText(
                  'RECOMMENDED',
                  style: CUTypography.labelSmall.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  void _showProductDetails(AccountProduct product) {
    final theme = CUTheme.of(context);

    showCUModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: EdgeInsets.all(CUSpacing.lg),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(CUSpacing.md),
                    decoration: BoxDecoration(
                      color: _getProductColor(product.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(CURadius.md),
                    ),
                    child: CUIcon(
                      _getProductIcon(product.type),
                      color: _getProductColor(product.type),
                      size: CUSize.iconMd,
                    ),
                  ),
                  SizedBox(width: CUSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CUText(
                          product.name,
                          style: CUTypography.headingSmall.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: CUSpacing.xxs),
                        CUText(
                          product.institution,
                          style: CUTypography.bodyLarge.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: CUSpacing.lg),

              // Description
              CUText(
                product.description,
                style: CUTypography.bodyLarge.copyWith(
                  height: 1.5,
                ),
              ),

              SizedBox(height: CUSpacing.xl),

              // Key details
              CUText(
                'Account Details',
                style: CUTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: CUSpacing.md),

              _buildDetailRow(
                'Account Type',
                _getAccountTypeName(product.type),
              ),
              _buildDetailRow(
                'Minimum Opening Deposit',
                '\$${product.minimumDeposit.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Monthly Maintenance Fee',
                product.monthlyFee == 0
                    ? 'None'
                    : '\$${product.monthlyFee.toStringAsFixed(2)}',
              ),
              if (product.interestRate > 0)
                _buildDetailRow(
                  'Interest Rate (APY)',
                  '${product.interestRate.toStringAsFixed(2)}%',
                ),

              SizedBox(height: CUSpacing.xl),

              // Features
              CUText(
                'Features & Benefits',
                style: CUTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(height: CUSpacing.md),

              ...product.features.map((feature) => Padding(
                padding: EdgeInsets.only(bottom: CUSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: CUSpacing.xxs),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _getProductColor(product.type),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: CUSpacing.sm),
                    Expanded(
                      child: CUText(
                        feature,
                        style: CUTypography.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),

              SizedBox(height: CUSpacing.xl),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: CUButton.outlined(
                      onPressed: () => Navigator.pop(context),
                      label: 'Close',
                    ),
                  ),
                  SizedBox(width: CUSpacing.md),
                  Expanded(
                    flex: 2,
                    child: CUButton.filled(
                      onPressed: () {
                        Navigator.pop(context);
                        _createAccount(product);
                      },
                      label: product.isPlaidSupported ? 'Connect Account' : 'Open Account',
                      leadingIcon: CupertinoIcons.add_circled,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: CUSpacing.sm),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CUText(
              label,
              style: CUTypography.bodyMedium.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: CUText(
              value,
              style: CUTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createAccount(AccountProduct product) async {
    SoundService().playButtonTap();

    try {
      // Show loading dialog
      showCUDialog(
        context: context,
        builder: (context) => CUDialog(
          title: 'Creating Account',
          content: CUProgressIndicator(),
        ),
      );

      // Create the account
      final result = await _productsService.createAccountProduct(
        productId: product.id,
        userInfo: widget.userProfile ?? {},
        biometricSettings: widget.biometricSettings ?? {},
        initialDeposit: product.minimumDeposit,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show success dialog
      if (mounted) {
        await showCUDialog(
          context: context,
          builder: (context) => CUDialog(
            title: 'Account Created Successfully!',
            content: 'Your ${product.name} account has been created and added to your profile.',
            actions: [
              CUButton.text(
                onPressed: () => Navigator.of(context).pop(),
                label: 'Continue',
              ),
              CUButton.filled(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                label: 'View Dashboard',
              ),
            ],
          ),
        );
      }

    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error dialog
      if (mounted) {
        showCUDialog(
          context: context,
          builder: (context) => CUDialog(
            title: 'Error',
            content: 'Failed to create account: ${e.toString()}',
            actions: [
              CUButton.text(
                onPressed: () => Navigator.of(context).pop(),
                label: 'OK',
              ),
            ],
          ),
        );
      }
    }
  }

  Color _getProductColor(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return CUColors.info;
      case AccountType.savings:
        return CUColors.success;
      case AccountType.credit:
        return CUColors.warning;
      case AccountType.investment:
        return CUColors.purple;
      case AccountType.retirement:
        return CUColors.indigo;
      case AccountType.moneyMarket:
        return CUColors.teal;
      case AccountType.cd:
        return CUColors.amber;
      case AccountType.loan:
        return CUColors.error;
    }
  }

  IconData _getProductIcon(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return CupertinoIcons.money_dollar;
      case AccountType.savings:
        return CupertinoIcons.money_dollar_circle;
      case AccountType.credit:
        return CupertinoIcons.creditcard;
      case AccountType.investment:
        return CupertinoIcons.chart_bar_alt_fill;
      case AccountType.retirement:
        return CupertinoIcons.person_2;
      case AccountType.moneyMarket:
        return CupertinoIcons.building_2_fill;
      case AccountType.cd:
        return CupertinoIcons.lock_circle;
      case AccountType.loan:
        return CupertinoIcons.doc_text;
    }
  }

  String _getAccountTypeName(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return 'Checking Account';
      case AccountType.savings:
        return 'Savings Account';
      case AccountType.credit:
        return 'Credit Card';
      case AccountType.investment:
        return 'Investment Account';
      case AccountType.retirement:
        return 'Retirement Account (IRA)';
      case AccountType.moneyMarket:
        return 'Money Market Account';
      case AccountType.cd:
        return 'Certificate of Deposit';
      case AccountType.loan:
        return 'Loan Account';
    }
  }
}
