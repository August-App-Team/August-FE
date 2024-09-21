// import 'dart:convert';
// import 'package:august/components/profile/contact_option.dart';
// import 'package:august/const/font/font.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:august/provider/courseprovider.dart';
// import 'package:august/login/login.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:typed_data';
// import 'package:contacts_service/contacts_service.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:colorful_safe_area/colorful_safe_area.dart';
// import 'package:image_cropper/image_cropper.dart';

// class NamePage extends StatefulWidget {
//   final bool onboard;
//   final VoidCallback onTap;
//   final Function(Uint8List?) onPhotoUpdated;
//   NamePage({
//     Key? key,
//     required this.onboard,
//     required this.onTap,
//     required this.onPhotoUpdated,
//   }) : super(key: key);

//   @override
//   _NamePageState createState() => _NamePageState();
// }

// class _NamePageState extends State<NamePage> {
//   TextEditingController _nameController = TextEditingController();
//   late Future<void> _loadUserFuture;

//   @override
//   void dispose() {
//     _nameController.dispose();

//     super.dispose();
//   }

//   @override
//   void initState() {
//     super.initState();

//     _loadUserFuture = _loadInfo();
//   }

//   final ImagePicker _picker = ImagePicker();
//   Uint8List? contactPhoto; // Variable to store the contact's photo
//   File? _image;

//   Future getImage() async {
//     // 사용자가 갤러리에서 이미지를 선택합니다.
//     final pickedFile = await ImagePicker()
//         .pickImage(source: ImageSource.gallery, imageQuality: 20);

//     if (pickedFile != null) {
//       // 선택된 이미지를 크롭합니다.
//       CroppedFile? croppedFile = await ImageCropper().cropImage(
//         sourcePath: pickedFile.path,
//         uiSettings: [
//           AndroidUiSettings(
//             toolbarTitle: 'Cropper',
//             toolbarColor: Colors.deepOrange,
//             toolbarWidgetColor: Colors.white,
//             initAspectRatio: CropAspectRatioPreset.square,
//             lockAspectRatio: false,
//             aspectRatioPresets: [
//               CropAspectRatioPreset.original,
//               CropAspectRatioPreset.square,
//               CropAspectRatioPreset.ratio4x3,
//             ],
//           ),
//           IOSUiSettings(
//             title: 'Cropper',
//             aspectRatioPresets: [
//               CropAspectRatioPreset.original,
//               CropAspectRatioPreset.square,
//               CropAspectRatioPreset.ratio4x3,
//             ],
//           ),
//         ],
//       );

//       if (croppedFile != null) {
//         final imageTemporary = File(croppedFile.path);
//         // 파일 크기를 바이트 단위로 얻습니다.
//         int fileSizeBytes = await imageTemporary.length();
//         // 바이트 단위의 파일 크기를 메가바이트 단위로 변환합니다.
//         double fileSizeMb = fileSizeBytes / (1024 * 1024);

//         // 콘솔에 이미지 파일의 크기를 프린트합니다.
//         print('Cropped image size: ${fileSizeMb.toStringAsFixed(2)} MB');
//         // Convert the File to a Uint8List
//         Uint8List imageBytes = await imageTemporary.readAsBytes();
//         setState(() {
//           this._image =
//               imageTemporary; // If you still need to use the File somewhere
//           this.contactPhoto =
//               imageBytes; // Update contactPhoto with the new image
//           widget.onPhotoUpdated(
//               contactPhoto); // Notify the parent widget of the update
//         });
//       }
//     }
//   }

//   Future<void> _pickContact() async {
//     try {
//       Contact? contact = await ContactsService.openDeviceContactPicker();
//       if (contact != null) {
//         // Concatenate givenName and familyName to get the full name
//         String fullName = '';
//         if (contact.givenName != null) {
//           fullName += contact.givenName!;
//         }
//         if (contact.familyName != null) {
//           // Add a space before the family name if the given name is not null
//           if (fullName.isNotEmpty) {
//             fullName += ' ';
//           }
//           fullName += contact.familyName!;
//         }

//         setState(() {
//           setState(() {
//             contactPhoto = contact.avatar;
//             widget.onPhotoUpdated(contactPhoto); // Add this
//           });

//           _nameController.text = fullName; // Set the contact's full name
//         });

//         // Debugging: Check if the photo was fetched
//         if (contactPhoto != null) {
//           print("Contact photo fetched successfully.");
//         } else {
//           print("No photo available for this contact.");
//         }
//       }
//     } catch (e) {
//       // Handle any errors here and print them for debugging
//       print("Error picking contact: $e");
//     }
//   }

//   Future<void> _loadInfo() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     // Load name
//     setState(() {
//       _nameController.text = (prefs.getString('name') ?? '');
//     });

//     // Load image
//     String? base64Image = prefs.getString('contactPhoto');

//     if (base64Image != null) {
//       setState(() {
//         contactPhoto = base64Decode(base64Image);
//       });
//     }
//   }

//   Future<void> _saveInfo() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('name', _nameController.text);

