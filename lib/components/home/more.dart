import 'package:august/const/font/font.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

class MoreButton extends StatefulWidget {
  final VoidCallback setMain;
  final VoidCallback editSchedule;
  final VoidCallback share;
  final VoidCallback remove;
  final int currentIndex;
  MoreButton({
    Key? key,
    required this.editSchedule,
    required this.remove,
    required this.share,
    required this.setMain,
    required this.currentIndex,
  }) : super(key: key);
  @override
  _MoreButtonState createState() => _MoreButtonState();
}

class _MoreButtonState extends State<MoreButton> {
  @override
  Widget build(BuildContext context) {
    return MyPopupMenu(
      child: Icon(
        FeatherIcons.moreHorizontal,
        key: GlobalKey(),
        color: Theme.of(context).colorScheme.outline,
        size: 20,
      ),
      setMain: widget.setMain,
      editSchedule: widget.editSchedule,
      remove: widget.remove,
      share: widget.share,
      currentIndex: widget.currentIndex,
    );
  }
}

class MyPopupMenu extends StatefulWidget {
  final Widget child;
  final VoidCallback setMain;
  final VoidCallback editSchedule;
  final VoidCallback share;
  final VoidCallback remove;

  final int currentIndex;
  MyPopupMenu(
      {Key? key,
      required this.child,
      required this.setMain,
      required this.editSchedule,
      required this.share,
      required this.remove,
      required this.currentIndex})
      : assert(child.key != null),
        super(key: key);

  @override
  _MyPopupMenuState createState() => _MyPopupMenuState();
}

class _MyPopupMenuState extends State<MyPopupMenu> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child,
      onTap: () {
        _showPopupMenu();
        HapticFeedback.lightImpact();
      },
    );
  }

  void _showPopupMenu() {
    //Find renderbox object
    RenderBox renderBox = (widget.child.key as GlobalKey)
        .currentContext
        ?.findRenderObject() as RenderBox;
    Offset position = renderBox.localToGlobal(Offset.zero);

    showCupertinoDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return PopupMenuContent(
              position: position,
              size: renderBox.size,
              onAction: (x) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  duration: Duration(seconds: 1),
                  content: Text('Action => $x'),
                ));
              },
              setMain: widget.setMain,
              editSchedule: widget.editSchedule,
              remove: widget.remove,
              currentIndex: widget.currentIndex,
              share: widget.share);
        });
  }
}

class PopupMenuContent extends StatefulWidget {
  final Offset position;
  final Size size;
  final ValueChanged<String>? onAction;
  final VoidCallback setMain;
  final VoidCallback editSchedule;
  final VoidCallback share;
  final VoidCallback remove;
  final int currentIndex;
  const PopupMenuContent(
      {Key? key,
      required this.position,
      required this.size,
      this.onAction,
      required this.setMain,
      required this.editSchedule,
      required this.share,
      required this.remove,
      required this.currentIndex})
      : super(key: key);

  @override
  _PopupMenuContentState createState() => _PopupMenuContentState();
}

class _PopupMenuContentState extends State<PopupMenuContent>
    with SingleTickerProviderStateMixin {
  //Let's create animation
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closePopup("");
        HapticFeedback.lightImpact();
        return false;
      },
      child: GestureDetector(
        onTap: () {
          _closePopup("");
          HapticFeedback.lightImpact();
        },
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            height: double.maxFinite,
            width: double.maxFinite,
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right:
                      (MediaQuery.of(context).size.width - widget.position.dx) -
                          widget.size.width,
                  top: widget.position.dy,
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _animation.value,
                        alignment: Alignment.topRight,
                        child: Opacity(opacity: _animation.value, child: child),
                      );
                    },
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        width: double.maxFinite,
                        padding: EdgeInsets.only(
                            left: 10,
                            right: 10,
                            top: (widget.currentIndex != 0) ? 10 : 10,
                            bottom: 10),
                        margin: EdgeInsets.only(left: 155),
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.1),
                                blurRadius: 8,
                              )
                            ]),
                        child: Column(
                          children: [
                            (widget.currentIndex != 0)
                                ? GestureDetector(
                                    onTap: () {
                                      widget.setMain();
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Color.fromARGB(
                                                255, 212, 248, 239),
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                          child: Icon(
                                            size: 20,
                                            FeatherIcons.star,
                                            color: Color.fromARGB(
                                                255, 9, 201, 156),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Text(
                                          "Set as Main",
                                          style: AugustFont.subText3(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(24),
                                        ),
                                        child: Icon(
                                          size: 20,
                                          FeatherIcons.star,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 12,
                                      ),
                                      Text(
                                        "Main",
                                        style: AugustFont.subText3(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                        ),
                                      ),
                                    ],
                                  ),
                            //Edit workout
                            SizedBox(
                              height: 16,
                            ),

                            GestureDetector(
                              onTap: () {
                                widget.editSchedule();
                              },
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE1E1FC),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(
                                      size: 20,
                                      FeatherIcons.edit2,
                                      color: Color(0xFF3840A2),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    "Edit Schedule",
                                    style: AugustFont.subText3(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //Share workout

                            // //Edit workout
                            // SizedBox(
                            //   height: 16,
                            // ),

                            // GestureDetector(
                            //   onTap: () {
                            //     widget.share();
                            //   },
                            //   child: Row(
                            //     children: [
                            //       Container(
                            //         padding: EdgeInsets.all(6),
                            //         decoration: BoxDecoration(
                            //           color: Color.fromARGB(255, 253, 207, 179),
                            //           borderRadius: BorderRadius.circular(24),
                            //         ),
                            //         child: Icon(
                            //           size: 20,
                            //           FeatherIcons.share,
                            //           color: Color.fromARGB(255, 176, 77, 15),
                            //         ),
                            //       ),
                            //       SizedBox(
                            //         width: 12,
                            //       ),
                            //       Text(
                            //         "Share",
                            //         style: AugustFont.subText3(
                            //           color:
                            //               Theme.of(context).colorScheme.outline,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            SizedBox(height: 5),
                            Divider(
                              color: Colors.grey.shade600,
                              thickness: 1,
                            ),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                widget.remove();
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 227, 227),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(
                                      size: 20,
                                      FeatherIcons.trash,
                                      color: Colors.red,
                                    ),
                                    //Color(0xFF0586C0),
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    "Remove",
                                    style: AugustFont.subText3(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _closePopup(String action) {
    _animationController.reverse().whenComplete(() {
      Navigator.of(context).pop();

      if (action.isNotEmpty) widget.onAction?.call(action);
    });
  }
}
