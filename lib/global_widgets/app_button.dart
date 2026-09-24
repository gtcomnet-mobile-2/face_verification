import 'package:facetest/constants/color_pallet.dart';
import 'package:facetest/global_widgets/app_text.dart';
import 'package:flutter/material.dart';


class AppButton extends StatelessWidget {
  const AppButton({super.key, required this.onTap});
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: EdgeInsets.symmetric(vertical: 14.5, horizontal: 97),
        decoration: BoxDecoration(
          color: PrimaryColors.p800,
          borderRadius: BorderRadius.circular(24),
        ),
        child: AppText(
          text: "Start Verification",
          color: Colors.white,
          size: 16,
          fontWeight: FontWeight.w600,
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
