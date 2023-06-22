import 'package:flutter/material.dart';
import 'package:nft_marketplace/screens/cart_screen.dart';
import 'package:nft_marketplace/widgets/section.dart';
import 'package:provider/provider.dart';
import 'package:badges/badges.dart' as badges;
import '../provider/NFTMarketProvider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.label, required this.detailsPath, Key? key})
      : super(key: key);
  final String label;
  final String detailsPath;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;

  @override
  void initState() {
    Provider.of<NFTMarketProvider>(context, listen: false)
        .fetchMarketItems()
        .then((value) {
      Provider.of<NFTMarketProvider>(context, listen: false).fetchAuction();
    }).then((value) => setState(() {
              loading = false;
            }));

    if (Provider.of<NFTMarketProvider>(context, listen: false).loged == true) {
      Provider.of<NFTMarketProvider>(context, listen: false).fetchUserCart();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.label),
        actions: [
          Consumer<NFTMarketProvider>(
            builder: (context, value, child) {
              return IconButton(
                icon: badges.Badge(
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Colors.blue,
                  ),
                  showBadge: false,
                  child: Icon(
                    Icons.shopping_cart_outlined,
                    size: 25,
                  ),
                ),
                onPressed: () {
                  if (value.loged == false) {
                    value.loginUsingMetamask(context).then((value) {
                      if (value == true) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => CartScreen(),
                        ));
                      }
                    });
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => CartScreen(),
                    ));
                  }
                },
              );
            },
          )
        ],
      ),
      body: Consumer<NFTMarketProvider>(builder: (context, value, child) {
        return loading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    value.auctions.isNotEmpty
                        ? Section(
                            title: "Đang đấu giá",
                            detailsPath: widget.detailsPath,
                            nfts: value.auctions)
                        : SizedBox.shrink(),
                    Section(
                        title: "Ảnh",
                        detailsPath: widget.detailsPath,
                        nfts: value.nfts
                            .where((element) => element.typeFile == "image")
                            .toList()),
                    Section(
                        title: "Video",
                        detailsPath: widget.detailsPath,
                        nfts: value.nfts
                            .where((element) => element.typeFile == "video")
                            .toList()),
                    Section(
                        title: "Nhạc",
                        detailsPath: widget.detailsPath,
                        nfts: value.nfts
                            .where((element) => element.typeFile == "audio")
                            .toList()),
                    Section(
                        title: "Tài liệu",
                        detailsPath: widget.detailsPath,
                        nfts: value.nfts
                            .where(
                                (element) => element.typeFile == "application")
                            .toList()),
                  ],
                ),
              );
      }),
    );
  }
}
