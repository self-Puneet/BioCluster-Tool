// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';

// class AnalysisPage extends StatefulWidget {
//   final Map<String, String> data;
//   final List<String> keys;

//   AnalysisPage({required this.data, required this.keys});

//   @override
//   _AnalysisPageState createState() => _AnalysisPageState();
// }

// class _AnalysisPageState extends State<AnalysisPage> {
//   late Future<Map<String, Uint8List?>> imagesFuture;

//   @override
//   void initState() {
//     super.initState();
//     imagesFuture = fetchImages();
//   }

//   // Re-fetch images if the incoming data changes
//   @override
//   void didUpdateWidget(covariant AnalysisPage oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.data != widget.data) {
//       setState(() {
//         imagesFuture = fetchImages();
//       });
//     }
//   }

//   /// Fetches similarity matrix, then retrieves both heatmap & dendrogram.
//   Future<Map<String, Uint8List?>> fetchImages() async {
//     List<String> sequences = widget.data.values.toList();

//     // Step 1: Get the similarity matrix from /similarity
//     final similarityResponse = await http.post(
//       Uri.parse("http://127.0.0.1:5000/similarity"),
//       headers: {"Content-Type": "application/json"},
//       body: jsonEncode({"sequences": sequences}),
//     );

//     if (similarityResponse.statusCode != 200) {
//       print(
//         "Error fetching similarity matrix: ${similarityResponse.statusCode}",
//       );
//       return {"heatmap": null, "dendrogram": null};
//     }

//     final similarityJson = jsonDecode(similarityResponse.body);
//     List<List<double>> similarityMatrix =
//         (similarityJson["similarity_matrix"] as List)
//             .map(
//               (row) => (row as List).map((e) => (e as num).toDouble()).toList(),
//             )
//             .toList();

//     // Step 2: Fetch both heatmap and dendrogram concurrently
//     final responses = await Future.wait([
//       http.post(
//         Uri.parse("http://127.0.0.1:5000/heatmap"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "similarity_matrix": similarityMatrix,
//           "keys": widget.keys,
//         }),
//       ),
//       http.post(
//         Uri.parse("http://127.0.0.1:5000/dendrogram"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({
//           "similarity_matrix": similarityMatrix,
//           "keys": widget.keys,
//         }),
//       ),
//     ]);

//     Uint8List? heatmapImage;
//     Uint8List? dendrogramImage;

//     if (responses[0].statusCode == 200) {
//       final jsonData = jsonDecode(responses[0].body);
//       heatmapImage = base64Decode(jsonData["heatmap_image"]);
//     }

//     if (responses[1].statusCode == 200) {
//       final jsonData = jsonDecode(responses[1].body);
//       dendrogramImage = base64Decode(jsonData["dendrogram_image"]);
//     }

//     return {"heatmap": heatmapImage, "dendrogram": dendrogramImage};
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.grey[300],
//         toolbarHeight: 80,
//         title: Padding(
//           padding: EdgeInsets.symmetric(vertical: 10),
//           child: Row(
//             children: [
//               Container(
//                 width: 48,
//                 height: 48,
//                 margin: EdgeInsets.all(5),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: Image.asset(
//                     'ndg_logo.jpg',
//                     width: 48,
//                     height: 48,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 10),
//               Text(
//                 'BioCluster Tool',
//                 style: TextStyle(
//                   color: Color.fromRGBO(251, 135, 5, 1),
//                   fontSize: 30,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Center(
//         child: FutureBuilder<Map<String, Uint8List?>>(
//           future: imagesFuture,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                   Color.fromRGBO(251, 135, 5, 1),
//                 ),
//               );
//             } else if (snapshot.hasError || snapshot.data == null) {
//               return Text("Error loading images.");
//             } else {
//               Uint8List? heatmapImage = snapshot.data!["heatmap"];
//               Uint8List? dendrogramImage = snapshot.data!["dendrogram"];

//               if (heatmapImage == null || dendrogramImage == null) {
//                 return Text("Error loading one or both images.");
//               }

//               return Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Heatmap Container
//                   Container(
//                     width: 400,
//                     height: 400,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.black),
//                     ),
//                     child: Image.memory(heatmapImage, fit: BoxFit.fitWidth),
//                   ),
//                   SizedBox(width: 10),
//                   // Dendrogram Container
//                   Container(
//                     width: 400,
//                     height: 400,
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Colors.black),
//                     ),
//                     child: Image.memory(dendrogramImage, fit: BoxFit.fitWidth),
//                   ),
//                 ],
//               );
//             }
//           },
//         ),
//       ),
//       // floatingActionButton: Row(
//       //   mainAxisSize: MainAxisSize.min,
//       //   children: [
//       //     FloatingActionButton(
//       //       backgroundColor: Color.fromRGBO(251, 135, 5, 1),
//       //       onPressed: () {
//       //         null;
//       //       },
//       //       child: Icon(Icons.group_work_rounded, color: Colors.white),
//       //     ),
//       //   ],
//       // ),
//       // floatingActionButtonLocation: FloatingActionButtonLocation.miniEndFloat,
//     );
//   }

//   // **Modified customCarousel function**
//   Widget customCarousel(
//     List<Map<String, dynamic>> events,
//     Function updateCarouselIndex,
//     Function fetchCarouselIndex,
//   ) {
//     return Column(
//       children: [
//         CarouselSlider(
//           options: CarouselOptions(
//             height: 200.0,
//             autoPlay: true,
//             enlargeCenterPage: true,
//             viewportFraction: 0.75,
//             onPageChanged: (index, reason) {
//               updateCarouselIndex(index);
//             },
//           ),
//           items:
//               events.map((eventInfo) {
//                 return Stack(
//                   children: [
//                     Container(
//                       decoration: BoxDecoration(
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.3),
//                             blurRadius: 6,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       margin: EdgeInsets.all(8.0),
//                       width: double.infinity,
//                       height: 200.0,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(10),
//                         child: Image.memory(
//                           eventInfo['event_image'],
//                           fit: BoxFit.cover,
//                           alignment: Alignment.center,
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 20,
//                       left: 20,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             eventInfo['event_name'],
//                             textAlign: TextAlign.left,
//                             style: TextStyle(color: Colors.white, fontSize: 20),
//                           ),
//                           Text(
//                             DateFormat(
//                               "dd-MM-yyyy",
//                             ).format(DateTime.parse(eventInfo["date"])),
//                             textAlign: TextAlign.left,
//                             style: TextStyle(color: Colors.white, fontSize: 10),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 );
//               }).toList(),
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(
//             events.length,
//             (index) => Container(
//               width: 6.0,
//               height: 6.0,
//               margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color:
//                     fetchCarouselIndex() == index ? Colors.blue : Colors.grey,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
