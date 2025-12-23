import 'package:flutter/widgets.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class ElevationScreen extends StatelessWidget {
  const ElevationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final Color shadowColor = theme.colorScheme.shadow;
    final Color surfaceTint = theme.colorScheme.primary;
    
    return CUScaffold(
      appBar: CUAppBar(
        title: Text(
          'Elevation',
          style: CUTypography.titleLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(CUSpacing.md, CUSpacing.lg, CUSpacing.md, 0),
              child: Text(
                'Surface Tint Color Only',
                style: CUTypography.titleLarge,
              ),
            ),
          ),
          ElevationGrid(
            surfaceTintColor: surfaceTint,
            shadowColor: Colors.transparent,
          ),
          SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              SizedBox(height: CUSpacing.sm),
              Padding(
                padding: EdgeInsets.fromLTRB(CUSpacing.md, CUSpacing.sm, CUSpacing.md, 0),
                child: Text(
                  'Surface Tint Color and Shadow Color',
                  style: CUTypography.titleLarge,
                ),
              ),
            ]),
          ),
          ElevationGrid(
            shadowColor: shadowColor,
            surfaceTintColor: surfaceTint,
          ),
          SliverList(
            delegate: SliverChildListDelegate(<Widget>[
              SizedBox(height: CUSpacing.sm),
              Padding(
                padding: EdgeInsets.fromLTRB(CUSpacing.md, CUSpacing.sm, CUSpacing.md, 0),
                child: Text(
                  'Shadow Color Only',
                  style: CUTypography.titleLarge,
                ),
              ),
            ]),
          ),
          ElevationGrid(shadowColor: shadowColor),
        ],
      ),
    );
  }
}

const double narrowScreenWidthThreshold = 450;

// Import Colors for transparent
import 'package:flutter/material.dart' show Colors;

class ElevationGrid extends StatelessWidget {
  const ElevationGrid({
    super.key,
    this.shadowColor,
    this.surfaceTintColor,
  });

  final Color? shadowColor;
  final Color? surfaceTintColor;

  List<ElevationCard> elevationCards(
    Color? shadowColor,
    Color? surfaceTintColor,
  ) {
    return elevations
        .map(
          (elevationInfo) => ElevationCard(
            info: elevationInfo,
            shadowColor: shadowColor,
            surfaceTint: surfaceTintColor,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.all(CUSpacing.sm),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          if (constraints.crossAxisExtent < narrowScreenWidthThreshold) {
            return SliverGrid.count(
              crossAxisCount: 3,
              children: elevationCards(shadowColor, surfaceTintColor),
            );
          } else {
            return SliverGrid.count(
              crossAxisCount: 6,
              children: elevationCards(shadowColor, surfaceTintColor),
            );
          }
        },
      ),
    );
  }
}

class ElevationCard extends StatefulWidget {
  const ElevationCard({
    super.key,
    required this.info,
    this.shadowColor,
    this.surfaceTint,
  });

  final ElevationInfo info;
  final Color? shadowColor;
  final Color? surfaceTint;

  @override
  State<ElevationCard> createState() => _ElevationCardState();
}

class _ElevationCardState extends State<ElevationCard> {
  late double _elevation;

  @override
  void initState() {
    super.initState();
    _elevation = widget.info.elevation;
  }

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);
    final Color color = theme.colorScheme.surface;

    return Padding(
      padding: EdgeInsets.all(CUSpacing.sm),
      child: CUCard(
        elevation: _elevation,
        backgroundColor: color,
        child: Padding(
          padding: EdgeInsets.all(CUSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Level ${widget.info.level}',
                style: CUTypography.labelMedium,
              ),
              Text(
                '${widget.info.elevation.toInt()} dp',
                style: CUTypography.labelMedium,
              ),
              if (widget.surfaceTint != null)
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      '${widget.info.overlayPercent}%',
                      style: CUTypography.bodySmall,
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

class ElevationInfo {
  const ElevationInfo(this.level, this.elevation, this.overlayPercent);
  final int level;
  final double elevation;
  final int overlayPercent;
}

const List<ElevationInfo> elevations = <ElevationInfo>[
  ElevationInfo(0, 0.0, 0),
  ElevationInfo(1, 1.0, 5),
  ElevationInfo(2, 3.0, 8),
  ElevationInfo(3, 6.0, 11),
  ElevationInfo(4, 8.0, 12),
  ElevationInfo(5, 12.0, 14),
];
