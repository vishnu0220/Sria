import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Function()? onMenuPressed;
  final Function()? onNotificationPressed;

  CustomAppBar({
    super.key,
    this.onMenuPressed,
    // required this.hasDrawer,
    this.onNotificationPressed,
  });

  final TextEditingController _searchController = TextEditingController();

  final FocusNode _searchFocusNode = FocusNode();

  // final bool hasDrawer;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading:
          //hasDrawer?
          Builder(
            builder: (context) {
              return InkWell(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Image.asset('assets/images/menu_bar.png'),
              );
            },
          ),

      //: null,
      title: SearchBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        hintText: 'Search employees, requests...',
        leading: const Icon(
          Icons.search,
          color: Color.fromARGB(179, 11, 11, 11),
        ),
        elevation: WidgetStateProperty.all(0),
        backgroundColor: WidgetStateProperty.all(Colors.white24),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            // Handle notification tap
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60);
}
