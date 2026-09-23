import 'package:facetest/constants/color_pallet.dart';
import 'package:flutter/widgets.dart';

String messageUrl = '';

class AppText extends StatelessWidget {
  const AppText({
    super.key,
    required this.text,
    this.size = 18,
    this.color,
    this.fontWeight = FontWeight.w400,
    this.decoration,
    this.textAlign,
    this.maxline,
    this.letterSpacing = 0,
    this.height,
    this.minFontSize,
    this.wordSpacing,
  });
  final String text;
  final int size;
  final Color? color;
  final FontWeight fontWeight;
  final TextDecoration? decoration;
  final TextAlign? textAlign;
  final int? maxline;
  final double? letterSpacing, height, wordSpacing, minFontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      maxLines: maxline,
      softWrap: true,
      text,

      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
      style: TextStyle(
        wordSpacing: wordSpacing,
        decoration: decoration ?? TextDecoration.none,
        decorationColor: color,
        height: height,
        color: color ?? NeutralColors.n800,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        fontSize: size.toDouble(),
      ),
    );
  }
}
