import 'package:facetest/constants/app_images.dart';
import 'package:facetest/constants/color_pallet.dart';
import 'package:facetest/global_widgets/app_button.dart';
import 'package:facetest/global_widgets/app_text.dart';
import 'package:facetest/global_widgets/sound_activate.dart';
import 'package:flutter/material.dart';

class SuccessAlert extends StatelessWidget {
  const SuccessAlert({super.key, this.icon, this.title, this.subTitle});
  final String? icon;
  final String? title;
  final String? subTitle;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        height: 325,
        width: 358,
        // constraints: BoxConstraints(maxWidth: 358, maxHeight: 325),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 144,
              width: double.infinity,
              decoration: BoxDecoration(
                color: SuccessColors.s500,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(16),
                  height: 104,
                  width: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(12),

                    height: 72,
                    width: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    child: AssetImages(
                      imgPath: icon ?? AppImages.check,
                      height: 47,
                      width: 47,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            AppText(
              text: title ?? "Verification Complete",
              color: NeutralColors.n800,
              size: 16,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 12),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              child: AppText(
                textAlign: TextAlign.center,
                maxline: 4,
                text: title ?? "Your identity has been successfully verified. You can now continue using your account.",
                color: NeutralColors.n600,
                size: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 24),

            Container(
              margin: EdgeInsets.symmetric(horizontal: 24),
              child: AppButton(
                onTap: () {},
                backgroundColor: PrimaryColors.p800,
                child: AppText(
                  text: "Continue",
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
