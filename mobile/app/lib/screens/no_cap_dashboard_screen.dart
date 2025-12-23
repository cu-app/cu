import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../services/no_cap_ai_service.dart';
import '../services/budget_commitment_service.dart';
import '../services/point_system_service.dart' as point_service;
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class NoCapDashboardScreen extends StatefulWidget {
  const NoCapDashboardScreen({super.key});

  @override
  State<NoCapDashboardScreen> createState() => _NoCapDashboardScreenState();
}

class _NoCapDashboardScreenState extends State<NoCapDashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final String _userId = 'current_user'; // Replace with actual user ID

  point_service.UserPointStats? _userStats;
  List<BudgetCommitment> _activeCommitments = [];
  List<point_service.Achievement> _recentAchievements = [];
  final List<point_service.PointUpdate> _recentPointHistory = [];
  bool _isLoading = true;

  // Services
  final _pointService = point_service.PointSystemService();
  final _commitmentService = BudgetCommitmentService();
  final _aiService = NoCapAIService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadDashboardData();
    _setupStreams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Load all dashboard data in parallel
      final futures = await Future.wait([
        _pointService.getUserStats(_userId),
        _commitmentService.getActiveCommitments(_userId),
        _pointService.getUserAchievements(_userId),
      ]);

      setState(() {
        _userStats = futures[0] as point_service.UserPointStats;
        _activeCommitments = futures[1] as List<BudgetCommitment>;
        _recentAchievements =
            (futures[2] as List<point_service.Achievement>).take(5).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        CUSnackbar.show(
          context,
          message: 'Failed to load dashboard: $e',
          type: CUSnackbarType.error,
        );
      }
    }
  }

  void _setupStreams() {
    // Listen for point updates
    _pointService.pointUpdateStream.listen((update) {
      if (update.userId == _userId) {
        _loadDashboardData(); // Refresh data

        // Show point update notification
        if (mounted) {
          CUSnackbar.show(
            context,
            message: update.pointsAwarded > 0
                ? '+${update.pointsAwarded} points!'
                : '${update.pointsAwarded} points',
            type: update.pointsAwarded > 0
                ? CUSnackbarType.success
                : CUSnackbarType.error,
          );
        }
      }
    });

    // Listen for achievement unlocks
    _pointService.achievementStream.listen((point_service.Achievement achievement) {
      if (mounted) {
        _showAchievementDialog(achievement);
      }
    });

    // Listen for violations
    _aiService.violationStream.listen((violation) {
      if (mounted) {
        _showViolationAlert(violation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      appBar: CUAppBar(
        title: Row(
          children: [
            CUText(
              'No Cap',
              style: CUTextStyle.h2,
            ),
            SizedBox(width: CUSpacing.sm),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: CUSpacing.sm,
                vertical: CUSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(CURadius.md),
              ),
              child: CUText(
                'Can\'t Take It Back',
                style: CUTextStyle.caption.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        actions: [
          CUIconButton(
            onPressed: _showNotifications,
            icon: CupertinoIcons.bell,
          ),
          CUIconButton(
            onPressed: _loadDashboardData,
            icon: CupertinoIcons.refresh,
          ),
        ],
        bottom: CUTabBar(
          controller: _tabController,
          tabs: const [
            CUTab(text: 'Overview'),
            CUTab(text: 'Commitments'),
            CUTab(text: 'Achievements'),
            CUTab(text: 'Leaderboard'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CUProgressIndicator())
          : CUTabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildCommitmentsTab(),
                _buildAchievementsTab(),
                _buildLeaderboardTab(),
              ],
            ),
      floatingActionButton: CUButton(
        onPressed: () => _createNewCommitment(),
        text: 'New Commitment',
        icon: CupertinoIcons.add_circled,
        type: CUButtonType.primary,
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_userStats == null) return const SizedBox();

    return CURefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCard(),
            SizedBox(height: CUSpacing.md),
            _buildStreakCard(),
            SizedBox(height: CUSpacing.md),
            _buildQuickActionsCard(),
            SizedBox(height: CUSpacing.md),
            _buildRecentActivityCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CUText(
                  'Your Stats',
                  style: CUTextStyle.h3,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: CUSpacing.sm,
                    vertical: CUSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: CUColors.warning,
                    borderRadius: BorderRadius.circular(CURadius.lg),
                  ),
                  child: CUText(
                    'Level ${_userStats!.level}',
                    style: CUTextStyle.caption.copyWith(
                      color: CUColors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: CUSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '',
                    'Points',
                    NumberFormat('#,###').format(_userStats!.totalPoints),
                    CUColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '',
                    'Streak',
                    '${_userStats!.currentStreak} days',
                    CUColors.error,
                  ),
                ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '🎖',
                    'Achievements',
                    '${_userStats!.achievementsUnlocked}',
                    theme.colorScheme.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '',
                    'Best Streak',
                    '${_userStats!.longestStreak} days',
                    CUColors.success,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(CUSpacing.sm),
      margin: EdgeInsets.only(right: CUSpacing.sm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(CURadius.md),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 24),
          ),
          SizedBox(height: CUSpacing.xs),
          CUText(
            value,
            style: CUTextStyle.h4.copyWith(
              color: color,
            ),
          ),
          CUText(
            label,
            style: CUTextStyle.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    final streakColor = _getStreakColor(_userStats!.currentStreak);
    final streakMessage = _getStreakMessage(_userStats!.currentStreak);

    return CUCard(
      child: Container(
        padding: EdgeInsets.all(CUSpacing.lg),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(CURadius.md),
          gradient: LinearGradient(
            colors: [
              streakColor.withOpacity(0.1),
              streakColor.withOpacity(0.05),
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
                Icon(CupertinoIcons.flame_fill, color: streakColor, size: CUSize.iconLg),
                SizedBox(width: CUSpacing.sm),
                CUText(
                  'Streak Status',
                  style: CUTextStyle.h3,
                ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            CUText(
              streakMessage,
              style: CUTextStyle.bodyLarge.copyWith(
                color: streakColor,
              ),
            ),
            SizedBox(height: CUSpacing.md),
            CUProgressBar(
              progress: (_userStats!.currentStreak % 7) / 7,
              color: streakColor,
              backgroundColor: streakColor.withOpacity(0.2),
            ),
            SizedBox(height: CUSpacing.sm),
            CUText(
              'Next milestone in ${7 - (_userStats!.currentStreak % 7)} days',
              style: CUTextStyle.caption,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CUText(
              'Quick Actions',
              style: CUTextStyle.h3,
            ),
            SizedBox(height: CUSpacing.md),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: CUSpacing.sm,
              crossAxisSpacing: CUSpacing.sm,
              childAspectRatio: 2.5,
              children: [
                _buildActionButton(
                  'New Commitment',
                  CupertinoIcons.lock_fill,
                  theme.colorScheme.primary,
                  () => _createNewCommitment(),
                ),
                _buildActionButton(
                  'View Rewards',
                  CupertinoIcons.gift,
                  CUColors.warning,
                  () => _showRewards(),
                ),
                _buildActionButton(
                  'Emergency Stop',
                  CupertinoIcons.exclamationmark_circle,
                  CUColors.error,
                  () => _showEmergencyOptions(),
                ),
                _buildActionButton(
                  'AI Coach',
                  CupertinoIcons.brain,
                  CUColors.info,
                  () => _showAICoach(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return CUInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(CURadius.md),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(CURadius.md),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: CUSize.iconMd),
            SizedBox(width: CUSpacing.sm),
            CUText(
              label,
              style: CUTextStyle.caption.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
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
                CUText(
                  'Recent Activity',
                  style: CUTextStyle.h3,
                ),
                CUButton(
                  onPressed: () => _showFullHistory(),
                  text: 'View All',
                  type: CUButtonType.text,
                ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            // Show recent achievements or activity
            if (_recentAchievements.isEmpty)
              Container(
                padding: EdgeInsets.all(CUSpacing.lg),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.chart_bar,
                      size: CUSize.iconXl,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(height: CUSpacing.sm),
                    CUText(
                      'No recent activity',
                      style: CUTextStyle.bodyLarge,
                    ),
                    SizedBox(height: CUSpacing.xs),
                    CUText(
                      'Create your first commitment to get started!',
                      style: CUTextStyle.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ..._recentAchievements.take(3).map(
                    (achievement) => CUListTile(
                      leading: CUAvatar(
                        backgroundColor: achievement.isRare
                            ? theme.colorScheme.primary.withOpacity(0.2)
                            : CUColors.warning.withOpacity(0.2),
                        child: Text(achievement.icon),
                      ),
                      title: achievement.name,
                      subtitle: achievement.description,
                      trailing: CUText(
                        '+${achievement.points}pts',
                        style: CUTextStyle.bodyMedium.copyWith(
                          color: CUColors.success,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitmentsTab() {
    return CURefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CUText(
              'Active Commitments',
              style: CUTextStyle.h2,
            ),
            SizedBox(height: CUSpacing.md),
            if (_activeCommitments.isEmpty)
              _buildEmptyCommitments()
            else
              ..._activeCommitments
                  .map((commitment) => _buildCommitmentCard(commitment)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCommitments() {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.xl),
        child: Column(
          children: [
            Icon(
              CupertinoIcons.lock_open,
              size: CUSize.iconXxl,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: CUSpacing.md),
            CUText(
              'No Commitments Yet',
              style: CUTextStyle.h3,
            ),
            SizedBox(height: CUSpacing.sm),
            CUText(
              'Ready to lock in your financial goals? Create your first "No Cap" commitment and start building unstoppable habits!',
              style: CUTextStyle.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: CUSpacing.lg),
            CUButton(
              onPressed: _createNewCommitment,
              icon: CupertinoIcons.add_circled,
              text: 'Create First Commitment',
              type: CUButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommitmentCard(BudgetCommitment commitment) {
    final progress = commitment.currentSpent / commitment.spendingLimit;
    final isViolated = progress > 1.0;

    return CUCard(
      margin: EdgeInsets.only(bottom: CUSpacing.sm),
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  commitment.isLocked ? CupertinoIcons.lock_fill : CupertinoIcons.lock_open,
                  color: commitment.isLocked ? CUColors.error : CUColors.success,
                ),
                SizedBox(width: CUSpacing.sm),
                Expanded(
                  child: CUText(
                    commitment.target,
                    style: CUTextStyle.h4,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: CUSpacing.sm,
                    vertical: CUSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(commitment.difficulty)
                        .withOpacity(0.2),
                    borderRadius: BorderRadius.circular(CURadius.md),
                  ),
                  child: CUText(
                    commitment.difficulty.name.toUpperCase(),
                    style: CUTextStyle.caption.copyWith(
                      color: _getDifficultyColor(commitment.difficulty),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            CUProgressBar(
              progress: progress.clamp(0.0, 1.0),
              color: isViolated ? CUColors.error : CUColors.success,
              backgroundColor: theme.colorScheme.surfaceVariant,
            ),
            SizedBox(height: CUSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CUText(
                  '\$${commitment.currentSpent.toStringAsFixed(2)} / \$${commitment.spendingLimit.toStringAsFixed(2)}',
                  style: CUTextStyle.bodyMedium.copyWith(
                    color: isViolated ? CUColors.error : null,
                  ),
                ),
                CUText(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: CUTextStyle.bodyMedium.copyWith(
                    color: isViolated ? CUColors.error : CUColors.success,
                  ),
                ),
              ],
            ),
            if (isViolated) ...[
              SizedBox(height: CUSpacing.sm),
              Container(
                padding: EdgeInsets.all(CUSpacing.sm),
                decoration: BoxDecoration(
                  color: CUColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(CURadius.sm),
                ),
                child: Row(
                  children: [
                    Icon(CupertinoIcons.exclamationmark_triangle, color: CUColors.error, size: CUSize.iconSm),
                    SizedBox(width: CUSpacing.sm),
                    CUText(
                      'VIOLATED: Over budget by \$${(commitment.currentSpent - commitment.spendingLimit).toStringAsFixed(2)}',
                      style: CUTextStyle.caption.copyWith(
                        color: CUColors.error,
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

  Widget _buildAchievementsTab() {
    final theme = CUTheme.of(context);

    return CURefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CUText(
              'Your Achievements',
              style: CUTextStyle.h2,
            ),
            SizedBox(height: CUSpacing.md),
            if (_recentAchievements.isEmpty)
              CUCard(
                child: Padding(
                  padding: EdgeInsets.all(CUSpacing.xl),
                  child: Column(
                    children: [
                      Icon(
                        CupertinoIcons.trophy,
                        size: CUSize.iconXxl,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(height: CUSpacing.md),
                      CUText(
                        'No Achievements Yet',
                        style: CUTextStyle.h3,
                      ),
                      SizedBox(height: CUSpacing.sm),
                      CUText(
                        'Start making commitments and keeping them to unlock achievements!',
                        style: CUTextStyle.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._recentAchievements.map(
                (achievement) => CUCard(
                  margin: EdgeInsets.only(bottom: CUSpacing.sm),
                  child: CUListTile(
                    leading: CUAvatar(
                      radius: CUSize.avatarLg,
                      backgroundColor: achievement.isRare
                          ? theme.colorScheme.primary.withOpacity(0.2)
                          : CUColors.warning.withOpacity(0.2),
                      child: Text(
                        achievement.icon,
                        style: CUTypography.bodyLarge,
                      ),
                    ),
                    title: achievement.name,
                    subtitle: achievement.description,
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CUText(
                          '+${achievement.points}',
                          style: CUTextStyle.h4.copyWith(
                            color: CUColors.success,
                          ),
                        ),
                        CUText(
                          'points',
                          style: CUTextStyle.caption,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardTab() {
    return FutureBuilder<List<point_service.LeaderboardEntry>>(
      future: _pointService.getLeaderboard(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CUProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.chart_bar, size: CUSize.iconXxl, color: CUColors.textSecondary),
                SizedBox(height: CUSpacing.md),
                const CUText('Leaderboard coming soon!'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(CUSpacing.md),
          child: Column(
            children: [
              CUText(
                'Global Leaderboard',
                style: CUTextStyle.h2,
              ),
              SizedBox(height: CUSpacing.md),
              ...snapshot.data!.asMap().entries.map((entry) {
                final index = entry.key;
                final leader = entry.value;
                return CUCard(
                  margin: EdgeInsets.only(bottom: CUSpacing.sm),
                  child: CUListTile(
                    leading: CUAvatar(
                      backgroundColor: _getRankColor(leader.rank),
                      child: CUText(
                        '#${leader.rank}',
                        style: CUTextStyle.bodyMedium.copyWith(
                          color: CUColors.white,
                        ),
                      ),
                    ),
                    title: leader.displayName,
                    subtitle: '${leader.totalPoints} points',
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.flame_fill,
                            size: CUSize.iconSm, color: CUColors.warning),
                        CUText('${leader.currentStreak}'),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  // Helper methods
  Color _getStreakColor(int streak) {
    if (streak >= 30) return CUTheme.of(context).colorScheme.primary;
    if (streak >= 14) return CUColors.warning;
    if (streak >= 7) return CUColors.error;
    return CUColors.textSecondary;
  }

  String _getStreakMessage(int streak) {
    if (streak == 0) return 'Start your streak today!';
    if (streak >= 30) return 'LEGENDARY streak! You\'re unstoppable!';
    if (streak >= 14) return 'Amazing consistency! Keep it up!';
    if (streak >= 7) return 'Great week! You\'re building momentum!';
    return 'Building your streak, day by day!';
  }

  Color _getDifficultyColor(CommitmentDifficulty difficulty) {
    final theme = CUTheme.of(context);
    switch (difficulty) {
      case CommitmentDifficulty.easy:
        return CUColors.success;
      case CommitmentDifficulty.medium:
        return CUColors.warning;
      case CommitmentDifficulty.hard:
        return CUColors.error;
      case CommitmentDifficulty.extreme:
        return theme.colorScheme.primary;
      case CommitmentDifficulty.casual:
        return CUColors.info;
      case CommitmentDifficulty.moderate:
        return CUColors.warning;
      case CommitmentDifficulty.hardcore:
        return theme.colorScheme.primary;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return CUColors.warning;
      case 2:
        return CUColors.textSecondary;
      case 3:
        return const Color(0xFF8B4513);
      default:
        return CUColors.info;
    }
  }

  // Action methods
  void _createNewCommitment() {
    // Navigate to commitment creation screen
    Navigator.pushNamed(context, '/create-commitment');
  }

  void _showRewards() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 400,
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          children: [
            CUText(
              'Available Rewards',
              style: CUTextStyle.h2,
            ),
            SizedBox(height: CUSpacing.md),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.gift, size: CUSize.iconXxl, color: CUColors.warning),
                    SizedBox(height: CUSpacing.md),
                    CUText(
                      'Rewards Coming Soon!',
                      style: CUTextStyle.h3,
                    ),
                    const CUText(
                        'Keep earning points to unlock amazing rewards!'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyOptions() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CUAlertDialog(
        title: 'Emergency Options',
        content: const CUText(
          'Emergency spending detected or need to break a commitment? '
          'Remember: No Cap means no backing down, but we understand life happens.',
        ),
        actions: [
          CUButton(
            onPressed: () => Navigator.pop(context),
            text: 'Cancel',
            type: CUButtonType.text,
          ),
          CUButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to emergency options
            },
            text: 'Continue',
            type: CUButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showAICoach() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Icon(CupertinoIcons.brain, color: CUColors.info),
                SizedBox(width: CUSpacing.sm),
                CUText(
                  'No Cap AI Coach',
                  style: CUTextStyle.h2,
                ),
              ],
            ),
            SizedBox(height: CUSpacing.md),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CUText(
                      '"Ready to lock in those financial goals?"',
                      style: CUTextStyle.bodyLarge,
                    ),
                    SizedBox(height: CUSpacing.md),
                    CUButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to AI chat
                      },
                      text: 'Chat with AI Coach',
                      type: CUButtonType.primary,
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

  void _showNotifications() {
    // Show notifications screen
  }

  void _showFullHistory() {
    // Show full activity history
  }

  void _showAchievementDialog(point_service.Achievement achievement) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CUAlertDialog(
        title: 'Achievement Unlocked!',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(achievement.icon, style: const TextStyle(fontSize: 24)),
            SizedBox(height: CUSpacing.sm),
            CUText(
              achievement.name,
              style: CUTextStyle.h3,
            ),
            SizedBox(height: CUSpacing.sm),
            CUText(achievement.description),
            SizedBox(height: CUSpacing.md),
            Container(
              padding: EdgeInsets.all(CUSpacing.sm),
              decoration: BoxDecoration(
                color: CUColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(CURadius.sm),
              ),
              child: CUText(
                '+${achievement.points} Points Earned!',
                style: CUTextStyle.h4.copyWith(
                  color: CUColors.success,
                ),
              ),
            ),
          ],
        ),
        actions: [
          CUButton(
            onPressed: () => Navigator.pop(context),
            text: 'Awesome!',
            type: CUButtonType.primary,
          ),
        ],
      ),
    );
  }

  void _showViolationAlert(BudgetViolation violation) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CUAlertDialog(
        title: 'Budget Violation!',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CUText(violation.message),
            SizedBox(height: CUSpacing.md),
            Container(
              padding: EdgeInsets.all(CUSpacing.sm),
              decoration: BoxDecoration(
                color: CUColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(CURadius.sm),
              ),
              child: CUText(
                'Penalty: -${violation.penaltyPoints} points',
                style: CUTextStyle.bodyMedium.copyWith(
                  color: CUColors.error,
                ),
              ),
            ),
          ],
        ),
        actions: [
          CUButton(
            onPressed: () => Navigator.pop(context),
            text: 'Understood',
            type: CUButtonType.text,
          ),
        ],
      ),
    );
  }
}
