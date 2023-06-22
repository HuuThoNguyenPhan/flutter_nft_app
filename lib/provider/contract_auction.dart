import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:big_decimal/big_decimal.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/credentials.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import '../internal/ethereum_credentials.dart';
import '../model/nft.dart';
import 'config.dart';

class Auction {
  late String _abiCode;
  late EthereumAddress _contractAddress;
  final String api = Config.api;
  late DeployedContract _contract;
  late WalletConnectEthereumCredentials wcCredentials;
  late Web3Client _client;
  late ContractFunction _createAuction;
  late ContractFunction _finishAuction;
  late ContractFunction _joinAuction;
  late ContractFunction _cancleAuction;
  late ContractFunction _getAuction;
  late ContractFunction _getAuctionByStatus;
  late ContractEvent eventJoin;

  Auction(Web3Client client) {
    initialSetup(client);
  }

  initialSetup(Web3Client client) async {
    _client = client;
    await getAbi();
    await getDeployedContract();
  }

  Future<void> getAbi() async {
    // Reading the contract abi
    String abiStringFile =
        await rootBundle.loadString("src/artifacts/Auction.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    // print(_abiCode);
    var address = await getContractAddress();
    _contractAddress = EthereumAddress.fromHex(address["auctionAddress"]);
    // print(_contractAddress);
  }

  Future<void> getDeployedContract() async {
    // Telling Web3dart where our contract is declared.
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "Auction"), _contractAddress);
    // Extracting the functions, declared in contract.
    _createAuction = _contract.function("createAuction");
    _finishAuction = _contract.function("finishAuction");
    _cancleAuction = _contract.function("cancleAuction");
    _getAuctionByStatus = _contract.function("getAuctionByStatus");
    _joinAuction = _contract.function("joinAuction");
    _getAuction = _contract.function("getAuction");
    eventJoin = _contract.event('join');
  }

  Future<dynamic> getContractAddress() async {
    var res = await http.get(
        headers: {"Content-type": "application/json"},
        Uri.parse("${api}addresses"));
    return json.decode(res.body)["address"];
  }

  Future<List<dynamic>> getTokenURI(String id) async {
    return await _client.call(
        contract: _contract,
        function: _createAuction,
        params: [BigInt.parse(id)]);
  }

  Future<dynamic> createAuction(tokenId, initialPrice, startTime, endTime, name,
      sender, _contractFactory) async {
    Completer<bool> completer = Completer<bool>();
    BigInt cId = await _client.getChainId();
    var time = name + DateTime.timestamp().toString();
    var urlToken = await _contractFactory.getTokenURI(tokenId);
    var finalItem = [];
    finalItem.add(urlToken[0].toString().substring(38));

    BigDecimal a = BigDecimal.parse(initialPrice.toString());
    BigDecimal b = BigDecimal.parse(pow(10, 18).toString());
    String tick = (a * b).toString();
    BigInt price = BigInt.parse(tick.substring(0, tick.indexOf(".")));
    String txnHash = await _client.sendTransaction(
        wcCredentials,
        Transaction.callContract(
          from: EthereumAddress.fromHex(sender),
          contract: _contract,
          function: _createAuction,
          parameters: [
            BigInt.parse(tokenId),
            price,
            BigInt.parse(startTime.toString()),
            BigInt.parse(endTime.toString())
          ],
          // gasPrice: EtherAmount.inWei(BigInt.one),
          // maxGas: 100000,
        ),
        chainId: cId.toInt());

    late Timer txnTimer;
    txnTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      TransactionReceipt? t = await _client.getTransactionReceipt(txnHash);
      if (t != null) {
        print("Đấu giá thành công");
        completer.complete(true);
        var res = await http.post(
            headers: {"Content-type": "application/json"},
            Uri.parse(
              "${api}products/changeBreed",
            ),
            body: json.encode({'time': time, 'ids': finalItem}));
        // fetchMarketItems();
        txnTimer.cancel();
      }
    });
    return completer.future;
  }

  Future<List<NFT>> fetchAuction(
      sender, bool isActive, _contractFactory, fetchData) async {
    var resNfts = await _client.call(
        contract: _contract,
        function: _getAuctionByStatus,
        params: [isActive],
        sender: EthereumAddress.fromHex(sender));
    List<NFT> list = [];
    for (var e in resNfts[0]) {
      var tokenURL = await _contractFactory.getTokenURI(e[1].toString());
      var id = tokenURL[0].toString().substring(38);
      var data = await fetchData(id);
      list.add(NFT(
          name: data["name"],
          image:
              "https://gateway.pinata.cloud/ipfs/" + data["image"].substring(7),
          typeFile: data["typeFile"],
          tokenId: e[1].toString(),
          initialPrice: e[2] / BigInt.from(pow(10, 18)),
          previousBidder: e[3].toString(),
          lastBid: e[4] / BigInt.from(pow(10, 18)),
          price: e[4] / BigInt.from(pow(10, 18)),
          lastBidder: e[5].toString(),
          startTime: e[6].toString(),
          endTime: e[7].toString(),
          completed: e[8],
          active: e[9],
          auctionId: e[10].toString(),
          auctioneer: e[0].toString(),
          size: data["size"].toString(),
          topics: data["topics"].toString(),
          genealogy: data["genealogy"]));
    }

    return list;
  }

  Future<NFT> getDetailAuction(
      auctionId, sender, _contractFactory, fetchData) async {
    var resNft = await _client.call(
        contract: _contract,
        function: _getAuction,
        params: [BigInt.parse(auctionId)],
        sender: EthereumAddress.fromHex(sender));
    resNft = resNft[0];
    var tokenURL = await _contractFactory.getTokenURI(resNft[1].toString());
    var id = tokenURL[0].toString().substring(38);
    var data = await fetchData(id);
    return NFT(
        name: data["name"],
        image:
            "https://gateway.pinata.cloud/ipfs/" + data["image"].substring(7),
        typeFile: data["typeFile"],
        tokenId: resNft[1].toString(),
        initialPrice: resNft[2] / BigInt.from(pow(10, 18)),
        previousBidder: resNft[3].toString(),
        lastBid: resNft[4] / BigInt.from(pow(10, 18)),
        lastBidder: resNft[5].toString(),
        startTime: resNft[6].toString(),
        endTime: resNft[7].toString(),
        completed: resNft[8],
        active: resNft[9],
        auctionId: resNft[10].toString(),
        auctioneer: resNft[0].toString(),
        size: data["size"].toString(),
        description: data["description"],
        genealogy: data["genealogy"]);
  }

  Future<dynamic> endAuction(auctionId, type, sender) async {
    BigInt cId = await _client.getChainId();
    String txnHash = await _client.sendTransaction(
        wcCredentials,
        Transaction.callContract(
          from: EthereumAddress.fromHex(sender),
          contract: _contract,
          function: type == true ? _cancleAuction : _finishAuction,
          parameters: [BigInt.parse(auctionId)],
        ),
        chainId: cId.toInt());

    late Timer txnTimer;
    txnTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      TransactionReceipt? t = await _client.getTransactionReceipt(txnHash);
      if (t != null) {
        print("Giao dịch thành công");
        txnTimer.cancel();
      }
    });
  }

  Future<dynamic> joinAuction(auctionId, bid, sender) async {
    BigInt cId = await _client.getChainId();
    BigDecimal a = BigDecimal.parse(bid.toString());
    BigDecimal b = BigDecimal.parse(pow(10, 18).toString());
    String tick = (a * b).toString();
    BigInt price = BigInt.parse(tick.substring(0, tick.indexOf(".")));
    String txnHash = await _client.sendTransaction(
        wcCredentials,
        Transaction.callContract(
          from: EthereumAddress.fromHex(sender),
          contract: _contract,
          function: _joinAuction,
          value: EtherAmount.fromBigInt(EtherUnit.wei, price),
          parameters: [BigInt.parse(auctionId), price],
        ),
        chainId: cId.toInt());

    late Timer txnTimer;
    txnTimer = Timer.periodic(Duration(seconds: 5), (_) async {
      TransactionReceipt? t = await _client.getTransactionReceipt(txnHash);
      if (t != null) {
        print("Giao dịch thành công");
        txnTimer.cancel();
      }
    });
  }

  join() async {
    final filter = FilterOptions.events(
      contract: _contract,
      event: eventJoin,
    );

    final stream = _client.events(filter);

    stream.take(1);
    return stream;
  }
}
