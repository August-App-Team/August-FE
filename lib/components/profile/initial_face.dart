import 'package:august/const/colors/tile_color.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class initialFace extends StatelessWidget {
  // Constants for grid dimensions
  static const int daysOfWeek = 5;
  static const int timeSlots = 8; // For half-day representation
  static const double boxSize = 20.0; // Height of each time slot box

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        height: timeSlots * boxSize - 50,
        width: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 10,
              offset: const Offset(6, 4),
            ),
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              blurRadius: 10,
              offset: const Offset(-2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  buildTimeColumn(context),
                  for (int index = 0; index < daysOfWeek; index++)
                    ...buildDayColumn(context, index),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTimeColumn(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          ...List.generate(timeSlots, (index) {
            return SizedBox(
              height: boxSize,
              child: (index % 2 == 0)
                  ? const Divider(color: Colors.grey, height: 1)
                  : const Divider(color: Colors.transparent, height: 0),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> buildDayColumn(BuildContext context, int index) {
    return [
      const VerticalDivider(color: Colors.grey, width: 1),
      Expanded(
        child: Column(
          children: List.generate(timeSlots, (index) {
            return SizedBox(
              height: boxSize,
              child: (index % 2 == 0)
                  ? const Divider(color: Colors.grey, height: 1)
                  : const Divider(color: Colors.transparent, height: 0),
            );
          }),
        ),
      ),
    ];
  }
}

class InitialFaces extends StatefulWidget {
  final int count;

  const InitialFaces({Key? key, this.count = 6}) : super(key: key);

  @override
  _InitialFacesGridState createState() => _InitialFacesGridState();
}

class _InitialFacesGridState extends State<InitialFaces> {
  @override
  Widget build(BuildContext context) {
    return initialFace();
  }
}
