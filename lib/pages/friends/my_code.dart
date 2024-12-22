import 'dart:convert';
import 'dart:typed_data';
import 'package:august/components/firebase/firebase_analytics.dart';
import 'package:august/components/friends/number_box.dart';
import 'package:august/components/profile/profile.dart';
import 'package:august/const/font/font.dart';
import 'package:august/get_api/friends/invitation_code.dart';
import 'package:august/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toasty_box/toasty_box.dart';

class InvitationCodePage extends StatefulWidget {
  const InvitationCodePage({Key? key}) : super(key: key);

  @override
  _InvitationCodePageState createState() => _InvitationCodePageState();
}

class _InvitationCodePageState extends State<InvitationCodePage>
    with TickerProviderStateMixin {
  AnimationController? _refreshFriendsController;
  String? formattedTime;
  String? _code = "00000000";
  String? _expires;
  String? _url;

  @override
  void initState() {
    checkAccessToken();
    _refreshFriendsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    formatExpires();
    super.initState();
    initCode();
  }

  @override
  void dispose() {
    _refreshFriendsController!.dispose();
    super.dispose();
  }

  Future<void> initCode() async {
    final prefs = await SharedPreferences.getInstance();
    _expires = prefs.getString('codeExpires');
    if (isCodeExpired()) {
      await checkAccessToken();
      await generateCode();
    } else {
      await checkAccessToken();
      // get code but still can use the old code
      await generateCode();
      // _code = prefs.getString('invitationCode') ?? _code;
      // formattedTime = formatExpires();
    }
    setState(() {}); // Update UI after verification or generation
  }

  bool isCodeExpired() {
    if (_expires != null) {
      final now = DateTime.now();
      final expires = DateTime.parse(_expires!);
      print('Now: $now, Expires: $expires'); // Debug output to check values
      return expires.isBefore(now);
    }
    return true; // Assume expired if no expiry date is set
  }

  String formatExpires() {
    if (_expires != null) {
      final now = DateTime.now();
      final expires = DateTime.parse(_expires!);
      final duration = expires.difference(now);

      if (duration.isNegative) {
        return "Expired";
      } else {
        final days = duration.inDays;
        final hours = duration.inHours % 24;
        final minutes = duration.inMinutes % 60;

        return "${days}d ${hours}h ${minutes}m";
      }
    }
    return "No expiry date";
  }

  Future<void> generateCode() async {
    FriendsRequestCode requestCode =
        await FriendRequestService().createFriendRequestCode();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('codeExpires', requestCode.expires);
    await prefs.setString('invitationCode', requestCode.code);

    setState(() {
      _code = requestCode.code;
      _expires = requestCode.expires;
      formattedTime = formatExpires();
    });
  }

  Future<void> revokeGeneratedCode(BuildContext context, String code) async {
    final bool? revoke = await showDialog<bool>(
      context: context, // Add context parameter
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          icon: Icon(
            Icons.refresh,
            color: Colors.redAccent,
            size: 40,
          ),
          title: Text(
            'Revoke My Code?',
            textAlign: TextAlign.center,
            style: AugustFont.head5(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          content: Text(
            "Previous code (${code}) will be revoked and a new code will be generated.",
            textAlign: TextAlign.center,
            style: AugustFont.subText2(color: Colors.grey),
          ),
          actions: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(true);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Revoke',
                          style: AugustFont.head8(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30),
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(60)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No, I want to keep my code',
                          style: AugustFont.head8(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
    if (revoke!) {
      await FriendRequestService().revokeFriendRequestCode().then((_) async {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        generateCode();
        await prefs.remove('codeExpires');
        await prefs.remove('invitationCode');
        _refreshFriendsController!.forward(from: 0.0);
      });
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    print(_expires);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 25),
              height: 310,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 10,
                    offset: Offset(6, 4),
                  ),
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow,
                    blurRadius: 10,
                    offset: Offset(-2, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ProfileWidget(
                    isBottomBar: false,
                    isMyCode: true,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "My Code",
                        style: AugustFont.head2(
                            color: Theme.of(context).colorScheme.outline),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          checkAccessToken();
                          revokeGeneratedCode(context, _code!);
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          child: Center(
                            child: RotationTransition(
                              turns: Tween(begin: 0.0, end: 1.0)
                                  .animate(_refreshFriendsController!),
                              child: Icon(
                                Icons.refresh,
                                color: Theme.of(context).colorScheme.outline,
                                size: 23,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      DigitBoxes(code: "$_code"),
                      Padding(
                        padding: const EdgeInsets.only(right: 10, bottom: 5),
                        child: Text(
                          formattedTime?.isEmpty ?? true
                              ? "Expires in 0 days 0 hours 0 minutes"
                              : "Expires in $formattedTime",
                          style: AugustFont.captionSmallBold(
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () async {
                      Clipboard.setData(ClipboardData(text: "$_code"));
                      await AnalyticsService()
                          .copyMyCode(DateTime.now().toString());
                      ToastService.showToast(
                        context,
                        isClosable: true,
                        backgroundColor:
                            Theme.of(context).colorScheme.background,
                        shadowColor: Theme.of(context).colorScheme.shadow,
                        leading: Icon(
                          FeatherIcons.checkCircle,
                          color: Colors.greenAccent,
                        ),
                        message: "Your invitation code has been copied!",
                      );
                    },
                    child: Text(
                      "Copy Code",
                      style: AugustFont.subText2(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: () => Navigator.pop(context, _code),
              child: CircleAvatar(
                radius: 25, // Increased radius for a larger avatar
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  FeatherIcons.x,
                  size: 25, // Increased size for the icon
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
