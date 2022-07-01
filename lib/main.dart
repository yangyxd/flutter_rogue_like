import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'game/game_app.dart';
import 'styles.dart';
import 'view/home_page.dart';

void main() {
  runApp(
    const App()
  );
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  final locale = const Locale('zh', 'CH');

  @override
  Widget build(BuildContext context) {
    Styles.useAppStyle();
    return OKToast(
      textStyle: const TextStyle(
          fontSize: 15.0,
          color: Colors.white,
          fontFamily: Styles.fontFamily),
      backgroundColor: Colors.black.withOpacity(0.8),
      radius: 20.0,
      textPadding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scrollBehavior: const MaterialScrollBehavior().copyWith(
            scrollbars: true,
            dragDevices: _kTouchLikeDeviceTypes
        ),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: locale,
        supportedLocales: [locale],
        home: Stack(
          children: [
            GameWidget(game: GameApp()),
            const HomePage(),
          ],
        ),
      ),
    );
  }
}


const Set<PointerDeviceKind> _kTouchLikeDeviceTypes = <PointerDeviceKind>{
  PointerDeviceKind.touch,
  PointerDeviceKind.mouse,
  PointerDeviceKind.stylus,
  PointerDeviceKind.invertedStylus,
  PointerDeviceKind.unknown
};