import 'package:august/provider/course_color_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class _SliderIndicatorPainter extends CustomPainter {
  final double position;
  final Color color; // Accept color as a parameter

  _SliderIndicatorPainter(this.position, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    var strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Ensure the handle is drawn within the bar limits
    double validPosition =
        position.clamp(15.0, size.width - 15.0); // Assuming handle radius is 15
    canvas.drawCircle(Offset(validPosition, size.height / 2), 15, fillPaint);
    canvas.drawCircle(Offset(validPosition, size.height / 2), 15, strokePaint);
  }

  @override
  bool shouldRepaint(_SliderIndicatorPainter old) {
    return position != old.position || color != old.color;
  }
}

class ColorPicker extends StatefulWidget {
  final double width;
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  ColorPicker({
    required this.width,
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  _ColorPickerState createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  final List<Color> _colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.lightGreen,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
    Colors.pink,
    Colors.deepOrange,
    Colors.grey,
  ];
  double _colorSliderPosition = 0;
  double _shadeSliderPosition = 0;
  late Color _currentColor;
  late Color _shadedColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    _colorSliderPosition = _calculatePositionFromColor(_currentColor);
    _shadeSliderPosition = widget.width / 2;
    _shadedColor = _calculateShadedColor(_shadeSliderPosition);
  }

  void _colorChangeHandler(double position) {
    // Allow the handle center to reach the very ends of the bar
    position = position.clamp(0, widget.width);
    setState(() {
      _colorSliderPosition = position;
      _currentColor = _calculateSelectedColor(_colorSliderPosition);
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
      widget.onColorChanged(_shadedColor);
    });
  }

  _shadeChangeHandler(double position) {
    // Similarly clamp for shade slider
    position = position.clamp(15.0, widget.width - 15.0);
    setState(() {
      _shadeSliderPosition = position;
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
      widget.onColorChanged(_shadedColor);
    });
  }

  double _calculatePositionFromColor(Color color) {
    // Adjust this logic if necessary to initialize position
    int index = _colors.indexOf(color);
    return index == -1
        ? widget.width / 2
        : (widget.width - 30) * (index / (_colors.length - 1)) + 15;
  }

  Color _calculateShadedColor(double position) {
    double ratio = position / widget.width;
    if (ratio > 0.5) {
      //Calculate new color (values converge to 255 to make the color lighter)
      int redVal = _currentColor.red != 255
          ? (_currentColor.red +
                  (255 - _currentColor.red) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      int greenVal = _currentColor.green != 255
          ? (_currentColor.green +
                  (255 - _currentColor.green) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      int blueVal = _currentColor.blue != 255
          ? (_currentColor.blue +
                  (255 - _currentColor.blue) * (ratio - 0.5) / 0.5)
              .round()
          : 255;
      return Color.fromARGB(255, redVal, greenVal, blueVal);
    } else if (ratio < 0.5) {
      //Calculate new color (values converge to 0 to make the color darker)
      int redVal = _currentColor.red != 0
          ? (_currentColor.red * ratio / 0.5).round()
          : 0;
      int greenVal = _currentColor.green != 0
          ? (_currentColor.green * ratio / 0.5).round()
          : 0;
      int blueVal = _currentColor.blue != 0
          ? (_currentColor.blue * ratio / 0.5).round()
          : 0;
      return Color.fromARGB(255, redVal, greenVal, blueVal);
    } else {
      //return the base color
      return _currentColor;
    }
  }

  Color _calculateSelectedColor(double position) {
    // Adjust to fetch color based on clamped position
    int index = ((position.clamp(15, widget.width - 15) - 15) /
            (widget.width - 30) *
            (_colors.length - 1))
        .floor();
    double ratio = ((position.clamp(15, widget.width - 15) - 15) /
            (widget.width - 30) *
            (_colors.length - 1)) -
        index;
    Color startColor = _colors[index];
    Color endColor = _colors[(index + 1) % _colors.length];
    int red =
        (startColor.red + (endColor.red - startColor.red) * ratio).round();
    int green = (startColor.green + (endColor.green - startColor.green) * ratio)
        .round();
    int blue =
        (startColor.blue + (endColor.blue - startColor.blue) * ratio).round();
    return Color.fromARGB(255, red, green, blue);
  }

  void resetToInitialColor() {
    setState(() {
      _currentColor = widget.initialColor;
      _colorSliderPosition = _calculatePositionFromColor(_currentColor);
      _shadedColor = _calculateShadedColor(_shadeSliderPosition);
      widget.onColorChanged(_shadedColor);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            _colorChangeHandler(details.localPosition.dx);
          },
          onTapDown: (TapDownDetails details) {
            _colorChangeHandler(details.localPosition.dx);
          },
          child: Container(
            width: widget.width,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                  color: Theme.of(context).colorScheme.shadow, width: 2),
              gradient: LinearGradient(colors: _colors),
            ),
            child: CustomPaint(
              painter:
                  _SliderIndicatorPainter(_colorSliderPosition, _currentColor),
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            _shadeChangeHandler(details.localPosition.dx);
          },
          onTapDown: (TapDownDetails details) {
            _shadeChangeHandler(details.localPosition.dx);
          },
          child: Container(
            width: widget.width,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                  color: Theme.of(context).colorScheme.shadow, width: 2),
              gradient: LinearGradient(
                colors: [Colors.black, _currentColor, Colors.white],
              ),
            ),
            child: CustomPaint(
              painter:
                  _SliderIndicatorPainter(_shadeSliderPosition, _shadedColor),
            ),
          ),
        ),
      ],
    );
  }
}
