import 'package:flutter/cupertino.dart';

///This class creates an abstraction of the MediaQuery class
///creates simple access to the `height` and `width` params;
///
class SizeReference {
  ///The current context on the widget tree;
  final BuildContext context;

  ///This class creates an abstraction of the MediaQuery class
  ///creates simple access to the `height` and `width` params;
  SizeReference(this.context);

  ///Returns the vertical extent of this size.
  get height {
    return MediaQuery.of(context).size.height;
  }

  ///Returns the vertical extent of this size.
  get width {
    return MediaQuery.of(context).size.width;
  }

  ///Returns the horizontal extent of this size.
  get w {
    return MediaQuery.of(context).size.width;
  }

  ///Returns the vertical extent of this size.
  get h {
    return MediaQuery.of(context).size.height;
  }
}
