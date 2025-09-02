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
  int selected = 0;
  bool isExpanded = false; // State variable for sidebar expansion

  void _onMenuItemTapped(int index) {
    setState(() {
      selected = index;
    });
  }

  void _onHover(bool hover) {
    if (isExpanded != hover) {
      setState(() {
        isExpanded = hover;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: readJsonFromFile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
        }
        if (snapshot.data == null) {
          return const Center(child: Text('No data found.'));
        }
        final appData = snapshot.data ?? <String, dynamic>{};

        return Scaffold(
          body: Row(
            children: <Widget>[
              // The Sidebar
              MouseRegion(
                onEnter: (_) => _onHover(true),
                onExit: (_) => _onHover(false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut, // smoother animation
                  width: isExpanded ? 200.0 : 70.0,
                  padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  color: const Color.fromARGB(255, 19, 19, 19),
                  child: Column(
                    children: [
                      Logo(isExpanded: isExpanded),
                      const SizedBox(height: 8),
                      _buildMenuItem(Icons.home_rounded, 'Home', 0),
                      _buildMenuItem(Icons.dataset_rounded, 'Data', 1),
                      _buildMenuItem(Icons.code_rounded, 'Editor', 2),
                      _buildMenuItem(Icons.analytics_rounded, 'Analytics', 3),
                      _buildMenuItem(Icons.now_widgets_rounded, 'Blueprint', 4),
                      const Spacer(),
                      _buildMenuItem(Icons.group_rounded, 'Team', 5),
                      _buildMenuItem(Icons.settings_rounded, 'Settings', 6),
                    ],
                  ),
                ),
              ),
              // Maintab remains in the main body
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 10, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 31, 31, 31),
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

  Widget _buildMenuItem(IconData icon, String title, int index) {
    final bool isCurrent = selected == index;
    return GestureDetector(
      onTap: () => _onMenuItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: isCurrent
              ? const Color.fromARGB(255, 31, 31, 31)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          mainAxisAlignment: isExpanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isCurrent ? Colors.white : Colors.white54,
              size: 24.0,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.white54,
                          fontSize: 16.0,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
