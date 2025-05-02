import 'package:flutter/material.dart';
import 'popup.dart';
import 'component.dart';
// import 'analysis_page.dart';
import 'cluster_page.dart';

// Dummy next page for demonstration
class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Next Page'),
        backgroundColor: Color.fromRGBO(251, 135, 5, 1),
      ),
      body: Center(child: Text('All sequences are valid!')),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Popup Example with Custom Typewriter Loop',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String resultText = '';

  // Global key to access the state of DynamicTextFields.
  final GlobalKey<DynamicTextFieldsState> dynamicFieldsKey =
      GlobalKey<DynamicTextFieldsState>();

  Map<String, String> parseStringToMap(String input) {
    Map<String, String> result = {};
    List<String> lines = input.trim().split('\n'); // Split by new lines
    for (String line in lines) {
      List<String> parts = line.split(':'); // Split by colon
      if (parts.length == 2) {
        String key = parts[0].trim();
        String value = parts[1].trim();
        result[key] = value;
      }
    }
    return result;
  }

  Map<String, String> parseStringToMap1(String input) {
    Map<String, String> result = {};
    List<String> lines = input.trim().split('\n'); // Split by new lines
    for (String line in lines) {
      List<String> parts = line.split(':'); // Split by colon
      if (parts.length == 2) {
        String key = parts[0].trim();
        String value = parts[1].trim();
        result[key] = value;
      }
    }
    return result;
  }

  bool isValidBiologicalSequence(String sequence) {
    // Allowed letters: A, T, C, G, U, N, R, D, Q, E, H, I, L, K, M, F, P, S, T, W, Y, V, B, Z, X
    final regex = RegExp(
      r'^[ATCGUARNDCQEGHILKMFPSTWYVBZXatcguarndcqeghilkmfpstwyvbzx]+$',
    );
    return regex.hasMatch(sequence);
  }

  /// Modified: Retrieve the current data from dynamicFieldsKey (if available) and validate it.
  void validateAndProcessData() {
    Map<String, String> currentData = {};
    if (dynamicFieldsKey.currentState != null) {
      currentData = dynamicFieldsKey.currentState!.getCurrentData();
    } else if (resultText.isNotEmpty) {
      currentData = parseStringToMap(resultText);
    }
    bool isValid = currentData.values.every(isValidBiologicalSequence);
    // Retrieve the list of keys.
    List<String> keys =
        dynamicFieldsKey.currentState != null
            ? dynamicFieldsKey.currentState!.getKeys()
            : currentData.keys.toList();

    if (isValid && currentData.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ClusterPage(data: currentData, keys: keys),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("One or more sequences are invalid."),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void openPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: PopupContent(
            onDone: (String text) {
              setState(() {
                resultText = text;
              });
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        toolbarHeight: 80,
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                margin: EdgeInsets.all(5),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'ndg_logo.jpg',
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'BioCluster Tool',
                style: TextStyle(
                  color: Color.fromRGBO(251, 135, 5, 1),
                  fontSize: 30,
                ),
              ),
            ],
          ),
        ),
      ),
      body:
          !resultText.isNotEmpty
              ? Center(
                child: Text(
                  'Enter sequence data',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
              : SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width * 0.5,
                        margin: EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 20,
                        ),
                        child: DynamicTextFields(
                          key: dynamicFieldsKey,
                          initialData: parseStringToMap(resultText),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'analysis',
            onPressed: () {
              validateAndProcessData();
            },
            label: Text('Analysis', style: TextStyle(color: Colors.white)),
            icon: Icon(Icons.analytics_outlined, color: Colors.white),
            backgroundColor: Color.fromRGBO(251, 135, 5, 1),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            backgroundColor: Color.fromRGBO(251, 135, 5, 1),
            heroTag: 'add',
            onPressed: () {
              openPopup();
            },
            child: Icon(Icons.add, color: Colors.white),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
    );
  }
}
