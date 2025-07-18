import 'package:flutter/cupertino.dart';
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
              const Text('Apple wallet cards using URL'),
              const SizedBox(height: 5),
              CupertinoButton.filled(
                onPressed: () => generateWalletPassFromUri(exampleUrl),
                child: Text('Add apple pass'),
              ),
              const SizedBox(height: 20),
              const Text('Apple wallet cards using File Path'),
              const SizedBox(height: 5),
              CupertinoButton.filled(
                onPressed: () => generateWalletPassFromPath(),
                child: Text('Add apple pass (from path)'),
              ),
              const SizedBox(height: 20),
              const Text('iOS Enhanced Features'),
              const SizedBox(height: 5),
              CupertinoButton.filled(
                onPressed: () => validatePassFile(),
                child: Text('Validate Pass File'),
              ),
              const SizedBox(height: 10),
              CupertinoButton.filled(
                onPressed: () => checkPassValidity(),
                child: Text('Check Pass Validity'),
              ),
              const SizedBox(height: 10),
              CupertinoButton.filled(
                onPressed: () => getPassInformation(),
                child: Text('Get Pass Information'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
