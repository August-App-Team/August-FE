import 'dart:convert';
import 'package:august/components/profile/contact_option.dart';
import 'package:august/components/profile/profile.dart';
import 'package:august/const/font/font.dart';
import 'package:august/provider/user_info_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:august/provider/courseprovider.dart';
import 'package:august/login/login.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:image_cropper/image_cropper.dart';

class NamePage extends StatefulWidget {
  final bool onboard;
  final VoidCallback onTap;
  NamePage({
    Key? key,
    required this.onboard,
    required this.onTap,
  }) : super(key: key);

  @override
  _NamePageState createState() => _NamePageState();
}

class _NamePageState extends State<NamePage> {
  TextEditingController _nameController = TextEditingController();
  late Future<void> _loadUserFuture;
  String? imagePath; // Holds either a URL or a local path

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUserFuture = loadInfo();
  }

  Future<void> updateProfileImage(String imagePath) async {
    int? userPk = await fetchUserPk();
    if (userPk == null) {
      print("Failed to fetch userPk");
      return;
    }
    if (mounted) {
      Provider.of<UserInfoProvider>(context, listen: false)
          .updateUserProfileImage(imagePath);
    }

    File imageFile = File(imagePath);
    updatePhoto(userPk, imageFile).then((_) {
      print('Name updated successfully with $imagePath');
      _saveInfo();
    }).catchError((error) {
      print('Failed to update name: $error');
    });
  }

  Future<void> updateUserName(String name) async {
    int? userPk = await fetchUserPk();
    if (userPk == null) {
      print("Failed to fetch userPk");
      return;
    }
    if (mounted) {
      Provider.of<UserInfoProvider>(context, listen: false)
          .updateUserName(name);
    }

    updateName(userPk, name).then((_) {
      print('Name updated successfully with $name');
      _saveInfo();
    }).catchError((error) {
      print('Failed to update name: $error');
    });
  }

  Future<void> getImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      // Attempt to retrieve any lost data from previous attempts
      final LostDataResponse lostDataResponse = await picker.retrieveLostData();
      if (!lostDataResponse.isEmpty) {
        if (lostDataResponse.files != null) {
          _handleLostFiles(lostDataResponse.files);
        } else {
          print('No file picked');
        }
        return; // Return early if recovered data to handle it first
      }
    } catch (e) {
      // Handle the scenario where retrieveLostData is not implemented
      if (e is UnimplementedError) {
        print('retrieveLostData is not implemented on this platform.');
      } else {
        print('An unexpected error occurred: $e');
      }
    }
    // Proceed to pick a new image if no lost data
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );

    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Theme.of(context).colorScheme.background,
            toolbarWidgetColor: Theme.of(context).colorScheme.outline,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Cropper',
          ),
        ],
      );
      if (croppedFile != null) {
        if (!mounted) return;
        setState(() {
          imagePath = croppedFile.path;
        });
        updateProfileImage(imagePath!); // Update shared state
      }
    }
  }

