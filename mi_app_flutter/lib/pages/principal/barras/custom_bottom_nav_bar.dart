import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    this.currentIndex = 0,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: _buildNavContent(),
    );
  }

  Widget _buildNavContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _buildNavItems(),
      ),
    );
  }

  List<Widget> _buildNavItems() {
    return [
      _buildNavItem('assets/icons/icon_home.svg', 0),
      _buildNavItem('assets/icons/icon_calendar.svg', 1),
      _buildNavItem('assets/icons/icon_search.svg', 2),
      _buildNavItem('assets/icons/icon_bell.svg', 3),
    ];
  }

  Widget _buildNavItem(String iconPath, int index) {
    return IconButton(
      icon: SvgPicture.asset(
        iconPath,
        color: _getIconColor(index),
        width: 24,
        height: 24,
      ),
      onPressed: () => onTap(index),
    );
  }

  Color _getIconColor(int index) {
    return currentIndex == index ? Colors.green : Colors.grey;
  }
}