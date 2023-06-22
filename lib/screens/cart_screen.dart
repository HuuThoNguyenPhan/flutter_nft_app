import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:nft_marketplace/provider/NFTMarketProvider.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool isChecked = false;
  bool loading = true;
  List<dynamic> carts = [];
  @override
  void initState() {
    Provider.of<NFTMarketProvider>(context, listen: false)
        .fetchUserCart()
        .then((value) {
      setState(() {
        if (value != null) {
          carts = value;
        }
        loading = !loading;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var contractlink = Provider.of<NFTMarketProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text("Giỏ hàng (${carts.length})"),
        actions: [
          IconButton(
              onPressed: () {
                contractlink.removeAllCart(context).then((value) {
                  setState(() {
                    carts = [];
                  });
                });
              },
              icon: Icon(
                Icons.remove_shopping_cart_outlined,
                color: Colors.black,
              ))
        ],
      ),
      body: loading == true
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                carts.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).size.width / 2),
                          child: Text(
                            "Hãy thêm sản phẩm",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 50),
                        child: ListView.separated(
                          separatorBuilder: (context, index) {
                            return Divider(
                              height: 0,
                              color: Colors.grey,
                            );
                          },
                          itemBuilder: (context, index) => Slidable(
                            endActionPane: ActionPane(
                                extentRatio: 0.2,
                                motion: BehindMotion(),
                                children: [
                                  SlidableAction(
                                    autoClose: true,
                                    onPressed: (context) {
                                      contractlink
                                          .removeItemCart(
                                              carts[index]['tokenId'])
                                          .then((value) {
                                        setState(() {
                                          carts.removeAt(index);
                                        });
                                      });
                                      print("xóa");
                                    },
                                    backgroundColor: Colors.red,
                                    icon: Icons.delete,
                                  )
                                ]),
                            child: Container(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: renderImage(
                                            carts[index]['typeFile'],
                                            carts[index]['image'])),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            carts[index]['name'] +
                                                " #" +
                                                carts[index]['tokenId'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue,
                                              fontSize: 16,
                                            )),
                                        Text(
                                            "User_${carts[index]['author'].substring(carts[index]['author'].length - 4)}",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                                height: 1.5)),
                                        Text(
                                          "Tiền bản quyền: 1%",
                                          style: TextStyle(
                                              fontSize: 13,
                                              height: 1.5,
                                              color: Colors.grey),
                                        ),
                                        RichText(
                                            text: TextSpan(children: [
                                          TextSpan(
                                              text: "Đơn giá: ",
                                              style: TextStyle(
                                                  color: Colors.black)),
                                          TextSpan(
                                              text:
                                                  "${carts[index]['price']} ETH",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold))
                                        ]))
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          itemCount: carts.length,
                        ),
                      ),
                Positioned(
                    bottom: 0,
                    width: MediaQuery.of(context).size.width,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      color: Colors.white,
                      child: Wrap(
                        runSpacing: 5,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: RichText(
                              text: TextSpan(
                                text: 'Tổng thanh toán: ',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black),
                                children: <TextSpan>[
                                  TextSpan(
                                      text:
                                          "${carts.isNotEmpty ? carts.map((e) => e['price']).toList().reduce((value, element) => value + element) : 0} ETH",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   width: MediaQuery.of(context).size.width,
                          //   child: ElevatedButton(
                          //       style: ElevatedButton.styleFrom(
                          //           padding: EdgeInsets.symmetric(
                          //               vertical: 13, horizontal: 25)),
                          //       onPressed: () {},
                          //       child: Text("Thanh toán",
                          //           style: TextStyle(
                          //               fontWeight: FontWeight.bold))),
                          // )
                        ],
                      ),
                    ))
              ],
            ),
    );
  }

  renderImage(typeFile, url) {
    switch (typeFile) {
      case "image":
        return CachedNetworkImage(
          fit: BoxFit.cover,
          width: 80,
          height: 80,
          imageUrl: url,
          placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
            color: Colors.grey,
          )),
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.error)),
        );
      case "video":
        return Image.asset(
          "assets/images/nft-video.png",
          width: 80,
          height: 80,
        );
      case "audio":
        return Image.asset("assets/images/nft-music.png",
            width: 80, height: 80);
      default:
        return Image.asset("assets/images/nft-application.png",
            width: 80, height: 80);
    }
  }
}
