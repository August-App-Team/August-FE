import 'package:august/const/colors/color_slider.dart';
import 'package:august/const/font/font.dart';
import 'package:flutter/material.dart';

class SelectColorWidget extends StatefulWidget {
  final String title;
  final Color color;
  final ValueChanged<Color> onColorChanged;
  const SelectColorWidget({
    Key? key,
    required this.title,
    required this.color,
    required this.onColorChanged,
  }) : super(key: key);

  @override
  _SelectColorWidgetState createState() => _SelectColorWidgetState();
}

class _SelectColorWidgetState extends State<SelectColorWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.color,
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
          width: 90,
          height: 90,
          child: Center(
            child: Text(
              widget.title,
              style: AugustFont.head3(
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(width: 20),
        ColorPicker(
            width: MediaQuery.of(context).size.width * 0.6,
            initialColor: widget.color,
            onColorChanged: widget.onColorChanged)
      ],
    );
  }
}
