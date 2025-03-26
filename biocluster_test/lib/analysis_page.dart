import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AnalysisPage extends StatefulWidget {
  final Map<String, String> data;
  final List<String> keys;

  AnalysisPage({required this.data, required this.keys});

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  late Future<Uint8List?> heatmapImageFuture;

  @override
  void initState() {
    super.initState();
    heatmapImageFuture = fetchHeatmap();
  }

  // If the incoming data changes, re-fetch the heatmap image.
  @override
  void didUpdateWidget(covariant AnalysisPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data != widget.data) {
      setState(() {
        heatmapImageFuture = fetchHeatmap();
      });
    }
  }

  /// Fetches similarity matrix then heatmap image from the Flask backend.
  Future<Uint8List?> fetchHeatmap() async {
    // Convert the data map values into a list of sequences.
    List<String> sequences = widget.data.values.toList();

    // First, call the /similarity endpoint.
    final similarityResponse = await http.post(
      Uri.parse("http://127.0.0.1:5000/similarity"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"sequences": sequences}),
    );

    if (similarityResponse.statusCode != 200) {
      print(
        "Error fetching similarity matrix: ${similarityResponse.statusCode}",
      );
      return null;
    }

    final similarityJson = jsonDecode(similarityResponse.body);
    List<List<double>> similarityMatrix =
        (similarityJson["similarity_matrix"] as List)
            .map(
              (row) => (row as List).map((e) => (e as num).toDouble()).toList(),
            )
            .toList();

    // Next, call the /heatmap endpoint using the similarity matrix and the keys.
    final heatmapResponse = await http.post(
      Uri.parse("http://127.0.0.1:5000/heatmap"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "similarity_matrix": similarityMatrix,
        "keys": widget.keys, // NEW: send the keys for axis labels.
      }),
    );

    if (heatmapResponse.statusCode == 200) {
      final jsonData = jsonDecode(heatmapResponse.body);
      final String base64Image = jsonData["heatmap_image"];
      return base64Decode(base64Image);
    } else {
      print("Error fetching heatmap image: ${heatmapResponse.statusCode}");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis'),
        backgroundColor: Color.fromRGBO(251, 135, 5, 1),
      ),
      body: Center(
        child: FutureBuilder<Uint8List?>(
          future: heatmapImageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(251, 135, 5, 1),
                ),
              );
            } else if (snapshot.hasError || snapshot.data == null) {
              return Text("Error loading heatmap.");
            } else {
              // Display the heatmap image once ready
              return Image.memory(snapshot.data!);
            }
          },
        ),
      ),
    );
  }
}
