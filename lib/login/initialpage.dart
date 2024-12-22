import 'dart:io';

import 'package:august/components/home/dialog.dart';
import 'package:august/const/device/device_util.dart';
import 'package:august/const/font/font.dart';
import 'package:august/login/login.dart';
import 'package:august/pages/main/homepage.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:lottie/lottie.dart';
import 'dart:math';

class InitialPage extends StatefulWidget {
  final bool guest;

  const InitialPage({
    super.key,
    this.guest = false,
  });

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  bool isDefault = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: Platform.isIOS
        ? '469588470984-or2haks4c471937fblbnc1j26061n6d1.apps.googleusercontent.com'
        : Platform.isAndroid
            ? '469588470984-87et979ds37bt4svf5mv6tfe64i9ue21.apps.googleusercontent.com'
            : '469588470984-db1qs59t70rq8etubhmdrgn3ig91j9n8.apps.googleusercontent.com',
    serverClientId:
        '469588470984-db1qs59t70rq8etubhmdrgn3ig91j9n8.apps.googleusercontent.com',
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/userinfo.profile',
    ],
  );

// 사진 보낼때 file로 보내야됌
  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final String? accessToken = googleAuth?.accessToken;
      final String? idToken = googleAuth?.idToken;

      // String path = '/Users/Files/tokens.txt';

      // // Create a file at the specified path
      // final file = File(path);

      // // Write the tokens to the file
      // await file.writeAsString('AccessToken: $accessToken\nIdToken: $idToken');

      print('Check accessToken $accessToken');
      print('Check idtoken $idToken');

      if (googleUser == null || accessToken == null || idToken == null) {
        print(
            'Google login was cancelled by the user or failed to receive ID token.');
        return;
      }

      String requestBody =
          jsonEncode({'access_token': accessToken, 'id_token': idToken});
      final response = await http.post(
        Uri.parse('https://augustapp.one/users/google/login/callback/'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['access'];
        final newRefreshToken = responseData['refresh'];
        final userPk = responseData['user']['id']; // Extract user PK

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', newAccessToken);
        await prefs.setString('refreshToken', newRefreshToken);
        await prefs.setInt('userPk', userPk);

        startTokenRefreshTimer(); // Start token refresh timer after successful login

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(), fullscreenDialog: true),
        );
      } else {
        print('Server error: ${response.body}');
        logoutUser();
        bool isOnline = await InternetConnectionChecker().hasConnection;
        !isOnline ? showLoginPrompt(context) : showFixingPopup(context);
      }
    } catch (error) {
      print('Error logging in with Google: $error');
    }
  }

  Future<void> _loginWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
            clientId: 'one.august',
            redirectUri:
                Uri.parse('https://augustapp.one/users/apple/login/callback/')),
      );

      final String? accessToken = appleCredential.authorizationCode;
      final String? idToken = appleCredential.identityToken;

      if (accessToken == null || idToken == null) {
        print(
            'Apple login was cancelled by the user or failed to receive ID token.');
        return;
      }

      String requestBody =
          jsonEncode({'access_token': accessToken, 'id_token': idToken});
      final response = await http.post(
        Uri.parse('https://augustapp.one/users/apple/login/callback/'),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final newAccessToken = responseData['access'];
        final newRefreshToken = responseData['refresh'];
        final userPk = responseData['user']['id']; // Extract user PK

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', newAccessToken);
        await prefs.setString('refreshToken', newRefreshToken);
        await prefs.setInt('userPk', userPk);

        startTokenRefreshTimer(); // Start token refresh timer after successful login

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        print('Server error: ${response.body}');
        logoutUser();
        bool isOnline = await InternetConnectionChecker().hasConnection;
        !isOnline ? showLoginPrompt(context) : showFixingPopup(context);
      }
    } catch (error) {
      print('Error logging in with Apple: $error');
    }
  }

  @override
  void initState() {
    FirebaseAnalytics.instance.logAppOpen();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkLoginStatusAndNavigate();
  }

  Future<void> _checkLoginStatusAndNavigate() async {
    // Show loading indicator
    Future.microtask(
      () => loadingShowDialog(context),
    );

    final isLoggedIn = await checkLoginStatus(); // Check current login status

    if (!isLoggedIn) {
      final isTokenRefreshed =
          await refreshToken(); // Attempt to refresh the token

      if (isTokenRefreshed) {
        // If token refresh is successful, fetch user info and navigate to homepage
        if (await fetchAndPrintUserInfo(context)) {
          Navigator.pop(context); // Close loading indicator
          _navigateToHomePage(); // Navigate to homepage
        } else {
          // If fetching user info fails, show login prompt
          Navigator.pop(context); // Close loading indicator
          print('1');
          logoutUser();
          bool isOnline = await InternetConnectionChecker().hasConnection;
          !isOnline ? showLoginPrompt(context) : showFixingPopup(context);
        }
      } else {
        // If token refresh fails, logout the user and show login prompt
        logoutUser();
        print('2');
        Navigator.pop(context); // Close loading indicator
      }
    } else {
      // If already logged in, fetch user info and navigate to homepage
      if (await fetchAndPrintUserInfo(context)) {
        Navigator.pop(context); // Close loading indicator
        print('3');
        _navigateToHomePage(); // Navigate to homepage
      } else {
        // If fetching user info fails, show login prompt
        Navigator.pop(context); // Close loading indicator
        logoutUser();
        print('4');
        //showLoginPrompt(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: ColorfulSafeArea(
        child: DeviceUtils.isTablet(context) && DeviceUtils.isLandscape(context)
            ? isTablet()
            : isMobile(),
      ),
    );
  }

  Widget isMobile() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Spacer(),
          introText(),
          SizedBox(height: 20),
          appleButton(),
          SizedBox(height: 20),
          googleButton(),
          SizedBox(height: 20),
          policyTerms(),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget isTablet() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: introText(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  signInText(),
                  SizedBox(height: 20),
                  appleButton(),
                  SizedBox(height: 20),
                  googleButton(),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: policyTerms(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /* --- functions ---- */

  void showLoginPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          icon: Icon(
            FeatherIcons.alertTriangle,
            color: Colors.redAccent,
            size: 45,
          ),
          title: Text(
            textAlign: TextAlign.center,
            'Login Failed',
            style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                height: 55,
                width: MediaQuery.of(context).size.width - 80,
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(60)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'OK',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showFixingPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          icon: Icon(
            FeatherIcons.alertTriangle,
            color: Colors.redAccent,
            size: 45,
          ),
          title: Text(
            textAlign: TextAlign.center,
            'Please try later...',
            style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
          content: Text(
            textAlign: TextAlign.center,
            'Currently, we are fixing the server.\nPlease try again later.',
            style: AugustFont.subText2(
                color: Theme.of(context).colorScheme.outline),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                height: 55,
                width: MediaQuery.of(context).size.width - 80,
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(60)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'OK',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToHomePage() {
    if (!mounted)
      return; // Add this line to check if the widget is still mounted

    HapticFeedback.heavyImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);

          return FadeTransition(
            opacity: fadeAnimation,
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 650), // 애니메이션 속도 조정
      ),
    );
  }

  void privaryPolicy() async {
    const url = 'http://extra-mile.notion.site';
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void termsOfUse() async {
    const url =
        'https://extra-mile.notion.site/Terms-Conditions-c312612c53a141978c3503da5028680f?pvs=4';
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void _launchURL() async {
    const url = 'https://forms.gle/2ytdRmXgFps7pK567';
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  /* --- widges --- */

  Widget signInText() {
    return Text(
      'Sign in with',
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 35,
        color: Theme.of(context).colorScheme.outline,
        height: 1.5,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget introText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Share ',
              style: AugustFont.intial(
                  color: Theme.of(context).colorScheme.outline),
            ),
            WidgetSpan(
              child: Lottie.asset(
                'assets/lottie/share.json',
                height: 35,
                width: 40,
              ),
            ),
            TextSpan(
              text: ' School life \n',
              style: AugustFont.intial(
                  color: Theme.of(context).colorScheme.outline),
            ),
            TextSpan(
              text: 'with ',
              style: AugustFont.intial(color: Colors.grey),
            ),
            TextSpan(
              text: ' Auto created ',
              style: AugustFont.intial(
                  color: Theme.of(context).colorScheme.outline),
            ),
            WidgetSpan(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.rotationY(pi),
                child: Lottie.asset(
                  'assets/lottie/magic_wand.json',
                  height: 35,
                  width: 40,
                ),
              ),
            ),
            TextSpan(
              text: 'Schedules!',
              style: AugustFont.intial(
                  color: Theme.of(context).colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  Widget appleButton() {
    return AppleAuthButton(
      onPressed: () {
        _loginWithApple();
        print('apple login clicked');
      },
      style: AuthButtonStyle(
        buttonColor: Theme.of(context).colorScheme.outline,
        borderRadius: 18,
        iconSize: 28,
        iconColor: Theme.of(context).colorScheme.background,
        separator: 10,
        splashColor: Theme.of(context).colorScheme.background.withOpacity(0.1),
        textStyle: TextStyle(
          fontSize: 18,
          color: Theme.of(context).colorScheme.background,
          fontFamily: 'Nanum',
          fontWeight: FontWeight.w600,
        ),
        width: MediaQuery.of(context).size.width,
        height: 56.0,
      ),
    );
  }

  Widget googleButton() {
    return GoogleAuthButton(
      onPressed: _loginWithGoogle,
      style: AuthButtonStyle(
        buttonColor: Colors.white,
        iconSize: 28,
        borderRadius: 18,
        separator: 10,
        borderColor: Colors.black,
        borderWidth: 1,
        splashColor: Theme.of(context).colorScheme.background.withOpacity(0.1),
        textStyle: TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontWeight: FontWeight.w600,
          fontFamily: 'Nanum',
        ),
        width: MediaQuery.of(context).size.width,
        height: 60,
      ),
    );
  }

  Widget policyTerms() {
    return Text.rich(
      textAlign: TextAlign.center,
      TextSpan(
        text:
            'By signing up for an account in August, you confirm that\nyou have read and agreed to our ',
        style: AugustFont.captionSmall(color: Colors.grey),
        children: <TextSpan>[
          TextSpan(
            text: 'Terms of Use',
            style: AugustFont.captionSmallUnderline(color: Colors.grey),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                termsOfUse();
              },
          ),
          TextSpan(
            text: ' and ',
            style: AugustFont.captionSmall(color: Colors.grey),
          ),
          TextSpan(
            text: 'Privacy Policy',
            style: AugustFont.captionSmallUnderline(color: Colors.grey),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                privaryPolicy();
              },
          ),
        ],
      ),
    );
  }
}
