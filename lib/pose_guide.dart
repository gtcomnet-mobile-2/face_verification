import 'dart:async';

import 'package:facetest/constants/color_pallet.dart';
import 'package:facetest/global_widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PoseGuideGif extends StatefulWidget {
  final String assetPath;
  final String command;
  final String subtitle;
  final String number;

  const PoseGuideGif({
    super.key,
    required this.assetPath,
    required this.command,
    required this.subtitle,
    required this.number,
  });

  @override
  State<PoseGuideGif> createState() => _PoseGuideGifState();
}

class _PoseGuideGifState extends State<PoseGuideGif> {
  static const _packageName = 'facetest';
  static String? _package;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    unawaited(_resolvePackage());
  }

  Future<void> _resolvePackage() async {
    if (_package != null) {
      if (mounted) setState(() => _ready = true);
      return;
    }
    final assets = (await AssetManifest.loadFromAssetBundle(rootBundle))
        .listAssets();
    _package =
        assets.any((asset) => asset.startsWith('packages/$_packageName/'))
        ? _packageName
        : '';
    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(width: 100, height: 150);
    }
    return Column(
      children: [
        SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: PrimaryColors.p500,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: AppText(
                  text: widget.number,
                  color: Colors.white,
                  size: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 8),
            AppText(
              text: widget.command,
              color: NeutralColors.n800,
              size: 14,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        AppText(
          text: widget.subtitle,
          color: NeutralColors.n600,
          size: 14,
          fontWeight: FontWeight.w400,
        ),
        SizedBox(height: 16),
        Image.asset(
          widget.assetPath,
          width: 70,
          height: 70,
          package: _package!.isEmpty ? null : _package,
          gaplessPlayback: true,
          excludeFromSemantics: true,
          filterQuality: FilterQuality.low,
        ),
      ],
    );
  }
}
