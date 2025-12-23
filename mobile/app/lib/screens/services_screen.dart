import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
// import 'cards_screen.dart'; // Disabled - needs CU widgets
import 'check_deposit_screen.dart';
import 'connect_account_screen.dart';
import 'analytics/spending_analytics_screen.dart';
// import 'analytics/net_worth_screen.dart'; // Disabled - needs CU widgets
import 'transfer_screen.dart';
import 'bill_pay_screen.dart';
import 'no_cap_dashboard_screen.dart';
// import 'file_dropper_demo_screen.dart'; // Disabled - needs CU widgets

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      appBar: CUAppBar(
        title: Text(
          'Services',
          style: CUTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServicesGrid(context),
                  SizedBox(height: CUSpacing.lg),
                  _buildQuickActions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(BuildContext context) {
    final theme = CUTheme.of(context);

    final services = [
      {
        'title': 'Card Management',
        'description': 'Manage your debit and credit cards',
        'icon': CupertinoIcons.creditcard,
        'color': CUColors.purple,
        'route': '/cards',
      },
      {
        'title': 'Connect Accounts',
        'description': 'Link external bank accounts',
        'icon': CupertinoIcons.link,
        'color': CUColors.cyan,
        'route': '/connect-accounts',
      },
      {
        'title': 'Spending Analytics',
        'description': 'Track and analyze your spending',
        'icon': CupertinoIcons.chart_pie,
        'color': CUColors.pink,
        'route': '/spending-analytics',
      },
      {
        'title': 'Net Worth',
        'description': 'Monitor your financial health',
        'icon': CupertinoIcons.graph_circle,
        'color': CUColors.green,
        'route': '/net-worth',
      },
      {
        'title': 'Transfer Money',
        'description': 'Send money between accounts or to others',
        'icon': CupertinoIcons.arrow_right_arrow_left,
        'color': CUColors.blue,
        'route': '/transfer',
      },
      {
        'title': 'Pay Bills',
        'description': 'Schedule and manage bill payments',
        'icon': CupertinoIcons.money_dollar,
        'color': CUColors.amber,
        'route': '/bill-pay',
      },
      {
        'title': 'Deposit Check',
        'description': 'Mobile check deposit',
        'icon': CupertinoIcons.arrow_up_circle,
        'color': CUColors.orange,
        'route': '/check-deposit',
      },
      {
        'title': 'Apply for Loan',
        'description': 'Personal, auto, and home loans',
        'icon': CupertinoIcons.building_2_fill,
        'color': CUColors.purple,
        'route': '/loan-application',
      },
      {
        'title': 'Open Account',
        'description': 'Savings, checking, and investment accounts',
        'icon': CupertinoIcons.add_circled,
        'color': CUColors.teal,
        'route': '/open-account',
      },
      {
        'title': 'Customer Support',
        'description': 'Get help and support',
        'icon': CupertinoIcons.chat_bubble_2,
        'color': CUColors.indigo,
        'route': '/support',
      },
      {
        'title': 'No Cap System',
        'description': 'AI budget commitments you can\'t break',
        'icon': CupertinoIcons.lock,
        'color': CUColors.purple,
        'route': '/no-cap-dashboard',
      },
      {
        'title': 'File Upload',
        'description': 'Upload and manage documents',
        'icon': CupertinoIcons.cloud_upload,
        'color': CUColors.lightBlue,
        'route': '/file-dropper',
      },
      {
        'title': 'CU Widget Showcase',
        'description': 'View all Credit Union design components',
        'icon': CupertinoIcons.square_grid_2x2,
        'color': theme.colorScheme.onSurface,
        'route': '/cu-showcase',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: CUSpacing.md,
        mainAxisSpacing: CUSpacing.md,
        childAspectRatio: 1.0,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return _buildServiceCard(context, service);
      },
    );
  }

  Widget _buildServiceCard(BuildContext context, Map<String, dynamic> service) {
    final theme = CUTheme.of(context);

    return CUCard(
      child: CUInkWell(
        onTap: () {
          if (service.containsKey('route')) {
            switch (service['route']) {
              case '/cards':
                CUSnackBar.show(
                  context,
                  message: 'Card Management coming soon!',
                  type: CUSnackBarType.info,
                );
                break;
              case '/check-deposit':
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const CheckDepositScreen()),
                );
                break;
              case '/connect-accounts':
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const ConnectAccountScreen()),
                );
                break;
              case '/spending-analytics':
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const SpendingAnalyticsScreen()),
                );
                break;
              case '/net-worth':
                CUSnackBar.show(
                  context,
                  message: 'Net Worth tracking coming soon!',
                  type: CUSnackBarType.success,
                );
                break;
              case '/transfer':
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const TransferScreen()),
                );
                break;
              case '/bill-pay':
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const BillPayScreen()),
                );
                break;
              case '/loan-application':
                CUSnackBar.show(
                  context,
                  message: 'Loan applications coming soon!',
                  type: CUSnackBarType.info,
                );
                break;
              case '/open-account':
                CUSnackBar.show(
                  context,
                  message: 'Account opening coming soon!',
                  type: CUSnackBarType.info,
                );
                break;
              case '/support':
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CUDialog(
                    title: 'Customer Support',
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSupportListTile(
                          context,
                          icon: CupertinoIcons.phone,
                          title: 'Call Support',
                          subtitle: '1-800-CUAPP-AI',
                        ),
                        _buildSupportListTile(
                          context,
                          icon: CupertinoIcons.mail,
                          title: 'Email Support',
                          subtitle: 'support@cu.app',
                        ),
                        _buildSupportListTile(
                          context,
                          icon: CupertinoIcons.chat_bubble_2,
                          title: 'Live Chat',
                          subtitle: 'Available 24/7',
                        ),
                      ],
                    ),
                    actions: [
                      CUButton(
                        onPressed: () => Navigator.pop(context),
                        label: 'Close',
                        type: CUButtonType.text,
                      ),
                    ],
                  ),
                );
                break;
              case '/no-cap-dashboard':
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => const NoCapDashboardScreen()),
                );
                break;
              case '/file-dropper':
                CUSnackBar.show(
                  context,
                  message: 'File Upload coming soon!',
                  type: CUSnackBarType.info,
                );
                break;
              case '/cu-showcase':
                CUSnackBar.show(
                  context,
                  message: 'CU Widget Showcase - Coming Soon!',
                  type: CUSnackBarType.info,
                );
                break;
              default:
                break;
            }
          }
        },
        borderRadius: BorderRadius.circular(CURadius.md),
        child: Padding(
          padding: EdgeInsets.all(CUSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: CUSize.iconLg,
                height: CUSize.iconLg,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (service['color'] as Color).withOpacity(0.1),
                ),
                child: Icon(
                  service['icon'] as IconData,
                  color: service['color'] as Color,
                  size: CUSize.iconMd,
                ),
              ),
              SizedBox(height: CUSpacing.xs),
              Flexible(
                child: Text(
                  service['title'] as String,
                  style: CUTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: CUSpacing.xxs),
              Flexible(
                child: Text(
                  service['description'] as String,
                  style: CUTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupportListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: CUSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
            size: CUSize.iconMd,
          ),
          SizedBox(width: CUSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CUTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: CUSpacing.xxs),
                Text(
                  subtitle,
                  style: CUTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: CUTypography.titleLarge,
            ),
            SizedBox(height: CUSpacing.md),
            Row(
              children: [
                Expanded(
                  child: CUButton(
                    onPressed: () {
                      CUSnackBar.show(
                        context,
                        message: 'QR Scanner launching...',
                        type: CUSnackBarType.info,
                      );
                    },
                    label: 'Scan QR',
                    icon: CupertinoIcons.qrcode,
                    type: CUButtonType.filled,
                  ),
                ),
                SizedBox(width: CUSpacing.sm),
                Expanded(
                  child: CUButton(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CUDialog(
                          title: 'Nearby ATMs',
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildATMListTile(
                                context,
                                title: 'Chase Bank',
                                subtitle: '0.3 miles - 24/7 Access',
                              ),
                              _buildATMListTile(
                                context,
                                title: 'Bank of America',
                                subtitle: '0.5 miles - No Fee',
                              ),
                              _buildATMListTile(
                                context,
                                title: 'Wells Fargo',
                                subtitle: '0.8 miles - 24/7 Access',
                              ),
                            ],
                          ),
                          actions: [
                            CUButton(
                              onPressed: () => Navigator.pop(context),
                              label: 'Close',
                              type: CUButtonType.text,
                            ),
                            CUButton(
                              onPressed: () {
                                Navigator.pop(context);
                                CUSnackBar.show(
                                  context,
                                  message: 'Opening Maps...',
                                  type: CUSnackBarType.info,
                                );
                              },
                              label: 'View in Maps',
                              type: CUButtonType.filled,
                            ),
                          ],
                        ),
                      );
                    },
                    label: 'Find ATM',
                    icon: CupertinoIcons.location,
                    type: CUButtonType.filled,
                  ),
                ),
              ],
            ),
            SizedBox(height: CUSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: CUButton(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CUDialog(
                          title: 'Schedule Appointment',
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Select a service:',
                                style: CUTypography.bodyMedium,
                              ),
                              SizedBox(height: CUSpacing.md),
                              _buildAppointmentListTile(
                                context,
                                icon: CupertinoIcons.building_2_fill,
                                title: 'Loan Consultation',
                              ),
                              _buildAppointmentListTile(
                                context,
                                icon: CupertinoIcons.graph_circle,
                                title: 'Investment Advisor',
                              ),
                              _buildAppointmentListTile(
                                context,
                                icon: CupertinoIcons.creditcard,
                                title: 'Account Services',
                              ),
                            ],
                          ),
                          actions: [
                            CUButton(
                              onPressed: () => Navigator.pop(context),
                              label: 'Cancel',
                              type: CUButtonType.text,
                            ),
                            CUButton(
                              onPressed: () {
                                Navigator.pop(context);
                                CUSnackBar.show(
                                  context,
                                  message: 'Opening appointment scheduler...',
                                  type: CUSnackBarType.success,
                                );
                              },
                              label: 'Continue',
                              type: CUButtonType.filled,
                            ),
                          ],
                        ),
                      );
                    },
                    label: 'Appointments',
                    icon: CupertinoIcons.calendar,
                    type: CUButtonType.filled,
                  ),
                ),
                SizedBox(width: CUSpacing.sm),
                Expanded(
                  child: CUButton(
                    onPressed: () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CUDialog(
                          title: 'Help & Support',
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildHelpListTile(
                                context,
                                icon: CupertinoIcons.book,
                                title: 'FAQ',
                                subtitle: 'Common questions',
                              ),
                              _buildHelpListTile(
                                context,
                                icon: CupertinoIcons.chat_bubble_2,
                                title: 'Chat with CU.APPGPT',
                                subtitle: 'AI Assistant',
                              ),
                              _buildHelpListTile(
                                context,
                                icon: CupertinoIcons.phone,
                                title: 'Call Support',
                                subtitle: '1-800-CUAPP-AI',
                              ),
                            ],
                          ),
                          actions: [
                            CUButton(
                              onPressed: () => Navigator.pop(context),
                              label: 'Close',
                              type: CUButtonType.text,
                            ),
                          ],
                        ),
                      );
                    },
                    label: 'Help',
                    icon: CupertinoIcons.question_circle,
                    type: CUButtonType.filled,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildATMListTile(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: CUSpacing.xs),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.location_fill,
            color: theme.colorScheme.primary,
            size: CUSize.iconMd,
          ),
          SizedBox(width: CUSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CUTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: CUSpacing.xxs),
                Text(
                  subtitle,
                  style: CUTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: CUSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.onSurface,
            size: CUSize.iconMd,
          ),
          SizedBox(width: CUSpacing.sm),
          Text(
            title,
            style: CUTypography.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildHelpListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: CUSpacing.xs),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.onSurface,
            size: CUSize.iconMd,
          ),
          SizedBox(width: CUSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CUTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: CUSpacing.xxs),
                Text(
                  subtitle,
                  style: CUTypography.bodySmall.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
