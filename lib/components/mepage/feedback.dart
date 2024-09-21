import 'package:august/const/font/font.dart';
import 'package:flutter/material.dart';

class FeedbackTile extends StatefulWidget {
  final VoidCallback onTap;

  FeedbackTile({required this.onTap});

  @override
  _FeedbackTileState createState() => _FeedbackTileState();
}

class _FeedbackTileState extends State<FeedbackTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // color: Color.fromRGBO(147, 52, 74, 1),

            color: Colors.grey,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Send Feedback',
                      style: AugustFont.head2(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                    Icon(
                      Icons.keyboard_arrow_right,
                      color: Theme.of(context).colorScheme.outline,
                      size: 20,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
