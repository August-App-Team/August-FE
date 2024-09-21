import 'package:august/components/firebase/firebase_analytics.dart';
import 'package:august/components/mepage/customize_icon_tile.dart';
import 'package:august/const/device/device_util.dart';
import 'package:august/const/font/font.dart';
import 'package:august/provider/appIcon_provider.dart';
import 'package:flutter/material.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class ChangeIconPage extends StatefulWidget {
  const ChangeIconPage({super.key});

  @override
  State<ChangeIconPage> createState() => _ChangeIconPageState();
}

class _ChangeIconPageState extends State<ChangeIconPage> {
  AppIcon? currentIcon = AppIcon.dark_prime;
  @override
  void initState() {
    FlutterDynamicIcon.getAlternateIconName().then((iconName) {
      setState(() {
        currentIcon = AppIcon.values.byName(iconName ?? 'dark_prime');
      });
    });
    super.initState();
  }

  void changeAppIcon(AppIcon icon) async {
    try {
      // Check if the device supports alternate icons
      if (await FlutterDynamicIcon.supportsAlternateIcons) {
        // Change the icon
        await FlutterDynamicIcon.setAlternateIconName(icon.name);
        Provider.of<AppIconProvider>(context, listen: false).iconName =
            icon.name;

        setState(() {
          currentIcon = icon; // Update the currentIcon value
        });
      }
    } on PlatformException catch (_) {
      print('Failed to change app icon');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      extendBody: true,
      body: ColorfulSafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Customize App Icon',
                      style: AugustFont.head1(
                          color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 10),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                      },
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
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
                  ),
                ],
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  "Change the August App icon on your home screen to match your style or mood.",
                  style: AugustFont.head4(color: Colors.grey),
                ),
              ),
              SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: AppIcon.values.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CustomIconTile(
                      iconAsset:
                          'assets/launch/${AppIcon.values[index].name}.png',
                      name: AppIcon.values[index].name,
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        AnalyticsService()
                            .changeIcon(AppIcon.values[index].name);
                        changeAppIcon(AppIcon.values[index]);
                      },
                      tileColor:
                          (currentIcon!.name == AppIcon.values[index].name)
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.primaryContainer,
                      isShadow:
                          (currentIcon!.name == AppIcon.values[index].name),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget launchIcon(String name) {
    String iconAsset = 'assets/launch/$name.png';
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20), // 원하는 반경 값으로 설정
          child: Image.asset(
            iconAsset,
            width: 90,
            height: 90,
          ),
        ),
        SizedBox(width: 20),
        Text(
          convertIconName(name),
          style: AugustFont.head2(color: Theme.of(context).colorScheme.outline),
        ),
        SizedBox(width: 10),
        if (currentIcon!.name == name)
          const Icon(
            Icons.check,
            color: Colors.green,
          ),
      ],
    );
  }
}
