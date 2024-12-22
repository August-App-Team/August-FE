import 'package:august/components/profile/profile.dart';
import 'package:august/const/font/font.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bouncing_widgets/custom_bounce_widget.dart';
import "package:flutter_feather_icons/flutter_feather_icons.dart";

class MeTile extends StatefulWidget {
  final String title;
  final String name;
  final String email;
  final String semesterIcon;
  final String univPhoto;
  final Icon icons;
  final Color backgroundColor;
  final VoidCallback onTap;
  final bool isProfile;
  final bool isSemester;
  final bool isUniv;

  // 네임드 파라미터를 사용하고 onTap와 onTap을 nullable로 변경
  const MeTile({
    Key? key,
    this.title = '',
    this.name = '',
    this.email = '',
    this.semesterIcon = '',
    this.univPhoto = '',
    this.backgroundColor = Colors.white,
    this.icons = const Icon(Icons.abc),
    required this.onTap,
    this.isProfile = false,
    this.isSemester = false,
    this.isUniv = false,
  }) : super(key: key);

  @override
  _MeTileState createState() => _MeTileState();
}

class _MeTileState extends State<MeTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, bottom: 5),
      child: CustomBounceWidget(
        isScrollable: true,
        duration: Duration(milliseconds: 100),
        onPressed: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            height: widget.isProfile ? 80 : 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.isProfile
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: widget.isProfile
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.transparent),
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
            child: Row(
              children: [
                widget.isSemester ? SizedBox(width: 0) : SizedBox(width: 4),
                widget.isUniv ? SizedBox(width: 0) : SizedBox(width: 2),
                widget.isSemester
                    ? CircleAvatar(
                        backgroundColor: widget.backgroundColor,
                        maxRadius: 15,
                        child: SvgPicture.asset(
                          widget.semesterIcon,
                          width: 15,
                          height: 15,
                        ),
                      )
                    : widget.isUniv
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: widget.univPhoto,
                              progressIndicatorBuilder:
                                  (context, url, downloadProgress) =>
                                      CircularProgressIndicator(
                                          value: downloadProgress.progress),
                              errorWidget: (context, url, error) =>
                                  CircleAvatar(
                                maxRadius: 15,
                                backgroundColor: Colors.white,
                              ),
                            ),
                          )
                        : widget.isProfile
                            ? ProfileWidget(
                                isBottomBar: false,
                                isMePage: true,
                              )
                            : widget.icons,
                SizedBox(width: 10),
                Expanded(
                  child: widget.isProfile
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.name}',
                              style: AugustFont.head2(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1, // Ensure single-line truncation
                            ),
                            Text(
                              '${widget.email}',
                              style:
                                  AugustFont.captionNormal(color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        )
                      : Text(
                          '${widget.title}',
                          style: AugustFont.head6(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                ),
                Icon(Icons.keyboard_arrow_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LogoutTile extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  // 네임드 파라미터를 사용하고 onTap와 onTap을 nullable로 변경
  const LogoutTile({
    Key? key,
    this.title = '',
    required this.onTap,
  }) : super(key: key);

  @override
  _LogoutTileState createState() => _LogoutTileState();
}

class _LogoutTileState extends State<LogoutTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
        child: Container(
          color: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          height: 50,
          width: double.infinity,
          child: Row(
            children: [
              Icon(
                FeatherIcons.logOut,
                color: Colors.red,
              ),
              SizedBox(width: 10),
              Text(
                '${widget.title}',
                style: AugustFont.head6(
                  color: Colors.red,
                ),
              ),
              Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
