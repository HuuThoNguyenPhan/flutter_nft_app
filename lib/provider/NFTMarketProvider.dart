import 'dart:convert';
import 'dart:async';
import 'package:big_decimal/big_decimal.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:nft_marketplace/model/nft.dart';
import 'package:nft_marketplace/provider/contract_auction.dart';
import 'package:nft_marketplace/provider/contract_factory.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import '../internal/ethereum_credentials.dart';
import 'config.dart';

class NFTMarketProvider extends ChangeNotifier {
  final String api = Config.api;
  final String _rpcURl = "https://${Config.ipNgrok}";
  final String _wsURl = "ws://${Config.ipNgrok}";

  late EthereumWalletConnectProvider provider;
  late WalletConnect walletConnector;
  late WalletConnectEthereumCredentials wcCredentials;
  int lengthCarts = 0;
  late Web3Client _client;
  late String _abiCode;
  late String sender = "0x0000000000000000000000000000000000000000";
  late EthereumAddress _contractAddress;

  late DeployedContract _contract;
  late ContractFactory _contractFactory;
  late Auction _contractAuction;
  late ContractFunction _getListingPrice;
  late ContractFunction _resellToken;
  late ContractFunction _createMarketSale;
  late ContractFunction _fetchMarketItems;
  late ContractFunction _fetchMyNFTs;
  late ContractFunction _fetchItemsListed;
  late Timer fetchGreetingTimer;
  bool isLoading = true;
  BigInt? deployedName;
  List<NFT> nfts = [];
  List<NFT> myNFTs = [];
  List<NFT> myListedNFTs = [];
  List<NFT> auctions = [];
  NFTMarketProvider() {
    initialSetup();
  }
  var session, url, connector;
  bool loged = false;

  Future<bool> loginUsingMetamask(BuildContext context) async {
    try {
      connector = WalletConnect(
          bridge: 'https://bridge.walletconnect.org',
          clientMeta: const PeerMeta(
              name: 'My App',
              description: 'An app for converting pictures to NFT',
              url: 'https://walletconnect.org',
              icons: [
                'https://files.gitbook.com/v0/b/gitbook-legacy-files/o/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png?alt=media'
              ]));
      session = await connector.createSession(onDisplayUri: (uri) async {
        url = uri;
        await launchUrlString(uri, mode: LaunchMode.externalApplication);
      });

      if (session.accounts[0] != "") {
        getSigner();
        loged = true;
        fetchUserCart();
        notifyListeners();
      }

      return loged;
    } catch (e) {
      print(e);
      return loged;
    }
  }

  getSigner() {
    walletConnector = connector;
    sender = session.accounts[0];
    provider = EthereumWalletConnectProvider(walletConnector);
    wcCredentials = WalletConnectEthereumCredentials(provider: provider);
    _contractAuction.wcCredentials = wcCredentials;
  }

  disconect() {
    sender = "0x0000000000000000000000000000000000000000";
    loged = false;
    isLoading = false;
    notifyListeners();
  }

  initialSetup() async {
    _client = Web3Client(_rpcURl, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(_wsURl).cast<String>();
    });

