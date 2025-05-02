import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class CarouselWidget extends StatelessWidget {
  final List<String> imagePaths;
  final List<String> graphNames;

  const CarouselWidget({
    Key? key,
    required this.imagePaths,
    required this.graphNames,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: imagePaths.length,
          options: CarouselOptions(
            height: 500, // Adjust height as needed
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.8,
          ),
          itemBuilder: (context, index, realIndex) {
            return Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePaths[index],
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  color: Colors.black.withOpacity(0.6),
                  child: Text(
                    graphNames[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
