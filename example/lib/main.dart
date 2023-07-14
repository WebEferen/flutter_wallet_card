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
    final generated = await FlutterWalletCard.generatePass(
      id: 'example-pass',
      pass: ExamplePass,
      override: true,
      deleteAfterwards: false,
    );

    final certificates = await Future.wait([
      ExampleSigner.generateKey(),
      ExampleSigner.generateCertificate(),
      ExampleSigner.generateSignature(manifest: generated.manifestFile),
    ]);

    await FlutterWalletCard.addPasskit(generated.passkitFile);
    await Future.wait(certificates.map((future) => future.delete()));
  }
}
