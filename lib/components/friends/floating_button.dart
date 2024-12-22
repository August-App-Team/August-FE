import 'package:august/const/font/font.dart';
import 'package:flutter/material.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

Widget buildFAB(BuildContext context, VoidCallback onPressed) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 300),
    curve: Curves.fastEaseInToSlowEaseOut,
    width: 50,
    height: 50,
    child: FloatingActionButton.extended(
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: () {
        onPressed();
      },
      label: SizedBox(),
      icon: Padding(
        padding: const EdgeInsets.only(left: 13),
        child: Icon(
          FeatherIcons.users,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    ),
  );
}

Widget buildExtendedFAB(BuildContext context, VoidCallback onPressed) {
  return AnimatedContainer(
    duration: Duration(milliseconds: 300),
    curve: Curves.fastEaseInToSlowEaseOut,
    width: 180,
    height: 50,
    child: FloatingActionButton.extended(
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onPressed: () {
        onPressed();
      },
      label: Text(
        "Group Hangouts",
        style: AugustFont.subText(
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      icon: Icon(
        FeatherIcons.users,
        color: Theme.of(context).colorScheme.outline,
      ),
    ),
  );
}
