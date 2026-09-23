import 'package:facetest/constants/app_images.dart';
import 'package:facetest/constants/color_pallet.dart';
import 'package:facetest/global_widgets/app_text.dart';
import 'package:facetest/global_widgets/sound_activate.dart';
import 'package:flutter/material.dart';

class PoweredBy extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppText(
          text: "Powered by",
          size: 10,
          color: NeutralColors.n500,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(width: 8),
        AssetImages(imgPath: AppImages.logo, height: 12, width: 12),
        SizedBox(width: 4),

        AppText(
          text: "Green Tech Comm. & Networks Ltd",
          size: 10,
          color: NeutralColors.n500,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }
}
