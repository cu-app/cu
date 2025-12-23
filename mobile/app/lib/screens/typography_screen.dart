import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class TypographyScreen extends StatelessWidget {
  const TypographyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    
    return CUScaffold(
      appBar: CUAppBar(
        title: Text(
          'Typography',
          style: CUTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(CUSpacing.md),
        children: <Widget>[
          SizedBox(height: CUSpacing.sm),
          TextStyleExample(
            name: 'Display Large',
            style: CUTypography.displayLarge,
          ),
          TextStyleExample(
            name: 'Display Medium',
            style: CUTypography.displayMedium,
          ),
          TextStyleExample(
            name: 'Display Small',
            style: CUTypography.displaySmall,
          ),
          TextStyleExample(
            name: 'Headline Large',
            style: CUTypography.headlineLarge,
          ),
          TextStyleExample(
            name: 'Headline Medium',
            style: CUTypography.headlineMedium,
          ),
          TextStyleExample(
            name: 'Headline Small',
            style: CUTypography.headlineSmall,
          ),
          TextStyleExample(
            name: 'Title Large',
            style: CUTypography.titleLarge,
          ),
          TextStyleExample(
            name: 'Title Medium',
            style: CUTypography.titleMedium,
          ),
          TextStyleExample(
            name: 'Title Small',
            style: CUTypography.titleSmall,
          ),
          TextStyleExample(
            name: 'Label Large',
            style: CUTypography.labelLarge,
          ),
          TextStyleExample(
            name: 'Label Medium',
            style: CUTypography.labelMedium,
          ),
          TextStyleExample(
            name: 'Label Small',
            style: CUTypography.labelSmall,
          ),
          TextStyleExample(
            name: 'Body Large',
            style: CUTypography.bodyLarge,
          ),
          TextStyleExample(
            name: 'Body Medium',
            style: CUTypography.bodyMedium,
          ),
          TextStyleExample(
            name: 'Body Small',
            style: CUTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

class TextStyleExample extends StatelessWidget {
  const TextStyleExample({
    super.key,
    required this.name,
    required this.style,
  });

  final String name;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(CUSpacing.sm),
      child: Text(name, style: style),
    );
  }
}
