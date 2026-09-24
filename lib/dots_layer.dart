import 'package:facetest/config/face_capture_config.dart';
import 'package:facetest/constants/app_images.dart';
import 'package:facetest/constants/color_pallet.dart';
import 'package:facetest/controller/face_capture_cubit.dart';
import 'package:facetest/controller_select.dart';
import 'package:facetest/global_widgets/app_text.dart';
import 'package:facetest/global_widgets/powered_by.dart';
import 'package:facetest/global_widgets/sound_activate.dart';
import 'package:flutter/material.dart';

class DotsLayer extends StatelessWidget {
  final FaceCaptureConfig config;
  final FaceCaptureController controller;

  const DotsLayer({super.key, required this.config, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: ControllerSelect<int>(
        controller: controller,
        selector: (state) => state.currentStepIndex,
        builder: (context, currentIndex) {
          final total = controller.stepsCount;
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(total, (i) {
                  final active = i == currentIndex;
                  final done = currentIndex >= i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active
                          ? config.primaryColor
                          : done
                          ? SuccessColors.s500
                          : config.primaryColor.withValues(alpha: 0.25),
                    ),
                  );
                }),
              ),
              SizedBox(height: 25),
              Row(
                spacing: 4,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AssetImages(imgPath: AppImages.lock, height: 16, width: 16),

                  AppText(
                    text: "Your information is secure and protected",
                    size: 12,
                    color: NeutralColors.n600,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
              SizedBox(height: 25),
              PoweredBy(),
            ],
          );
        },
      ),
    );
  }
}
