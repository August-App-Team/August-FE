import 'dart:io';
import 'package:august/provider/user_info_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

// UserInfoProvider remains the same, but ensure it is capable of handling new image data.

class ProfileWidget extends StatefulWidget {
  final bool isBottomBar;
  final bool isProfilePage;
  final bool isMePage;
  final bool isMyCode;
  final bool isFriendsPage;
  final bool isGroupHangoutPage;
  final String friendPhoto;
  const ProfileWidget({
    Key? key,
    required this.isBottomBar,
    this.isProfilePage = false,
    this.isMePage = false,
    this.isMyCode = false,
    this.isFriendsPage = false,
    this.friendPhoto = '',
    this.isGroupHangoutPage = false,
  }) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  Future<MemoryImage?> getMemoryImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      return MemoryImage(response.bodyBytes);
    } catch (e) {
      print("Failed to load image: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserInfoProvider>(context);
    var userDetails = userProvider.userInfo;

    if (userDetails == null || userDetails.profileImage == null) {
      return CircularProgressIndicator();
    }

    String profileImageUrl = userDetails.profileImage!;
    return Padding(
      padding: widget.isBottomBar ? const EdgeInsets.all(5.0) : EdgeInsets.zero,
      child: CircleAvatar(
        radius: widget.isGroupHangoutPage
            ? 30
            : widget.isFriendsPage
                ? 45
                : widget.isMePage
                    ? 20
                    : widget.isProfilePage
                        ? 100
                        : widget.isMyCode
                            ? 50
                            : 20,
        backgroundColor: Colors.grey,
        backgroundImage: widget.isFriendsPage
            ? NetworkImage(widget.friendPhoto) as ImageProvider
            : profileImageUrl.startsWith('http')
                ? NetworkImage(profileImageUrl) as ImageProvider
                : FileImage(File(profileImageUrl)),
      ),
    );
  }
}