//     // Remove the existing image from SharedPreferences
//     await prefs.remove('contactPhoto');

//     // If a new image has been selected, save it
//     if (contactPhoto != null) {
//       String base64Image = base64Encode(contactPhoto!);
//       await prefs.setString('contactPhoto', base64Image);
//     }
//   }

//   void _saveAndClose() async {
//     checkAccessToken();
//     // 사용자 정보 업데이트 작업을 시작하지만 완료를 기다리지 않음
//     await _saveInfo(); // 비동기로 저장 작업 시작

//     String base64Image = '';
//     if (contactPhoto != null) {
//       base64Image = base64Encode(contactPhoto!);
//     }

//     Map<String, dynamic> userInfo = {
//       'name': _nameController.text,
//       'photo': base64Image,
//     };
//     // 업데이트 작업을 기다리지 않고 바로 화면 전환
//     widget.onboard ? null : Navigator.pop(context, userInfo);

//     Provider.of<ProfilePhotoNotifier>(context, listen: false)
//         .updatePhoto(contactPhoto);
//     // Once the save process is complete, notify the parent widget.
//     widget.onPhotoUpdated(contactPhoto);
//     int? userPk = await fetchUserPk(); // 사용자 PK 가져오기는 여전히 기다림

//     if (userPk != null) {
//       if (_nameController.text.isNotEmpty) {
//         updateName(userPk, _nameController.text); // 비동기로 이름 업데이트 시작
//       }

