import 'package:august/components/mepage/stacked_photo.dart';
import 'package:flutter/material.dart';

class FriendBox extends StatefulWidget {
  final String info;
  final String photo;
  final String subInfo;
  final VoidCallback onTap;

  const FriendBox({
    Key? key,
    required this.onTap,
    required this.info,
    required this.subInfo,
    required this.photo,
  }) : super(key: key);

  @override
  _FriendBoxState createState() => _FriendBoxState();
}

class _FriendBoxState extends State<FriendBox> {
  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            blurRadius: 10, // 블러 효과를 줄여서 그림자를 더 세밀하게
            offset: Offset(4, -1), // 좌우 그림자의 길이를 줄임
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            blurRadius: 10,
            offset: Offset(-1, 0), // 좌우 그림자의 길이를 줄임
          ),
        ],
      ),
      width: 145,
      height: 145,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              maxRadius: 25,
              child: (widget.photo != null)
                  ? Image.network(widget.photo)
                  : Icon(Icons.person),
              backgroundColor: Colors.white,
            ),
            SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Text(
                  widget.info,
                  style: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.keyboard_arrow_right)
              ],
            ),
            Text(
              widget.subInfo,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );

    // Conditional wrapping with GestureDetector
    return GestureDetector(onTap: widget.onTap, child: content);
  }
}
