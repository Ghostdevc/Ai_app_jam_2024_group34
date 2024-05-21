import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io'; // For accessing environment variables

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String apiKey = Platform.environment['API_KEY'] ?? 'YOUR_API_KEY_HERE';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Metin Düzeltme Uygulaması',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue,
        ).copyWith(
          secondary: Colors.red,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(apiKey: apiKey),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String apiKey;

  MyHomePage({required this.apiKey});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textEditingController = TextEditingController();
  String _correctedText = '';
  bool _isLoading = false;
  List<String> _textHistory = []; // List to store entered texts
  List<String> _correctionHistory = []; // List to store corrected texts

  Future<void> _correctText() async {
    setState(() {
      _isLoading = true;
    });

    final model = GenerativeModel(model: 'gemini-pro', apiKey: widget.apiKey);
    final content = [
      Content.text(
          "If there is a spelling mistake in this sentence or words, can you correct it and answer only with the corrected text? : " +
              " ' " +
              _textEditingController.text +
              " ' ")
    ];

    try {
      final response = await model.generateContent(content);
      setState(() {
        _correctedText = response.text!;
        _correctionHistory.add(_correctedText); // Add corrected text to correction history
      });
    } catch (e) {
      print('Error: $e');
      setState(() {
        _correctedText = 'An error occurred while correcting the text.';
      });
    } finally {
      setState(() {
        _textHistory.add(_textEditingController.text); // Add entered text to text history
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Text Correction Application'),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 4.0,
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Correct Your Text',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.green, // Change text color to green
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _textEditingController,
              decoration: InputDecoration(
                labelText: 'Enter text',
                labelStyle: TextStyle(color: Colors.blue.shade900),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                // Set text field color to light yellow
                filled: true,
                fillColor: Colors.yellow[100],
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 12.0,
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _correctText,
              style: ElevatedButton.styleFrom(
                primary: Colors.red.shade700,
                onPrimary: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.0,
                ),
              )
                  : Text('Correct Text', style: TextStyle(fontSize: 16.0)),
            ),
            SizedBox(height: 20.0),
            if (_correctedText.isNotEmpty)
              Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Corrected: $_correctedText',
                    style: TextStyle(fontSize: 16.0, color: Colors.black87),
                  ),
                ),
              ),
            SizedBox(height: 20.0),
            Expanded(
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Text History:',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        // Display text history
                        for (String historyText in _textHistory)
                          Text(
                            historyText,
                            style: TextStyle(fontSize: 14.0, color: Colors.grey),
                          ),
                        SizedBox(height: 20.0),
                        Text(
                          'Correction History:',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 5.0),
                        // Display correction history
                        for (String historyText in _correctionHistory)
                          Text(
                            historyText,
                            style: TextStyle(fontSize: 14.0, color: Colors.grey),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}