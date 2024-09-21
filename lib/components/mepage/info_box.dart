import 'package:august/components/mepage/stacked_photo.dart';
import 'package:august/const/font/font.dart';
import 'package:august/provider/friends_provider.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';

class InfoWidget extends StatefulWidget {
  final String info;
  final String? photo;
  final String subInfo;
  final VoidCallback onTap;
  final bool isSchool;
  final bool isFrirend;
  final bool isIcon;

  const InfoWidget({
    Key? key,
    required this.onTap,
    required this.isSchool,
    required this.info,
    required this.subInfo,
    required this.photo,
    required this.isFrirend,
    this.isIcon = false,
  }) : super(key: key);

  @override
  _InfoWidgetState createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> {
  List<String>? friendsPhoto;
  List<dynamic>? test;

  void initState() {
    super.initState();
    friendsPhoto = [];
    loadFriendsPhotos();
  }

  @override
  void didUpdateWidget(covariant InfoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    loadFriendsPhotos();
  }

  Future<void> loadFriendsPhotos() async {
    var provider = Provider.of<FriendsProvider>(context, listen: false);
    if (provider.friendsPhotosInMePage.isNotEmpty) {
      setState(() {
        friendsPhoto = provider.friendsPhotosInMePage.cast<String>();
        friendsPhoto?.sort((a, b) => a.compareTo(b));
      });
    }
  }

  List<String> defaultImages() {
    return [
      'assets/memoji/Memoji2.png',
      'assets/memoji/Memoji3.png',
      'assets/memoji/Memoji1.png',
    ];
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            blurRadius: 10, // 블러 효과를 줄여서 그림자를 더 세밀하게
            offset: Offset(4, -1), // 좌우 그림자의 길이를 줄임
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            blurRadius: 10,
            offset: Offset(-1, 0), // 좌우 그림자의 길이를 줄임
          ),
        ],
      ),
      width: 145,
      height: 145,
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.isFrirend
                ? StackedPhoto(
                    imagePaths: (friendsPhoto!.length == 0)
                        ? defaultImages()
                        : friendsPhoto!,
                    isDeleteConfirm: (friendsPhoto!.length == 0) ? false : true,
                  )
                : widget.isIcon
                    ? CircleAvatar(
                        maxRadius: 25,
                        child: Icon(Icons.grade),
                        backgroundColor: Colors.white,
                      )
                    : widget.photo == null
                        ? Container()
                        : widget.isSchool
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  width: 50,
                                  height: 50,
                                  imageUrl: widget.photo!,
                                  progressIndicatorBuilder:
                                      (context, url, downloadProgress) =>
                                          CircularProgressIndicator(
                                              value: downloadProgress.progress),
                                  errorWidget: (context, url, error) =>
                                      CircleAvatar(
                                    maxRadius: 25,
                                    backgroundColor: Colors.white,
                                  ),
                                ),
                              )
                            : ClipOval(
                                child: CircleAvatar(
                                  maxRadius: 25,
                                  child: Image.asset(widget.photo!,
                                      fit: BoxFit.cover, width: 50, height: 50),
                                  backgroundColor: Colors.red,
                                ),
                              ),
            SizedBox(
              height: 25,
            ),
            Row(
              children: [
                Text(
                  widget.info,
                  style: AugustFont.head2(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                widget.isSchool
                    ? Icon(Icons.keyboard_arrow_right)
                    : Container(),
              ],
            ),
            Text(
              widget.subInfo,
              style: widget.isSchool
                  ? AugustFont.captionBoldUniv(
                      color: Colors.grey,
                    )
                  : AugustFont.captionBold(
                      color: Colors.grey,
                    ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );

    // Conditional wrapping with GestureDetector
    return Column(
      children: [
        widget.isSchool
            ? GestureDetector(onTap: widget.onTap, child: content)
            : content,
      ],
    );
  }
}
