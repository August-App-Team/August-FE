import 'package:august/components/profile/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';

class BottomBar extends StatefulWidget {
  final ValueChanged<int> onIndexChanged;

  BottomBar({
    Key? key,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  _BottomBarState createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return SnakeNavigationBar.color(
      height: 55,
      padding: EdgeInsets.only(
        left: 80,
        right: 80,
      ),
      behaviour: SnakeBarBehaviour.floating,
      snakeShape: SnakeShape.circle,
      snakeViewColor: Theme.of(context).colorScheme.inversePrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(400)),
      backgroundColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor:
          Theme.of(context).colorScheme.outline.withOpacity(0.1),
      selectedItemColor: Theme.of(context).colorScheme.outline,
      currentIndex: currentIndex,
      onTap: (index) {
        setState(() {
          currentIndex = index;
        });
        widget.onIndexChanged(index);
      },
      items: [
        BottomNavigationBarItem(
          activeIcon: Icon(
            FeatherIcons.search,
            color: Theme.of(context).colorScheme.outline,
          ),
          icon: Icon(
            FeatherIcons.search,
          ),
          label: 'Schedules',
        ),
        BottomNavigationBarItem(
          icon: Icon(FeatherIcons.layout),
          label: 'Schedules',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.people,
          ),
          label: 'Friends',
        ),
        BottomNavigationBarItem(
          icon: ProfileWidget(
            isBottomBar: true,
          ),
          label: 'Schedules',
        ),
      ],
    );
  }
}
