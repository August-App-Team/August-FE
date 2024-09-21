import 'dart:io';

import 'package:august/components/ad/ad_list.dart';
import 'package:august/components/friends/add_friend.dart';
import 'package:august/components/mepage/stacked_photo.dart';
import 'package:august/components/profile/profile.dart';
import 'package:august/const/font/font.dart';
import 'package:august/get_api/friends/invitation_code.dart';
import 'package:august/pages/friends/add_friends.dart';
import 'package:august/pages/friends/group_hangouts.dart';
import 'package:august/provider/courseprovider.dart';
import 'package:august/provider/friends_provider.dart';
import 'package:august/get_api/friends/delete_friend.dart';
import 'package:august/get_api/friends/verify_friend.dart';
import 'package:august/login/login.dart';
import 'package:august/pages/friends/my_code.dart';
import 'package:august/get_api/friends/get_friends.dart';
import 'package:august/pages/friends/friend_schedule_page.dart';
import 'package:august/provider/user_info_provider.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:provider/provider.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:toasty_box/toasty_box.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class FriendsPage extends StatefulWidget {
  const FriendsPage({Key? key}) : super(key: key);

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage>
    with TickerProviderStateMixin {
  /* ---- contact picker ---- */
  final FlutterContactPicker _contactPicker = new FlutterContactPicker();
  List<Contact>? _contacts;

  int bottomIndex = 0;
  List<FriendInfo> friends = [];
  bool isLoading = true;
  bool isEdit = false;
  String? selectedValue;
  Uint8List? profilePhoto;
  TextEditingController inviteController = TextEditingController();
  AnimationController? _controller;
  AnimationController? _jiggleController;

  AnimationController? _refreshFriendsController;
  String? _ownInvitationCode;
  String? myName;
  String? myCode = "00000000";
  int timetableLength = 0;

  List<String> friendsPhotos = [];
  List<String> groupFriendsPhoto = [];
  List<String> defaultPhoto = [
    'assets/memoji/Memoji2.png',
    'assets/memoji/Memoji3.png',
    'assets/memoji/Memoji1.png',
  ];

  @override
  void initState() {
    super.initState();
    myName =
        Provider.of<UserInfoProvider>(context, listen: false).userInfo!.name ??
            'August';
    getInvitationCode();
    loadFriends();
    //refresh button
    _refreshFriendsController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    //for edit button
    _controller = AnimationController(
      duration: const Duration(
          milliseconds:
              300), // Adjust duration to control speed of the animation
      vsync: this,
    );

    //for trashcan jiggle
    _jiggleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    timetableLength =
        Provider.of<CoursesProvider>(context, listen: false).timetableLength;
  }

  void toggleisEdit(int friendListLength) {
    setState(() {
      isEdit =
          friendListLength > 0 ? !isEdit : false; // Toggle the edit mode state
    });
    if (isEdit) {
      _controller!.forward(); // Animate to expanded aspect ratio
    } else {
      _controller!.reverse(); // Animate to normal aspect ratio
    }
  }

  Widget JiggleTrashIcon() {
    return AnimatedBuilder(
      animation: _jiggleController!,
      child: Icon(FeatherIcons.trash2, color: Colors.black, size: 40),
      builder: (context, child) {
        // Use sin function to create the jiggle effect
        final angle = math.sin(_jiggleController!.value * 5 * math.pi) *
            0.1; // Adjust amplitude for more/less jiggle
        return Transform.rotate(
          angle: angle,
          child: child,
        );
      },
    );
  }

  void getInvitationCode() async {
    FriendsRequestCode requestCode =
        await FriendRequestService().createFriendRequestCode();
    setState(() {
      myCode = requestCode.code;
    });
    print('Code has been refreshed after sending SMS');
  }

  void sendSMS(String message, String number) async {
    if (Platform.isAndroid) {
      String uri = 'sms:$number?body=${Uri.encodeComponent(message)}';
      await launchUrl(Uri.parse(uri));
    } else if (Platform.isIOS) {
      String uri = 'sms:$number&body=${Uri.encodeComponent(message)}';
      await launchUrl(Uri.parse(uri));
    }
    // final Uri uri = Uri(
    //     scheme: 'sms',
    //     path: number,
    //     query: Platform.isIOS ? 'body=$message' : 'content=$message');
    // if (await canLaunchUrl(uri)) {
    //   await launchUrl(uri);
    // } else {
    //   print('Could not launch $uri');
    // }
  }

  String MessageInfo(String myCode, String myLink) {
    myName =
        Provider.of<UserInfoProvider>(context, listen: false).userInfo!.name ??
            'August';
    return Platform.isIOS
        ? "${myName} invites you to August!\n\nDownload August to auto-generate and share schedules with friends!\n\n${myName}'s code: ${myCode}\n\nApp Store Link: ${myLink}"
        : "${myName} invites you to August!\n\nDownload August to auto-generate and share schedules with friends!\n\n${myName}'s code: ${myCode}\n\nPlay Store Link: ${myLink}";
  }
//${myName} invites you to August! Download August to share college schedules with friends!  ${myName}'s code: ${myCode}  App Store Link: ${myLink}

  Future<void> loadFriends() async {
    var fetchedFriends = await FriendInfos().fetchFriends();
    fetchedFriends
        .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    if (mounted) {
      setState(() {
        friends = fetchedFriends;
        isLoading = false;
      });
      Provider.of<FriendsProvider>(context, listen: false)
          .setFriendsCount(friends.length);
    }
    setState(() {
      isLoading = false;
    });

    //save length of frined lsit
    Provider.of<FriendsProvider>(context, listen: false)
        .setFriendsCount(friends.length);

    friendsPhotos = [];
    if (friends.length >= 3) {
      for (int i = 0; i < friends.length; i++) {
        friendsPhotos.add(friends[i].profileImage!);
      }
      friendsPhotos.sort((a, b) => a.compareTo(b));
    }
    //save friends photo
    Provider.of<FriendsProvider>(context, listen: false)
        .setFriendsPhoto(friendsPhotos);

    groupFriendsPhoto = [];
    if (friends.length >= 3) {
      for (int i = 0; i < 3; i++) {
        groupFriendsPhoto.add(friends[i].profileImage!);
      }
      groupFriendsPhoto.sort((a, b) => a.compareTo(b));
    }

    Provider.of<FriendsProvider>(context, listen: false)
        .setFriendsPhotosInMePage(groupFriendsPhoto);
  }

  @override
  void dispose() {
    _controller!.dispose();
    _jiggleController!.dispose();
    _refreshFriendsController!.dispose();
    super.dispose();
  }

  String convertDepartment(String department) {
    switch (department) {
      case 'FR':
        department = 'Freshman';
        break;
      case 'SO':
        department = 'Sophomore';
        break;
      case 'JR':
        department = 'Junior';
        break;
      case 'SR':
        department = 'Senior';
        break;
      case 'GR':
        department = 'Graduated';
        break;
      default:
        department = 'New?'; // 기본값 또는 오류 처리
    }
    return department;
  }

  void addFriend(String input) async {
    // Assuming VerifyFriendService is properly imported and initialized
    var response = await VerifyFriendService().acceptFriendRequest(input);

    if (myName == input) {
      ToastService.showToast(
        context,
        backgroundColor: Theme.of(context).colorScheme.background,
        shadowColor: Theme.of(context).colorScheme.shadow,
        leading: Icon(
          FeatherIcons.xCircle,
          color: Colors.redAccent,
        ),
        message: "Yo! You can't add yourself as a friend.",
      );
    } else if (!response.success) {
      ToastService.showToast(
        context,
        backgroundColor: Theme.of(context).colorScheme.background,
        shadowColor: Theme.of(context).colorScheme.shadow,
        leading: Icon(
          FeatherIcons.xCircle,
          color: Colors.redAccent,
        ),
        message: "This code is invalid or expired. Please try again.",
      );
    } else {
      ToastService.showToast(
        context,
        backgroundColor: Theme.of(context).colorScheme.background,
        shadowColor: Theme.of(context).colorScheme.shadow,
        leading: Icon(
          FeatherIcons.checkCircle,
          color: Colors.greenAccent,
        ),
        message: "You have successfully added a friend!",
      );
    }
  }

  Future<void> deleteFriends(int friendId) async {
    // Show a confirmation dialog to confirm deletion
    final bool? deleted = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            icon: Icon(
              FeatherIcons.trash2,
              color: Colors.redAccent,
              size: 30,
            ),
            title: Text(
              textAlign: TextAlign.center,
              'Delete Friend?',
              style: AugustFont.head5(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            content: Text(
              textAlign: TextAlign.center,
              'Are you sure you want to delete\nthis friend?',
              style: AugustFont.subText2(color: Colors.grey),
            ),
            actions: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
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
                            'Delete',
                            style: AugustFont.head8(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
                            'No, I want to keep him/her',
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
          ),
        );
      },
    );

    if (deleted!) {
      // Delete the friend from your database or API here
      await deleteFriend(friendId);
      // Fetch the updated list of friends
      friends = await FriendInfos().fetchFriends();

      // Rebuild the widget with the updated list of friends
      setState(() {});
    }
  }

  Widget refreshIcon() {
    return StackedPhoto(
      imagePaths: groupFriendsPhoto.isEmpty ? defaultPhoto : groupFriendsPhoto,
      isDeleteConfirm: groupFriendsPhoto.isEmpty ? false : true,
    );
  }

  Widget buildGridItem(int index, VoidCallback onRefresh) {
    if (index == 0) {
      return GestureDetector(
        onTap: () async {
          HapticFeedback.mediumImpact();
          final codeValue = await Navigator.push(
            context,
            CupertinoPageRoute(
              fullscreenDialog: true,
              builder: (context) => AddFriendsPage(
                onRefresh: onRefresh,
              ),
            ),
          );

          if (codeValue != null) {
            addFriend(codeValue);
          }
          await checkAccessToken();
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow,
                blurRadius: 10,
                offset: const Offset(6, 4),
              ),
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow,
                blurRadius: 10,
                offset: const Offset(-2, 0),
              ),
            ],
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FeatherIcons.plus,
                size: 40,
              ),
              SizedBox(height: 10),
              Text(
                'Add Friend',
                style: AugustFont.head6(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (index == 1 && friends.length >= 2) {
      return GestureDetector(
        onTap: () {
          HapticFeedback.mediumImpact();
          showCupertinoModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent, // BottomSheet 배경을 투명하게 설정
            topRadius: Radius.circular(30),

            builder: (BuildContext context) {
              return Container(
                  height:
                      MediaQuery.of(context).size.height, // BottomSheet의 높이 조정
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .background, // BottomSheet의 배경색
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(100),
                      topRight: Radius.circular(100),
                    ),
                  ),
                  child: GroupHangouts(
                    friends: friends,
                  ));
            },
          );
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow,
                blurRadius: 10,
                offset: const Offset(6, 4),
              ),
              BoxShadow(
                color: Theme.of(context).colorScheme.shadow,
                blurRadius: 10,
                offset: const Offset(-2, 0),
              ),
            ],
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FeatherIcons.users,
                size: 40,
              ),
              SizedBox(height: 10),
              Text(
                'Group',
                style: AugustFont.head6(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else {
      var friendIndex = friends.length >= 2 ? index - 2 : index - 1;
      if (friendIndex >= 0 && friendIndex < friends.length) {
        return GestureDetector(
          // onTap에서 호출되는 부분
          onTap: () {
            HapticFeedback.mediumImpact();
            if (!isEdit) {
              showCupertinoModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent, // BottomSheet 배경을 투명하게 설정
                topRadius: Radius.circular(30),
                builder: (BuildContext context) {
                  return Container(
                    height: MediaQuery.of(context).size.height *
                        0.93, // BottomSheet의 높이 조정
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .background, // BottomSheet의 배경색
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(100),
                        topRight: Radius.circular(100),
                      ),
                    ),
                    child: FriendSchedulePage(
                      photoUrl: friends[friendIndex].profileImage,
                      name: friends[friendIndex].name,
                      department:
                          friends[friendIndex].department ?? 'Undecided',
                      yearInSchool:
                          convertDepartment(friends[friendIndex].yearInSchool),
                      friendId: friends[friendIndex].id,
                    ),
                  );
                },
              );
              refreshToken().then((_) {
                checkAccessToken();
              });
            } else {
              deleteFriends(friends[friendIndex].id).then((_) {
                Provider.of<FriendsProvider>(context, listen: false)
                    .setFriendsCount(friends.length);
                setState(() {
                  isEdit = false;
                });
              });
            }
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(0), // 내부 여백 추가
            decoration: BoxDecoration(
              color: isEdit
                  ? Colors.redAccent
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
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
            child: (!isEdit)
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ProfileWidget(
                            isBottomBar: false,
                            isFriendsPage: true,
                            friendPhoto: friends[friendIndex].profileImage!),
                        SizedBox(height: 5),
                        Text(
                          friends[friendIndex].name,
                          style: AugustFont.head6(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              friends[friendIndex].department ?? 'Undecided',
                              style: AugustFont.captionBold(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              '|',
                              style: AugustFont.captionSmall(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              friends[friendIndex].institution!.nickname,
                              style: AugustFont.captionBold(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              '|',
                              style: AugustFont.captionSmall(
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text(
                              friends[friendIndex].yearInSchool,
                              style: AugustFont.captionBold(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                              backgroundColor: Colors.transparent,
                              maxRadius: 50,
                              child: JiggleTrashIcon()),
                        ),
                        Text(
                          friends[friendIndex].name,
                          style: AugustFont.head6(
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
          ),
        );
      } else {
        return SizedBox();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    RefreshController _refreshController =
        RefreshController(initialRefresh: false);

    void _onRefresh() async {
      try {
        HapticFeedback.mediumImpact();
        await loadFriends();
        _refreshController.refreshCompleted();
        print('Refreshed');
      } catch (error) {
        _refreshController.refreshFailed();
        print("Error during refresh: $error");
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ColorfulSafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          friends.length.toString() + ' Friends',
                          style: AugustFont.head1(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                        Text(
                          'Are you an extrovert?',
                          style: AugustFont.subText(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: GestureDetector(
                      onTap: () async {
                        HapticFeedback.mediumImpact();
                        var result = await Navigator.push(
                          context,
                          PageRouteBuilder(
                            opaque: false,
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    InvitationCodePage(),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return FadeTransition(
                                opacity: animation,
                                child: child,
                              );
                            },
                            transitionDuration: Duration(milliseconds: 200),
                          ),
                        );

                        if (result != null) {
                          _ownInvitationCode = result;
                          print("Received invitation code: $result");
                          // You can use the `result` here to perform further operations
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: Center(
                          child: Text(
                            'My Code',
                            style: AugustFont.head4(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (friends.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 20, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Spacer(),
                      // Padding(
                      //   padding: const EdgeInsets.only(
                      //     top: 10,
                      //     right: 10,
                      //   ),
                      //   child: Text(
                      //     'Your Main Schedule will be shared',
                      //     style: AugustFont.captionSmallBold(
                      //       color: Colors.grey,
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              toggleisEdit(friends.length);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                height: 30,
                                width: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: isEdit
                                      ? Colors.blueAccent
                                      : Theme.of(context).colorScheme.primary,
                                ),
                                child: Center(
                                  child: Text(
                                    isEdit ? 'Done' : 'Edit',
                                    style: AugustFont.subText(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () async {
                              HapticFeedback.mediumImpact();
                              Contact? contact =
                                  await _contactPicker.selectContact();
                              setState(() {
                                _contacts = contact == null ? null : [contact];
                              });
                              if (_contacts != null) {
                                sendSMS(
                                    Platform.isIOS
                                        ? MessageInfo(myCode!,
                                            'https://augustapp.one/get')
                                        : MessageInfo(myCode!,
                                            'https://augustapp.one/get'),
                                    _contacts![0].phoneNumbers![0].toString());
                              }
                              // print(
                              //     'this is the phone number${_contacts![0].phoneNumbers![0].toString()}');
                              getInvitationCode();
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 5, right: 15),
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                child: Icon(
                                  FeatherIcons.share,
                                  color: Theme.of(context).colorScheme.outline,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              isLoading
                  ? Container()
                  : friends.isNotEmpty
                      ? Expanded(
                          child: SmartRefresher(
                            enablePullDown: true,
                            onRefresh: _onRefresh,
                            controller: _refreshController,
                            physics: BouncingScrollPhysics(),
                            header: ClassicHeader(
                              releaseIcon: refreshIcon(),
                              refreshingIcon: refreshIcon(),
                              completeIcon: refreshIcon(),
                              idleIcon: refreshIcon(),
                              failedIcon: refreshIcon(),
                              textStyle: AugustFont.subText(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: GridView.builder(
                              padding: EdgeInsets.all(10),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 10 / 9.5,
                              ),
                              itemCount: friends.length + 2,
                              itemBuilder: (context, index) {
                                return buildGridItem(index, _onRefresh);
                              },
                            ),
                          ),
                        )
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.7,
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Wanna Invite Friends?',
                                style: AugustFont.head2(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                              ),
                              SizedBox(height: 20),
                              GestureDetector(
                                onTap: () {
                                  HapticFeedback.mediumImpact();
                                  _onRefresh();
                                  checkAccessToken();
                                },
                                child: AnimationFriends(),
                              ),
                              SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    HapticFeedback.mediumImpact();
                                    final codeValue = await Navigator.push(
                                      context,
                                      CupertinoPageRoute(
                                        fullscreenDialog: true,
                                        builder: (context) => AddFriendsPage(
                                          onRefresh: _onRefresh,
                                        ),
                                      ),
                                    );

                                    if (codeValue != null) {
                                      addFriend(codeValue);
                                    }
                                    await checkAccessToken();
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric(
                                        vertical: 18, horizontal: 15),
                                    decoration: BoxDecoration(
                                      color: Colors.blueAccent,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Click here to Add Friends',
                                        style: AugustFont.head4(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}

// UpperCaseTextFormatter definition
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
