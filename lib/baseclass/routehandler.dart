import 'package:baserouter/baseclass/pagemap.dart';
import 'package:flutter/material.dart';

import 'basecontainerOptions.dart';

class RouteWatcher extends ChangeNotifier {
  ///A stack of the navigated screens
  List<Widget> screenViewHistory = [];

  /// dynamic arguments parsEed between screens. it is similar to the [ModalRoute.settings] feature
  dynamic routeArguments;

  ///A stack of the base options parsed to the the navigated screens
  ///it must always remain equal to the [screenViewHistory]
  List<BaseContainerOptions> optionsHistory = [];

  ///Option is parsed to a [BaseContainer] to determine how it is
  ///rendered
  BaseContainerOptions baseContainerOptions = BaseContainerOptions.defaultSetup;

  @override
  String toString() {
    Map collection = {
      'HISTORY LENGTHS': [screenViewHistory.length, optionsHistory.length],
      'SCREEN VIEW HISTORY': screenViewHistory,

      'ROUTE ARGUMENTS': routeArguments,
      'OPTIONS HISTORY': optionsHistory,
      // 'BASE CONTAINER OPTIONS': baseContainerOptions
    };
    return collection.toString();
  }

  ///Adds a new screen to the [screenViewHistory] stack.
  ///also accepts optional [routeArguments]
  ///after which it performs a [deepClean] on the navigation stack
  ///to keep it tidy and free of redundant screen additions
  void addToStack(Widget screen,
      {BaseContainerOptions options = BaseContainerOptions.defaultSetup,
      dynamic? arguments}) {
    screenViewHistory.add(screen);
    baseContainerOptions = options;
    optionsHistory.add(baseContainerOptions);
    if (arguments != null) routeArguments = arguments;

    notifyListeners();
    // deepClean;
  }

  ///access the last screen that was viewed.
  ///it pops the [currentScreen] and sets the preceding screen to current
  void previousScreen() {
    if (screenViewHistory.length >= 2) {
      optionsHistory.removeLast();
      screenViewHistory.removeLast();

      notifyListeners();
      // deepClean;
    }
  }

  ///Removes redundant screens when the [screenViewHistory] gets more than
  ///7 active screens. acts as a flush for the [screenViewHistory] and the
  ///[optionsHistory]
  void get deepClean {
    if (screenViewHistory.length >= 7) {
      int last = screenViewHistory.length;
      List<Widget> screenHistoryCache = [];
      List<BaseContainerOptions> optionsHistoryCache = [];
      screenHistoryCache.add(screenViewHistory[last - 2]);
      screenHistoryCache.add(screenViewHistory.last);
      optionsHistoryCache.add(optionsHistory[last - 2]);
      optionsHistoryCache.add(optionsHistory.last);

      screenViewHistory = screenHistoryCache;
      optionsHistory = optionsHistoryCache;
    }
  }

  ///creates a sequence where a fallback Screen is added to the viewHistory
  void addWithFallback(Widget screen, Widget fallBackScreen,
      {BaseContainerOptions? options = BaseContainerOptions.defaultSetup,
      BaseContainerOptions? fallOptions = BaseContainerOptions.defaultSetup,
      dynamic arguments}) {
    screenViewHistory =
        fallBackScreen != screen ? [fallBackScreen, screen] : [screen];
    optionsHistory =
        fallOptions != options ? [fallOptions!, options!] : [options!];

    if (arguments != null) routeArguments = arguments;
    notifyListeners();
  }

  void removeFromStack() {
    if (screenViewHistory.isNotEmpty) {
      screenViewHistory.removeLast();
      optionsHistory.removeLast();
    } else {
      throw (Exception('Screenview stack is currently empty'));
    }
    notifyListeners();
  }

  void addReplacement(Widget screen,
      {BaseContainerOptions? options = BaseContainerOptions.defaultSetup,
      dynamic arguments}) {
    screenViewHistory.removeLast();
    optionsHistory.removeLast();

    screenViewHistory.add(screen);

    optionsHistory.add(options!);
    if (arguments != null) routeArguments = arguments;
    notifyListeners();
  }

  void emptyStack() {
    screenViewHistory = [];
    optionsHistory = [];
    notifyListeners();
  }

  ///Creates a new head node by clearing all lists and replacing it
  ///with the newly created Screens
  ///
  ///Best suited for screens that you don't want to revisit again throughout
  ///the app lifecycle

  void addHead(Widget screen,
      {BaseContainerOptions? options = BaseContainerOptions.defaultSetup,
      dynamic arguments}) {
    screenViewHistory = [screen];
    optionsHistory = [options!];
    notifyListeners();
  }

  ///Creates a new tail home
  void addTail(Widget screen,
      {BaseContainerOptions? options = BaseContainerOptions.defaultSetup,
      dynamic arguments}) {
    screenViewHistory = [screenViewHistory.first];
    optionsHistory = [optionsHistory.first];

    screenViewHistory.add(screen);
    baseContainerOptions = options!;
    optionsHistory.add(baseContainerOptions);
    if (arguments != null) routeArguments = arguments;
    notifyListeners();
  }

  ///Adds a new screen with a purge
  ///similar to replaceUntil
  ///It removes the screens upto a particular specified purgeTail
  void addWithPurge(Widget screen, Widget purgeTail,
      {BaseContainerOptions? options = BaseContainerOptions.defaultSetup,
      dynamic arguments}) {
    List<Widget> screenCache =
        screenViewHistory.sublist(0, screenViewHistory.indexOf(purgeTail) + 1);
    List<BaseContainerOptions> optionsCache =
        optionsHistory.sublist(0, screenViewHistory.indexOf(purgeTail) + 1);
    screenCache.add(screen);
    baseContainerOptions = options!;
    optionsCache.add(baseContainerOptions);
    screenViewHistory = screenCache;
    optionsHistory = optionsCache;
    if (arguments != null) routeArguments = arguments;
    notifyListeners();
  }

  //Returns the current Screen being viewed
  Widget get currentScreen {
    if (screenViewHistory.isNotEmpty) {
      return screenViewHistory.last;
    } else {
      throw (Exception('Screenview stack is currently empty'));
    }
  }

  BaseContainerOptions get currentOptions {
    if (optionsHistory.isNotEmpty) {
      return optionsHistory.last;
    } else {
      throw (Exception('Screenview stack is currently empty'));
    }
  }

  int get eliminateCurrent {
    if (screenViewHistory.isNotEmpty) {
      return screenViewHistory.length - 1;
    } else {
      throw (Exception('Screenview stack is currently empty'));
    }
  }

  void get reset {
    screenViewHistory = [PageMap.initialLoading];
    optionsHistory = [BaseContainerOptions.defaultSetup];

    baseContainerOptions = BaseContainerOptions.defaultSetup;
    notifyListeners();
  }
}
