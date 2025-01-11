import 'package:flutter/material.dart';
import 'package:netflix_app/screens/home_screen.dart';
import 'package:netflix_app/screens/search_screen.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int position = 0;

  List<Widget> screens = [HomeScreen(), SearchScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[position],
      backgroundColor: Colors.black,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: position,
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        showSelectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: "", // No label
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, size: 30),
            label: "", // No label
          ),
        ],
        onTap: (value) => setState(() => position = value),
      ),
    );
  }
}
