import 'package:august/const/font/font.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'class.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

class AddCourseToGroup extends StatefulWidget {
  final List<GroupList?> addedCourses;
  final int index;
  final VoidCallback onRemove;

  AddCourseToGroup({
    Key? key,
    required this.addedCourses,
    required this.index,
    required this.onRemove, // Required parameter for the callback
  }) : super(key: key);

  @override
  _AddCourseToGroupState createState() => _AddCourseToGroupState();
}

class _AddCourseToGroupState extends State<AddCourseToGroup> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  widget.addedCourses[widget.index] == null
                      ? 'No Course Yet'
                      : widget.addedCourses[widget.index]!.courseCode ??
                          'unknown',
                  style: AugustFont.textField2(color: Colors.black)),
              ..._buildInstructorList(
                  widget.addedCourses[widget.index]?.instructors),
              SizedBox(height: 10),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: IconButton(
            icon: Icon(
              FeatherIcons.xCircle,
              color: Colors.black,
              size: 20,
            ),
            onPressed: widget.onRemove,
          ),
        ),
      ],
    );
  }
}

List<Widget> _buildInstructorList(List<GroupInstructor>? instructors) {
  if (instructors == null || instructors.isEmpty) {
    return [
      Text("No Instructors",
          style: TextStyle(fontSize: 14, color: Colors.black))
    ];
  }

  return instructors
      .map((instructor) => Text(
            instructor.name!,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ))
      .toList();
}
