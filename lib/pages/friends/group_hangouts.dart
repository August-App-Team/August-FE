import 'package:august/components/ad/ad_list.dart';
import 'package:august/components/home/loading.dart';
import 'package:august/components/profile/profile.dart';
import 'package:august/components/timetable/timetable.dart';
import 'package:august/const/colors/modify_color.dart';
import 'package:august/const/colors/tile_color.dart';
import 'package:august/const/font/font.dart';
import 'package:august/get_api/friends/get_friends.dart';
import 'package:august/get_api/friends/group_hangouts.dart';
import 'package:august/get_api/onboard/get_semester.dart';
import 'package:august/get_api/timetable/schedule.dart';
import 'package:august/login/login.dart';
import 'package:august/provider/admin_provider.dart';
import 'package:august/provider/semester_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import 'package:flutter_bouncing_widgets/custom_bounce_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GroupHangouts extends StatefulWidget {
  final List<FriendInfo> friends;

  const GroupHangouts({
    Key? key,
    required this.friends,
  }) : super(key: key);

  @override
  State<GroupHangouts> createState() => _GroupHangoutsState();
}

class _GroupHangoutsState extends State<GroupHangouts>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

  bool isLoading = false;
  List<int> selectedFriends = [];
  List<bool>? clickedStates;
  String? currentSemester;
  bool _showBottomNavBar = false;

  /* --- for the entire semesters */
  List<String> semesterList = [];

  List<ScheduleList> chillLists = [];

  @override
  void initState() {
    super.initState();

    // selectedSemester = friendSemList!.last;
    // selectedSemester = widget.semesterList!.last;
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _animationController!.forward();

    checkAndLoad();

    Future.delayed(Duration(milliseconds: 800), () {
      setState(() {
        _showBottomNavBar = true;
      });
    });

    // initialize friends click
    clickedStates = List<bool>.filled(widget.friends.length, false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    semesterList = Provider.of<SemesterProvider>(context).semestersList;
    checkCurrentSemester();
  }

  void checkCurrentSemester() {
    final DateTime now = DateTime.now();
    final String currentYearMonth =
        '${now.year}${now.month.toString().padLeft(2, '0')}';

    if (semesterList.isNotEmpty &&
        semesterList.last.compareTo(currentYearMonth) > 0) {
      print('semesterList.last: ${semesterList.last}');
      print('currentYearMonth: $currentYearMonth');
      print('currentSemester: $currentSemester');
      currentSemester = semesterList[semesterList.length - 3];
    } else {
      currentSemester = semesterList.last;
    }
  }

  void _selectHangoutSemester(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      sheetAnimationStyle: AnimationStyle(
        curve: Curves.fastEaseInToSlowEaseOut,
        duration: Duration(milliseconds: 350),
        reverseCurve: Curves.fastEaseInToSlowEaseOut,
        reverseDuration: Duration(milliseconds: 400),
      ),
      context: context,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(40)),
          child: Container(
            margin: EdgeInsets.only(bottom: 20),
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width - 20,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.all(Radius.circular(40)),
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 30, right: 20, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Text(
                          "Select Semester",
                          style: AugustFont.head1(
                              color: Theme.of(context).colorScheme.outline),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.pop(context);
                        },
                        child: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.background,
                          child: Center(
                            child: Icon(
                              FeatherIcons.x,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 10),
                      shrinkWrap: true,
                      itemCount: semesterList.length,
                      itemBuilder: (context, index) {
                        List<int> semesterListInt =
                            semesterList.map((e) => int.parse(e)).toList();
                        int semester = semesterListInt[index];
                        String semesterString = semester.toString();

                        String formattedSemester =
                            formatSemester(semester.toString());
                        bool isSelected = currentSemester ==
                            semester
                                .toString(); // Check if it's the selected semester

                        return ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                formattedSemester,
                                style: AugustFont.head6(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.outline
                                      : makeDarker(
                                          Theme.of(context).colorScheme.outline,
                                          0.3),
                                ),
                              ),
                            ],
                          ),
                          trailing: isSelected
                              ? const Icon(FeatherIcons.check,
                                  color: Colors.green)
                              : null,
                          onTap: () {
                            if (semesterString != currentSemester) {
                              setState(() {
                                currentSemester = semesterString;

                                // Reset the friend list
                                selectedFriends.clear();
                                clickedStates = List<bool>.filled(
                                    widget.friends.length, false);
                              });
                            }
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void checkAndLoad() async {
    // Perform an asynchronous check for an access token and then load data accordingly
    await checkAccessToken();
    print('token refreshed');
  }

  Future<void> _loadGroupHangout() async {
    int semesterInt = int.parse(currentSemester!);
    await checkAccessToken();
    if (mounted) {
      setState(() {
        isLoading = true; // Start loading
      });
      if (selectedFriends != null) {
        try {
          ScheduleList hangoutList = await GroupHangoutRequest()
              .fetchGroupHangout(selectedFriends, semesterInt);
          setState(() {
            chillLists.clear();
            chillLists.add(hangoutList);
            isLoading = false;
          });
        } catch (e) {
          print("Failed to load semesters: $e");
        }
      }
    }
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  Widget _buildChild() {
    if (isLoading) {
      return Center(
        key: ValueKey('loading_${selectedFriends.length}'),
        child: GroupLoading4(context),
      );
    } else if (selectedFriends.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        key: ValueKey('empty'),
        children: [
          const Text(
            "Click friends you want to hang out with",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          Spacer(),
          Icon(
            FeatherIcons.xCircle,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 10),
          Center(
            child: Text(
              'No friends selected',
              style: AugustFont.head6(
                color: Colors.grey,
              ),
            ),
          ),
          SizedBox(height: 100),
          Spacer(),
        ],
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            SingleTimetable(
              key: ValueKey(
                  'timetable_${selectedFriends.hashCode}${selectedFriends.length}'),
              courses: chillLists,
              index: 0,
              forceFixedTimeRange: true,
              isFriend: true,
            ),
            SizedBox(height: 150),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Group Hangouts',
                            style: AugustFont.head1(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          Text(
                            '${selectedFriends.length} friends selected',
                            style: AugustFont.subText(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 165,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: widget.friends.length + 1,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(vertical: 10),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return CustomBounceWidget(
                          isScrollable: true,
                          duration: Duration(milliseconds: 100),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            _selectHangoutSemester(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 500),
                              width: 110,
                              height: 70,
                              decoration: BoxDecoration(
                                color: lightenColor(
                                    determineColor(
                                        formatSemester(currentSemester!)),
                                    0.02),
                                borderRadius: BorderRadius.circular(30),
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
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Add AnimatedSwitcher for CircleAvatar
                                    AnimatedSwitcher(
                                      duration: Duration(
                                          milliseconds:
                                              300), // Adjust fade duration
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50.0)),
                                          border: Border.all(
                                            color: darkenColor(
                                                determineColor(formatSemester(
                                                    currentSemester!)),
                                                0.3),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          key: ValueKey(formatSemester(
                                              currentSemester!)), // Unique key for the avatar
                                          backgroundColor: determineColor(
                                              formatSemester(currentSemester!)),

                                          maxRadius: 30,
                                          child: SvgPicture.asset(
                                            "assets/season/${extractSeason(formatSemester(currentSemester!))}.svg",
                                            width: 30,
                                            height: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    // Add AnimatedSwitcher for Text
                                    AnimatedSwitcher(
                                      duration: Duration(
                                          milliseconds:
                                              300), // Adjust fade duration
                                      child: Text(
                                        formatSemester(currentSemester!),
                                        key: ValueKey(formatSemester(
                                            currentSemester!)), // Unique key for the text
                                        style: extractSeason(formatSemester(
                                                    currentSemester!)) ==
                                                'summer'
                                            ? AugustFont.textField4(
                                                color: Colors.black)
                                            : AugustFont.textField3(
                                                color: Colors.black),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    Icon(
                                      Icons.keyboard_arrow_down,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      int friendIndex = index - 1;
                      bool isClicked = clickedStates![friendIndex];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: CustomBounceWidget(
                          isScrollable: true,
                          duration: Duration(milliseconds: 100),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            setState(() {
                              if (isLoading != true) {
                                isLoading = true;
                              }

                              clickedStates![friendIndex] =
                                  !clickedStates![friendIndex];
                              if (clickedStates![friendIndex]) {
                                selectedFriends
                                    .add(widget.friends[friendIndex].id);
                                print(selectedFriends);
                                print(widget.friends[friendIndex].name);
                              } else {
                                selectedFriends
                                    .remove(widget.friends[friendIndex].id);
                                print(selectedFriends);
                                print(widget.friends[friendIndex].name);
                              }

                              if (selectedFriends.isEmpty && isLoading) {
                                isLoading = false;
                              }
                            });

                            selectedFriends.isNotEmpty
                                ? _loadGroupHangout()
                                : null;
                          },
                          child: Container(
                            width: 110,
                            height: 70,
                            decoration: BoxDecoration(
                              color: isClicked
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: !isClicked
                                      ? Theme.of(context).colorScheme.shadow
                                      : Colors.transparent,
                                  blurRadius: !isClicked ? 10 : 0,
                                  offset:
                                      !isClicked ? Offset(6, 4) : Offset(0, 0),
                                ),
                                BoxShadow(
                                  color: !isClicked
                                      ? Theme.of(context).colorScheme.shadow
                                      : Colors.transparent,
                                  blurRadius: !isClicked ? 10 : 0,
                                  offset:
                                      !isClicked ? Offset(-2, 0) : Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ProfileWidget(
                                    isBottomBar: false,
                                    isFriendsPage: true,
                                    isGroupHangoutPage: true,
                                    friendPhoto: widget
                                        .friends[friendIndex].profileImage!,
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    widget.friends[friendIndex].name,
                                    style: AugustFont.textField(
                                      color:
                                          Theme.of(context).colorScheme.outline,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  AnimatedContainer(
                                    duration: Duration(milliseconds: 100),
                                    height: 30,
                                    width: 30,
                                    child: isClicked
                                        ? Icon(Icons.check_circle,
                                            size: 30, color: Color(0xFF7cd78c))
                                        : Icon(
                                            Icons.circle_outlined,
                                            size: 30,
                                            color: const Color(0xffE5E7EB),
                                          ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 5),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildChild(),
                  ),
                )
              ],
            ),
            Positioned(
              right: 20,
              top: 20,
              child: Builder(
                builder: (BuildContext innerContext) {
                  return Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Theme.of(innerContext).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        FeatherIcons.x,
                        color: Theme.of(innerContext).colorScheme.outline,
                        size: 25,
                      ),
                      onPressed: () {
                        setState(() {
                          selectedFriends.clear();
                        });

                        Navigator.pop(innerContext);
                      },
                      padding: EdgeInsets.all(5),
                    ),
                  );
                },
              ),
            ),
            if (!Provider.of<AdminProvider>(context, listen: false).isAdmin)
              Positioned(
                left: 0,
                right: 0,
                bottom:
                    _showBottomNavBar && selectedFriends.isNotEmpty ? 10 : 0,
                child: AnimatedSlide(
                  offset: _showBottomNavBar && selectedFriends.isNotEmpty
                      ? Offset(0, 0)
                      : Offset(0, 1),
                  duration: Duration(milliseconds: 500),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  child: _showBottomNavBar
                      ? googleAdMobContainer(isGroup: true)
                      : Container(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
