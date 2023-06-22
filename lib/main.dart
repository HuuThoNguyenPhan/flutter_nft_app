import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:nft_marketplace/provider/NFTMarketProvider.dart';
import 'package:nft_marketplace/routes/go_router.dart';

import 'package:provider/provider.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return ChangeNotifierProvider<NFTMarketProvider>(
      create: (context)=>NFTMarketProvider(),
      child: MaterialApp.router(
        theme: ThemeData(
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(color: Colors.grey),
            titleTextStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 23),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0.0,
          ),
        ),
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        routerConfig: goRouter,
      ),
    );
  }
}

