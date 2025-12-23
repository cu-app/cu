import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class DataAccessHistoryScreen extends StatefulWidget {
  const DataAccessHistoryScreen({super.key});

  @override
  State<DataAccessHistoryScreen> createState() => _DataAccessHistoryScreenState();
}

class _DataAccessHistoryScreenState extends State<DataAccessHistoryScreen> {
  List<AccessEvent> _accessEvents = [];
  bool _isLoading = true;
  AccessFilter _selectedFilter = AccessFilter.all;

  @override
  void initState() {
    super.initState();
    _loadAccessHistory();
  }

  Future<void> _loadAccessHistory() async {
    setState(() => _isLoading = true);

    // Simulate loading access history
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _accessEvents = [
        AccessEvent(
          id: '1',
          appName: 'Plaid',
          appLogoUrl: 'https://www.google.com/s2/favicons?domain=plaid.com&sz=128',
          accessType: AccessType.read,
          dataCategory: 'Transactions',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ipAddress: '192.168.1.100',
          location: 'San Francisco, CA',
          recordsAccessed: 45,
        ),
        AccessEvent(
          id: '2',
          appName: 'Mint',
          appLogoUrl: 'https://www.google.com/s2/favicons?domain=mint.com&sz=128',
          accessType: AccessType.read,
          dataCategory: 'Balances',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          ipAddress: '192.168.1.100',
          location: 'San Francisco, CA',
          recordsAccessed: 8,
        ),
        AccessEvent(
          id: '3',
          appName: 'Personal Capital',
          appLogoUrl: 'https://www.google.com/s2/favicons?domain=personalcapital.com&sz=128',
          accessType: AccessType.read,
          dataCategory: 'Accounts',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ipAddress: '192.168.1.100',
          location: 'San Francisco, CA',
          recordsAccessed: 5,
        ),
        AccessEvent(
          id: '4',
          appName: 'Plaid',
          appLogoUrl: 'https://www.google.com/s2/favicons?domain=plaid.com&sz=128',
          accessType: AccessType.read,
          dataCategory: 'Identity',
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          ipAddress: '192.168.1.100',
          location: 'San Francisco, CA',
          recordsAccessed: 1,
        ),
        AccessEvent(
          id: '5',
          appName: 'Mint',
          appLogoUrl: 'https://www.google.com/s2/favicons?domain=mint.com&sz=128',
          accessType: AccessType.read,
          dataCategory: 'Transactions',
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          ipAddress: '192.168.1.100',
          location: 'San Francisco, CA',
          recordsAccessed: 120,
        ),
        AccessEvent(
          id: '6',
          appName: 'User Export',
          appLogoUrl: null,
          accessType: AccessType.export,
          dataCategory: 'All Data',
          timestamp: DateTime.now().subtract(const Duration(days: 7)),
          ipAddress: '192.168.1.100',
          location: 'San Francisco, CA',
          recordsAccessed: 500,
        ),
        AccessEvent(
          id: '7',
          appName: 'Plaid',
          appLogoUrl: 'https://www.google.com/s2/favicons?domain=plaid.com&sz=128',
          accessType: AccessType.read,
          dataCategory: 'Balances',
          timestamp: DateTime.now().subtract(const Duration(days: 10)),
          ipAddress: '192.168.1.100',
          location: 'San Francisco, CA',
          recordsAccessed: 8,
        ),
      ];
      _isLoading = false;
    });
  }

  List<AccessEvent> get _filteredEvents {
    switch (_selectedFilter) {
      case AccessFilter.all:
        return _accessEvents;
      case AccessFilter.today:
        final today = DateTime.now();
        return _accessEvents.where((event) {
          return event.timestamp.year == today.year &&
              event.timestamp.month == today.month &&
              event.timestamp.day == today.day;
        }).toList();
      case AccessFilter.last7Days:
        final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
        return _accessEvents.where((event) => event.timestamp.isAfter(sevenDaysAgo)).toList();
      case AccessFilter.last30Days:
        final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
        return _accessEvents.where((event) => event.timestamp.isAfter(thirtyDaysAgo)).toList();
    }
  }

  Map<String, List<AccessEvent>> get _groupedEvents {
    final Map<String, List<AccessEvent>> grouped = {};
    final events = _filteredEvents;

    for (var event in events) {
      final dateKey = _getDateKey(event.timestamp);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(event);
    }

    return grouped;
  }

  String _getDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final eventDate = DateTime(date.year, date.month, date.day);

    if (eventDate == today) {
      return 'Today';
    } else if (eventDate == yesterday) {
      return 'Yesterday';
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final groupedEvents = _groupedEvents;

    return CUScacuold(
      backgroundColor: theme.colorScheme.surface,
      appBar: CUAppBar(
        title: Text(
          'Data Access History',
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
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(CUSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Data Access Log',
                        style: CUTypography.headlineLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: CUSpacing.xs),
                      Text(
                        'View all instances when your financial data has been accessed by connected apps.',
                        style: CUTypography.bodyLarge.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Stats
              if (!_isLoading)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: CUSpacing.lg, vertical: CUSpacing.xs),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: CUIcons.visibility,
                            label: 'Total Accesses',
                            value: '${_accessEvents.length}',
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: CUSpacing.sm),
                        Expanded(
                          child: _StatCard(
                            icon: CUIcons.description,
                            label: 'Records',
                            value: '${_accessEvents.fold<int>(0, (sum, event) => sum + event.recordsAccessed)}',
                            color: CUColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Filter Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: CUSpacing.lg, vertical: CUSpacing.md),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All',
                          selected: _selectedFilter == AccessFilter.all,
                          onTap: () => setState(() => _selectedFilter = AccessFilter.all),
                        ),
                        SizedBox(width: CUSpacing.xs),
                        _FilterChip(
                          label: 'Today',
                          selected: _selectedFilter == AccessFilter.today,
                          onTap: () => setState(() => _selectedFilter = AccessFilter.today),
                        ),
                        SizedBox(width: CUSpacing.xs),
                        _FilterChip(
                          label: 'Last 7 Days',
                          selected: _selectedFilter == AccessFilter.last7Days,
                          onTap: () => setState(() => _selectedFilter = AccessFilter.last7Days),
                        ),
                        SizedBox(width: CUSpacing.xs),
                        _FilterChip(
                          label: 'Last 30 Days',
                          selected: _selectedFilter == AccessFilter.last30Days,
                          onTap: () => setState(() => _selectedFilter = AccessFilter.last30Days),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Access Events
              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CUProgressIndicator(),
                  ),
                )
              else if (groupedEvents.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CUIcons.history,
                          size: CUSize.iconLarge * 2,
                          color: theme.colorScheme.outline,
                        ),
                        SizedBox(height: CUSpacing.md),
                        Text(
                          'No Access Events',
                          style: CUTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: CUSpacing.xs),
                        Text(
                          'No data access events in this time period',
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
                  padding: EdgeInsets.fromLTRB(CUSpacing.lg, 0, CUSpacing.lg, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final dateKeys = groupedEvents.keys.toList();
                        final dateKey = dateKeys[index];
                        final events = groupedEvents[dateKey]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: CUSpacing.sm, top: CUSpacing.md),
                              child: Text(
                                dateKey,
                                style: CUTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            ...events.map((event) => Padding(
                              padding: EdgeInsets.only(bottom: CUSpacing.xs),
                              child: _AccessEventCard(event: event),
                            )),
                          ],
                        );
                      },
                      childCount: groupedEvents.length,
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: CUSpacing.md, vertical: CUSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primary : theme.colorScheme.surface,
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.outline,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(CURadius.full),
        ),
        child: Text(
          label,
          style: CUTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: selected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _AccessEventCard extends StatelessWidget {
  final AccessEvent event;

  const _AccessEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final accessTypeColor = event.accessType == AccessType.read
        ? theme.colorScheme.primary
        : event.accessType == AccessType.write
            ? CUColors.warning
            : CUColors.purple;

    final accessTypeIcon = event.accessType == AccessType.read
        ? CUIcons.visibility
        : event.accessType == AccessType.write
            ? CUIcons.edit
            : CUIcons.fileDownload;

    return CUOutlinedCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CUAvatar(
            text: event.appName,
            size: CUSize.iconMedium * 1.25,
            imageUrl: event.appLogoUrl,
            icon: CUIcons.apps,
          ),
          SizedBox(width: CUSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.appName,
                        style: CUTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: CUSpacing.xs, vertical: CUSpacing.xxs),
                      decoration: BoxDecoration(
                        color: accessTypeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(CURadius.xs),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(accessTypeIcon, size: CUSize.iconSmall / 1.5, color: accessTypeColor),
                          SizedBox(width: CUSpacing.xxs),
                          Text(
                            event.accessType.name.toUpperCase(),
                            style: CUTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: accessTypeColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: CUSpacing.xs),
                Text(
                  event.dataCategory,
                  style: CUTypography.bodyMedium.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: CUSpacing.xs),
                Row(
                  children: [
                    Icon(CUIcons.schedule, size: CUSize.iconSmall, color: theme.colorScheme.onSurfaceVariant),
                    SizedBox(width: CUSpacing.xxs),
                    Text(
                      _formatTimestamp(event.timestamp),
                      style: CUTypography.labelSmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(width: CUSpacing.sm),
                    Icon(CUIcons.description, size: CUSize.iconSmall, color: theme.colorScheme.onSurfaceVariant),
                    SizedBox(width: CUSpacing.xxs),
                    Text(
                      '${event.recordsAccessed} records',
                      style: CUTypography.labelSmall.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour > 12 ? timestamp.hour - 12 : timestamp.hour;
    final period = timestamp.hour >= 12 ? 'PM' : 'AM';
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }
}

// Models
class AccessEvent {
  final String id;
  final String appName;
  final String? appLogoUrl;
  final AccessType accessType;
  final String dataCategory;
  final DateTime timestamp;
  final String ipAddress;
  final String location;
  final int recordsAccessed;

  AccessEvent({
    required this.id,
    required this.appName,
    this.appLogoUrl,
    required this.accessType,
    required this.dataCategory,
    required this.timestamp,
    required this.ipAddress,
    required this.location,
    required this.recordsAccessed,
  });
}

enum AccessType { read, write, export }
enum AccessFilter { all, today, last7Days, last30Days }
