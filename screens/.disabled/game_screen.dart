import 'package:flutter/widgets.dart';
import 'package:flame/game.dart';
import '../games/flappy_bird_game.dart';
import 'package:cu_design_system_omni/cu_design_system_omni.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = CUTheme.of(context);

    return CUScaffold(
      backgroundColor: CUColors.black,
      appBar: CUAppBar(
        backgroundColor: CUColors.transparent,
        leading: CUIconButton(
          icon: CupertinoIcons.xmark,
          color: CUColors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: CUText(
          'CU.APP Game Zone',
          style: CUTextStyle.h3.copyWith(
            color: CUColors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(CUSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(CURadius.lg),
            border: Border.all(color: CUColors.white.withOpacity(0.24), width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: GameWidget(game: FlappyBirdGame()),
        ),
      ),
    );
  }
}
