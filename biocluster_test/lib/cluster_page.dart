import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:html' as html;
import 'package:biocluster_test/carousel.dart';

class ClusterPage extends StatefulWidget {
  final Map<String, String> data;
  final List<String> keys;

  ClusterPage({required this.data, required this.keys});

  @override
  _ClusterPageState createState() => _ClusterPageState();
}

class _ClusterPageState extends State<ClusterPage> {
  late Future<Map<String, List<String>>> clustersFuture;
  final TextEditingController _clusterController = TextEditingController();
  int _clusterCount = 3; // Default number of clusters

  @override
  void initState() {
    super.initState();
    _clusterController.text = _clusterCount.toString();
    clustersFuture = processImagesAndFetchClusters(_clusterCount);
  }

  Future<Map<String, List<String>>> processImagesAndFetchClusters(
    int numClusters,
  ) async {
    List<String> sequences = widget.data.values.toList();

    // Step 1: Get similarity matrix
    final similarityResponse = await http.post(
      Uri.parse("http://127.0.0.1:5000/similarity"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"sequences": sequences}),
    );

    if (similarityResponse.statusCode != 200) {
      print("Error fetching similarity matrix");
      return {};
    }

    final similarityJson = jsonDecode(similarityResponse.body);
    List<List<double>> similarityMatrix =
        (similarityJson["similarity_matrix"] as List)
            .map(
              (row) => (row as List).map((e) => (e as num).toDouble()).toList(),
            )
            .toList();

    // Step 2: Upload images (Heatmap & Dendrogram)
    await Future.wait([
      http.post(
        Uri.parse("http://127.0.0.1:5000/heatmap"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "similarity_matrix": similarityMatrix,
          "keys": widget.keys,
        }),
      ),
      http.post(
        Uri.parse("http://127.0.0.1:5000/dendrogram"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "similarity_matrix": similarityMatrix,
          "keys": widget.keys,
        }),
      ),
    ]);

    // Step 3: Show Snackbar (Images Uploaded)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Images successfully uploaded!"),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Step 4: Fetch Clusters using the user-specified number
    final clusterResponse = await http.post(
      Uri.parse("http://127.0.0.1:5000/cluster"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "confusion_matrix": similarityMatrix,
        "labels": widget.keys,
        "num_clusters": numClusters,
      }),
    );

    final Map<String, dynamic> rawClusters = jsonDecode(clusterResponse.body);
    final Map<String, List<String>> clusters = {};
    rawClusters.forEach((key, value) {
      clusters[key] = List<String>.from(value);
    });
    print(clusters);
    return clusters;
  }

  void _fetchClusters() {
    final parsed = int.tryParse(_clusterController.text);
    if (parsed == null || parsed < 1 || parsed > widget.keys.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter a valid number of clusters (1 - ${widget.keys.length})",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _clusterCount = parsed;
      clustersFuture = processImagesAndFetchClusters(_clusterCount);
    });
  }

  Future<void> _downloadClusters() async {
    try {
      // Wait for clusters to be available if not already.
      final clusters = await clustersFuture;

      // Build the text content with both sequence name and its value.
      StringBuffer buffer = StringBuffer();
      clusters.forEach((clusterName, sequenceNames) {
        buffer.writeln("$clusterName:");
        for (var seqName in sequenceNames) {
          // Look up the corresponding sequence content from widget.data
          String sequenceContent = widget.data[seqName] ?? "N/A";
          buffer.writeln("  $seqName: $sequenceContent");
        }
        buffer.writeln(); // Extra line break between clusters
      });
      String fileContent = buffer.toString();

      // Create a Blob from the content using dart:html (works on web)
      final bytes = utf8.encode(fileContent);
      final blob = html.Blob([bytes], 'text/plain');
      final url = html.Url.createObjectUrlFromBlob(blob);

      // Create an anchor element, set its href to the blob URL, and trigger download
      final anchor =
          html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..style.display = 'none'
            ..download = 'clusters.txt';
      html.document.body!.append(anchor);
      anchor.click();

      // Cleanup
      anchor.remove();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("File downloaded successfully.")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error downloading file: $e")));
    }
  }

  List<String> imagePaths = [
    "image/gaussian.png",
    "image/imagedendrogram.png",
    "image/imageheatmap.png",
  ];

  List<String> graphNames = ["Gaussian Graph", "Dendrogram", "Heatmap"];

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
      body: Column(
        children: [
          // Input panel for number of clusters
          // CarouselWidget(imagePaths: imagePaths, graphNames: graphNames),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text("Number of Clusters:", style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _clusterController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter number",
                    ),
                  ),
                ),
                SizedBox(width: 10),
                InkWell(
                  onTap: _fetchClusters,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Fetch Clusters",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Display clusters
          Expanded(
            child: FutureBuilder<Map<String, List<String>>>(
              future: clustersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  );
                } else if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.isEmpty) {
                  return Center(child: Text("Error loading clusters."));
                }

                Map<String, List<String>> clusters = snapshot.data!;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:
                        clusters.entries.map((entry) {
                          return Container(
                            width: 200,
                            margin: EdgeInsets.all(10),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  entry.key.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10),
                                ...entry.value.map(
                                  (sequence) => Text(
                                    sequence,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _downloadClusters,
        child: Icon(Icons.download, color: Colors.white),
        backgroundColor: Colors.orange,
      ),
    );
  }
}
