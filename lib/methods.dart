import 'package:baserouter/baseclass/routehandler.dart';
import 'package:baserouter/bridge/bridge.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

RouteWatcher route(BuildContext context) =>
    Provider.of<RouteWatcher>(context, listen: false);

BridgeBase bridge(BuildContext context) =>
    Provider.of<BridgeBase>(context, listen: false);
