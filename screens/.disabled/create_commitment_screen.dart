import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/budget_commitment_service.dart';
import '../services/no_cap_ai_service.dart';
import '../services/point_system_service.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class CreateCommitmentScreen extends StatefulWidget {
  const CreateCommitmentScreen({super.key});

  @override
  State<CreateCommitmentScreen> createState() => _CreateCommitmentScreenState();
}

class _CreateCommitmentScreenState extends State<CreateCommitmentScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _targetController = TextEditingController();
  final _limitController = TextEditingController();
  final _notesController = TextEditingController();

  // Services
  final _commitmentService = BudgetCommitmentService();
  final _aiService = NoCapAIService();
  final _pointService = PointSystemService();

  // Form state
  CommitmentType _selectedType = CommitmentType.merchant;
  CommitmentDifficulty _selectedDifficulty = CommitmentDifficulty.medium;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));
  String _selectedPersonality = 'motivational';
  bool _requireBiometric = true;
  bool _isCreating = false;
  bool _showAIInsights = false;

  // AI suggestions
  List<String> _aiSuggestions = [];
  String? _aiRiskAssessment;
  Map<String, dynamic>? _spendingAnalysis;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = _animationController;

    _animationController.forward();
    _loadAIInsights();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _targetController.dispose();
    _limitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAIInsights() async {
    try {
      // Get AI suggestions based on user spending patterns
      final insights =
          await _aiService.generateCommitmentSuggestions('current_user');
      setState(() {
        _aiSuggestions = insights.take(5).toList();
        _showAIInsights = true;
      });
    } catch (e) {
      debugPrint('Failed to load AI insights: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      appBar: CUAppBar(
        title: const CUText(
          'Create Commitment',
          style: CUTextStyle.h2,
        ),
        actions: [
          CUIconButton(
            onPressed: () => _showHelpDialog(),
            icon: CupertinoIcons.question_circle,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(CUSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                SizedBox(height: CUSpacing.lg),
                _buildCommitmentTypeSection(),
                SizedBox(height: CUSpacing.lg),
                _buildTargetSection(),
                SizedBox(height: CUSpacing.lg),
                _buildLimitSection(),
                SizedBox(height: CUSpacing.lg),
                _buildDateSection(),
                SizedBox(height: CUSpacing.lg),
                _buildDifficultySection(),
                SizedBox(height: CUSpacing.lg),
                _buildPersonalitySection(),
                SizedBox(height: CUSpacing.lg),
                _buildSecuritySection(),
                if (_showAIInsights) ...[
                  SizedBox(height: CUSpacing.lg),
                  _buildAIInsightsSection(),
                ],
                SizedBox(height: CUSpacing.xl),
                _buildCreateButton(),
                SizedBox(height: CUSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(CUSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CURadius.md),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(CUSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(CURadius.md),
                  ),
                  child: Icon(
                    CupertinoIcons.lock_fill,
                    color: theme.colorScheme.primary,
                    size: CUSize.iconLg,
                  ),
                ),
                SizedBox(width: CUSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CUText(
                        'No Cap, Can\'t Take It Back',
                        style: CUTextStyle.h3.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: CUSpacing.xs),
                      CUText(
                        'Create a locked commitment that enforces your financial discipline',
                        style: CUTextStyle.bodyMedium.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: CUSpacing.md),
            Container(
              padding: EdgeInsets.all(CUSpacing.sm),
              decoration: BoxDecoration(
                color: CUColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(CURadius.sm),
                border: Border.all(color: CUColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.exclamationmark_triangle,
                      color: CUColors.warning, size: CUSize.iconMd),
                  SizedBox(width: CUSpacing.sm),
                  Expanded(
                    child: CUText(
                      'Once locked, this commitment cannot be easily broken. Choose wisely!',
                      style: CUTextStyle.bodySmall.copyWith(
                        color: CUColors.warning,
                      ),
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

  Widget _buildCommitmentTypeSection() {
    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CUText(
              'Commitment Type',
              style: CUTextStyle.h4,
            ),
            SizedBox(height: CUSpacing.sm),
            ...CommitmentType.values.map((type) {
              final info = _getTypeInfo(type);
              return CURadioListTile<CommitmentType>(
                value: type,
                groupValue: _selectedType,
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                    _targetController.clear();
                  });
                  _onTypeChanged();
                },
                title: Row(
                  children: [
                    Icon(info['icon'] as IconData,
                        size: CUSize.iconMd, color: info['color'] as Color),
                    SizedBox(width: CUSpacing.sm),
                    CUText(info['title'] as String),
                  ],
                ),
                subtitle: info['description'] as String,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSection() {
    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CUText(
              _getTargetLabel(),
              style: CUTextStyle.h4,
            ),
            SizedBox(height: CUSpacing.sm),
            CUTextField(
              controller: _targetController,
              hintText: _getTargetHint(),
              prefixIcon: _getTypeInfo(_selectedType)['icon'] as IconData,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Please enter a ${_getTargetLabel().toLowerCase()}';
                }
                return null;
              },
              onChanged: (_) => _analyzeTarget(),
              suffixIcon: CUIconButton(
                icon: CupertinoIcons.brain,
                onPressed: _showAISuggestions,
              ),
            ),
            SizedBox(height: CUSpacing.sm),
            CUText(
              _getTargetDescription(),
              style: CUTextStyle.bodySmall.copyWith(
                color: CUTheme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitSection() {
    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CUText(
              _getLimitLabel(),
              style: CUTextStyle.h4,
            ),
            SizedBox(height: CUSpacing.sm),
            CUTextField(
              controller: _limitController,
              hintText: _getLimitHint(),
              prefixIcon: CupertinoIcons.money_dollar,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
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
              onChanged: (_) => _analyzeLimit(),
            ),
            SizedBox(height: CUSpacing.sm),
            CUText(
              _getLimitDescription(),
              style: CUTextStyle.bodySmall.copyWith(
                color: CUTheme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CUText(
              'Duration',
              style: CUTextStyle.h4,
            ),
            SizedBox(height: CUSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: CUInkWell(
                    onTap: () => _selectDate(true),
                    child: Container(
                      padding: EdgeInsets.all(CUSpacing.sm),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(CURadius.sm),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CUText('Start Date',
                              style: CUTextStyle.caption),
                          CUText(
                            DateFormat('MMM d, y').format(_startDate),
                            style: CUTextStyle.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: CUSpacing.md),
                Expanded(
                  child: CUInkWell(
                    onTap: () => _selectDate(false),
                    child: Container(
                      padding: EdgeInsets.all(CUSpacing.sm),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outline),
                        borderRadius: BorderRadius.circular(CURadius.sm),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CUText('End Date',
                              style: CUTextStyle.caption),
                          CUText(
                            DateFormat('MMM d, y').format(_endDate),
                            style: CUTextStyle.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            Container(
              padding: EdgeInsets.all(CUSpacing.sm),
              decoration: BoxDecoration(
                color: CUColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(CURadius.sm),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.clock, color: CUColors.info, size: CUSize.iconSm),
                  SizedBox(width: CUSpacing.sm),
                  CUText(
                    '${_endDate.difference(_startDate).inDays} days commitment',
                    style: CUTextStyle.bodySmall.copyWith(
                      color: CUColors.info,
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

  Widget _buildDifficultySection() {
    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CUText(
              'Difficulty Level',
              style: CUTextStyle.h4,
            ),
            SizedBox(height: CUSpacing.sm),
            ...CommitmentDifficulty.values.map((difficulty) {
              final info = _getDifficultyInfo(difficulty);
              return CURadioListTile<CommitmentDifficulty>(
                value: difficulty,
                groupValue: _selectedDifficulty,
                onChanged: (value) {
                  setState(() => _selectedDifficulty = value!);
                },
                title: Row(
                  children: [
                    Icon(info['icon'] as IconData,
                        size: CUSize.iconMd, color: info['color'] as Color),
                    SizedBox(width: CUSpacing.sm),
                    CUText(info['title'] as String),
                    SizedBox(width: CUSpacing.sm),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: CUSpacing.xs, vertical: CUSpacing.xxs),
                      decoration: BoxDecoration(
                        color: (info['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(CURadius.sm),
                      ),
                      child: CUText(
                        '+${info['points']} pts',
                        style: CUTextStyle.caption.copyWith(
                          color: info['color'] as Color,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: info['description'] as String,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalitySection() {
    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.brain, color: CUColors.info),
                SizedBox(width: CUSpacing.sm),
                CUText(
                  'AI Coach Personality',
                  style: CUTextStyle.h4,
                ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            CUDropdown<String>(
              value: _selectedPersonality,
              items: const [
                CUDropdownItem(value: 'motivational', label: 'Motivational Coach'),
                CUDropdownItem(value: 'strict', label: 'Strict Trainer'),
                CUDropdownItem(value: 'supportive', label: 'Supportive Friend'),
                CUDropdownItem(value: 'analytical', label: 'Data-Driven Analyst'),
                CUDropdownItem(value: 'humorous', label: 'Humorous Mentor'),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPersonality = value);
                }
              },
            ),
            SizedBox(height: CUSpacing.sm),
            CUText(
              _getPersonalityDescription(_selectedPersonality),
              style: CUTextStyle.bodySmall.copyWith(
                color: CUTheme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.lock_shield, color: CUColors.success),
                SizedBox(width: CUSpacing.sm),
                CUText(
                  'Security Settings',
                  style: CUTextStyle.h4,
                ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            CUSwitchListTile(
              title: 'Require Biometric Authentication',
              subtitle: 'Use fingerprint/face ID to modify or delete this commitment',
              value: _requireBiometric,
              onChanged: (value) {
                setState(() => _requireBiometric = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsightsSection() {
    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.lightbulb, color: CUColors.warning),
                SizedBox(width: CUSpacing.sm),
                CUText(
                  'AI Insights',
                  style: CUTextStyle.h4,
                ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            if (_aiSuggestions.isNotEmpty) ...[
              CUText(
                'Suggestions based on your spending patterns:',
                style: CUTextStyle.bodyMedium,
              ),
              SizedBox(height: CUSpacing.sm),
              ..._aiSuggestions.map(
                (suggestion) => Container(
                  margin: EdgeInsets.only(bottom: CUSpacing.sm),
                  padding: EdgeInsets.all(CUSpacing.sm),
                  decoration: BoxDecoration(
                    color: CUColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(CURadius.sm),
                  ),
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.sparkles,
                          color: CUColors.info, size: CUSize.iconSm),
                      SizedBox(width: CUSpacing.sm),
                      Expanded(child: CUText(suggestion)),
                    ],
                  ),
                ),
              ),
            ],
            if (_aiRiskAssessment != null) ...[
              SizedBox(height: CUSpacing.sm),
              Container(
                padding: EdgeInsets.all(CUSpacing.sm),
                decoration: BoxDecoration(
                  color: CUColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(CURadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.chart_bar, color: CUColors.warning, size: CUSize.iconSm),
                    SizedBox(width: CUSpacing.sm),
                    Expanded(
                      child: CUText(
                        'Risk Assessment: $_aiRiskAssessment',
                        style: CUTextStyle.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: CUButton(
        onPressed: _isCreating ? null : _createCommitment,
        text: _isCreating ? 'Creating Commitment...' : 'Lock It In - No Cap!',
        icon: _isCreating ? null : CupertinoIcons.lock_fill,
        type: CUButtonType.primary,
        isLoading: _isCreating,
      ),
    );
  }

  // Helper methods
  Map<String, dynamic> _getTypeInfo(CommitmentType type) {
    switch (type) {
      case CommitmentType.merchant:
        return {
          'title': 'Merchant Restriction',
          'description': 'Block spending at specific merchants',
          'icon': CupertinoIcons.building_2_fill,
          'color': CUColors.error,
        };
      case CommitmentType.category:
        return {
          'title': 'Category Limit',
          'description': 'Limit spending in specific categories',
          'icon': CupertinoIcons.square_grid_2x2,
          'color': CUColors.warning,
        };
      case CommitmentType.amountLimit:
        return {
          'title': 'Amount Limit',
          'description': 'Set maximum spending amount',
          'icon': CupertinoIcons.money_dollar,
          'color': CUColors.success,
        };
      case CommitmentType.savingsGoal:
        return {
          'title': 'Savings Goal',
          'description': 'Commit to saving a specific amount',
          'icon': CupertinoIcons.creditcard,
          'color': CUColors.info,
        };
    }
  }

  Map<String, dynamic> _getDifficultyInfo(CommitmentDifficulty difficulty) {
    final theme = CUTheme.of(context);
    switch (difficulty) {
      case CommitmentDifficulty.easy:
        return {
          'title': 'Easy',
          'description': 'Flexible enforcement, warnings first',
          'icon': CupertinoIcons.smiley,
          'color': CUColors.success,
          'points': 100,
        };
      case CommitmentDifficulty.medium:
        return {
          'title': 'Medium',
          'description': 'Balanced approach with penalties',
          'icon': CupertinoIcons.equal,
          'color': CUColors.warning,
          'points': 250,
        };
      case CommitmentDifficulty.hard:
        return {
          'title': 'Hard',
          'description': 'Strict enforcement, immediate penalties',
          'icon': CupertinoIcons.hammer,
          'color': CUColors.error,
          'points': 500,
        };
      case CommitmentDifficulty.extreme:
        return {
          'title': 'Extreme',
          'description': 'Nuclear option - severe penalties',
          'icon': CupertinoIcons.exclamationmark_triangle,
          'color': theme.colorScheme.primary,
          'points': 1000,
        };
      case CommitmentDifficulty.casual:
        return {
          'title': 'Casual',
          'description': 'Relaxed approach with gentle reminders',
          'icon': CupertinoIcons.hand_thumbsup,
          'color': CUColors.info,
          'points': 50,
        };
      case CommitmentDifficulty.moderate:
        return {
          'title': 'Moderate',
          'description': 'Steady enforcement with fair penalties',
          'icon': CupertinoIcons.arrow_up_right,
          'color': CUColors.warning,
          'points': 200,
        };
      case CommitmentDifficulty.hardcore:
        return {
          'title': 'Hardcore',
          'description': 'Intense enforcement with heavy penalties',
          'icon': CupertinoIcons.bolt_fill,
          'color': theme.colorScheme.primary,
          'points': 750,
        };
    }
  }

  String _getPersonalityDescription(String personality) {
    switch (personality) {
      case 'motivational':
        return 'Energetic and encouraging, celebrates victories and motivates through challenges';
      case 'strict':
        return 'No-nonsense approach, direct feedback and tough love when needed';
      case 'supportive':
        return 'Understanding and compassionate, focuses on emotional support';
      case 'analytical':
        return 'Data-driven insights, focuses on numbers and trends';
      case 'humorous':
        return 'Uses humor to make financial discipline more enjoyable';
      default:
        return '';
    }
  }

  String _getTargetLabel() {
    switch (_selectedType) {
      case CommitmentType.merchant:
        return 'Merchant Name';
      case CommitmentType.category:
        return 'Spending Category';
      case CommitmentType.amountLimit:
        return 'Budget Name';
      case CommitmentType.savingsGoal:
        return 'Goal Name';
    }
  }

  String _getTargetHint() {
    switch (_selectedType) {
      case CommitmentType.merchant:
        return 'e.g., Starbucks, Amazon, Target';
      case CommitmentType.category:
        return 'e.g., Dining, Entertainment, Shopping';
      case CommitmentType.amountLimit:
        return 'e.g., Weekly Groceries, Monthly Entertainment';
      case CommitmentType.savingsGoal:
        return 'e.g., Emergency Fund, Vacation Savings';
    }
  }

  String _getTargetDescription() {
    switch (_selectedType) {
      case CommitmentType.merchant:
        return 'Specify the merchant where spending will be restricted';
      case CommitmentType.category:
        return 'Choose a spending category to limit';
      case CommitmentType.amountLimit:
        return 'Give your budget a descriptive name';
      case CommitmentType.savingsGoal:
        return 'Name your savings goal for motivation';
    }
  }

  String _getLimitLabel() {
    switch (_selectedType) {
      case CommitmentType.merchant:
        return 'Monthly Spending Limit';
      case CommitmentType.category:
        return 'Category Spending Limit';
      case CommitmentType.amountLimit:
        return 'Maximum Amount';
      case CommitmentType.savingsGoal:
        return 'Savings Target';
    }
  }

  String _getLimitHint() {
    switch (_selectedType) {
      case CommitmentType.merchant:
        return '0.00';
      case CommitmentType.category:
        return '500.00';
      case CommitmentType.amountLimit:
        return '1000.00';
      case CommitmentType.savingsGoal:
        return '5000.00';
    }
  }

  String _getLimitDescription() {
    switch (_selectedType) {
      case CommitmentType.merchant:
        return 'Set to \$0 for complete restriction, or set a monthly limit';
      case CommitmentType.category:
        return 'Maximum amount you can spend in this category';
      case CommitmentType.amountLimit:
        return 'The spending limit you\'re committing to';
      case CommitmentType.savingsGoal:
        return 'Target amount you want to save';
    }
  }

  void _onTypeChanged() {
    // Clear AI analysis when type changes
    setState(() {
      _aiRiskAssessment = null;
      _spendingAnalysis = null;
    });
  }

  void _analyzeTarget() {
    // Trigger AI analysis of the target
    // This could provide suggestions or warnings
  }

  void _analyzeLimit() {
    // Analyze the spending limit
    // Could provide insights about whether it's realistic
  }

  Future<void> _selectDate(bool isStartDate) async {
    final date = await showCupertinoModalPopup<DateTime>(
      context: context,
      builder: (context) => Container(
        height: 300,
        color: CUTheme.of(context).colorScheme.surface,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: isStartDate ? _startDate : _endDate,
          minimumDate: DateTime.now(),
          maximumDate: DateTime.now().add(const Duration(days: 365)),
          onDateTimeChanged: (date) {
            setState(() {
              if (isStartDate) {
                _startDate = date;
                if (_endDate.isBefore(_startDate)) {
                  _endDate = _startDate.add(const Duration(days: 30));
                }
              } else {
                _endDate = date;
              }
            });
          },
        ),
      ),
    );
  }

  void _showAISuggestions() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CUText(
              'AI Suggestions',
              style: CUTextStyle.h2,
            ),
            SizedBox(height: CUSpacing.md),
            if (_aiSuggestions.isNotEmpty)
              ..._aiSuggestions.map(
                (suggestion) => CUListTile(
                  leading: Icon(CupertinoIcons.lightbulb, color: CUColors.warning),
                  title: suggestion,
                  onTap: () {
                    _targetController.text = suggestion;
                    Navigator.pop(context);
                  },
                ),
              )
            else
              Center(
                child: Column(
                  children: [
                    Icon(CupertinoIcons.hourglass, size: CUSize.iconXl, color: CUColors.textSecondary),
                    SizedBox(height: CUSpacing.md),
                    const CUText('Analyzing your spending patterns...'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CUAlertDialog(
        title: 'How No Cap Works',
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CUText('Lock Mechanism:',
                  style: CUTextStyle.bodyMedium),
              CUText(
                  'Once created, commitments are locked and difficult to break.'),
              SizedBox(height: 12),
              CUText('AI Monitoring:',
                  style: CUTextStyle.bodyMedium),
              CUText('Our AI watches your transactions 24/7 for violations.'),
              SizedBox(height: 12),
              CUText('Instant Penalties:',
                  style: CUTextStyle.bodyMedium),
              CUText('Violations trigger immediate point deductions and alerts.'),
              SizedBox(height: 12),
              CUText('Rewards System:',
                  style: CUTextStyle.bodyMedium),
              CUText('Staying on track earns points and unlocks achievements.'),
              SizedBox(height: 12),
              CUText('Security:',
                  style: CUTextStyle.bodyMedium),
              CUText('Biometric authentication required for changes.'),
            ],
          ),
        ),
        actions: [
          CUButton(
            onPressed: () => Navigator.pop(context),
            text: 'Got it!',
            type: CUButtonType.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _createCommitment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final limit = double.parse(_limitController.text);

      final result = await _commitmentService.createCommitment(
        type: _selectedType,
        target: _targetController.text,
        spendingLimit: limit,
        timePeriod: 'monthly', // Default to monthly
        difficulty: _selectedDifficulty,
        requireBiometric: _requireBiometric,
        userNote: _notesController.text,
      );

      if (result.success) {
        // Award points for creating commitment
        await _pointService.awardPoints(
          userId: 'current_user',
          action: PointAction.commitmentSuccess,
          points: _getDifficultyInfo(_selectedDifficulty)['points'] as int,
          metadata: {
            'commitment_type': _selectedType.name,
            'difficulty': _selectedDifficulty.name,
            'target': _targetController.text,
            'limit': limit,
          },
        );

        if (mounted) {
          // Show success dialog
          showCupertinoDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CUAlertDialog(
              title: 'Commitment Locked!',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CUText(
                    'Your commitment is now locked in!',
                    style: CUTextStyle.h4,
                  ),
                  SizedBox(height: CUSpacing.sm),
                  CUText(result.message ?? 'Commitment created successfully'),
                  SizedBox(height: CUSpacing.md),
                  Container(
                    padding: EdgeInsets.all(CUSpacing.sm),
                    decoration: BoxDecoration(
                      color: CUColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(CURadius.sm),
                    ),
                    child: CUText(
                      '+${_getDifficultyInfo(_selectedDifficulty)['points']} Points Earned!',
                      style: CUTextStyle.bodyMedium.copyWith(
                        color: CUColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                CUButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to dashboard
                  },
                  text: 'View Dashboard',
                  type: CUButtonType.primary,
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          CUSnackbar.show(
            context,
            message: result.message ?? 'Failed to create commitment',
            type: CUSnackbarType.error,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        CUSnackbar.show(
          context,
          message: 'Failed to create commitment: $e',
          type: CUSnackbarType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}
