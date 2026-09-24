import 'package:facetest/constants/app_images.dart';
import 'package:facetest/constants/color_pallet.dart';
import 'package:facetest/global_widgets/app_button.dart';
import 'package:facetest/global_widgets/app_text.dart';
import 'package:facetest/global_widgets/sound_activate.dart';
import 'package:flutter/material.dart';

class ErrorAlert extends StatelessWidget {
  const ErrorAlert({super.key, this.icon, this.title, this.subTitile});
  final String? icon;
  final String? title;
  final String? subTitile;
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
            Stack(
              children: [
                Container(
                  height: 144,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ErrorColors.e500,
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
                          imgPath: icon ?? AppImages.info,
                          height: 47,
                          width: 47,
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: Center(
                        child: Icon(Icons.close, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            AppText(
              text: title ?? "Are you sure?",
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
                text: title ?? "Your progress won’t be saved if you leave. You’ll need to start the verification again.",
                color: NeutralColors.n600,
                size: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 24),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),

              child: Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: AppButton(
                      width: 147,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.maybePop(context);
                      },
                      backgroundColor: ErrorColors.e500,
                      child: AppText(
                        text: "Leave",
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        size: 16,
                      ),
                    ),
                  ),
                  // Spacer(),
                  Expanded(
                    child: AppButton(
                      border: Border.all(color: PrimaryColors.p800),
                      width: 147,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      backgroundColor: Colors.white,

                      child: AppText(
                        text: "Stay",
                        color: PrimaryColors.p500,
                        fontWeight: FontWeight.w600,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            //  Container(
            //     margin: EdgeInsets.symmetric(horizontal: 10),
            //     child: AppButton(
            //       onTap: () {},
            //       backgroundColor: PrimaryColors.p800,
            //       child: AppText(
            //         text: "Continue",
            //         color: Colors.white,
            //         fontWeight: FontWeight.w600,
            //         size: 16,
            //       ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
