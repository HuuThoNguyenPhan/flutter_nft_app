import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nft_marketplace/widgets/list_grid.dart';
import 'package:nft_marketplace/widgets/nft_card.dart';
import 'package:nft_marketplace/widgets/search_input.dart';
import 'package:provider/provider.dart';

import '../provider/NFTMarketProvider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({required this.label, required this.detailsPath, Key? key})
      : super(key: key);
  final String label;
  final String detailsPath;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  var _searchContent = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var contractLink = Provider.of<NFTMarketProvider>(context);
    return Scaffold(
        appBar: AppBar(
          shape:
              Border(bottom: BorderSide(color: Color(0xdF5F5F5), width: 0.5)),
          title: Text(widget.label),
          centerTitle: true,
          bottom: PreferredSize(
              preferredSize: const Size.fromHeight(80),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: SearchInput(
                  searchContent: _searchContent,
                  onChanged: (value) {
                    print(value);
                  },
                ),
              )),
        ),
        body: ListGrid(
          nfts: contractLink.nfts,
          header: Text(
            'Danh sách sản phẩm',
            style: const TextStyle(
                color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ));
  }

  
}
