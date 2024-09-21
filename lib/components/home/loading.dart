// ignore_for_file: depend_on_referenced_packages, use_super_parameters, use_key_in_widget_constructors, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:skeleton_text/skeleton_text.dart';

class SkeletonContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Color? color;
  final BorderRadius borderRadius;

  const SkeletonContainer._({
    this.width,
    this.height,
    this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(0)),
    Key? key,
  }) : super(key: key);

  const SkeletonContainer.rounded({
    double? width,
    double? height,
    Color? color,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
  }) : this._(
          width: width,
          height: height,
          color: color,
          borderRadius: borderRadius,
        );

  const SkeletonContainer.circular({
    double? width,
    double? height,
    Color? color,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(80)),
  }) : this._(
          width: width,
          height: height,
          color: color,
          borderRadius: borderRadius,
        );

  const SkeletonContainer.schedule({
    double? width,
    double? height,
    Color? color,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
  }) : this._(
          width: width,
          height: height,
          color: color,
          borderRadius: borderRadius,
        );

  @override
  Widget build(BuildContext context) {
    return SkeletonAnimation(
      shimmerColor:
          color ?? Theme.of(context).colorScheme.tertiary, // Adjust this line
      borderRadius: borderRadius,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.tertiary,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

// search page for grouping
Widget GroupLoading1(BuildContext context) {
  return Stack(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Skelton(height: 100, width: MediaQuery.of(context).size.width),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonContainer.rounded(height: 20, width: 95),
                SizedBox(height: 5),
                SkeletonContainer.rounded(height: 20, width: 200),
                SizedBox(height: 5),
                SkeletonContainer.rounded(height: 20, width: 140),
              ],
            ),
            Spacer(),
            Padding(
              padding: EdgeInsets.only(right: 10, bottom: 10, top: 10),
              child: SkeletonContainer.rounded(
                height: 50,
                width: 50,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// search page for other
Widget GroupLoading2(BuildContext context) {
  return Stack(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
        child: Skelton(height: 120, width: MediaQuery.of(context).size.width),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonContainer.rounded(
                      color: Theme.of(context).colorScheme.tertiary,
                      height: 20,
                      width: 100),
                  const SizedBox(
                    height: 5,
                  ),
                  SkeletonContainer.rounded(
                      color: Theme.of(context).colorScheme.tertiary,
                      height: 20,
                      width: 200),
                  const SizedBox(
                    height: 5,
                  ),
                  SkeletonContainer.rounded(
                      color: Theme.of(context).colorScheme.tertiary,
                      height: 20,
                      width: 140),
                  const SizedBox(
                    height: 5,
                  ),
                  SkeletonContainer.rounded(
                      color: Theme.of(context).colorScheme.tertiary,
                      height: 20,
                      width: 170),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: SkeletonContainer.rounded(
                color: Theme.of(context).colorScheme.tertiary,
                height: 100,
                width: 100,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// loading for the timetable
Widget GroupLoading3(BuildContext context) {
  return Stack(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: SkeletonContainer.schedule(
            color: Theme.of(context).colorScheme.tertiary,
            height: 450,
            width: MediaQuery.of(context).size.width),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 25),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            Spacer(),
          ],
        ),
      ),
    ],
  );
}

Widget GroupLoading4(BuildContext context) {
  return Stack(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
        child: SkeletonContainer.rounded(
            color: Theme.of(context).colorScheme.tertiary,
            height: MediaQuery.of(context).size.height - 250,
            width: MediaQuery.of(context).size.width),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 30, horizontal: 25),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            Spacer(),
          ],
        ),
      ),
    ],
  );
}

Widget UnivLoading(BuildContext context) {
  return Stack(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Skelton(height: 70, width: MediaQuery.of(context).size.width),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.only(right: 10, bottom: 10),
              child: SkeletonContainer.circular(
                height: 50,
                width: 50,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonContainer.rounded(height: 20, width: 95),
                SizedBox(height: 5),
                SkeletonContainer.rounded(height: 20, width: 200),
                SizedBox(height: 10),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    ],
  );
}

Widget MajorLoading(BuildContext context) {
  return Stack(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Skelton(height: 70, width: MediaQuery.of(context).size.width),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 2),
            SkeletonContainer.rounded(height: 20, width: 95),
            SizedBox(height: 5),
            SkeletonContainer.rounded(height: 20, width: 200),
          ],
        ),
      ),
    ],
  );
}

class Skelton extends StatelessWidget {
  const Skelton({
    super.key,
    this.height,
    this.width,
  });
  final double? height, width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(
        bottom: 15.0,
      ),
    );
  }
}
