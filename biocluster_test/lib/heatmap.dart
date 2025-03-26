import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<Uint8List?> fetchHeatmapImage(List<List<double>> similarityMatrix) async {
  final url = Uri.parse("http://127.0.0.1:5000/heatmap");
  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode({"similarity_matrix": similarityMatrix}),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonData = jsonDecode(response.body);
    final String base64Image = jsonData["heatmap_image"];
    return base64Decode(base64Image);
  } else {
    print("Error: ${response.statusCode}");
    return null;
  }
}

// Widget example to display the heatmap image.
class HeatmapWidget extends StatelessWidget {
  final List<List<double>> similarityMatrix;

  HeatmapWidget({required this.similarityMatrix});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: fetchHeatmapImage(similarityMatrix),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.fromRGBO(251, 135, 5, 1),
              ),
            ),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text("Error loading heatmap."));
        } else {
          return Image.memory(snapshot.data!);
        }
      },
    );
  }
}
