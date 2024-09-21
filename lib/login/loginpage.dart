import 'package:august/pages/main/homepage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/services.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isObscured = true;
  IconData _iconVisible = Icons.visibility;
  IconData _iconInvisible = Icons.visibility_off;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  FocusNode _emailFocusNode = FocusNode();

  // Regular expressions for validation
  final RegExp _upperCase = RegExp(r'(?=.*[A-Z])');
  final RegExp _lowerCase = RegExp(r'(?=.*[a-z])');
  final RegExp _number = RegExp(r'(?=.*\d)');
  final RegExp _specialChar = RegExp(r'(?=.*[!@#\$&*~])');

  // Validation flags
  bool hasUppercase = false;
  bool hasLowercase = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool hasMinLength = false;
  @override
  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration(milliseconds: 300), () {
        FocusScope.of(context).requestFocus(_emailFocusNode);
      });
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  void _validatePassword() {
    setState(() {
      hasUppercase = _upperCase.hasMatch(_passwordController.text);
      hasLowercase = _lowerCase.hasMatch(_passwordController.text);
      hasNumber = _number.hasMatch(_passwordController.text);
      hasSpecialChar = _specialChar.hasMatch(_passwordController.text);
      hasMinLength = _passwordController.text.length >= 8;
    });
  }

  Widget _buildValidationIcon(bool isValid) {
    return Icon(
      isValid ? FeatherIcons.checkCircle : FeatherIcons.xCircle,
      color: isValid ? CupertinoColors.activeGreen : CupertinoColors.systemGrey,
      size: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.background,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              FocusScope.of(context).unfocus(); // 포커스 해제하여 키보드 숨기기
              Future.delayed(Duration(milliseconds: 100), () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context); // 페이지 이동
                }
              });
            },
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
              ),
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
      ),
      body: ColorfulSafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'Login or Sign up',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),

              SizedBox(height: 30),
              // 아이디
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
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
                child: TextField(
                  cursorColor: Theme.of(context).colorScheme.outline,
                  controller: _emailController,
                  focusNode: _emailFocusNode,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (value) {
                    // 'Next' 버튼을 누를 때 수행할 동작
                    // 예를 들어, 다음 필드로 포커스 이동
                  },
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter Email",
                    hintStyle: TextStyle(
                      color: Colors.grey[400],
                      fontFamily: 'Nanum',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // 비번
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
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
                    padding: EdgeInsets.only(
                        left: 20, right: 10, top: 12, bottom: 12),
                    child: TextField(
                      controller: _passwordController,
                      cursorColor: Theme.of(context).colorScheme.outline,
                      obscureText: _isObscured,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Password",
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontFamily: 'Nanum',
                        ),
                        suffixIcon: IconButton(
                          icon:
                              Icon(_isObscured ? _iconVisible : _iconInvisible),
                          color: Colors.grey[400],
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.only(top: 8, left: 10),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _buildValidationIcon(hasUppercase),
                            SizedBox(width: 5),
                            Text(
                              "At least one uppercase letter",
                              style: TextStyle(
                                  color: hasUppercase
                                      ? CupertinoColors.activeGreen
                                      : CupertinoColors.systemGrey,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _buildValidationIcon(hasLowercase),
                            SizedBox(width: 5),
                            Text(
                              "At least one lowercase letter",
                              style: TextStyle(
                                  color: hasLowercase
                                      ? CupertinoColors.activeGreen
                                      : CupertinoColors.systemGrey,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _buildValidationIcon(hasNumber),
                            SizedBox(width: 5),
                            Text(
                              "At least one number",
                              style: TextStyle(
                                  color: hasNumber
                                      ? CupertinoColors.activeGreen
                                      : CupertinoColors.systemGrey,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _buildValidationIcon(hasSpecialChar),
                            SizedBox(width: 5),
                            Text(
                              "At least one special character",
                              style: TextStyle(
                                  color: hasSpecialChar
                                      ? CupertinoColors.activeGreen
                                      : CupertinoColors.systemGrey,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            _buildValidationIcon(hasMinLength),
                            SizedBox(width: 5),
                            Text(
                              "Minimum 8 characters",
                              style: TextStyle(
                                  color: hasMinLength
                                      ? CupertinoColors.activeGreen
                                      : CupertinoColors.systemGrey,
                                  fontSize: 15),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Container(
          child: Container(
            width: double.infinity,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.shadow,
                  blurRadius: 10,
                  offset: Offset(4, 8),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
              },
              child: Center(
                  child: Text('Done',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold))),
            ),
          ),
        ),
      ),
    );
  }
}
