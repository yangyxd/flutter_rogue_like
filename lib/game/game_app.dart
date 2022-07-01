import 'utils/game.dart';
import 'utils/fps.dart';
import 'game_view.dart';

/// 游戏 APP
class GameApp extends FlameGame with HasDraggables {

  @override
  Future<void> onLoad() async {
    add(GameView());
    add(Fps());
  }

}