    await getAbi();
    await getDeployedContract();
    _contractFactory = ContractFactory(_client);
    _contractAuction = Auction(_client);
    isLoading = false;
  }

  Future<void> getAbi() async {
    // Reading the contract abi
    String abiStringFile =
        await rootBundle.loadString("src/artifacts/NFTMarketplace.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    // print(_abiCode);
    var address = await getContractAddress();
    _contractAddress =
        EthereumAddress.fromHex(address["nftmarketplaceAddress"]);
    // print(_contractAddress);
  }

  Future<dynamic> getContractAddress() async {
    var res = await http.get(
        headers: {"Content-type": "application/json"},
        Uri.parse("${api}addresses"));
    return json.decode(res.body)["address"];
  }

  Future<void> getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "NFTMarketplace"), _contractAddress);
    _getListingPrice = _contract.function("getListingPrice");
    _resellToken = _contract.function("resellToken");
    _createMarketSale = _contract.function("createMarketSale");
    _fetchMarketItems = _contract.function("fetchMarketItems");
    _fetchMyNFTs = _contract.function("fetchMyNFTs");
    _fetchItemsListed = _contract.function("fetchItemsListed");
  }

  Future<dynamic> getListingPrice() async {
    var ltp = await _client
        .call(contract: _contract, function: _getListingPrice, params: []);
    isLoading = false;
    return EtherAmount.inWei(ltp[0]);
  }

  NFT getDetails(id) {
    return nfts.firstWhere((element) => element.tokenId == id);
  }

  Future<dynamic> buyNFT(NFT nft, limit) async {
    isLoading = true;
    notifyListeners();
    // create a Completer object
    Completer<bool> completer = Completer<bool>();
    try {
      BigInt cId = await _client.getChainId();
      var time = nft.name + DateTime.timestamp().toString();
      nft.price = nft.price * limit;
      BigDecimal a = BigDecimal.parse(nft.price.toString());
      BigDecimal b = BigDecimal.parse(pow(10, 18).toString());
      String tick = (a * b).toString();
      BigInt price = BigInt.parse(tick.substring(0, tick.indexOf(".")));
      var finalItem = [];
      List<BigInt> ids = [];

      for (var i = 0; i < limit; i++) {
        var urlToken = await _contractFactory.getTokenURI(nft.tokenIDs[i]);
        finalItem.add(urlToken[0].toString().substring(38));
      }

      for (var i = 0; i < limit; i++) {
        ids.add(BigInt.parse(nft.tokenIDs[i]));
      }
      String txnHash = await _client.sendTransaction(
          wcCredentials,
          Transaction.callContract(
            from: EthereumAddress.fromHex(sender),
            contract: _contract,
            function: _createMarketSale,
            parameters: [ids],
            value: EtherAmount.fromBigInt(EtherUnit.wei, price),
          ),
          chainId: cId.toInt());
      late Timer txnTimer;
      txnTimer = Timer.periodic(Duration(seconds: 5), (_) async {
        TransactionReceipt? t = await _client.getTransactionReceipt(txnHash);

        if (t != null) {
          print("Giao dịch thành công");
          fetchMarketItems();
          var res = await http.post(
              headers: {"Content-type": "application/json"},
              Uri.parse(
                "${api}products/changeBreed",
              ),
              body: json.encode({'time': time, 'ids': finalItem}));
          txnTimer.cancel();
          completer.complete(true);
        }
      });
      return completer.future; //
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> resellNFT(NFT nft, double changePrice, limit) async {
    isLoading = true;
    notifyListeners();
    Completer<bool> completer = Completer<bool>();
    try {
      BigInt cId = await _client.getChainId();
      var time = nft.name + DateTime.timestamp().toString();
      BigDecimal a = BigDecimal.parse(changePrice.toString());
      BigDecimal b = BigDecimal.parse(pow(10, 18).toString());
      String tick = (a * b).toString();
      BigInt price = BigInt.parse(tick.substring(0, tick.indexOf(".")));
      print(price);
      var finalItem = [];
      List<BigInt> ids = [];
      for (var i = 0; i < limit; i++) {
        var urlToken = await _contractFactory.getTokenURI(nft.tokenIDs[i]);
        finalItem.add(urlToken[0].toString().substring(38));
      }
      var res = await http.post(
          headers: {"Content-type": "application/json"},
          Uri.parse(
            "${api}products/changeBreed",
          ),
          body: json.encode({'time': time, 'ids': finalItem}));

      if (res.statusCode == 200) {
        print("Chuyển breed thành công");
        for (var i = 0; i < limit; i++) {
          ids.add(BigInt.parse(nft.tokenIDs[i]));
        }

        var fee = await getListingPrice();
        String txnHash = await _client.sendTransaction(
            wcCredentials,
            Transaction.callContract(
              from: EthereumAddress.fromHex(sender),
              contract: _contract,
              function: _resellToken,
              parameters: [ids, price],
              // gasPrice: EtherAmount.inWei(BigInt.one),
              // maxGas: 100000,
              value: fee,
            ),
            chainId: cId.toInt());

        late Timer txnTimer;
        txnTimer = Timer.periodic(Duration(seconds: 5), (_) async {
          TransactionReceipt? t = await _client.getTransactionReceipt(txnHash);
          if (t != null) {
            print("Giao dịch thành công");
            completer.complete(true);
            txnTimer.cancel();
          }
        });
      }
      return completer.future; //
    } catch (e) {
      print(e);
    }
  }

  Future<dynamic> fetchData(String id) async {
    final res = await http.get(Uri.parse("${api}products/$id"));

    return json.decode(res.body)["products"];
  }

  Future<void> fetchMarketItems() async {
    // isLoading = true;
    // notifyListeners();
    nfts = await fetchNFTs(_fetchMarketItems, sender, true);
    isLoading = false;
    notifyListeners();
  }

  // Future<void> fetchMarketItems() async {
  //   List<NFT> list = [];
  //   final res = await http.get(Uri.parse("${api}getAllproductFromRedis"));
  //   var resNFTs = json.decode(res.body)["products"];
  //   for (var i = 0; i < resNFTs.length; i++) {
  //     list.add(NFT(
  //         name: resNFTs[i]["name"],
  //         image: resNFTs[i]["image"],
  //         typeFile: resNFTs[i]["typeFile"],
  //         description: resNFTs[i]["description"],
  //         owner: resNFTs[i]["owner"],
  //         tokenId: resNFTs[i]["tokenId"],
  //         size: resNFTs[i]["size"],
  //         sender: resNFTs[i]["seller"],
  //         price: double.parse(resNFTs[i]["price"].toString()),
  //         breed: resNFTs[i]["breed"],
  //         limit: resNFTs[i]["limit"],
  //         genealogy: resNFTs[i]["genealogy"],
  //         author: resNFTs[i]["author"],
  //         royalties: resNFTs[i]["royalties"],
  //         createAt: resNFTs[i]["createAt"],
  //         topics:  resNFTs[i]["topics"].toString(),
  //         only: resNFTs[i]["only"]));
  //   }
  //
  //   List<NFT> finalItems = [];
  //   for (var i = 0; i < list.length; i++) {
  //     if (list[i].breed != 1) {
  //       list[i].count = 1;
  //       list[i].tokenIDs.add(list[i].tokenId);
  //       for (var j = i + 1; j < list.length; j++) {
  //         if (list[j].breed == list[i].breed) {
  //           list[i].count++;
  //           list[i].tokenIDs.add(list[j].tokenId);
  //           list.removeAt(j);
  //           j--;
  //         }
  //       }
  //     }
  //     finalItems.add(list[i]);
  //   }
  //   nfts = finalItems.reversed.toList();
  // }

  Future<void> fetchMyNFTs(userAccount) async {
    isLoading = true;
    notifyListeners();
    myNFTs = await fetchNFTs(_fetchMyNFTs, userAccount, false);
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyListedNFTs(userAccount) async {
    isLoading = true;
    notifyListeners();
    myListedNFTs = await fetchNFTs(_fetchItemsListed, userAccount, false);
    isLoading = false;
    notifyListeners();
  }

  Future<List<NFT>> fetchNFTs(function, address, check) async {
    var resNfts;
    if (check == true) {
      resNfts = await _client.call(
          contract: _contract,
          function: function,
          params: [],
          sender: EthereumAddress.fromHex(sender));
    } else {
      resNfts = await _client.call(
          contract: _contract,
          function: function,
          params: [EthereumAddress.fromHex(address)],
          sender: EthereumAddress.fromHex(sender));
    }

    List<NFT> list = [];
    for (var e in resNfts[0]) {
      var tokenURL = await _contractFactory.getTokenURI(e[0].toString());
      var id = tokenURL[0].toString().substring(38);
      var data = await fetchData(id);
      list.add(NFT(
          name: data["name"],
          image:
              "https://gateway.pinata.cloud/ipfs/" + data["image"].substring(7),
          typeFile: data["typeFile"],
          description: data["description"],
          owner: e[2].toString(),
          tokenId: e[0].toString(),
          size: data["size"].toString(),
          sender: e[1].toString(),
          price: e[3] / BigInt.from(pow(10, 18)),
          breed: data["breed"],
          limit: data["limit"],
          genealogy: data["genealogy"],
          author: e[5].toString(),
          royalties: e[6].toString(),
          topics: data["topics"].toString(),
          createAt: DateFormat('dd-MM-yyyy HH:mm:ss')
              .format(DateTime.parse(data["createAt"])),
          only: data["only"]));
    }
    List<NFT> finalItems = [];
    for (var i = 0; i < list.length; i++) {
      if (list[i].breed != 1) {
        list[i].count = 1;
        list[i].tokenIDs.add(list[i].tokenId);
        for (var j = i + 1; j < list.length; j++) {
          if (list[j].breed == list[i].breed) {
            list[i].count++;
            list[i].tokenIDs.add(list[j].tokenId);
            list.removeAt(j);
            j--;
          }
        }
      }
      finalItems.add(list[i]);
    }

    return finalItems.reversed.toList();
  }

  Future<dynamic> createAuction(
      tokenId, initialPrice, startTime, endTime, name) async {
    bool completer = false;
    isLoading = true;
    notifyListeners();
    completer = await _contractAuction.createAuction(tokenId, initialPrice,
        startTime, endTime, name, sender, _contractFactory);
  }

  Future<dynamic> fetchAuction() async {
    isLoading = true;
    notifyListeners();
    auctions = await _contractAuction.fetchAuction(
        sender, true, _contractFactory, fetchData);
    isLoading = false;
    notifyListeners();
  }

  Future<NFT> getDetailAuction(auctionId) async {
    NFT nft = await _contractAuction.getDetailAuction(
        auctionId, sender, _contractFactory, fetchData);
    var data = await _contractFactory.getDetail(nft.tokenId);
    nft.author = data[0][5].toString();
    nft.royalties = data[0][6].toString();
    return nft;
  }

  Future<dynamic> endAuction(auctionId, type) async {
    await _contractAuction.endAuction(auctionId, type, sender);
  }

  Future<dynamic> joinAuction(auctionId, bid) async {
    await _contractAuction.joinAuction(auctionId, bid, sender);
  }

  getContractEvent() {
    return _contractAuction.eventJoin;
  }

  Future<dynamic> join() async {
    return await _contractAuction.join();
  }

  Future<dynamic> fetchContentReport() async {
    var res = await http.get(
        headers: {"Content-type": "application/json"},
        Uri.parse("${api}getContentReports"));
    return json.decode(res.body)["content"];
  }

  Future<dynamic> sendReport(option, genealogy, context) async {
    try {
      var res = await http.post(
          headers: {"Content-type": "application/json"},
          Uri.parse("${api}sendReport"),
          body: json.encode({
            'addressWallet': sender,
            'option': option,
            'genealogy': genealogy
          }));
      if (json.decode(res.body)["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Gửi tố cáo thành công"),
          duration: Duration(seconds: 1),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Bạn đã gửi tố cáo"),
          duration: Duration(seconds: 1),
        ));
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi"), duration: Duration(seconds: 1)));
    }
  }

  Future<dynamic> addToCart(
      name, tokenId, image, price, typeFile, author, context) async {
    try {
      print(tokenId);
      var body = {
        "addressWallet": sender,
        "cart": {
          "name": name,
          "tokenId": tokenId,
          "image": image,
          "price": price,
          "typeFile": typeFile,
          "author": author
        }
      };
      var res = await http.post(
          headers: {"Content-type": "application/json"},
          Uri.parse("${api}addToCart"),
          body: json.encode(body));
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Đã thêm sản phẩm vào giỏ"),
          duration: Duration(seconds: 1),
        ));
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi"), duration: Duration(seconds: 1)));
    }
  }

  Future<dynamic> fetchUserCart() async {
    try {
      var res = await http.get(
          headers: {"Content-type": "application/json"},
          Uri.parse("${api}address/${sender}"));
      if (res.statusCode == 200) {
        return json.decode(res.body)["user"]["cart"];
      }
    } catch (err) {
      print(err);
    }
  }

  Future<dynamic> removeItemCart(tokenId) async {
    try {
      var body = {
        "addressWallet": sender,
        "tokenId": tokenId,
      };
      var res = await http.post(
          headers: {"Content-type": "application/json"},
          Uri.parse("${api}deleteCart"),
          body: json.encode(body));
      if (res.statusCode == 200) {
        fetchUserCart();
      }
    } catch (err) {}
  }

  Future<dynamic> removeAllCart(context) async {
    try {
      var body = {
        "addressWallet": sender,
      };
      var res = await http.post(
          headers: {"Content-type": "application/json"},
          Uri.parse("${api}deleteALLCart"),
          body: json.encode(body));
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Xóa thành công"), duration: Duration(seconds: 1)));
        return true;
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Có lỗi trong khi xóa"),
          duration: Duration(seconds: 1)));
    }
  }
}
