import 'package:flutter/material.dart';

class RatingWidget extends StatelessWidget {
  final int rating;
  final bool isMobile;

  const RatingWidget({Key? key, required this.rating, required this.isMobile})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: isMobile ? 16 : 20,
        );
      }),
    );
  }
}
