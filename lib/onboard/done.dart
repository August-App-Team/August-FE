import 'package:august/const/font/font.dart';
import 'package:august/login/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:august/provider/user_info_provider.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:lottie/lottie.dart';

class OnBoardDonePage extends StatefulWidget {
  final VoidCallback goBack;
  final VoidCallback gonext;
  const OnBoardDonePage({
    super.key,
    required this.goBack,
    required this.gonext,
  });

  @override
  State<OnBoardDonePage> createState() => _OnBoardDonePageState();
}

class _OnBoardDonePageState extends State<OnBoardDonePage> {
  String _authStatus = 'Unknown';
  @override
  void initState() {
    super.initState();
    var infoProvider =
        Provider.of<UserInfoProvider>(context, listen: false).userInfo;
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initPlugin() async {
    try {
      final TrackingStatus status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      setState(() => _authStatus = '$status');
      // If the system can show an authorization request dialog
      if (status == TrackingStatus.notDetermined) {
        // Show a custom explainer dialog before the system dialog
        final TrackingStatus status =
            await AppTrackingTransparency.requestTrackingAuthorization();
        setState(() => _authStatus = '$status');
      }
    } on PlatformException {
      setState(() => _authStatus = 'PlatformException was thrown');
    }
    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ColorfulSafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.background,
          ),
          child: Center(
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
                          widget.goBack();
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
                Spacer(),
                Lottie.asset(
                  'assets/lottie/success.json',
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                  repeat: false,
                ),
                SizedBox(height: 10),
                Text(
                  'You are all set!\nWelcome to August!',
                  style: AugustFont.head1(),
                  textAlign: TextAlign.center,
                ),
                Spacer(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          bottom: 60,
        ),
        child: GestureDetector(
          onTap: () async {
            checkAccessToken();
            await initPlugin(); // Ensure initPlugin completes before proceeding
            widget.gonext(); // Call gonext after initPlugin is done
            HapticFeedback.mediumImpact();
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
