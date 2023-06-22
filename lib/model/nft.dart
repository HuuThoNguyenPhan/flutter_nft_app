import 'dart:ffi';

class NFT {
  late String name,
      description,
      image,
      typeFile,
      owner,
      tokenId,
      size,
      sender,
      breed,
      genealogy,
      auctioneer,
      previousBidder,
      lastBidder,
      startTime,
      endTime,
      auctionId,
      createAt,
      royalties,
      author;

  late int count, limit;
  late List<String> tokenIDs = [];
  late String topics;
  late double price, initialPrice, lastBid;
  late bool active, completed, only;
  NFT(
      {this.name = "",
      this.description = "",
      this.image = "",
      this.typeFile = "",
      this.owner = "",
      this.tokenId = "",
      this.size = "",
      this.sender = "",
      this.breed = "",
      this.limit = 0,
      this.genealogy = "",
      this.auctioneer = "",
      this.previousBidder = "",
      this.lastBidder = "",
      this.startTime = "",
      this.endTime = "",
      this.auctionId = "",
      this.count = 0,
      this.price = 0,
      this.initialPrice = 0,
      this.lastBid = 0,
      this.active = false,
      this.completed = false,
      this.author = "",
      this.royalties = "",
      this.topics = "",
      this.only = false,
      this.createAt = ""});
}
