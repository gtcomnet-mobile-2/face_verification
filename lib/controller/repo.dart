import 'dart:developer';

class Repo {
  static bool isSoundOn = true;
  static void toggleSound() {
    isSoundOn = !isSoundOn;
    log("Sound toggled. New state: $isSoundOn");
  }
}
