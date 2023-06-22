import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nft_marketplace/widgets/nft_card.dart';

import '../model/nft.dart';

class Section extends StatefulWidget {
  const Section(
      {Key? key,
      required this.title,
      required this.detailsPath,
      required this.nfts,})
      : super(key: key);
  final String title;
  final String detailsPath;
  final List<NFT> nfts;

  @override
  State<Section> createState() => _SectionState();
}

class _SectionState extends State<Section> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Text(widget.title,style: TextStyle(fontWeight: FontWeight.w900,fontSize: 18),),
          ),
          SizedBox(height: 15,),
          SizedBox(
            height: 220,
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 10),
              scrollDirection: Axis.horizontal,
              itemCount: widget.nfts.length,
              itemBuilder: (context, index) => NFTCard(nft:
                widget.nfts[index],),
            ),
          ),
          SizedBox(height: 20,),
        ],
      ),
    );
  }
}
