import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:web3dart/contracts.dart';
import 'package:web3dart/credentials.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

import 'config.dart';

class ContractFactory {
  late String _abiCode;
  late EthereumAddress _contractAddress;
  final String api = Config.api;
  late DeployedContract _contract;
  late Web3Client _client;
  late ContractFunction _tokenURI;
  late ContractFunction _ownerOf;
  late ContractFunction _detailNFT;

  ContractFactory(Web3Client client) {
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
        await rootBundle.loadString("src/artifacts/NFTFactory.json");
    var jsonAbi = jsonDecode(abiStringFile);
    _abiCode = jsonEncode(jsonAbi["abi"]);
    // print(_abiCode);
    var address = await getContractAddress();
    _contractAddress = EthereumAddress.fromHex(address["nftFactory"]);
    // print(_contractAddress);
  }

  Future<void> getDeployedContract() async {
    // Telling Web3dart where our contract is declared.
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "NFTFactory"), _contractAddress);
    // Extracting the functions, declared in contract.
    _tokenURI = _contract.function("tokenURI");
    _ownerOf = _contract.function("ownerOf");
    _detailNFT = _contract.function("detailNFT");
  }

  Future<dynamic> getContractAddress() async {
    var res = await http.get(
        headers: {"Content-type": "application/json"},
        Uri.parse("${api}addresses"));
    return json.decode(res.body)["address"];
  }

  Future<List<dynamic>> getTokenURI(String id) async {
    return await _client.call(
        contract: _contract, function: _tokenURI, params: [BigInt.parse(id)]);
  }
  Future<dynamic> getDetail(String id) async {
    return await _client.call(
        contract: _contract, function: _detailNFT, params: [BigInt.parse(id)]);
  }
}
