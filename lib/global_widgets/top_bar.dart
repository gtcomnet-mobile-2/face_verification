import 'dart:developer';

import 'package:facetest/constants/color_pallet.dart';
import 'package:facetest/global_widgets/app_text.dart';
import 'package:facetest/global_widgets/sound_activate.dart';
import 'package:flutter/material.dart';

class TopBar extends StatefulWidget {
  const TopBar({
    super.key,
    required this.showSound,
    this.onClose,
  });

  final bool showSound;
  final VoidCallback? onClose;

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  bool isSoundOn = false;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      actionsPadding: EdgeInsets.only(),
      toolbarHeight: 72,
      title: AppText(
        text: "Face Verification",
        fontWeight: FontWeight.w600,
        size: 16,
      ),
      centerTitle: true,
      leading: widget.showSound ? SoundActivate() : null,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      actions: [
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
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
                ),
              ],
            ),
            child: Icon(Icons.close, color: ErrorColors.e500),
          ),
        ),
        SizedBox(width: 10),
      ],
    );
  }
}
