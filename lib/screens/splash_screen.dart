import 'package:flutter/material.dart';
import 'package:nft_marketplace/provider/NFTMarketProvider.dart';
import 'package:nft_marketplace/screens/profile_screen.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({required this.label, required this.detailsPath, Key? key})
      : super(key: key);
  final String label;
  final String detailsPath;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollViewController;
  bool loadding = false;
  TextEditingController searchTXT = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _scrollViewController = ScrollController(initialScrollOffset: 0.0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NFTMarketProvider>(
      builder: (context, value, child) => value.loged != true
          ? Scaffold(
              appBar: AppBar(
                title: const Text('Hồ sơ'),
              ),
              body: Center(
                  child: value.isLoading == true
                      ? const CircularProgressIndicator()
                      : Wrap(
                          runSpacing: 80,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/images/metamask-icon.png'),
                                      fit: BoxFit.contain)),
                              width: MediaQuery.of(context).size.width,
                              height: 180,
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: const Column(
                                children: [
                                  Text(
                                    "Đăng nhập vào ví của bạn",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text("Hỗ trợ kết nối với ví MetaMask",
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      )),
                                  Text("Ví để lưu trữ an toàn tài sản của bạn",
                                      style: TextStyle(
                                        height: 1.5,
                                        color: Colors.grey,
                                        fontWeight: FontWeight.bold,
                                      ))
                                ],
                              ),
                            ),
                            Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15)),
                                    onPressed: () {
                                      value
                                          .loginUsingMetamask(context)
                                          .then((e) {
                                        if (value.loged == true) {
                                          value
                                              .getSigner()
                                              .then(() => setState(() {
                                                    loadding = value.loged;
                                                  }));
                                        }
                                      });
                                    },
                                    child: const Text(
                                      "Kết nối ví",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ))),
                            SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: const Center(
                                    child:
                                        Text("Chưa kết nối ví? Hãy cài đặt")))
                          ],
                        )),
            )
          : ProfileScreen(
              address: "",
            ),
    );
  }
}
