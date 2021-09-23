import 'dart:ui';

import 'package:afrolearn/src/components/widgetContainer/debugger.dart';
import 'package:afrolearn/src/components/widgetContainer/progressOverlay.dart';
import 'package:afrolearn/src/components/widgetContainer/topBarRow.dart';
import 'package:afrolearn/src/core/constants.dart';
import 'package:afrolearn/src/core/utilities/pageRoutes.dart';
import 'package:afrolearn/src/core/utilities/sizing.dart';
import 'package:afrolearn/src/customFunctions/generic/checkConnectivity.dart';
import 'package:afrolearn/src/customFunctions/generic/nightModeSwitcher.dart';
import 'package:afrolearn/src/customFunctions/generic/showExitModal.dart';
import 'package:afrolearn/src/customFunctions/streak/updateTimeSpent.dart';
import 'package:afrolearn/src/handlers/stateHandlers/providerHandlers/course.dart';
import 'package:afrolearn/src/handlers/stateHandlers/providerHandlers/generic.dart';
import 'package:afrolearn/src/handlers/stateHandlers/providerHandlers/routeWatcher.dart';
import 'package:afrolearn/src/handlers/stateHandlers/providerHandlers/theming.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'bottomBar.dart';

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
  const BaseContainer({
    Key? key,
    this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState>? scaffoldKey;

  ///Screens where navigation is not allowed.
  ///Such screen are the dashboard view screens
  ///Whenever the User gets to any of these screens,
  ///navigating to a  previous screen is prohibited

  static final prohibited = [
    PageMap.gameLanding,
    PageMap.profile,
    PageMap.community,
    PageMap.notifications,
    PageMap.store,
    PageMap.flashCards,
  ];

  ///These screens are for exercises and should trigger
  ///a modal popUp to inform user that the current progress
  ///would be lost if the screen is exited
  static final exerciseScreens = [
    PageMap.chooseMissingWord,
    PageMap.completeThisSentence,
    PageMap.translateThisSentence,
    PageMap.explanation,
    PageMap.lessonTip,
    PageMap.trueOrFalse,
    PageMap.tapWhatYouHear,
    PageMap.selectCorrectTranslation,
    PageMap.flipSelect,
    PageMap.identifyWhatYouSee
  ];

  @override
  _BaseContainerState createState() => _BaseContainerState();
}

class _BaseContainerState extends State<BaseContainer>
    with WidgetsBindingObserver {
  ///Checks if the app has been exited
  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    if ([
      AppLifecycleState.inactive,
      AppLifecycleState.detached,
      AppLifecycleState.inactive,
      AppLifecycleState.paused
    ].contains(state)) {
      updateTimeSpentOnApp(context);
    }
  }

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
    CourseProvider courseProvider = Provider.of<CourseProvider>(context);
    ThemeProvider customColor = Provider.of<ThemeProvider>(context);
    Generic generic = Provider.of<Generic>(context);

    return WillPopScope(
      onWillPop: () async {
        ///This refuses backward navigation for the prohibited screens
        if (BaseContainer.prohibited.contains(routeWatcher.currentScreen)) {
          return false;
        } else {
          if (BaseContainer.exerciseScreens
              .contains(routeWatcher.currentScreen)) {
            exerciseExitModal(context);
            return false;
          }
          routeWatcher.previousScreen();
          return false;
        }
      },
      child: Scaffold(
        key: widget.scaffoldKey,
        body: SingleChildScrollView(
          child: ProgressOverlay(
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: size.height,
              width: size.width,
              color: customColor.lightGreyToBlack,
              child: !generic.hasInternet
                  ? Center(
                      child: Text('No Internet'),
                    )
                  : Stack(
                      children: [
                        !routeWatcher.currentOptions.animate
                            ? Padding(
                                padding:
                                    routeWatcher.optionsHistory.last.padding ??
                                        EdgeInsets.zero,
                                child: routeWatcher.currentScreen,
                              )
                            : SlideInRight(
                                key: Key(courseProvider.counter.toString()),
                                child: Padding(
                                  padding: routeWatcher
                                          .optionsHistory.last.padding ??
                                      EdgeInsets.zero,
                                  child: routeWatcher.currentScreen,
                                ),
                              ),
                        CustomBottomBarRow(),
                        DebuggerView(),
                        TopBarRow()
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
      {this.bottomBarColor = AppColors.pink,
      this.color = AppColors.pink,
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
      backgroundColor: AppColors.pink.withOpacity(.14),
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
        backgroundColor: AppColors.pink.withOpacity(.14),
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
