import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/auth_service.dart';
import '../../services/membership_service.dart';

/// Identity Verification Screen
/// Shows after ID photo + heart identity check
/// Displays: "Hey Kyle, you're a general member and you have a business"
class IdentityVerificationScreen extends StatefulWidget {
  final String firstName;
  final List<Map<String, dynamic>> memberships; // [{type: 'general'}, {type: 'business'}]
  final VoidCallback onContinue;
  final VoidCallback onSkip;

  const IdentityVerificationScreen({
    super.key,
    required this.firstName,
    required this.memberships,
    required this.onContinue,
    required this.onSkip,
  });

  @override
  State<IdentityVerificationScreen> createState() => _IdentityVerificationScreenState();
}

class _IdentityVerificationScreenState extends State<IdentityVerificationScreen> {
  final ImagePicker _picker = ImagePicker();
  final Map<String, XFile?> _avatarFiles = {};
  final Map<String, String> _selectedEmojis = {};
  String? _homeMembershipType;

  @override
  void initState() {
    super.initState();
    // Initialize emoji defaults
    for (var membership in widget.memberships) {
      final type = membership['type'] as String;
      _selectedEmojis[type] = _getDefaultEmoji(type);
    }
    // Set first membership as default home
    if (widget.memberships.isNotEmpty) {
      _homeMembershipType = widget.memberships[0]['type'] as String;
    }
  }

  String _getDefaultEmoji(String membershipType) {
    switch (membershipType) {
      case 'general':
        return '👤';
      case 'business':
        return '💼';
      case 'youth':
        return '🎓';
      case 'fiduciary':
        return '🏛️';
      case 'premium':
        return '💎';
      case 'student':
        return '📚';
      default:
        return '👤';
    }
  }

  Future<void> _pickAvatar(String membershipType) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (image != null) {
        setState(() {
          _avatarFiles[membershipType] = image;
        });

        // Upload to Supabase storage
        await _uploadAvatar(membershipType, image);
      }
    } catch (e) {
      // Show error using CU Design System
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _uploadAvatar(String membershipType, XFile imageFile) async {
    try {
      final authService = AuthService();
      final user = authService.currentUser;
      if (user == null) return;

      // TODO: Upload to Supabase storage
      // final fileBytes = await imageFile.readAsBytes();
      // final fileName = '${user.id}_${membershipType}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      // await supabase.storage.from('avatars').upload(fileName, fileBytes);
      // final avatarUrl = supabase.storage.from('avatars').getPublicUrl(fileName);

      // For now, just store locally
      debugPrint('Avatar uploaded for $membershipType: ${imageFile.path}');
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
    }
  }

  void _setHomeMembership(String membershipType) {
    setState(() {
      _homeMembershipType = membershipType;
    });
  }

  Future<void> _saveAndContinue() async {
    // Save all avatars and preferences
    for (var membership in widget.memberships) {
      final type = membership['type'] as String;
      if (_avatarFiles[type] != null) {
        await _uploadAvatar(type, _avatarFiles[type]!);
      }
    }

    // Save home membership preference
    if (_homeMembershipType != null) {
      // TODO: Save to user preferences
      debugPrint('Home membership set to: $_homeMembershipType');
    }

    widget.onContinue();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    // Build membership list text
    String membershipText = '';
    if (widget.memberships.length == 1) {
      membershipText = 'you\'re a ${widget.memberships[0]['type']} member';
    } else {
      final types = widget.memberships.map((m) => m['type'] as String).toList();
      if (types.length == 2) {
        membershipText = 'you\'re a ${types[0]} member and you have a ${types[1]}';
      } else {
        membershipText = 'you have ${types.length} memberships: ${types.join(', ')}';
      }
    }

    return CUScaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(CUSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: CUSpacing.xl),

              // Greeting
              Text(
                'Hey ${widget.firstName},',
                style: CUTypography.headlineMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: CUSpacing.xs),
              Text(
                membershipText,
                style: CUTypography.titleLarge.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: CUSpacing.xl),

              // Membership Setup
              Expanded(
                child: ListView.builder(
                  itemCount: widget.memberships.length,
                  itemBuilder: (context, index) {
                    final membership = widget.memberships[index];
                    final type = membership['type'] as String;
                    final isHome = _homeMembershipType == type;
                    final hasAvatar = _avatarFiles[type] != null;

                    return CUCard(
                      margin: EdgeInsets.only(bottom: CUSpacing.md),
                      child: Padding(
                        padding: EdgeInsets.all(CUSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Avatar/Emoji
                                GestureDetector(
                                  onTap: () => _pickAvatar(type),
                                  child: Container(
                                    width: CUSize.xxl,
                                    height: CUSize.xxl,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surfaceVariant,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isHome ? theme.colorScheme.primary : Colors.transparent,
                                        width: 3,
                                      ),
                                    ),
                                    child: hasAvatar
                                        ? ClipOval(
                                            child: Image.file(
                                              File(_avatarFiles[type]!.path),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              _selectedEmojis[type] ?? '👤',
                                              style: CUTypography.displaySmall,
                                            ),
                                          ),
                                  ),
                                ),
                                SizedBox(width: CUSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        type.toUpperCase(),
                                        style: CUTypography.titleMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: CUSpacing.xxs),
                                      Text(
                                        'Tap to add photo',
                                        style: CUTypography.bodySmall.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Home badge
                                if (isHome)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: CUSpacing.xs,
                                      vertical: CUSpacing.xxs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(CURadius.md),
                                    ),
                                    child: Text(
                                      'HOME',
                                      style: CUTypography.labelSmall.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: CUSpacing.sm),
                            // Set as home button
                            if (!isHome)
                              CUTextButton(
                                onPressed: () => _setHomeMembership(type),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CUIcon(CUIcons.home, size: CUIconSize.sm),
                                    SizedBox(width: CUSpacing.xxs),
                                    Text('Set as Home', style: CUTypography.bodyMedium),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: CUOutlinedButton(
                      onPressed: widget.onSkip,
                      child: Text('Skip', style: CUTypography.bodyMedium),
                    ),
                  ),
                  SizedBox(width: CUSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: CUButton(
                      onPressed: _saveAndContinue,
                      child: Text('Continue to Dashboard', style: CUTypography.bodyMedium),
                    ),
                  ),
                ],
              ),
              SizedBox(height: CUSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
