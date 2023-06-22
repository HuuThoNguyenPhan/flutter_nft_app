import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nft_marketplace/routes/routes.dart';
import 'package:nft_marketplace/screens/activity_screen.dart';
import 'package:nft_marketplace/screens/home_screen.dart';

import 'package:nft_marketplace/screens/splash_screen.dart';
import 'package:nft_marketplace/screens/search_creen.dart';
import 'package:nft_marketplace/widgets/scaffold_with_bottom_navBar.dart';
import '../widgets/navbar_item.dart';

final tabs = [
  ScaffoldWithNavBarTabItem(
    initialLocation: Routes.home,
    icon: Icon(Icons.home),
    label: "h"
  ),
  // ScaffoldWithNavBarTabItem(
  //     initialLocation: Routes.activity,
  //     icon: Icon(Icons.show_chart),
  //     label: "c"),
  ScaffoldWithNavBarTabItem(
    initialLocation: Routes.search,
    icon: Icon(Icons.search),
    label: "s"
  ),

  ScaffoldWithNavBarTabItem(
    initialLocation: Routes.splash,
    icon: Icon(Icons.person_2_rounded),
    label: "p"
  ),
];

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  initialLocation: Routes.home,
  navigatorKey: _rootNavigatorKey,
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return ScaffoldWithBottomNavBar(tabs: tabs, child: child);
      },
      routes: [
        // Home
        GoRoute(
          path: Routes.home,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: HomeScreen(label: 'Trang chủ', detailsPath: "${Routes.home}/${Routes.nftDetails}"),
          ),
        ),
        // Search
        GoRoute(
          path: Routes.search,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: SearchScreen(label: 'Tìm kiếm', detailsPath: "${Routes.search}/${Routes.nftDetails}"),
          ),
        ),
        //Create
        // GoRoute(
        //   path: Routes.activity,
        //   pageBuilder: (context, state) => NoTransitionPage(
        //     key: state.pageKey,
        //     child: const ActivityPage(label: 'Hoạt động', detailsPath: '/profile/details'),
        //   ),
        // ),
        //Profile
        GoRoute(
          path: Routes.splash,
          pageBuilder: (context, state) => NoTransitionPage(
            key: state.pageKey,
            child: SplashScreen(label: 'D', detailsPath: '${Routes.splash}/${Routes.nftDetails}')
          ),
        ),
      ],
    ),
  ],
);