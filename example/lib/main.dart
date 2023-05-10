// import 'package:flutter/cupertino.dart';
// import 'dart:async';

// import 'package:flutter/services.dart';
// import 'package:flutter_wallet_card/flutter_wallet_card.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String _platformVersion = 'Unknown';
//   final TextEditingController _schemeController =
//       new TextEditingController(text: 'https');
//   final TextEditingController _hostController =
//       new TextEditingController(text: 'example.com');
//   final TextEditingController _pathController =
//       new TextEditingController(text: '/wallet');

//   @override
//   void initState() {
//     super.initState();
//     initPlatformState();
//   }

//   // Platform messages are asynchronous, so we initialize in an async method.
//   Future<void> initPlatformState() async {
//     String platformVersion;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     // We also handle the message potentially returning null.
//     try {
//       platformVersion =
//           await FlutterWalletCard.platformVersion ?? 'Unknown platform version';
//     } on PlatformException {
//       platformVersion = 'Failed to get platform version.';
//     }

//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;

//     setState(() {
//       _platformVersion = platformVersion;
//     });
//   }

//   _handlePress() async {
//     if (_schemeController.value.text.isNotEmpty &&
//         _hostController.value.text.isNotEmpty &&
//         _pathController.value.text.isNotEmpty) {
//       final Uri requestUri = Uri(
//           scheme: _schemeController.value.text,
//           host: _hostController.value.text,
//           path: _pathController.value.text,
//           queryParameters: {'code': 'someCode', 'holder': 'John Doe'});

//       await FlutterWalletCard.createPassFromUri(
//           scheme: requestUri.scheme,
//           host: requestUri.host,
//           path: requestUri.path,
//           parameters: requestUri.queryParameters);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     TextStyle style = TextStyle(
//         color: CupertinoTheme.of(context).barBackgroundColor, fontSize: 12);

//     return CupertinoApp(
//       home: CupertinoPageScaffold(
//         navigationBar: CupertinoNavigationBar(
//           middle: const Text('Plugin example app'),
//         ),
//         child: SafeArea(
//             child:
//                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           SizedBox(height: 20),
//           Text('Provide url scheme (http/https):', style: style),
//           SizedBox(height: 5),
//           CupertinoTextField(
//               controller: _schemeController, padding: EdgeInsets.all(10)),
//           SizedBox(height: 10),
//           Text('Provide url host (example.com):', style: style),
//           SizedBox(height: 5),
//           CupertinoTextField(
//               controller: _hostController, padding: EdgeInsets.all(10)),
//           SizedBox(height: 10),
//           Text('Provide url path (/wallet):', style: style),
//           SizedBox(height: 5),
//           CupertinoTextField(
//               controller: _pathController, padding: EdgeInsets.all(10)),
//           SizedBox(height: 20),
//           CupertinoButton(
//               child: Text('Check generated pass'),
//               onPressed: () => _handlePress()),
//           SizedBox(height: 20),
//           Text('Running on: $_platformVersion\n', style: style),
//         ])),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card_example/data.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on:'),
              ElevatedButton(
                  onPressed: () {
                    FlutterWalletCard.addMultipleWalletCards(
                        data.map((e) => Uri.parse(e)).toList());
                  },
                  child: Text('add more than one pass'))
            ],
          ),
        ),
      ),
    );
  }
}
