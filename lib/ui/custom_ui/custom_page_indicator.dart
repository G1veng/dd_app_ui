import 'package:flutter/material.dart';

class CustomPageIndicator extends StatelessWidget {
  final int count;
  final int? current;
  final double width;

  const CustomPageIndicator(
      {Key? key, required this.count, this.current = 0, this.width = 8})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> points = [];

    for (int i = 0; i < count; i++) {
      points.add(Icon(
        Icons.circle,
        size: i == (current ?? 0) ? width * 1.4 : width,
      ));
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: points,
    );
  }
}
