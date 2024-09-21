import 'package:flutter/material.dart';

class StackedPhoto extends StatelessWidget {
  final List<String> imagePaths;
  final bool isDeleteConfirm;

  const StackedPhoto({
    Key? key,
    required this.imagePaths,
    this.isDeleteConfirm = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> stackedImages = [];
    int imageCount = (imagePaths.length > 8) ? 6 : imagePaths.length;

    // Calculate the total width of the container to fit all images without cutting
    double containerWidth = 50 +
        (imageCount - 1) *
            15.0; // First image full width, others partially visible

    for (int i = 0; i < imageCount; i++) {
      double offset = i * 15.0; // Calculate the offset for stacking
      stackedImages.add(
        Positioned(
          right: offset, // Use a consistent offset calculation
          child: ClipOval(
            child: isDeleteConfirm
                ? Image.network(
                    imagePaths[i],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    imagePaths[i],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      );
    }

    return Container(
      width: containerWidth, // Set width to fit all images properly
      height: 50,
      child: Stack(
        children: stackedImages,
        alignment:
            Alignment.centerLeft, // Ensure alignment starts from center left
      ),
    );
  }
}
