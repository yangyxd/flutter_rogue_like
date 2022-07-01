import 'utils/game.dart';
import 'package:roguelike/game/test1.dart';

/// 游戏视图
class GameView extends PositionComponent with FpsMixin {
  @override
  Future<void>? onLoad() {
    add(Test1());
    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    this.size = size;
    super.onGameResize(size);
  }
}

