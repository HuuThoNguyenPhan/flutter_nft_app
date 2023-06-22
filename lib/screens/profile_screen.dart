import 'package:flutter/material.dart';
import 'package:jazzicon/jazzicon.dart';
import 'package:nft_marketplace/model/nft.dart';
import 'package:provider/provider.dart';

import '../provider/NFTMarketProvider.dart';
import '../widgets/list_grid.dart';
import '../widgets/search_input.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key, required this.address}) : super(key: key);
  final String address;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController searchTXT = TextEditingController();
  String address = "";
  bool loading = true;
  List<NFT> filterNFTs = [];
  List<NFT> filterListed = [];
  List<NFT> filterAuction = [];
  List<NFT> filterEndAuction = [];
  @override
  void initState() {
    if (widget.address.isNotEmpty) {
      address = widget.address;
    } else {
      address = Provider.of<NFTMarketProvider>(context, listen: false).sender;
    }
    // Provider.of<NFTMarketProvider>(context, listen: false)
    //     .fetchMyNFTs(address)
    //     .then((value) {
    //   setState(() {
    //     loading = !loading;
    //   });
    // });
    super.initState();
  }

  List<NFT> search(String v, List<NFT> list) {
    print("aa");
    if (searchTXT.text.isEmpty) {
      return list;
    }
    return list
        .where(
          (item) => item.name.toLowerCase().contains(v.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NFTMarketProvider>(builder: (context, value, child) {
      return Scaffold(
        appBar: AppBar(
          leading: !widget.address.isNotEmpty
              ? SizedBox.shrink()
              : Container(
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        padding: const EdgeInsets.all(8),
                        minimumSize: Size.zero,
                        shape: const CircleBorder()),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.arrow_back_ios_sharp,
                      size: 20,
                    ),
                  ),
                ),
          actions: [
            Container(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero,
                    shape: const CircleBorder()),
                onPressed: () => value.disconect(),
                child: const Icon(
                  Icons.login,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
        body: DefaultTabController(
          length: 4,
          child: NestedScrollView(
            physics: NeverScrollableScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: Colors.white,
                  collapsedHeight: 250,
                  expandedHeight: 250,
                  flexibleSpace: ProfileView(),
                ),
                SliverPersistentHeader(
                  delegate: MyDelegate(TabBar(
                    onTap: (num) {
                      switch (num) {
                        case 0:
                          value.fetchMyListedNFTs(address);
                          filterListed = value.myListedNFTs;
                          searchTXT.clear();
                          break;
                        case 1:
                          value.fetchMyNFTs(address);
                          filterNFTs = value.myNFTs;
                          searchTXT.clear();
                          break;
                        case 2:
                          value.fetchAuction();
                          filterAuction = value.auctions;
                          searchTXT.clear();
                          break;
                        default:
                          value.fetchAuction();
                          filterEndAuction = value.auctions
                              .where((element) => element.active == false)
                              .toList();
                          searchTXT.clear();
                          break;
                      }
                    },
                    isScrollable: true,
                    tabs: [
                      Tab(text: "Đang bán"),
                      Tab(
                        text: "NFT cá nhân",
                      ),
                      Tab(
                        text: "Đấu giá",
                      ),
                      Tab(
                        text: "Đấu giá kết thúc",
                      ),
                    ],
                    indicatorColor: Colors.blue,
                    unselectedLabelColor: Colors.grey,
                    labelColor: Colors.black,
                  )),
                  floating: true,
                  pinned: true,
                )
              ];
            },
            body: value.isLoading == true
                ? Center(child: CircularProgressIndicator())
                : TabBarView(
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                        ListGrid(
                          header: searchInput(
                              searchTXT,
                              (v) => {
                                    setState(() {
                                      filterListed =
                                          search(v, value.myListedNFTs);
                                    })
                                  },
                              value),
                          nfts: searchTXT.text == ""
                              ? value.myListedNFTs
                              : filterListed,
                        ),
                        ListGrid(
                          header: searchInput(
                              searchTXT,
                              (v) => {
                                    setState(() {
                                      filterNFTs = search(v, value.myNFTs);
                                    })
                                  },
                              value),
                          nfts:
                              searchTXT.text == "" ? value.myNFTs : filterNFTs,
                        ),
                        ListGrid(
                          header: searchInput(
                              searchTXT,
                              (v) => {
                                    setState(() {
                                      filterAuction = search(v, value.auctions);
                                    })
                                  },
                              value),
                          nfts: searchTXT.text == ""
                              ? value.auctions
                              : filterAuction,
                        ),
                        ListGrid(
                          header: searchInput(
                              searchTXT,
                              (v) => {
                                    setState(() {
                                      filterEndAuction = search(
                                          v,
                                          value.auctions
                                              .where((element) =>
                                                  element.active == false)
                                              .toList());
                                    })
                                  },
                              value),
                          nfts: searchTXT.text == ""
                              ? value.auctions
                                  .where((element) => element.active == false)
                                  .toList()
                              : filterEndAuction,
                        ),
                      ]),
          ),
        ),
      );
    });
  }

  ProfileView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Jazzicon.getIconWidget(
                    Jazzicon.getJazziconData(120, address: address))
              ],
            ),
          ),
          Container(
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: 'User_${address.substring(address.length - 4)}',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                TextSpan(
                    text:
                        '\n${address.replaceRange(4, address.length - 3, "...")}',
                    style: TextStyle(color: Colors.black87, fontSize: 14))
              ]),
            ),
          )
        ],
      ),
    );
  }

  Widget searchInput(searchContent, onChanged, NFTMarketProvider value) {
    return TextField(
      controller: searchContent,
      onChanged: onChanged,
      decoration: InputDecoration(
          suffixIcon: searchContent.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchContent.clear();
                    setState(() {
                      filterListed = value.myListedNFTs;
                      filterAuction = value.auctions;
                      filterNFTs = value.myNFTs;
                      filterEndAuction = value.auctions
                          .where((element) => element.active == false)
                          .toList();
                    });
                  },
                  icon: Icon(Icons.clear),
                )
              : null,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          hintText: "Tìm kiếm",
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 17)),
    );
  }
}

class MyDelegate extends SliverPersistentHeaderDelegate {
  MyDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
