import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nft_marketplace/screens/nft_detail_screen.dart';

import '../model/nft.dart';

class NFTCard extends StatefulWidget {
  const NFTCard({Key? key, required this.nft}) : super(key: key);
  final NFT nft;

  @override
  State<NFTCard> createState() => _NFTCardState();
}

class _NFTCardState extends State<NFTCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NFTDetailScreen(
                  nft: widget.nft,
                )));
      },
      child: Container(
        height: 220,
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
                child: renderMediaView(widget.nft.typeFile)),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(widget.nft.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Giá",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      Text("${widget.nft.price} ETH",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w500))
                    ],
                  ),
                  
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  renderMediaView(fileType) {
    switch (fileType) {
      case 'image':
        return CachedNetworkImage(
          fit: BoxFit.cover,
          height: 140,
          width: 200,
          imageUrl: widget.nft.image,
          placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
            color: Colors.grey,
          )),
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.error)),
        );
      case 'video':
        return Image.asset("assets/images/nft-video.png",
            height: 140, width: 200);

      case 'audio':
        return Image.asset("assets/images/nft-music.png",
            height: 140, width: 200);
      default:
        return Image.asset("assets/images/nft-application.png",
            height: 140, width: 200);
    }
  }
}
