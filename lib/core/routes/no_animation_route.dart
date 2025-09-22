import 'package:flutter/cupertino.dart';

class NoAnimationRoute<T> extends CupertinoPageRoute<T> {
  final WidgetBuilder builder;

  NoAnimationRoute({required this.builder, RouteSettings? settings})
      : super(builder: builder, settings: settings, fullscreenDialog: false);

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  bool get opaque => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;
}
