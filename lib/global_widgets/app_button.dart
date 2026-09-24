import 'package:facetest/constants/color_pallet.dart';
import 'package:facetest/global_widgets/app_text.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onTap,
    this.backgroundColor,
    this.border,
    this.child,
    this.width,
    this.height,
    this.padding,
  });
  final Function()? onTap;
  final Color? backgroundColor;
  final BoxBorder? border;
  final Widget? child;

  final num? width;
  final num? height;
  final EdgeInsets? padding;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height?.toDouble() ?? 48,
        width: width?.toDouble(),
        // padding: EdgeInsets.symmetric(vertical: 14.5, horizontal: 97),
        decoration: BoxDecoration(
          border: border,
          color: backgroundColor ?? PrimaryColors.p800,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child:
              child ??
              AppText(
                text: "Start Verification",
                color: Colors.white,
                size: 16,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
        ),
      ),
    );
  }
}

class Tips extends StatelessWidget {
  const Tips({super.key, required this.value});
  final String value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        children: [
          Container(
            height: 8,
            width: 8,
            decoration: BoxDecoration(
              color: InfoColors.i500,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          AppText(
            text: value,
            color: NeutralColors.n800,
            size: 12,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}
