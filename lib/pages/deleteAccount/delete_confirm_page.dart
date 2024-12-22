import 'package:august/components/firebase/firebase_analytics.dart';
import 'package:august/components/home/dialog.dart';
import 'package:august/login/initialpage.dart';
import 'package:august/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:lottie/lottie.dart';
import 'package:august/components/mepage/stacked_photo.dart';
import 'package:august/const/font/font.dart';
import 'package:august/provider/friends_provider.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class DeleteConfirmPage extends StatefulWidget {
  const DeleteConfirmPage({super.key});

  @override
  State<DeleteConfirmPage> createState() => _DeleteConfirmPageState();
}

class _DeleteConfirmPageState extends State<DeleteConfirmPage> {
  int countFriends = 0;
  List<String>? friends;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    countFriends = Provider.of<FriendsProvider>(context).friendsCount;
    friends =
        Provider.of<FriendsProvider>(context).friendsPhoto as List<String>;
    print(friends);
    print(countFriends);
  }

  @override
  Widget build(BuildContext context) {
    if (friends == null) {
      // Show a loading indicator while waiting for data
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: ColorfulSafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Delete Account',
                      style: AugustFont.head1(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Deleting your account will remove all your data from our servers. This action is irreversible.",
                      style: AugustFont.head4(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Center(
                    child: Lottie.asset('assets/lottie/crying.json',
                        height: 250, width: 250, repeat: true),
                  ),
                  (friends!.isNotEmpty)
                      ? Center(
                          child: StackedPhoto(
                            isDeleteConfirm: true,
                            imagePaths: [...friends!]
                              ..sort((a, b) => a.compareTo(b)),
                          ),
                        )
                      : Container(),
                  (friends!.isNotEmpty)
                      ? SizedBox(height: 30)
                      : SizedBox(height: 10),
                  (friends!.isNotEmpty)
                      ? Column(
                          children: [
                            Center(
                              child: Text(
                                "Your friends are still here.",
                                style: AugustFont.head6(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: 10),
                            Center(
                              child: Text(
                                "Are you sure you want to\n delete your account?",
                                style: AugustFont.head6(
                                    color:
                                        Theme.of(context).colorScheme.outline),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Text(
                            "Are you sure you want to\ndelete your account?",
                            style: AugustFont.head6(
                                color: Theme.of(context).colorScheme.outline),
                            textAlign: TextAlign.center,
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          height: 180,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showAlertDialog(context, 'Delete Account 😢',
                        'For Real? 😢', 'DELETE', 'Stay', false, () async {
                      Navigator.of(context).pop(); // Close the dialog
                      HapticFeedback.lightImpact();
                      await deleteUser(); // Perform the logout operation
                      await AnalyticsService().deleteAccount();
                      Navigator.pushReplacement(
                        // Navigate to the initial page
                        context,
                        CupertinoPageRoute(
                          builder: (context) => InitialPage(),
                        ),
                      );
                    }, () {
                      Navigator.of(context).pop(false);
                    }, () {});
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 60,
                    width: MediaQuery.of(context).size.width - 80,
                    decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'DELETE ACCOUNT',
                          style: AugustFont.head2(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 15),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 60,
                    width: MediaQuery.of(context).size.width - 80,
                    decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'KEEP',
                          style: AugustFont.head2(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
