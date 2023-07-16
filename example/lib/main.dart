import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_wallet_card/core/passkit.dart';
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:path_provider/path_provider.dart';

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
    return CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('Flutter Wallet Card Example'),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Apple wallet cards example (using links)'),
              CupertinoButton.filled(
                  onPressed: () {
                    _generateWalletPassFromPath();
                  },
                  child: Text('Add apple pass'))
            ],
          ),
        ),
      ),
    );
  }

  _generateWalletPassFromPath() async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/example.pkpass');

    final examplePass = await rootBundle.load('passes/example.pkpass');
    final written = await file.writeAsBytes(examplePass.buffer.asUint8List());

    final passkit = await Passkit().saveFromPath(id: 'example', file: written);
    await FlutterWalletCard.addPasskit(passkit);

    await file.delete();
  }
}
