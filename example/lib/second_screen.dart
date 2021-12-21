import 'package:baserouter/baserouter.dart';
import 'package:flutter/material.dart';

class Second extends StatelessWidget {
  const Second({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      width: 500,
      color: Colors.red,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${route(context).optionsHistory}'),
            Text('${bridge(context).read('First a', 0).type}'),
            TextButton(
              child: Text('Go Back'),
              onPressed: () {
                route(context).previousScreen();
              },
            ),
          ],
        ),
      ),
    );
  }
}
