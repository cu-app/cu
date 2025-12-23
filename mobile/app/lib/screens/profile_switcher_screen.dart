import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'package:provider/provider.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';

class ProfileSwitcherScreen extends StatelessWidget {
  final Function(UserProfile) onProfileSelected;

  const ProfileSwitcherScreen({
    super.key,
    required this.onProfileSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return Consumer<ProfileService>(
      builder: (context, profileService, child) {
        final profiles = profileService.userProfiles;
        final currentProfile = profileService.currentProfile;

        return Container(
          color: theme.colorScheme.surface,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(CUSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Switch Profile',
                      style: CUTypography.headingLarge(context),
                    ),
                    SizedBox(height: CUSpacing.xs),
                    Text(
                      'Select a profile to continue',
                      style: CUTypography.bodyMedium(context).copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              CUDivider(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: CUSpacing.sm),
                  itemCount: profiles.length + 1,
                  itemBuilder: (context, index) {
                    if (index == profiles.length) {
                      // Add new profile button
                      return _buildAddProfileTile(context);
                    }

                    final profile = profiles[index];
                    final isSelected = profile.id == currentProfile?.id;

                    return _buildProfileTile(
                      context,
                      profile,
                      isSelected,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileTile(
    BuildContext context,
    UserProfile profile,
    bool isSelected,
  ) {
    final theme = CUTheme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: CUSpacing.md,
        vertical: CUSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(CURadius.md),
        border: Border.all(
          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
          width: isSelected ? CUSize.borderWidthThick : CUSize.borderWidthThin,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: CUColors.black.withOpacity(0.1),
                  blurRadius: CUSpacing.sm,
                  offset: Offset(0, CUSpacing.xxs),
                ),
              ]
            : null,
      ),
      child: CUInkWell(
        onTap: () => onProfileSelected(profile),
        borderRadius: BorderRadius.circular(CURadius.md),
        child: Padding(
          padding: EdgeInsets.all(CUSpacing.md),
          child: Row(
            children: [
              Container(
                width: CUSize.iconXL,
                height: CUSize.iconXL,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.surface
                      : _getProfileColor(theme, profile.type),
                  borderRadius: BorderRadius.circular(CURadius.round),
                ),
                child: Center(
                  child: CUIcon(
                    _getProfileIcon(profile.type),
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onPrimary,
                    size: CUSize.iconLg,
                  ),
                ),
              ),
              SizedBox(width: CUSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: CUTypography.bodyLarge(context).copyWith(
                        fontWeight: CUFontWeight.semiBold,
                        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: CUSpacing.xxs),
                    Text(
                      profile.type.description,
                      style: CUTypography.bodySmall(context).copyWith(
                        color: isSelected
                            ? theme.colorScheme.onPrimary.withOpacity(0.8)
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (profile.businessName != null) ...[
                      SizedBox(height: CUSpacing.xxs),
                      Text(
                        profile.businessName!,
                        style: CUTypography.labelSmall(context).copyWith(
                          color: isSelected
                              ? theme.colorScheme.onPrimary.withOpacity(0.7)
                              : theme.colorScheme.onSurfaceVariant.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                CUIcon(
                  CUIconData.checkCircle,
                  color: theme.colorScheme.onPrimary,
                  size: CUSize.iconMd,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddProfileTile(BuildContext context) {
    final theme = CUTheme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: CUSpacing.md,
        vertical: CUSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(CURadius.md),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: CUSize.borderWidthThin,
        ),
      ),
      child: CUInkWell(
        onTap: () {
          // Navigate to profile creation
          _showCreateProfileDialog(context);
        },
        borderRadius: BorderRadius.circular(CURadius.md),
        child: Padding(
          padding: EdgeInsets.all(CUSpacing.md),
          child: Row(
            children: [
              Container(
                width: CUSize.iconXL,
                height: CUSize.iconXL,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(CURadius.round),
                  border: Border.all(
                    color: theme.colorScheme.outline,
                    width: CUSize.borderWidthThick,
                  ),
                ),
                child: Center(
                  child: CUIcon(
                    CUIconData.add,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: CUSize.iconLg,
                  ),
                ),
              ),
              SizedBox(width: CUSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Profile',
                      style: CUTypography.bodyLarge(context).copyWith(
                        fontWeight: CUFontWeight.semiBold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: CUSpacing.xxs),
                    Text(
                      'Create a new membership profile',
                      style: CUTypography.bodySmall(context).copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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

  void _showCreateProfileDialog(BuildContext context) {
    final theme = CUTheme.of(context);

    showCUDialog(
      context: context,
      builder: (context) => CUAlertDialog(
        title: Text(
          'Create New Profile',
          style: CUTypography.headingMedium(context),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildProfileTypeOption(
              context,
              ProfileType.business,
              'Apply for Business Membership',
              'Manage your business finances',
            ),
            SizedBox(height: CUSpacing.sm),
            _buildProfileTypeOption(
              context,
              ProfileType.youth,
              'Open Youth Account',
              'Start saving early (Under 18)',
            ),
            SizedBox(height: CUSpacing.sm),
            _buildProfileTypeOption(
              context,
              ProfileType.fiduciary,
              'Create Fiduciary Account',
              'Manage trust or estate',
            ),
          ],
        ),
        actions: [
          CUTextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: CUTypography.labelLarge(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTypeOption(
    BuildContext context,
    ProfileType type,
    String title,
    String subtitle,
  ) {
    final theme = CUTheme.of(context);

    return CUInkWell(
      onTap: () {
        Navigator.pop(context);
        // Navigate to profile creation flow
        CUSnackBar.show(
          context,
          message: 'Creating ${type.displayName} profile...',
        );
      },
      borderRadius: BorderRadius.circular(CURadius.sm),
      child: Container(
        padding: EdgeInsets.all(CUSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(CURadius.sm),
        ),
        child: Row(
          children: [
            Container(
              width: CUSize.iconLg,
              height: CUSize.iconLg,
              decoration: BoxDecoration(
                color: _getProfileColor(theme, type),
                borderRadius: BorderRadius.circular(CURadius.round),
              ),
              child: Center(
                child: CUIcon(
                  _getProfileIcon(type),
                  color: theme.colorScheme.onPrimary,
                  size: CUSize.iconMd,
                ),
              ),
            ),
            SizedBox(width: CUSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CUTypography.bodyMedium(context).copyWith(
                      fontWeight: CUFontWeight.semiBold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: CUTypography.bodySmall(context).copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
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

  Color _getProfileColor(CUThemeData theme, ProfileType type) {
    switch (type) {
      case ProfileType.personal:
        return CUColors.blue;
      case ProfileType.business:
        return CUColors.green;
      case ProfileType.youth:
        return CUColors.orange;
      case ProfileType.fiduciary:
        return CUColors.purple;
    }
  }

  CUIconData _getProfileIcon(ProfileType type) {
    switch (type) {
      case ProfileType.personal:
        return CUIconData.person;
      case ProfileType.business:
        return CUIconData.business;
      case ProfileType.youth:
        return CUIconData.school;
      case ProfileType.fiduciary:
        return CUIconData.accountBalance;
    }
  }
}
