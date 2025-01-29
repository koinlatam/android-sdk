import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Fingerprint Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Fingerprint Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('com.example.test_flutter/fingerprint');

  String _sessionID = "Press the button to get fingerprint session ID";

  /// Función para llamar al SDK nativo y obtener el session ID.
  Future<void> _getFingerprintSession() async {
    try {
      final String sessionID = await platform.invokeMethod('getFingerprintSession');
      setState(() {
        _sessionID = "Session ID: $sessionID";
      });
    } on PlatformException catch (e) {
      setState(() {
        _sessionID = "Error: ${e.message}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _sessionID,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getFingerprintSession,
              child: const Text("Get Fingerprint Session"),
            ),
          ],
        ),
      ),
    );
  }
}
