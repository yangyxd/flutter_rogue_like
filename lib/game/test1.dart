import 'dart:async';
import 'dart:math';
import 'dart:ui';

import '../events/restart_event.dart';
import '../utils.dart';
import 'utils/game.dart';

import 'game_app.dart';
import 'utils/text_render.dart';

class Test1 extends PositionComponent
    with FpsMixin, Draggable, HasGameRef<GameApp> {
  late Target target = Target(position: Vector2(width / 2, height / 2));
  Vector2? dragPosition;
  late Timer timer;
  TextRender timeText = TextRender(position: Vector2(10, 30));

  int startTime = 0;

  /// 游戏时间（秒）
  double time = 0;

  late StreamSubscription _streamReStart;

  @override
  Future<void>? onLoad() {
    timer = Timer(0.1, onTick: () => createBullet(), repeat: true);
    timer.pause();
    target.updatePath();
    _streamReStart = eventBus.on<Restart>().listen((event) {
      restart();
    });
    return super.onLoad();
  }

  @override
  void onRemove() {
    _streamReStart.cancel();
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    target.render(canvas);
    if (timer.isRunning()) {
      time = (Utils.currentTimestamp - startTime) / 1000;
    }
    timeText.render(canvas, "time: ${time.toStringAsFixed(2)}s");
  }

  @override
  void updateTree(double dt) {
    if (timer.isRunning()) {
      super.updateTree(dt);
    }
  }

  @override
  void update(double dt) {
    if (timer.isRunning()) {
      timer.update(dt);
    }
    for (var item in children) {
      if (item is Bullet) {
        if (item.isNotVisible(size.x, size.y)) {
          remove(item);
        } else if (item.isCollision(target)) {
          stop();
          break;
        }
      }
    }
  }

  @override
  void onGameResize(Vector2 size) {
    this.size = size;
    if (isMounted && !timer.isRunning()) {
      target.setPosition(size / 2, width, height);
    }
    super.onGameResize(size);
  }

  @override
  bool onDragStart(DragStartInfo info) {
    if (!timer.isRunning() ||
        target.position.distanceTo(info.eventPosition.game) > target.radius) {
      // 在圆内才允许拖动
      return false;
    }
    dragPosition = info.eventPosition.game - target.position;
    return true;
  }

  @override
  bool onDragUpdate(DragUpdateInfo info) {
    final dragPosition = this.dragPosition;
    if (dragPosition == null) {
      return false;
    }
    target.setPosition(info.eventPosition.game - dragPosition, width, height);
    return false;
  }

  @override
  bool onDragEnd(DragEndInfo info) {
    dragPosition = null;
    return false;
  }

  void restart() {
    target.setPosition(size / 2, width, height);
    startTime = Utils.currentTimestamp;
    clearChildren();
    timer.resume();
  }

  void stop() {
    dragPosition = null;
    timer.pause();
    eventBus.fire(Pause());
  }

  void createBullet() {
    final random = Random();
    bool isHorizontal = random.nextBool();
    bool isBottom = random.nextBool();
    int r = random.nextInt(6) + 5;
    int w = width.toInt();
    int h = height.toInt();
    int x = isHorizontal
        ? random.nextInt(w - r * 2)
        : isBottom
            ? r
            : w - r * 2;
    int y = isHorizontal
        ? isBottom
            ? r
            : h - r * 2
        : random.nextInt(h - r * 2);
    add(Bullet(
      position: Vector2(x.toDouble(), y.toDouble()),
      angle: atan2(y - target.position.y, x - target.position.x),
      radius: r.toDouble(),
      speed: time / 10 + 3,
    ));
  }
}

/// 目标
class Target {
  final Vector2 position;
  final double radius;
  late Path path = Path();
  late Paint paint = Paint()..color = Colors.greenAccent;

  Target({required this.position, this.radius = 20});

  void render(Canvas c) {
    c.drawCircle(position.toOffset(), radius, paint);
  }

  void setPosition(Vector2 v, double w, double h) {
    if (v.x < radius) v.x = radius;
    if (v.y < radius) v.y = radius;
    if (v.x > w - radius) v.x = w - radius;
    if (v.y > h - radius) v.y = h - radius;
    position.setFrom(v);
    updatePath();
  }

  void updatePath() {
    path.reset();
    path.addOval(Rect.fromLTWH(
        position.x - radius, position.y - radius, radius * 2, radius * 2));
  }
}

/// 子弹
class Bullet extends Component with FpsMixin {
  final Vector2 position;
  final double speed;
  final double angle;
  final double radius;
  late Paint paint = Paint()..color = Colors.orangeAccent;
  late Path path = Path();

  Bullet(
      {required this.position,
      this.radius = 10,
      this.speed = 5,
      this.angle = 0});

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(position.toOffset(), radius, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.setValues(
        position.x - cos(angle) * speed, position.y - sin(angle) * speed);
    path.reset();
    path.addOval(Rect.fromLTWH(
        position.x - radius, position.y - radius, radius * 2, radius * 2));
  }

  /// 是否不可见了
  bool isNotVisible(double x, double y) {
    return position.x < -radius * 2 ||
        position.y < -radius * 2 ||
        position.x > x - radius * 2 ||
        position.y > y - radius * 2;
  }

  /// 是否击中
  bool isCollision(Target target) {
    return Path.combine(PathOperation.intersect, target.path, path)
            .getBounds()
            .width >
        0;
  }
}
