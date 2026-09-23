import 'package:facetest/constants/app_images.dart';
import 'package:facetest/constants/color_pallet.dart';
import 'package:facetest/face_capture_screen.dart';
import 'package:facetest/face_pose.dart';
import 'package:facetest/global_widgets/app_button.dart';
import 'package:facetest/global_widgets/app_text.dart';
import 'package:facetest/global_widgets/powered_by.dart';
import 'package:facetest/global_widgets/sound_activate.dart';
import 'package:facetest/global_widgets/top_bar.dart';
import 'package:flutter/material.dart';

class SdkWelcomePage extends StatelessWidget {
  const SdkWelcomePage({super.key, this.onSuccess, this.onCancel});
  final void Function(List<CapturedFaceImage> images)? onSuccess;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 26),
              TopBar(showSound: false),

              SizedBox(height: 42),

              AppText(
                text: "Verify Your Identity",
                fontWeight: FontWeight.w500,
                size: 16,
                color: NeutralColors.n800,
              ),
              SizedBox(height: 8),
              AppText(
                textAlign: TextAlign.center,
                maxline: 5,
                text: "We’ll take you through a few quick steps to verify your identity. Make sure your face is clearly visible and follow the instructions on screen.",
                fontWeight: FontWeight.w400,
                size: 14,
                color: NeutralColors.n800,
              ),
              SizedBox(height: 20),
              AssetImages(
                imgPath: AppImages.sdkWelcome,
                height: 300,
                width: 300,
              ),
              SizedBox(height: 25),

              Container(
                decoration: BoxDecoration(
                  color: InfoColors.i50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          AssetImages(
                            imgPath: AppImages.bulb,
                            height: 20,
                            width: 20,
                          ),
                          SizedBox(width: 4),
                          AppText(
                            text: "Tips before you start",
                            size: 14,
                            color: InfoColors.i600,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1, color: InfoColors.i100),
                    SizedBox(height: 8),
                    Tips(value: "Find a well-lit area"),
                    Tips(value: "Keep your face inside the frame"),
                    Tips(value: "Remove anything covering your face"),
                    Tips(value: "Look directly at the camera when prompted"),
                  ],
                ),
              ),
              SizedBox(height: 24),
              AppButton(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FaceCaptureScreen(
                        onSuccess: onSuccess,
                        onCancel: onCancel,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24),

              PoweredBy(),
            ],
          ),
        ),
      ),
    );
  }
}
