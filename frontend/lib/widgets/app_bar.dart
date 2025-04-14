import 'package:flutter/material.dart';
import 'package:frontend/core/constants.dart';
import 'package:frontend/data/models/user.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final User user;
  final String? title;
  const AppBarWidget({
    super.key,
    required this.user,
    this.title,
  });

  void onClickLogout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      Constants.routeLogin,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      title: Text(
        title ?? Constants.appName,
        style: const TextStyle(
          fontFamily: 'mono',
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      toolbarHeight: 112,
      actions: [
        SizedBox(
          height: 80,
          width: 160,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC9C9C9),
            ),
            onPressed: () => onClickLogout(context),
            child: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
          ),
        ),
        const SizedBox(width: 32),
        SizedBox(
          height: 80,
          width: 320,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF222222),
              foregroundColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${user.name} [${user.role.toString().split('.')[1]}]\n${user.email}",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'mono',
                    fontSize: 16
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 52,
                  width: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(Icons.person, size: 42, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 32),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(112);
}
