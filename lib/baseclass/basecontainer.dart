import 'package:baserouter/baseclass/basecontainerOptions.dart';
import 'package:baserouter/baseclass/routehandler.dart';
import 'package:baserouter/baserouter.dart';
import 'package:baserouter/bridge/bridge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BaseContainerEntry extends StatefulWidget {
  const BaseContainerEntry({Key? key, required this.entry}) : super(key: key);
  final Widget entry;

  @override
  _BaseContainerEntryState createState() => _BaseContainerEntryState();
}

class _BaseContainerEntryState extends State<BaseContainerEntry> {
  
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<RouteWatcher>(
            create: (context) => RouteWatcher()),
        ChangeNotifierProvider<BridgeBase>(create: (context) => BridgeBase()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: BaseContainer(child: widget.entry),
      ),
    );
  }
}
