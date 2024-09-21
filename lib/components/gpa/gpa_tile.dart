import 'package:august/components/mepage/stacked_photo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GPATile extends StatefulWidget {
  final String classTitle;
  final String classCredit;
  final String classGrade;
  final bool major;
  final VoidCallback onTap;

  const GPATile({
    Key? key,
    required this.classTitle,
    required this.classCredit,
    required this.classGrade,
    required this.major,
    required this.onTap,
  }) : super(key: key);

  @override
  _GPATileState createState() => _GPATileState();
}

class _GPATileState extends State<GPATile> {
  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      height: 55,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    widget.classTitle,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.classCredit,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.classGrade,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.outline,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    widget.major == true ? "Major" : "Non-Major",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Conditional wrapping with GestureDetector
    return GestureDetector(onTap: widget.onTap, child: content);
  }
}