//       if (contactPhoto != null) {
//         // 프로필 사진이 변경된 경우 업데이트
//         final tempDir = await getTemporaryDirectory();
//         final file = File('${tempDir.path}/profile_image.png');
//         await file.writeAsBytes(contactPhoto!);
//         updatePhoto(userPk, file); // 비동기로 사진 업데이트 시작
//       } else {
//         final file = File('assets/icons/memoji.png');
//         await file.writeAsBytes(contactPhoto!);
//         updatePhoto(userPk, file);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var selectedCoursesData = Provider.of<CoursesProvider>(context);
//     return FutureBuilder<void>(
//       future: _loadUserFuture, // This should be your future that fetches data
//       builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
//         // Check the state of the future
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           // If the Future is still running, show a loading indicator
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           // If we run into an error, display it to the user
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else {
//           var selectedCoursesData = Provider.of<CoursesProvider>(context);
//           return Scaffold(
//             body: ColorfulSafeArea(
//               child: SingleChildScrollView(
//                 physics: NeverScrollableScrollPhysics(),
//                 reverse: true,
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).colorScheme.background,
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Row(
//                         children: [
//                           Spacer(),
//                           if (widget.onboard == false) SizedBox(height: 50),
//                         ],
//                       ),
//                       if (widget.onboard == true) SizedBox(height: 50),
//                       Text(
//                         widget.onboard ? "Who Are You?" : "Change Your Profile",
//                         style: AugustFont.head3(
//                             color: Theme.of(context).colorScheme.outline),
//                       ),
//                       SizedBox(height: 30),
//                       Text(
//                         widget.onboard
//                             ? "Set name and profile\nthat will be shown to others."
//                             : "Change name and profile\nthat will be shown to others.",
//                         textAlign: TextAlign.center,
//                         style: AugustFont.head4(color: Colors.grey),
//                       ),
//                       SizedBox(height: 40),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             SizedBox(
//                               width: 200,
//                               height: 200,
//                               child: CircleAvatar(
//                                 backgroundColor: Colors.grey,
//                                 foregroundColor:
//                                     Theme.of(context).colorScheme.background,
//                                 backgroundImage: contactPhoto != null
//                                     ? MemoryImage(contactPhoto!)
//                                     : null,
//                                 child: contactPhoto == null
//                                     ? Image.asset('assets/icons/memoji.png')
//                                     : null, // Only show the icon if contactPhoto is null
//                               ),
//                             ),
//                             Positioned(
//                               right: 10,
//                               bottom: 0,
//                               child: ContactButton(
//                                 getMemoji: () {
//                                   _pickContact();
//                                   HapticFeedback.mediumImpact();
//                                 },
//                                 openPhoto: () {
//                                   getImage();
//                                   HapticFeedback.mediumImpact();
//                                 },
//                                 defaultImage: () async {
//                                   ByteData data = await rootBundle
//                                       .load('assets/icons/memoji.png');
//                                   Uint8List bytes = data.buffer.asUint8List();
//                                   setState(() {
//                                     contactPhoto = bytes;
//                                   });
//                                   _saveInfo();
//                                   HapticFeedback.mediumImpact();
//                                 },
//                               ),
//                               // child: CustomPopup(
//                               //   showArrow: false,
//                               //   contentPadding: EdgeInsets.symmetric(
//                               //       horizontal: 30, vertical: 10),
//                               //   arrowColor: Theme.of(context)
//                               //       .colorScheme
//                               //       .primaryContainer,
//                               //   backgroundColor: Theme.of(context)
//                               //       .colorScheme
//                               //       .primaryContainer,
//                               //   content: Column(
//                               //     mainAxisSize: MainAxisSize.min,
//                               //     crossAxisAlignment: CrossAxisAlignment.start,
//                               //     children: <Widget>[
//                               //       GestureDetector(
//                               //         onTap: _pickContact,
//                               //         child: Text(
//                               //           'Get Memoji from Contacts',
//                               //           style: TextStyle(
//                               //             fontWeight: FontWeight.bold,
//                               //             color: Theme.of(context)
//                               //                 .colorScheme
//                               //                 .outline,
//                               //           ),
//                               //         ),
//                               //       ),
//                               //       SizedBox(height: 5),
//                               //       GestureDetector(
//                               //         child: Text(
//                               //           'Open Photo App',
//                               //           style: TextStyle(
//                               //             fontWeight: FontWeight.bold,
//                               //             color: Theme.of(context)
//                               //                 .colorScheme
//                               //                 .outline,
//                               //           ),
//                               //         ),
//                               //         onTap: getImage,
//                               //       ),
//                               //       SizedBox(height: 5),
//                               //       GestureDetector(
//                               //         child: Text(
//                               //           'Use Default Image',
//                               //           style: TextStyle(
//                               //             fontWeight: FontWeight.bold,
//                               //             color: Theme.of(context)
//                               //                 .colorScheme
//                               //                 .outline,
//                               //           ),
//                               //         ),
//                               //         onTap: () async {
//                               //           ByteData data = await rootBundle
//                               //               .load('assets/icons/memoji.png');
//                               //           Uint8List bytes =
//                               //               data.buffer.asUint8List();
//                               //           setState(() {
//                               //             contactPhoto = bytes;
//                               //           });
//                               //           _saveInfo();
//                               //         },
//                               //       ),
//                               //     ],
//                               //   ),
//                               //   child: Container(
//                               //     height: 50,
//                               //     width: 50,
//                               //     decoration: BoxDecoration(
//                               //       color: Theme.of(context)
//                               //           .colorScheme
//                               //           .background,
//                               //       shape: BoxShape.circle,
//                               //       border: Border.all(
//                               //         color:
//                               //             Theme.of(context).colorScheme.outline,
//                               //         width: 2.0,
//                               //       ),
//                               //     ),
//                               //     child: Icon(
//                               //       Icons.add,
//                               //       color:
//                               //           Theme.of(context).colorScheme.outline,
//                               //       size: 40,
//                               //     ),
//                               //   ),
//                               // ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 40),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 30),
//                         child: CupertinoTextField(
//                           textAlign: TextAlign.center,
//                           controller: _nameController,
//                           padding: EdgeInsets.all(10),
//                           placeholder: "Enter Your Name",
//                           placeholderStyle: AugustFont.profileName(
//                             color: Theme.of(context).colorScheme.inversePrimary,
//                           ),
//                           style: AugustFont.profileName(
//                             color: Theme.of(context).colorScheme.outline,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.transparent,
//                             borderRadius: BorderRadius.circular(15),
//                           ),
//                           cursorColor: Theme.of(context).colorScheme.outline,
//                           cursorHeight: 40,
//                           onChanged: (text) {
//                             setState(() {}); // 텍스트 필드의 내용이 변경될 때마다 UI 업데이트
//                           },
//                           maxLength: 12,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//             bottomNavigationBar: Padding(
//               padding: const EdgeInsets.only(
//                 left: 15,
//                 right: 15,
//                 bottom: 60,
//               ),
//               child: widget.onboard
//                   ? GestureDetector(
//                       onTap: () {
//                         FocusScope.of(context).unfocus();
//                         Future.delayed(Duration(milliseconds: 200), () {
//                           widget.onTap();
//                           _saveAndClose();
//                         });
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 20),
//                         height: 60,
//                         width: MediaQuery.of(context).size.width - 80,
//                         decoration: BoxDecoration(
//                             color: Colors.blueAccent,
//                             borderRadius: BorderRadius.circular(20)),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'NEXT',
//                               style: AugustFont.head2(color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     )
//                   : GestureDetector(
//                       onTap: () {
//                         _saveAndClose();
//                         HapticFeedback.mediumImpact();
//                       },
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 30),
//                         height: 55,
//                         width: MediaQuery.of(context).size.width - 80,
//                         decoration: BoxDecoration(
//                             color: Colors.blueAccent,
//                             borderRadius: BorderRadius.circular(60)),
//                         child: Row(
//                           crossAxisAlignment: CrossAxisAlignment.center,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text(
//                               'DONE',
//                               style: AugustFont.head2(color: Colors.white),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//             ),
//           );
//         }
//       },
//     );
//   }
// }

// class ProfilePhotoNotifier extends ChangeNotifier {
//   Uint8List? _photo;

//   Uint8List? get photo => _photo;

//   void updatePhoto(Uint8List? newPhoto) {
//     _photo = newPhoto;
//     notifyListeners();
//   }
// }
