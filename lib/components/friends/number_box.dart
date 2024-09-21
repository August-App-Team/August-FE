import 'package:august/const/font/font.dart';
import 'package:flutter/material.dart';

class DigitBoxes extends StatelessWidget {
  final String code;

  DigitBoxes({Key? key, required this.code}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: code
          .split('')
          .map((digit) => _buildDigitBox(digit, context))
          .toList(),
    );
  }

  Widget _buildDigitBox(String digit, BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double minHeightForLargeDevice = 812.0;
    bool isLargeDevice = screenSize.height > minHeightForLargeDevice;
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: isLargeDevice ? 35 : 32,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            digit,
            style: AugustFont.head3(
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
