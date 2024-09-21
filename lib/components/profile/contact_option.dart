import 'dart:io';

import 'package:august/const/font/font.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:flutter_svg/flutter_svg.dart';

class ContactButton extends StatefulWidget {
  final VoidCallback getMemoji;
  final VoidCallback openPhoto;
  final VoidCallback defaultImage;
  ContactButton({
    Key? key,
    required this.openPhoto,
    required this.defaultImage,
    required this.getMemoji,
  }) : super(key: key);
  @override
  _ContactButtonState createState() => _ContactButtonState();
}

class _ContactButtonState extends State<ContactButton> {
  @override
  Widget build(BuildContext context) {
    return MyPopupMenu(
      child: Container(
        key: GlobalKey(),
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 2.0,
          ),
        ),
        child: Icon(
          Icons.add,
          key: GlobalKey(),
          color: Theme.of(context).colorScheme.outline,
          size: 40,
        ),
      ),
      getMemoji: widget.getMemoji,
      openPhoto: widget.openPhoto,
      defaultImage: widget.defaultImage,
    );
  }
}

class MyPopupMenu extends StatefulWidget {
  final Widget child;
  final VoidCallback getMemoji;
  final VoidCallback openPhoto;
  final VoidCallback defaultImage;
  MyPopupMenu({
    Key? key,
    required this.child,
    required this.getMemoji,
    required this.openPhoto,
    required this.defaultImage,
  })  : assert(child.key != null),
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
            getMemoji: widget.getMemoji,
            openPhoto: widget.openPhoto,
            defaultImage: widget.defaultImage,
          );
        });
  }
}

class PopupMenuContent extends StatefulWidget {
  final Offset position;
  final Size size;
  final ValueChanged<String>? onAction;
  final VoidCallback getMemoji;
  final VoidCallback openPhoto;
  final VoidCallback defaultImage;
  const PopupMenuContent({
    Key? key,
    required this.position,
    required this.size,
    this.onAction,
    required this.getMemoji,
    required this.openPhoto,
    required this.defaultImage,
  }) : super(key: key);

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
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastEaseInToSlowEaseOut,
    ));
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
                  left: 60,
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
                            left: 10, right: 10, top: 10, bottom: 10),
                        margin: EdgeInsets.only(left: 20),
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
                            Platform.isIOS
                                ? GestureDetector(
                                    onTap: () {
                                      widget.getMemoji();
                                      Navigator.pop(context);
                                    },
                                    child: Row(
                                      children: [
                                        Container(
                                          height: 35,
                                          width: 35,
                                          padding: EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFDDF3FD),
                                            borderRadius:
                                                BorderRadius.circular(24),
                                          ),
                                          child: Icon(
                                            size: 20,
                                            Icons.contact_emergency,
                                            color: Color(0xFF0586C0),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Text(
                                          'Fill from Contacts',
                                          style: AugustFont.subText3(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            Platform.isIOS ? SizedBox(height: 5) : SizedBox(),
                            Platform.isIOS
                                ? Divider(
                                    color: Colors.grey.shade600,
                                    thickness: 1,
                                  )
                                : SizedBox(),
                            SizedBox(height: 5),
                            GestureDetector(
                              onTap: () {
                                widget.openPhoto();
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Container(
                                    height: 35,
                                    width: 35,
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 212, 248, 239),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(
                                      size: 20,
                                      Icons.insert_photo_outlined,
                                      color: Color(0xFF0586C0),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    'Open Photos',
                                    style: AugustFont.subText3(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            //Share workout
                            SizedBox(
                              height: 16,
                            ),

                            GestureDetector(
                              onTap: () {
                                widget.defaultImage();
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Container(
                                    height: 35,
                                    width: 35,
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFE1E1FC),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Icon(
                                      size: 20,
                                      Icons.question_mark_rounded,
                                      color: Color(0xFF3840A2),
                                    ),
                                  ),
                                  // Image.asset(
                                  //   'assets/icons/memoji.png',
                                  //   height: 35,
                                  //   width: 35,
                                  // ),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Text(
                                    'Default',
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
