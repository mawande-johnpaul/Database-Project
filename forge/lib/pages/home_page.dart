import 'package:flutter/material.dart';
import 'package:forge/models/io.dart';
import 'package:forge/widgets/logo.dart';
import 'package:forge/widgets/maintab.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Use a late final Future to ensure it's initialized once.
  // This is a common and correct pattern for handling futures in initState.
  late Future<dynamic> startup;
  int selected = 0;

  @override
  void initState() {
    super.initState();
    // No need to initialize the future here anymore.
    startup = getProjects();
  }

  void onMenuItemTapped(int index) {
    setState(() {
      selected = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // You can manage colors centrally for consistency and easy updates.
    final Color sidebarColor = const Color.fromARGB(255, 19, 19, 19);
    final Color contentContainerColor = const Color.fromARGB(255, 31, 31, 31);
    final Color activeColor = contentContainerColor;
    final Color inactiveColor = Colors.transparent;
    final Color activeTextColor = Colors.white;
    final Color inactiveTextColor = Colors.white54;

    return FutureBuilder(
      future: startup,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (snapshot.data == null) {
          return const Center(child: Text('No data found.'));
        }
        final appData = snapshot.data;

        return Scaffold(
          body: Row(
            children: <Widget>[
              // The Sidebar with a fixed width
              Container(
                width: 200.0,
                padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                color: sidebarColor,
                child: Column(
                  children: [
                    Logo(isExpanded: true),
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      Icons.home_rounded,
                      'Home',
                      0,
                      activeColor,
                      inactiveColor,
                      activeTextColor,
                      inactiveTextColor,
                    ),
                    _buildMenuItem(
                      Icons.code_rounded,
                      'Editor',
                      1,
                      activeColor,
                      inactiveColor,
                      activeTextColor,
                      inactiveTextColor,
                    ),
                    _buildMenuItem(
                      Icons.analytics_rounded,
                      'Analytics',
                      2,
                      activeColor,
                      inactiveColor,
                      activeTextColor,
                      inactiveTextColor,
                    ),
                    const Spacer(),
                    _buildMenuItem(
                      Icons.group_rounded,
                      'Team',
                      3,
                      activeColor,
                      inactiveColor,
                      activeTextColor,
                      inactiveTextColor,
                    ),
                    _buildMenuItem(
                      Icons.settings_rounded,
                      'Settings',
                      4,
                      activeColor,
                      inactiveColor,
                      activeTextColor,
                      inactiveTextColor,
                    ),
                  ],
                ),
              ),
              // Maintab remains in the main body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut, // smoother animation
                    decoration: BoxDecoration(
                      color: contentContainerColor,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Maintab(selected: selected, appData: appData),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Refactored _buildMenuItem to accept colors as parameters.
  // Use AnimatedContainer for a smooth transition effect.
  Widget _buildMenuItem(
    IconData icon,
    String title,
    int index,
    Color activeColor,
    Color inactiveColor,
    Color activeTextColor,
    Color inactiveTextColor,
  ) {
    final bool isCurrent = selected == index;
    return GestureDetector(
      onTap: () => onMenuItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ), // Duration of the animation
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isCurrent ? activeColor : inactiveColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isCurrent ? activeTextColor : inactiveTextColor,
              size: 24.0,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                title,
                style: TextStyle(
                  color: isCurrent ? activeTextColor : inactiveTextColor,
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
