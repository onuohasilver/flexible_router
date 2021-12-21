import 'dart:ui';

import 'package:baserouter/baseclass/progressOverlay.dart';
import 'package:baserouter/baseclass/routehandler.dart';
import 'package:baserouter/baseclass/sizeReference.dart';
import 'package:baserouter/methods.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

///Entry point for the app
class BaseContainer extends StatefulWidget {
  ///The root of the App
  ///
  ///Every Screen is simply a child of the [BaseContainer].
  ///
  ///Navigations controlled by the [RouteWatcher] simply act by changing the child of the [BaseContainer]
  ///Controlling how the bottombar is shown, the topBar and paddings are initiated by parsing
  ///a [BaseContainerOption] param to a [RouteWatcher] navigation method.
  ///
  ///Example to navigate to a new screen
  ///
  ///```dart
  ///(){
  ///RouteWatcher routeWatcher=Provider.of<RouteWatcher>(context);
  ///routeWatcher.addToStack(PageMap.profile,options:BaseContainerOptions(bottomBar:true));}
  ///
  ///```
  ///
  ///This example shows a simple method to navigate to Profile Screen
  const BaseContainer({Key? key, this.scaffoldKey, required this.child})
      : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  final Widget child;

  ///Screens where navigation is not allowed.
  ///Such screen are the dashboard view screens
  ///Whenever the User gets to any of these screens,
  ///navigating to a  previous screen is prohibited

  static final prohibited = [];

  ///These screens are for exercises and should trigger
  ///a modal popUp to inform user that the current progress
  ///would be lost if the screen is exited
  static final exerciseScreens = [];

  @override
  _BaseContainerState createState() => _BaseContainerState();
}

class _BaseContainerState extends State<BaseContainer>
    with WidgetsBindingObserver {
  ///Checks if the app has been exited

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    //TODO: Add this
    // checkInternetConnection(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SizeReference size = SizeReference(context);
    RouteWatcher routeWatcher = Provider.of<RouteWatcher>(context);
    if (routeWatcher.optionsHistory.isEmpty)
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        route(context).addToStack(widget.child);
      });

    return WillPopScope(
      onWillPop: () async {
        ///This refuses backward navigation for the prohibited screens
        if (BaseContainer.prohibited.contains(routeWatcher.currentScreen)) {
          return false;
        }
        routeWatcher.previousScreen();
        return false;
      },
      child: Scaffold(
        key: widget.scaffoldKey,
        body: SingleChildScrollView(
          child: ProgressOverlay(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: size.height,
              width: size.width,
              color: Colors.white,
              child: Stack(
                children: [
                  routeWatcher.optionsHistory.isNotEmpty
                      ? routeWatcher.currentScreen
                      : widget.child

                  // CustomBottomBarRow(),
                  // DebuggerView(),
                  // TopBarRow()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BaseContainerOptions {
  ///This dictates how each screen is going to be displayed
  ///Controls the minor details like the color, topBar, bottomBar and others
  const BaseContainerOptions(
      {this.bottomBarColor = Colors.pink,
      this.color = Colors.pink,
      this.showBottomBar = false,
      this.padding = EdgeInsets.zero,
      this.showTopBar = false,
      this.animate = false,
      this.allowDebugging = true,
      this.backgroundColor = Colors.white});

  final Color? bottomBarColor, color, backgroundColor;
  final bool showBottomBar, allowDebugging, showTopBar, animate;
  final EdgeInsets? padding;

  ///A default of the [BaseContainerOptions] in its most basic form

  static const BaseContainerOptions defaultSetup = BaseContainerOptions();
  static BaseContainerOptions exerciseSetup = BaseContainerOptions(
      showBottomBar: false,
      showTopBar: true,
      allowDebugging: true,
      animate: true,
      backgroundColor: Colors.pink.withOpacity(.14),
      padding: EdgeInsets.zero);

  ///Returns a [String] representation of the object
  @override
  String toString() {
    Map<String, dynamic> collections = {
      'bottomBarColor': bottomBarColor,
      'color': color,
      'showBottomBar': showBottomBar,
      'allowDebugging': allowDebugging,
      'backgroundColor': backgroundColor,
    };
    return collections.toString();
  }

  BaseContainerOptions extend(
      {showBottomBar: false,
      showTopBar: false,
      allowDebugging: true,
      animate: false,
      padding: EdgeInsets.zero}) {
    return BaseContainerOptions(
        showBottomBar: showBottomBar,
        showTopBar: showTopBar,
        allowDebugging: allowDebugging,
        animate: animate,
        backgroundColor: Colors.pink.withOpacity(.14),
        padding: padding);
  }

  ///`BaseContainerOptions.copyWith` has been [deprecated]
  ///use `BaseContainerOptions.defaultSetup` instead.
  @deprecated
  BaseContainerOptions copyWith(
      {allowDebugging = true,
      padding = EdgeInsets.zero,
      showBottomBar = false,
      backgroundColor = Colors.white,
      showTopBar = false,
      bottomBarColor}) {
    return BaseContainerOptions();
  }
}
