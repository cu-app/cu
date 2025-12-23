import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/banking_service.dart';
import '../../services/plaid_service.dart';
import '../../widgets/consistent_list_tile.dart';
import 'dart:math' as math;

class SpendingAnalyticsScreen extends StatefulWidget {
  const SpendingAnalyticsScreen({super.key});

  @override
  State<SpendingAnalyticsScreen> createState() => _SpendingAnalyticsScreenState();
}

class _SpendingAnalyticsScreenState extends State<SpendingAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final BankingService _bankingService = BankingService();
  final PlaidService _plaidService = PlaidService();

  late CUTabController _tabController;
  String _selectedPeriod = 'This Month';
  bool _isLoading = true;

  // Analytics data from Plaid
  Map<String, double> _categorySpending = {};
  List<SpendingTrend> _spendingTrends = [];
  double _totalSpending = 0;
  double _totalIncome = 0;
  double _netCashFlow = 0;
  final List<Transaction> _topTransactions = [];
  Map<String, BudgetData> _budgets = {};

  @override
  void initState() {
    super.initState();
    _tabController = CUTabController(length: 4, vsync: this);
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    try {
      // Get transactions from Plaid via our banking service
      final transactions = await _bankingService.searchTransactions(
        startDate: _getStartDate(),
        endDate: DateTime.now(),
      );

      // Process transactions for analytics
      _processTransactions(transactions);

      // Load budget data (mock for now, can be stored in Supabase)
      _loadBudgets();

    } catch (e) {
      print('Error loading analytics: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  DateTime _getStartDate() {
    switch (_selectedPeriod) {
      case 'This Week':
        return DateTime.now().subtract(const Duration(days: 7));
      case 'This Month':
        return DateTime(DateTime.now().year, DateTime.now().month, 1);
      case 'Last Month':
        final lastMonth = DateTime.now().subtract(const Duration(days: 30));
        return DateTime(lastMonth.year, lastMonth.month, 1);
      case 'This Year':
        return DateTime(DateTime.now().year, 1, 1);
      default:
        return DateTime.now().subtract(const Duration(days: 30));
    }
  }

  void _processTransactions(List<Map<String, dynamic>> transactions) {
    _categorySpending.clear();
    _totalSpending = 0;
    _totalIncome = 0;
    _topTransactions.clear();

    for (var txn in transactions) {
      final amount = (txn['amount'] ?? 0.0).toDouble();
      final category = txn['category'] ?? 'Other';
      final isIncome = amount < 0; // Plaid uses negative for income

      if (isIncome) {
        _totalIncome += amount.abs();
      } else {
        _totalSpending += amount;

        // Group by category
        _categorySpending[category] =
            (_categorySpending[category] ?? 0) + amount;
      }

      // Track top transactions
      if (amount > 0 && _topTransactions.length < 5) {
        _topTransactions.add(Transaction(
          name: txn['name'] ?? 'Unknown',
          amount: amount,
          category: category,
          date: DateTime.tryParse(txn['date'] ?? '') ?? DateTime.now(),
          merchantName: txn['merchant_name'],
        ));
      }
    }

    _netCashFlow = _totalIncome - _totalSpending;

    // Sort categories by spending
    _categorySpending = Map.fromEntries(
      _categorySpending.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value))
    );

    // Generate spending trends (mock data for demonstration)
    _generateSpendingTrends();
  }

  void _generateSpendingTrends() {
    _spendingTrends = [
      SpendingTrend(month: 'Jan', amount: 2850),
      SpendingTrend(month: 'Feb', amount: 3200),
      SpendingTrend(month: 'Mar', amount: 2900),
      SpendingTrend(month: 'Apr', amount: 3500),
      SpendingTrend(month: 'May', amount: 3100),
      SpendingTrend(month: 'Jun', amount: _totalSpending),
    ];
  }

  void _loadBudgets() {
    _budgets = {
      'Food & Dining': BudgetData(budget: 500, spent: _categorySpending['Food & Dining'] ?? 0),
      'Shopping': BudgetData(budget: 300, spent: _categorySpending['Shopping'] ?? 0),
      'Transportation': BudgetData(budget: 200, spent: _categorySpending['Transportation'] ?? 0),
      'Entertainment': BudgetData(budget: 150, spent: _categorySpending['Entertainment'] ?? 0),
      'Bills & Utilities': BudgetData(budget: 800, spent: _categorySpending['Bills & Utilities'] ?? 0),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      appBar: CUAppBar(
        title: const Text('Spending Analytics'),
        actions: [
          CUDropdownButton(
            value: _selectedPeriod,
            items: [
              CUDropdownItem(value: 'This Week', label: 'This Week'),
              CUDropdownItem(value: 'This Month', label: 'This Month'),
              CUDropdownItem(value: 'Last Month', label: 'Last Month'),
              CUDropdownItem(value: 'This Year', label: 'This Year'),
            ],
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPeriod = value;
                  _loadAnalytics();
                });
              }
            },
          ),
          SizedBox(width: CUSpacing.md),
        ],
      ),
      body: _isLoading
          ? const Center(child: CULoadingSpinner())
          : Column(
              children: [
                CUTabBar(
                  controller: _tabController,
                  tabs: const [
                    CUTab(text: 'Overview'),
                    CUTab(text: 'Categories'),
                    CUTab(text: 'Trends'),
                    CUTab(text: 'Budgets'),
                  ],
                ),
                Expanded(
                  child: CUTabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(),
                      _buildCategoriesTab(),
                      _buildTrendsTab(),
                      _buildBudgetsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cash Flow Summary Cards
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Income',
                  amount: _totalIncome,
                  color: CUColors.success,
                  icon: CUIcons.trendingUp,
                ),
              ),
              SizedBox(width: CUSpacing.sm),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Total Spending',
                  amount: _totalSpending,
                  color: CUColors.error,
                  icon: CUIcons.trendingDown,
                ),
              ),
            ],
          ),
          SizedBox(height: CUSpacing.sm),
          _buildSummaryCard(
            title: 'Net Cash Flow',
            amount: _netCashFlow,
            color: _netCashFlow >= 0 ? CUColors.success : CUColors.error,
            icon: _netCashFlow >= 0 ? CUIcons.addCircle : CUIcons.removeCircle,
            fullWidth: true,
          ),

          SizedBox(height: CUSpacing.lg),

          // Spending by Category Donut Chart
          Text(
            'Spending Breakdown',
            style: CUTypography.h2(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.md),
          SizedBox(
            height: 250,
            child: _buildDonutChart(),
          ),

          SizedBox(height: CUSpacing.lg),

          // Top Transactions
          Text(
            'Top Transactions',
            style: CUTypography.h2(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.sm),
          ..._topTransactions.map((txn) => _buildTransactionTile(txn)),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    final theme = CUTheme.of(context);
    final sortedCategories = _categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      padding: EdgeInsets.all(CUSpacing.md),
      itemCount: sortedCategories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: EdgeInsets.only(bottom: CUSpacing.md),
            child: Text(
              'Spending by Category',
              style: CUTypography.h2(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        final entry = sortedCategories[index - 1];
        final percentage = (_totalSpending > 0)
            ? (entry.value / _totalSpending * 100)
            : 0.0;

        return CUCard(
          margin: EdgeInsets.only(bottom: CUSpacing.xs),
          child: CUListTile(
            leading: Container(
              width: CUSize.iconLg,
              height: CUSize.iconLg,
              decoration: BoxDecoration(
                color: _getCategoryColor(entry.key).withOpacity(0.2),
                borderRadius: BorderRadius.circular(CURadius.sm),
              ),
              child: CUIcon(
                icon: _getCategoryIcon(entry.key),
                color: _getCategoryColor(entry.key),
                size: CUSize.iconSm,
              ),
            ),
            title: Text(entry.key),
            subtitle: CUProgressBar(
              value: percentage / 100,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              color: _getCategoryColor(entry.key),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${entry.value.toStringAsFixed(2)}',
                  style: CUTypography.bodyLarge(context).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: CUTypography.bodySmall(context).copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendsTab() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spending Trends',
            style: CUTypography.h2(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.md),
          SizedBox(
            height: 300,
            child: _buildLineChart(),
          ),
          SizedBox(height: CUSpacing.lg),

          // Insights
          Text(
            'Insights',
            style: CUTypography.h2(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.sm),
          _buildInsightCard(
            icon: CUIcons.trendingUp,
            title: 'Spending Trend',
            description: 'Your spending has increased by 12% compared to last month',
            color: CUColors.warning,
          ),
          SizedBox(height: CUSpacing.xs),
          _buildInsightCard(
            icon: CUIcons.restaurant,
            title: 'Top Category',
            description: 'Food & Dining is your highest spending category this month',
            color: CUColors.info,
          ),
          SizedBox(height: CUSpacing.xs),
          _buildInsightCard(
            icon: CUIcons.savings,
            title: 'Savings Opportunity',
            description: 'You could save \$200 by reducing discretionary spending',
            color: CUColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetsTab() {
    final theme = CUTheme.of(context);

    return ListView.builder(
      padding: EdgeInsets.all(CUSpacing.md),
      itemCount: _budgets.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Budget Overview',
                style: CUTypography.h2(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: CUSpacing.xs),
              Text(
                'Track your spending against your budget',
                style: CUTypography.bodyMedium(context).copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: CUSpacing.md),
            ],
          );
        }

        final entry = _budgets.entries.toList()[index - 1];
        final percentage = (entry.value.budget > 0)
            ? (entry.value.spent / entry.value.budget).clamp(0.0, 1.0)
            : 0.0;
        final remaining = math.max(0, entry.value.budget - entry.value.spent);
        final isOverBudget = entry.value.spent > entry.value.budget;

        return CUCard(
          margin: EdgeInsets.only(bottom: CUSpacing.sm),
          child: Padding(
            padding: EdgeInsets.all(CUSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: CUTypography.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CUBadge(
                      label: isOverBudget
                          ? 'Over by \$${(entry.value.spent - entry.value.budget).toStringAsFixed(2)}'
                          : '\$${remaining.toStringAsFixed(2)} left',
                      variant: isOverBudget ? CUBadgeVariant.error : CUBadgeVariant.success,
                    ),
                  ],
                ),
                SizedBox(height: CUSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Spent: \$${entry.value.spent.toStringAsFixed(2)}',
                                style: CUTypography.bodyMedium(context),
                              ),
                              Text(
                                'Budget: \$${entry.value.budget.toStringAsFixed(2)}',
                                style: CUTypography.bodyMedium(context).copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: CUSpacing.xs),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(CURadius.xxs),
                            child: CUProgressBar(
                              value: percentage,
                              height: CUSize.xs,
                              backgroundColor: theme.colorScheme.surfaceContainerHighest,
                              color: isOverBudget ? CUColors.error : _getCategoryColor(entry.key),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: CUSpacing.xs),
                Text(
                  '${(percentage * 100).toStringAsFixed(0)}% of budget used',
                  style: CUTypography.bodySmall(context).copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    bool fullWidth = false,
  }) {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(CUSpacing.xs),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(CURadius.sm),
                  ),
                  child: CUIcon(icon: icon, color: color, size: CUSize.iconSm),
                ),
                SizedBox(width: CUSpacing.xs),
                Text(
                  title,
                  style: CUTypography.bodyMedium(context).copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: CUSpacing.xs),
            Text(
              '\$${amount.abs().toStringAsFixed(2)}',
              style: CUTypography.h3(context).copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDonutChart() {
    final theme = CUTheme.of(context);
    final data = _categorySpending.entries.take(5).toList();

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: data.map((entry) {
                final percentage = (_totalSpending > 0)
                    ? (entry.value / _totalSpending * 100)
                    : 0.0;

                return PieChartSectionData(
                  color: _getCategoryColor(entry.key),
                  value: entry.value,
                  title: '${percentage.toStringAsFixed(0)}%',
                  radius: 60,
                  titleStyle: TextStyle(
                    fontSize: CUSize.textSm,
                    fontWeight: FontWeight.bold,
                    color: CUColors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        SizedBox(width: CUSpacing.md),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: data.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: CUSpacing.xxs),
                child: Row(
                  children: [
                    Container(
                      width: CUSize.sm,
                      height: CUSize.sm,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: CUSpacing.xs),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: CUTypography.bodySmall(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    final theme = CUTheme.of(context);
    final maxY = _spendingTrends.map((e) => e.amount).reduce(math.max);

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: theme.colorScheme.surfaceContainerHighest,
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${(value / 1000).toStringAsFixed(1)}k',
                  style: TextStyle(fontSize: CUSize.textXs),
                );
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < _spendingTrends.length) {
                  return Text(
                    _spendingTrends[value.toInt()].month,
                    style: TextStyle(fontSize: CUSize.textXs),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: _spendingTrends.length - 1.0,
        minY: 0,
        maxY: maxY * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: _spendingTrends.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.amount);
            }).toList(),
            isCurved: true,
            color: theme.colorScheme.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: theme.colorScheme.primary,
                  strokeWidth: 2,
                  strokeColor: theme.colorScheme.surface,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              color: theme.colorScheme.primary.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction txn) {
    final theme = CUTheme.of(context);

    return CUCard(
      margin: EdgeInsets.only(bottom: CUSpacing.xs),
      child: CUListTile(
        leading: Container(
          width: CUSize.iconLg,
          height: CUSize.iconLg,
          decoration: BoxDecoration(
            color: _getCategoryColor(txn.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(CURadius.sm),
          ),
          child: CUIcon(
            icon: _getCategoryIcon(txn.category),
            color: _getCategoryColor(txn.category),
            size: CUSize.iconSm,
          ),
        ),
        title: Text(txn.merchantName ?? txn.name),
        subtitle: Text(txn.category),
        trailing: Text(
          '\$${txn.amount.toStringAsFixed(2)}',
          style: CUTypography.bodyLarge(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    final theme = CUTheme.of(context);

    return CUCard(
      child: CUListTile(
        leading: Container(
          padding: EdgeInsets.all(CUSpacing.xs),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(CURadius.sm),
          ),
          child: CUIcon(icon: icon, color: color, size: CUSize.iconSm),
        ),
        title: Text(
          title,
          style: CUTypography.bodyLarge(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food and drink':
        return CUColors.orange;
      case 'shopping':
      case 'shops':
        return CUColors.pink;
      case 'transportation':
      case 'travel':
        return CUColors.info;
      case 'entertainment':
      case 'recreation':
        return CUColors.purple;
      case 'bills & utilities':
      case 'service':
        return CUColors.error;
      case 'healthcare':
      case 'medical':
        return CUColors.success;
      default:
        return CUColors.gray;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food and drink':
        return CUIcons.restaurant;
      case 'shopping':
      case 'shops':
        return CUIcons.shoppingBag;
      case 'transportation':
      case 'travel':
        return CUIcons.car;
      case 'entertainment':
      case 'recreation':
        return CUIcons.movie;
      case 'bills & utilities':
      case 'service':
        return CUIcons.receipt;
      case 'healthcare':
      case 'medical':
        return CUIcons.hospital;
      default:
        return CUIcons.category;
    }
  }
}

// Data Models
class SpendingTrend {
  final String month;
  final double amount;

  SpendingTrend({required this.month, required this.amount});
}

class Transaction {
  final String name;
  final double amount;
  final String category;
  final DateTime date;
  final String? merchantName;

  Transaction({
    required this.name,
    required this.amount,
    required this.category,
    required this.date,
    this.merchantName,
  });
}

class BudgetData {
  final double budget;
  final double spent;

  BudgetData({required this.budget, required this.spent});
}
