import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/NFTMarketProvider.dart';
import 'navbar_item.dart';

class ScaffoldWithBottomNavBar extends StatefulWidget {
  const ScaffoldWithBottomNavBar(
      {Key? key, required this.child, required this.tabs})
      : super(key: key);
  final Widget child;
  final List<ScaffoldWithNavBarTabItem> tabs;

  @override
  State<ScaffoldWithBottomNavBar> createState() =>
      _ScaffoldWithBottomNavBarState();
}

class _ScaffoldWithBottomNavBarState extends State<ScaffoldWithBottomNavBar> {
  bool loadding = true;
  bool loaddingBTN = false;
  int _locationToTabIndex(String location) {
    final index =
        widget.tabs.indexWhere((t) => location.startsWith(t.initialLocation!));
    // if index not found (-1), return 0
    return index < 0 ? 0 : index;
  }

  int get _currentIndex => _locationToTabIndex(GoRouter.of(context).location);

  void _onItemTapped(BuildContext context, int tabIndex) {
    // Only navigate if the tab index has changed
    if (tabIndex != _currentIndex) {
      context.go(widget.tabs[tabIndex].initialLocation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return loadding
        ? Scaffold(
            body: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Localhost"),
                  TextField(
                    onTap: () {},
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("api"),
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: loaddingBTN
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () {
                              setState(() {
                                loaddingBTN = true;
                              });
                              var contractLink = Provider.of<NFTMarketProvider>(
                                  context,
                                  listen: false);
                              Timer.periodic(Duration(seconds: 1), (timer) {
                                if (contractLink.isLoading == false) {
                                  setState(() {
                                    loadding = contractLink.isLoading;
                                    print("chuyen trang");
                                    timer.cancel();
                                  });
                                }
                              });
                            },
                            child: const Text("Success")),
                  )
                ],
              ),
            ),
          ))
        : Scaffold(
            body: widget.child,
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              showUnselectedLabels: false,
              showSelectedLabels: false,
              currentIndex: _currentIndex,
              items: widget.tabs,
              onTap: (index) => _onItemTapped(context, index),
            ),
          );
  }
}
