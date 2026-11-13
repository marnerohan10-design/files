import 'package:flutter/material.dart';

/// Indexes of the tabs in the bottom navigation bar.
class AppTab {
  static const home = 0;
  static const categories = 1;
  static const wishlist = 2;
  static const cart = 3;
  static const profile = 4;
}

/// The selected bottom-navigation tab. Screens that sit on top of the tab shell
/// (details, listing) use [openMainTab] to jump back to a tab.
final ValueNotifier<int> mainTabIndex = ValueNotifier<int>(AppTab.home);

void openMainTab(BuildContext context, int tab) {
  Navigator.of(context).popUntil((route) => route.isFirst);
  mainTabIndex.value = tab;
}
