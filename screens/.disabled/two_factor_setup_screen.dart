import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import '../models/security_model.dart';
import '../services/security_service.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  final SecurityService _securityService = SecurityService();
  final PageController _pageController = PageController();
  final TextEditingController _verificationCodeController = TextEditingController();

  TwoFactorMethod _selectedMethod = TwoFactorMethod.authenticator;
  int _currentStep = 0;
  bool _isLoading = false;
  String? _qrCodeData;
  String? _secretKey;
  List<String>? _backupCodes;

  @override
  void dispose() {
    _pageController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return CUScaffold(
      appBar: CUAppBar(
        title: const Text('Set Up Two-Factor Authentication'),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : double.infinity,
          ),
          child: Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildMethodSelection(),
                    _buildSetupStep(),
                    _buildVerificationStep(),
                    _buildBackupCodesStep(),
                    _buildCompletionStep(),
                  ],
                ),
              ),

              // Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final theme = CUTheme.of(context);

    return Container(
      padding: EdgeInsets.all(CUSpacing.large),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child: Row(
              children: [
                Container(
                  width: CUSize.icon,
                  height: CUSize.icon,
                  decoration: BoxDecoration(
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.surfaceVariant,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? CUIcon(
                            CUIcons.check,
                            size: CUSize.iconSmall,
                            color: theme.colorScheme.onPrimary,
                          )
                        : Text(
                            '${index + 1}',
                            style: CUTypography.labelMedium.copyWith(
                              color: isActive
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                if (index < 4)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceVariant,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMethodSelection() {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.all(CUSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose Your 2FA Method',
            style: CUTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.xSmall),
          Text(
            'Select how you want to receive your verification codes',
            style: CUTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.xLarge),
          ...TwoFactorMethod.values.map((method) => _buildMethodCard(method)),
        ],
      ),
    );
  }

  Widget _buildMethodCard(TwoFactorMethod method) {
    final theme = CUTheme.of(context);
    final isSelected = _selectedMethod == method;

    return CUCard(
      margin: EdgeInsets.only(bottom: CUSpacing.medium),
      elevation: isSelected ? 4 : 1,
      child: CUInkWell(
        onTap: () {
          setState(() => _selectedMethod = method);
        },
        borderRadius: CURadius.medium,
        child: Container(
          padding: EdgeInsets.all(CUSpacing.medium),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CURadius.medium),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : CUColors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              CUIcon(
                _getMethodIcon(method),
                size: CUSize.iconLarge,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: CUSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.displayName,
                      style: CUTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: CUSpacing.xxSmall),
                    Text(
                      method.description,
                      style: CUTypography.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              CURadio<TwoFactorMethod>(
                value: method,
                groupValue: _selectedMethod,
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedMethod = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSetupStep() {
    switch (_selectedMethod) {
      case TwoFactorMethod.authenticator:
        return _buildAuthenticatorSetup();
      case TwoFactorMethod.sms:
        return _buildSMSSetup();
      case TwoFactorMethod.email:
        return _buildEmailSetup();
    }
  }

  Widget _buildAuthenticatorSetup() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set Up Authenticator App',
            style: CUTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.xSmall),
          Text(
            'Scan this QR code with your authenticator app',
            style: CUTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.xLarge),

          // QR Code
          Center(
            child: Container(
              padding: EdgeInsets.all(CUSpacing.medium),
              decoration: BoxDecoration(
                color: CUColors.white,
                borderRadius: BorderRadius.circular(CURadius.large),
                boxShadow: [
                  BoxShadow(
                    color: CUColors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _qrCodeData != null
                  ? _buildQRCode(_qrCodeData!)
                  : SizedBox(
                      width: 200,
                      height: 200,
                      child: Center(
                        child: CUProgressIndicator(),
                      ),
                    ),
            ),
          ),

          SizedBox(height: CUSpacing.xLarge),

          // Manual Entry Option
          CUCard(
            child: CUExpansionTile(
              title: const Text('Can\'t scan? Enter manually'),
              children: [
                Padding(
                  padding: EdgeInsets.all(CUSpacing.medium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account: SUPAHYPER',
                        style: CUTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: CUSpacing.xSmall),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.all(CUSpacing.small),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant,
                                borderRadius: BorderRadius.circular(CURadius.small),
                              ),
                              child: Text(
                                _secretKey ?? 'Loading...',
                                style: CUTypography.bodySmall.copyWith(
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: CUSpacing.xSmall),
                          CUIconButton(
                            icon: CUIcons.copy,
                            onPressed: _secretKey != null
                                ? () {
                                    Clipboard.setData(ClipboardData(text: _secretKey!));
                                    _showSuccessSnackBar('Secret key copied');
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: CUSpacing.xLarge),

          // Supported Apps
          _buildSupportedApps(),
        ],
      ),
    );
  }

  Widget _buildSMSSetup() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SMS Verification Setup',
            style: CUTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.xSmall),
          Text(
            'We\'ll send verification codes to your registered phone number',
            style: CUTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.xLarge),

          CUCard(
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.large),
              child: Column(
                children: [
                  CUIcon(
                    CUIcons.phoneAndroid,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: CUSpacing.medium),
                  Text(
                    'Phone Number',
                    style: CUTypography.titleMedium,
                  ),
                  SizedBox(height: CUSpacing.xSmall),
                  Text(
                    '+1 (555) 123-4567',
                    style: CUTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: CUSpacing.large),
                  CUButton.outlined(
                    onPressed: () {
                      _showInfoSnackBar('Phone number update coming soon');
                    },
                    icon: CUIcons.edit,
                    text: 'Change Phone Number',
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: CUSpacing.large),

          CUCard(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.medium),
              child: Row(
                children: [
                  CUIcon(
                    CUIcons.infoOutline,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  SizedBox(width: CUSpacing.medium),
                  Expanded(
                    child: Text(
                      'Standard messaging rates may apply',
                      style: CUTypography.bodyMedium.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailSetup() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Email Verification Setup',
            style: CUTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.xSmall),
          Text(
            'We\'ll send verification codes to your registered email address',
            style: CUTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.xLarge),

          CUCard(
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.large),
              child: Column(
                children: [
                  CUIcon(
                    CUIcons.email,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: CUSpacing.medium),
                  Text(
                    'Email Address',
                    style: CUTypography.titleMedium,
                  ),
                  SizedBox(height: CUSpacing.xSmall),
                  Text(
                    'user@example.com',
                    style: CUTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: CUSpacing.large),
                  CUButton.outlined(
                    onPressed: () {
                      _showInfoSnackBar('Email update coming soon');
                    },
                    icon: CUIcons.edit,
                    text: 'Change Email Address',
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: CUSpacing.large),

          CUCard(
            color: theme.colorScheme.secondaryContainer,
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.medium),
              child: Row(
                children: [
                  CUIcon(
                    CUIcons.security,
                    color: theme.colorScheme.onSurface,
                  ),
                  SizedBox(width: CUSpacing.medium),
                  Expanded(
                    child: Text(
                      'Make sure you have access to this email address',
                      style: CUTypography.bodyMedium.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStep() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verify Your Setup',
            style: CUTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.xSmall),
          Text(
            _getVerificationInstructions(),
            style: CUTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.xLarge),

          // Verification Code Input
          CUTextField(
            controller: _verificationCodeController,
            keyboardType: TextInputType.number,
            hintText: '000000',
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(6),
            ],
          ),

          SizedBox(height: CUSpacing.large),

          // Resend Option
          if (_selectedMethod != TwoFactorMethod.authenticator)
            Center(
              child: CUButton.text(
                onPressed: _isLoading ? null : _resendCode,
                icon: CUIcons.refresh,
                text: 'Resend Code',
              ),
            ),

          SizedBox(height: CUSpacing.xLarge),

          // Help Card
          CUCard(
            color: theme.colorScheme.tertiaryContainer,
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CUIcon(
                        CUIcons.helpOutline,
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                      SizedBox(width: CUSpacing.xSmall),
                      Text(
                        'Having trouble?',
                        style: CUTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: CUSpacing.xSmall),
                  Text(
                    _getTroubleshootingTips(),
                    style: CUTypography.bodyMedium.copyWith(
                      color: theme.colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupCodesStep() {
    final theme = CUTheme.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(CUSpacing.large),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Save Your Backup Codes',
            style: CUTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.xSmall),
          Text(
            'Keep these codes safe. You can use them to access your account if you lose your 2FA device.',
            style: CUTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.xLarge),

          // Backup Codes Display
          CUCard(
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.large),
              child: Column(
                children: [
                  if (_backupCodes != null)
                    ..._backupCodes!.map((code) => Padding(
                          padding: EdgeInsets.symmetric(vertical: CUSpacing.xSmall),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: CUSpacing.medium,
                                  vertical: CUSpacing.xSmall,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(CURadius.small),
                                ),
                                child: Text(
                                  code,
                                  style: CUTypography.bodyLarge.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))
                  else
                    CUProgressIndicator(),
                ],
              ),
            ),
          ),

          SizedBox(height: CUSpacing.large),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CUButton.outlined(
                  onPressed: _copyBackupCodes,
                  icon: CUIcons.copy,
                  text: 'Copy All',
                ),
              ),
              SizedBox(width: CUSpacing.medium),
              Expanded(
                child: CUButton.outlined(
                  onPressed: _downloadBackupCodes,
                  icon: CUIcons.download,
                  text: 'Download',
                ),
              ),
            ],
          ),

          SizedBox(height: CUSpacing.xLarge),

          // Warning Card
          CUCard(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.medium),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CUIcon(
                    CUIcons.warning,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  SizedBox(width: CUSpacing.medium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Important',
                          style: CUTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                        SizedBox(height: CUSpacing.xxSmall),
                        Text(
                          'Each code can only be used once. Store them securely and never share them with anyone.',
                          style: CUTypography.bodyMedium.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStep() {
    final theme = CUTheme.of(context);

    return Padding(
      padding: EdgeInsets.all(CUSpacing.large),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CUIcon(
            CUIcons.checkCircle,
            size: 120,
            color: CUColors.green,
          ),
          SizedBox(height: CUSpacing.xLarge),
          Text(
            'All Set!',
            style: CUTypography.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: CUSpacing.medium),
          Text(
            'Two-factor authentication is now enabled for your account',
            textAlign: TextAlign.center,
            style: CUTypography.bodyLarge.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: CUSpacing.xxxLarge),

          // Summary Card
          CUCard(
            child: Padding(
              padding: EdgeInsets.all(CUSpacing.large),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Method',
                    _selectedMethod.displayName,
                    _getMethodIcon(_selectedMethod),
                  ),
                  CUDivider(height: CUSpacing.large),
                  _buildSummaryRow(
                    'Backup Codes',
                    '${_backupCodes?.length ?? 0} codes saved',
                    CUIcons.key,
                  ),
                  CUDivider(height: CUSpacing.large),
                  _buildSummaryRow(
                    'Security Score',
                    '+20% improvement',
                    CUIcons.trendingUp,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, IconData icon) {
    final theme = CUTheme.of(context);

    return Row(
      children: [
        CUIcon(icon, color: theme.colorScheme.primary),
        SizedBox(width: CUSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: CUTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: CUTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    final theme = CUTheme.of(context);

    return Container(
      padding: EdgeInsets.all(CUSpacing.large),
      child: Row(
        children: [
          if (_currentStep > 0)
            CUButton.text(
              onPressed: _previousStep,
              text: 'Back',
            )
          else
            const SizedBox(width: 80),
          const Spacer(),
          if (_currentStep < 4)
            CUButton.filled(
              onPressed: _isLoading ? null : _nextStep,
              isLoading: _isLoading,
              text: _currentStep == 3 ? 'Complete' : 'Continue',
            )
          else
            CUButton.filled(
              onPressed: _complete,
              text: 'Done',
            ),
        ],
      ),
    );
  }

  Widget _buildQRCode(String data) {
    // In a real app, you would use a QR code generation library
    // For now, we'll show a placeholder
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: CUColors.white,
        borderRadius: BorderRadius.circular(CURadius.small),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CUIcon(
              CUIcons.qrCode,
              size: 120,
              color: CUColors.black87,
            ),
            SizedBox(height: CUSpacing.xSmall),
            Text(
              'QR Code',
              style: CUTypography.bodySmall.copyWith(
                color: CUColors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportedApps() {
    final theme = CUTheme.of(context);
    final apps = [
      {'name': 'Google Authenticator', 'icon': CUIcons.key},
      {'name': 'Microsoft Authenticator', 'icon': CUIcons.security},
      {'name': 'Authy', 'icon': CUIcons.phoneAndroid},
      {'name': '1Password', 'icon': CUIcons.password},
    ];

    return CUCard(
      child: Padding(
        padding: EdgeInsets.all(CUSpacing.medium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supported Apps',
              style: CUTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: CUSpacing.medium),
            Wrap(
              spacing: CUSpacing.small,
              runSpacing: CUSpacing.small,
              children: apps.map<Widget>((app) => CUChip(
                    avatar: CUIcon(app['icon'] as IconData, size: CUSize.iconSm),
                    label: Text(app['name'] as String),
                  )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getMethodIcon(TwoFactorMethod method) {
    switch (method) {
      case TwoFactorMethod.sms:
        return CUIcons.sms;
      case TwoFactorMethod.email:
        return CUIcons.email;
      case TwoFactorMethod.authenticator:
        return CUIcons.smartphone;
    }
  }

  String _getVerificationInstructions() {
    switch (_selectedMethod) {
      case TwoFactorMethod.sms:
        return 'Enter the 6-digit code we sent to your phone';
      case TwoFactorMethod.email:
        return 'Enter the 6-digit code we sent to your email';
      case TwoFactorMethod.authenticator:
        return 'Enter the 6-digit code from your authenticator app';
    }
  }

  String _getTroubleshootingTips() {
    switch (_selectedMethod) {
      case TwoFactorMethod.sms:
        return 'Check your phone for SMS messages. The code may take a few moments to arrive.';
      case TwoFactorMethod.email:
        return 'Check your spam folder if you don\'t see the email in your inbox.';
      case TwoFactorMethod.authenticator:
        return 'Make sure the time on your device is synchronized correctly.';
    }
  }

  Future<void> _nextStep() async {
    switch (_currentStep) {
      case 0:
        // Method selected, proceed to setup
        await _initializeSetup();
        break;
      case 1:
        // Setup completed, send verification code
        await _sendVerificationCode();
        break;
      case 2:
        // Verify the code
        await _verifyCode();
        break;
      case 3:
        // Generate backup codes
        await _generateBackupCodes();
        break;
    }
  }

  Future<void> _initializeSetup() async {
    setState(() => _isLoading = true);

    try {
      if (_selectedMethod == TwoFactorMethod.authenticator) {
        final result = await _securityService.enableTwoFactor(_selectedMethod);
        setState(() {
          _qrCodeData = result['qrCode'];
          _secretKey = result['secret'];
        });
      }

      setState(() {
        _currentStep++;
        _isLoading = false;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to initialize setup');
    }
  }

  Future<void> _sendVerificationCode() async {
    if (_selectedMethod != TwoFactorMethod.authenticator) {
      setState(() => _isLoading = true);

      try {
        await _securityService.enableTwoFactor(_selectedMethod);
        _showSuccessSnackBar('Verification code sent');
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Failed to send verification code');
        return;
      }

      setState(() => _isLoading = false);
    }

    setState(() => _currentStep++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _verifyCode() async {
    final code = _verificationCodeController.text;

    if (code.length != 6) {
      _showErrorSnackBar('Please enter a 6-digit code');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isValid = await _securityService.verifyTwoFactorCode(code);

      if (isValid) {
        setState(() {
          _currentStep++;
          _isLoading = false;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Invalid code. Please try again.');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to verify code');
    }
  }

  Future<void> _generateBackupCodes() async {
    setState(() => _isLoading = true);

    try {
      final codes = await _securityService.generateBackupCodes();
      setState(() {
        _backupCodes = codes;
        _currentStep++;
        _isLoading = false;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to generate backup codes');
    }
  }

  void _previousStep() {
    setState(() => _currentStep--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _complete() {
    Navigator.pop(context, true);
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);

    try {
      await _securityService.enableTwoFactor(_selectedMethod);
      _showSuccessSnackBar('New code sent');
    } catch (e) {
      _showErrorSnackBar('Failed to resend code');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _copyBackupCodes() {
    if (_backupCodes != null) {
      final codesText = _backupCodes!.join('\n');
      Clipboard.setData(ClipboardData(text: codesText));
      _showSuccessSnackBar('Backup codes copied to clipboard');
    }
  }

  void _downloadBackupCodes() {
    // In a real app, this would download a file
    _showInfoSnackBar('Download feature coming soon');
  }

  void _showSuccessSnackBar(String message) {
    final theme = CUTheme.of(context);
    CUSnackBar.show(
      context,
      message: message,
      type: CUSnackBarType.success,
    );
  }

  void _showErrorSnackBar(String message) {
    final theme = CUTheme.of(context);
    CUSnackBar.show(
      context,
      message: message,
      type: CUSnackBarType.error,
    );
  }

  void _showInfoSnackBar(String message) {
    final theme = CUTheme.of(context);
    CUSnackBar.show(
      context,
      message: message,
      type: CUSnackBarType.info,
    );
  }
}
