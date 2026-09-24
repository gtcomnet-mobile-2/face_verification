import 'package:facetest/constants/app_images.dart';
import 'package:facetest/controller/repo.dart';
import 'package:flutter/material.dart';

class SoundActivate extends StatefulWidget {
  const SoundActivate({super.key});

  @override
  State<SoundActivate> createState() => _SoundActivateState();
}

class _SoundActivateState extends State<SoundActivate> {
  @override
  Widget build(BuildContext context) {
    final isSound = Repo.isSoundOn;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(Repo.toggleSound);
      },
      child: Container(
        padding: EdgeInsets.all(12),
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 4),
              blurRadius: 12,
              spreadRadius: 0,
            ),
          ],
        ),
        child: AssetImages(
          imgPath: isSound ? AppImages.sound : AppImages.noSound,
        ),
      ),
    );
  }
}

class AssetImages extends StatelessWidget {
  const AssetImages({
    super.key,
    required this.imgPath,
    this.height,
    this.width,
  });

  final String imgPath;
  final int? height;
  final int? width;
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      package: 'facetest',
      imgPath,
      height: height?.toDouble(),
      width: width?.toDouble(),
    );
  }
}
