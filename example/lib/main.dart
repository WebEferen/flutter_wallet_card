import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_wallet_card/flutter_wallet_card.dart';
import 'package:flutter_wallet_card_example/pass.dart';

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
                    _generateWalletPass();
                  },
                  child: Text('Add apple pass'))
            ],
          ),
        ),
      ),
    );
  }

  _generateWalletPass() async {
    final futures = await Future.wait([
      ExampleSigner.generateCertificate(),
      ExampleSigner.generateKey(),
      ExampleSigner.generateSignature(manifest: File(''))
    ]);

    final signature = await futures.last.readAsBytes();
    final pkpass = await FlutterWalletCard.generatePass(
        id: 'example-pass',
        signature: signature,
        pass: ExamplePass,
        override: true,
        deleteAfterwards: false);

    print(pkpass.file.path);
    print(await FlutterWalletCard.addPasskit(pkpass));

    await Future.wait(futures.map((future) => future.delete()));
  }
}
