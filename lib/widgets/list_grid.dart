import 'package:flutter/material.dart';
import 'package:nft_marketplace/widgets/nft_card.dart';
import 'package:nft_marketplace/widgets/search_input.dart';
import 'package:sticky_headers/sticky_headers/widget.dart';

import '../model/nft.dart';

class ListGrid extends StatefulWidget {
  const ListGrid({Key? key, required this.nfts, required this.header}) : super(key: key);
  final List<NFT> nfts;
 final Widget header;
  @override
  State<ListGrid> createState() => _ListGridState();
}

class _ListGridState extends State<ListGrid> {
  List<String> listHeader = [
    'Danh sách sản phẩm',
  ];


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listHeader.length,
      itemBuilder: (context, index) {
        return StickyHeader(
          header: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 15,vertical: 15),
            alignment: Alignment.centerLeft,
            child: widget.header
          ),
          content: Container(
            child: widget.nfts.isNotEmpty ? GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.nfts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisExtent: 220,
                mainAxisSpacing: 15
              ),
              itemBuilder: (context, index) {
                return NFTCard(nft: widget.nfts[index]);
              },
            ): Center(child: Column(
              children: [
                SizedBox(height: 50,),
                Image.asset('assets/images/search.png'),
                Text("Không tìm thấy kết quả")
              ],
            )),
          ),
        );
      },
      shrinkWrap: true,
    );
  }
}
