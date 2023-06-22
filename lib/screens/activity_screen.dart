import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/NFTMarketProvider.dart';
import '../widgets/search_input.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({required this.label, required this.detailsPath, Key? key})
      : super(key: key);
  final String label;
  final String detailsPath;

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  var _searchContent = TextEditingController();

  List<String> types = ["Mua bán", "Bán lại," "Đấu giá"];
  bool btnAuction = true;
  bool btnSale = false;
  bool btnResell = false;
  @override
  void initState() {
    Provider.of<NFTMarketProvider>(context, listen: false).fetchAuction();
    super.initState();
  }

  Color _buttonColor = Colors.blue;
  @override
  Widget build(BuildContext context) {
    var contractLink = Provider.of<NFTMarketProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        shape: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
        title: Text(widget.label),
        centerTitle: true,
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          _showBottomSheet();
                        },
                        child: Row(
                          children: [
                            Text(types
                                .toString()
                                .replaceAll('[', '')
                                .replaceAll(']', '')),
                            Icon(Icons.arrow_drop_down)
                          ],
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2,
                      child: SearchInput(
                        searchContent: _searchContent,
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
      body: ListView.separated(
        itemCount: contractLink.auctions.length,
        separatorBuilder: (context, index) {
          return Divider(
            color: Colors.grey,
          );
        },
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.only(top: 10, left: 15, right: 15),
            leading: Container(
              width: 50,
              height: 50,
              color: Colors.blue,
            ),
            title: Text("Chưa đặt tên",
                style: TextStyle(color: Colors.grey, fontSize: 13)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contractLink.auctions[index].name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 16)),
                TextButton(
                    onPressed: () {},
                    child: Text(
                      "+ Thêm",
                      style: TextStyle(fontSize: 13),
                    ))
              ],
            ),
            trailing: Column(
              children: [
                Text(contractLink.auctions[index].lastBid.toString()),
                Text("Thời gian"),
                Text("Đấu giá")
              ],
            ),
          );
        },
      ),
    );
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              child: Wrap(
                runSpacing: 10,
                alignment: WrapAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Align(
                      child: Text(
                        "Chọn loại",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: btnSale == false
                              ? _buttonColor = Colors.grey
                              : _buttonColor = Colors.blue),
                      onPressed: () {
                        setState(() {
                          btnSale = !btnSale;
                        });
                      },
                      child: Text("Mua bán")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: btnResell == false
                              ? _buttonColor = Colors.grey
                              : _buttonColor = Colors.blue),
                      onPressed: () {
                        setState(() {
                          btnResell = !btnResell;
                        });
                      },
                      child: Text("Bán lại")),
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: btnAuction == false
                              ? _buttonColor = Colors.grey
                              : _buttonColor = Colors.blue),
                      onPressed: () {
                        setState(() {
                          btnAuction = !btnAuction;
                        });
                      },
                      child: Text("Đấu giá")),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: () {},
                        child: Text(
                          "Áp dụng",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        )),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