// Handling lost files recovered from the previous session
  void _handleLostFiles(List<XFile>? files) {
    if (!mounted || files == null || files.isEmpty) return;
    setState(() {
      imagePath = files.first.path;
    });
    updateProfileImage(
        imagePath!); // Assuming this method updates the image in your app
  }

  Future<void> pickFromContact() async {
    try {
      Contact? contact = await ContactsService.openDeviceContactPicker();
      if (contact != null) {
        String fullName = '';
        if (contact.givenName != null) fullName += contact.givenName!;
        if (contact.familyName != null) {
          if (fullName.isNotEmpty) fullName += ' ';
          fullName += contact.familyName!;
        }

        Provider.of<UserInfoProvider>(context, listen: false)
            .updateUserName(fullName);
        if (!mounted) return;
        setState(() {
          _nameController.text = fullName;
        });
        updateUserName(fullName);

        if (contact.avatar != null && contact.avatar!.isNotEmpty) {
          final directory = await getApplicationDocumentsDirectory();
          String newPath =
              '${directory.path}/contact_image_${DateTime.now().millisecondsSinceEpoch}.png';
          File imgFile = File(newPath);
          await imgFile.writeAsBytes(contact.avatar!);
          if (!mounted) return;
          // Ensure imagePath is updated and UI is refreshed
          setState(() {
            imagePath = imgFile.path;
          });

          updateProfileImage(imagePath!);
          print('Contact image updated successfully');
        }
      }
    } catch (e) {
      print("Failed to pick contact: $e");
    }
  }

  Future<void> useDefaultImage() async {
    imagePath = await getUserDefaultPhoto();
    updateProfileImage(imagePath!);
  }

  Future<void> loadInfo() async {
    var infoProvider =
        Provider.of<UserInfoProvider>(context, listen: false).userInfo;
    _nameController.text = infoProvider!.name!;
    imagePath = infoProvider.profileImage;

    // setState(() {
    //   _nameController.text = infoProvider!.name;
    //   imagePath = infoProvider.profileImage;
    // });
  }

  Future<void> _saveInfo() async {
    if (!mounted) return;
    var infoProvider =
        Provider.of<UserInfoProvider>(context, listen: false).userInfo;
    infoProvider!.name = _nameController.text;
    infoProvider.profileImage = imagePath;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _loadUserFuture, // This should be your future that fetches data
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        // Check the state of the future
        if (snapshot.connectionState == ConnectionState.waiting) {
          // If the Future is still running, show a loading indicator
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // If we run into an error, display it to the user
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: ColorfulSafeArea(
              child: SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                reverse: true,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Spacer(),
                          if (widget.onboard == false) SizedBox(height: 50),
                        ],
                      ),
                      if (widget.onboard == true) SizedBox(height: 50),
                      Text(
                        widget.onboard ? "Who Are You?" : "Change Your Profile",
                        style: AugustFont.head3(
                            color: Theme.of(context).colorScheme.outline),
                      ),
                      SizedBox(height: 30),
                      Text(
                        widget.onboard
                            ? "Set name and profile\nthat will be shown to others."
                            : "Personalize your profile\nthat will be shown to others.",
                        textAlign: TextAlign.center,
                        style: AugustFont.head4(color: Colors.grey),
                      ),
                      SizedBox(height: 40),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ProfileWidget(
                            isBottomBar: false,
                            isProfilePage: true,
                          ),
                          Positioned(
                            right: 10,
                            bottom: 0,
                            child: ContactButton(
                              getMemoji: () {
                                pickFromContact();
                                HapticFeedback.mediumImpact();
                              },
                              openPhoto: () {
                                getImage();
                                HapticFeedback.mediumImpact();
                              },
                              defaultImage: () {
                                useDefaultImage();
                                HapticFeedback.mediumImpact();
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: CupertinoTextField(
                          textAlign: TextAlign.center,
                          controller: _nameController,
                          padding: EdgeInsets.all(10),
                          placeholder: "Enter Name",
                          placeholderStyle: AugustFont.profileName(
                            color: Theme.of(context).colorScheme.surfaceTint,
                          ),
                          style: AugustFont.profileName(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          cursorColor: Theme.of(context).colorScheme.outline,
                          cursorHeight: 40,
                          onChanged: (text) {
                            if (!mounted) return;
                            setState(() {}); // 텍스트 필드의 내용이 변경될 때마다 UI 업데이트
                          },
                          onSubmitted: (text) {
                            updateUserName(text);
                          },
                          maxLength: 16,
                        ),
                      ),
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
              child: widget.onboard
                  ? GestureDetector(
                      onTap: () {
                        if (_nameController.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                icon: Icon(
                                  FeatherIcons.alertTriangle,
                                  color: Colors.redAccent,
                                  size: 45,
                                ),
                                title: Text(
                                  'What is your name?',
                                  textAlign: TextAlign.center,
                                  style: AugustFont.head2(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                                content: Text(
                                  'You must enter your name to continue.',
                                  textAlign: TextAlign.center,
                                  style: AugustFont.subText2(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                                actions: <Widget>[
                                  GestureDetector(
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      HapticFeedback.lightImpact();
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      height: 55,
                                      width: MediaQuery.of(context).size.width -
                                          80,
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'OK',
                                            style: AugustFont.head4(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        } else {
                          FocusScope.of(context).unfocus();
                          updateUserName(_nameController.text);
                          Future.delayed(Duration(milliseconds: 200), () {
                            widget.onTap();
                          });
                        }
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
                              'NEXT',
                              style: AugustFont.head2(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        if (_nameController.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                icon: Icon(
                                  FeatherIcons.alertTriangle,
                                  color: Colors.redAccent,
                                  size: 45,
                                ),
                                title: Text(
                                  'What is your name?',
                                  textAlign: TextAlign.center,
                                  style: AugustFont.head2(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                                content: Text(
                                  'You must enter your name to continue.',
                                  textAlign: TextAlign.center,
                                  style: AugustFont.subText2(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline),
                                ),
                                actions: <Widget>[
                                  GestureDetector(
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      HapticFeedback.lightImpact();
                                    },
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 20),
                                      height: 55,
                                      width: MediaQuery.of(context).size.width -
                                          80,
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'OK',
                                            style: AugustFont.head4(
                                                color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        } else {
                          Navigator.pop(context);
                          updateUserName(_nameController.text);
                          HapticFeedback.mediumImpact();
                        }
                      },
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
      },
    );
  }
}
