import 'package:august/const/font/font.dart';
import 'package:august/pages/friends/friends_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';

class AddFriendsPage extends StatefulWidget {
  final VoidCallback onRefresh;
  AddFriendsPage({
    Key? key,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _AddFriendsPageState createState() => _AddFriendsPageState();
}

class _AddFriendsPageState extends State<AddFriendsPage> {
  TextEditingController inviteController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ColorfulSafeArea(
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.background,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Center(
                              child: Icon(
                                Icons.arrow_back_ios,
                                size: 15,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
                Text(
                  "Friend's Code?",
                  style: AugustFont.head3(
                      color: Theme.of(context).colorScheme.outline),
                ),
                SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    "Enter your friend's 8 digit code to share schedules and plan hangouts",
                    textAlign: TextAlign.center,
                    style: AugustFont.head4(color: Colors.grey),
                  ),
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: CupertinoTextField(
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      LengthLimitingTextInputFormatter(8),
                    ],
                    autofocus: true,
                    textAlign: TextAlign.center,
                    controller: inviteController,
                    padding: EdgeInsets.all(10),
                    placeholder: "Enter Friend\'s Code",
                    placeholderStyle: AugustFont.addFriends(
                      color: Theme.of(context).colorScheme.surfaceTint,
                    ),
                    style: AugustFont.addFriends(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    cursorColor: Theme.of(context).colorScheme.outline,
                    cursorHeight: 40,
                    onChanged: (text) {
                      setState(() {}); // 텍스트 필드의 내용이 변경될 때마다 UI 업데이트
                    },
                    maxLength: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: GestureDetector(
        onTap: () {
          Navigator.of(context).pop(inviteController.text);
          // widget.addFriend(inviteController.text);
          // addFriend(inviteController.text);
          inviteController.clear();

          Future.delayed(Duration(seconds: 1), () {
            widget.onRefresh();
            // _onRefresh();
          });
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 30),
            height: 55,
            width: MediaQuery.of(context).size.width - 80,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(60)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'DONE',
                  style: AugustFont.head2(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
