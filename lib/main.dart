// ignore_for_file: prefer_const_constructors, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WalletConnect Example',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _account;

  Future<void> _connectWallet() async {
    final connector = WalletConnect(
      bridge: 'https://bridge.walletconnect.org',
      clientMeta: const PeerMeta(
        name: 'Stockwise',
        description: 'Stockwise Developer App',
        url: 'https://app.stockwise.io',
        icons: ['https://stockwise.io/favicon.ico'],
      ),
    );

    // Subscribe to events
    connector.on(
        'connect', (session) => print('CONNECT NE: ${session?.toString()}'));
    connector.on('session_update',
        (payload) => print('SESSION_UPDATE NE: ${payload?.toString()}'));
    connector.on('disconnect',
        (session) => print('DISCONNECT NE: ${session?.toString()}'));

    // Create a new session
    if (!connector.connected) {
      try {
        final SessionStatus session = await connector.createSession(
          chainId: 43114,
          // chainId: 43113,
          onDisplayUri: (uri) async {
            print('DISPLAY_URI NE: $uri');
            await launchUrlString(uri);
          },
        );

        setState(() {
          _account = session.accounts[0];
        });
      } catch (e) {
        print(e);
      }

      if (_account != null) {
        final address = EthereumAddress.fromHex(_account!);
        final client = Web3Client(
          'https://mainnet.infura.io/v3/8ddd0b61947a4aad9a7c436449624d83',
          Client(),
        );
        final balance = await client.getBalance(address);

        final inEther = balance.getInEther;
        final inWei = balance.getInWei;
        print('EITHER NE: $inEther');
        print('WEI NE: $inWei');

        print('BALANCE NE: ${balance.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                _connectWallet();
              },
              child: Text('Connect wallet'),
            ),
            if (_account != null) Text(_account!)
          ],
        ),
      ),
    );
  }
}
