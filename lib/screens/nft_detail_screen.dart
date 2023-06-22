import 'dart:async';
import 'dart:math';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nft_marketplace/screens/profile_screen.dart';

import 'package:nft_marketplace/widgets/section.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../model/nft.dart';
import '../provider/NFTMarketProvider.dart';
import '../routes/routes.dart';
import 'package:video_player/video_player.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:jazzicon/jazzicon.dart';

class NFTDetailScreen extends StatefulWidget {
  NFTDetailScreen({Key? key, required this.nft}) : super(key: key);
  late NFT nft;

  @override
  State<NFTDetailScreen> createState() => _NFTDetailScreenState();
}

class PositionData {
  const PositionData(this.position, this.bufferedPosition, this.duration);
  final Duration position;
  final Duration bufferedPosition;
  final Duration duration;
}

class _NFTDetailScreenState extends State<NFTDetailScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectTime = TimeOfDay.now();
  bool loading = false;
  bool error = false;
  String titleError = "";
  late FlickManager flickManager;
  late AudioPlayer audioPlayer;
  String renderTime = "";
  bool displayBidBtn = false;
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        audioPlayer.positionStream,
        audioPlayer.bufferedPositionStream,
        audioPlayer.durationStream,
        (position, bufferedPosition, duration) =>
            PositionData(position, bufferedPosition, duration ?? Duration.zero),
      );

  _selectEndDate(BuildContext context, dateTXT) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateTXT.text = DateFormat('dd/MM/yyyy').format(selectedDate);
      });
  }

  _selectStartDate(BuildContext context, dateTXT) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateTXT.text = DateFormat('dd/MM/yyyy').format(selectedDate);
      });
  }

  _selectStartTime(BuildContext context, timeTXT) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectTime);
    if (picked != null && picked != selectTime)
      setState(() {
        selectTime = picked;
        timeTXT.text = selectTime
            .toString()
            .substring(10, TimeOfDay.now().toString().length - 1);
      });
  }

  _selectEndTime(BuildContext context, timeTXT) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: selectTime);
    if (picked != null && picked != selectTime)
      setState(() {
        selectTime = picked;
        timeTXT.text = selectTime
            .toString()
            .substring(10, TimeOfDay.now().toString().length - 1);
      });
  }

  @override
  void initState() {
    print(widget.nft.typeFile);
    loadData();
    initMedia();
    super.initState();
  }

  initMedia() {
    switch (widget.nft.typeFile) {
      case "video":
        _playVideo();
        break;
      case "audio":
        _playAudio();
        break;
      default:
        break;
    }
  }

  _playAudio() {
    audioPlayer = AudioPlayer()..setUrl(widget.nft.image);
  }

  _playVideo() {
    flickManager = FlickManager(
      videoPlayerController: VideoPlayerController.network(widget.nft.image)
        ..setLooping(true),
    );
  }

  Future<void> loadData() async {
    widget.nft.auctionId != ""
        ? {
            setState(() {
              loading = true;
            }),
            await Provider.of<NFTMarketProvider>(context, listen: false)
                .getDetailAuction(widget.nft.auctionId)
                .then((value) {
              widget.nft = value;
              setState(() {
                loading = false;
              });
            }),
            subscription =
                await Provider.of<NFTMarketProvider>(context, listen: false)
                    .join(),
            subscription.listen((event) {
              decode = Provider.of<NFTMarketProvider>(context, listen: false)
                  .getContractEvent()
                  .decodeResults(event.topics!, event.data!);
              decode[2].toString() == widget.nft.auctionId
                  ? {
                      setState(() {
                        widget.nft.lastBid =
                            decode[1] / BigInt.from(pow(10, 18));
                        widget.nft.lastBidder = decode[0].toString();
                      })
                    }
                  : null;
            }),
            _setIntterval()
          }
        : null;
    priceTXT.text = widget.nft.price.toString();
  }

  _setIntterval() {
    _duration =
        DateTime.fromMillisecondsSinceEpoch(int.parse(widget.nft.endTime))
            .difference(DateTime.now());
    if (_duration <= Duration.zero) {
      _duration = Duration.zero;
      renderTime = "Đấu giá đã kết thúc";
    } else {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(
                int.parse(widget.nft.startTime))) <=
            Duration.zero) {
          setState(() {
            renderTime =
                "Bắt đầu lúc: ${DateTime.fromMillisecondsSinceEpoch(int.parse(widget.nft.startTime))}";
          });
        } else {
          setState(() {
            displayBidBtn = true;
            _duration = DateTime.fromMillisecondsSinceEpoch(
                    int.parse(widget.nft.endTime))
                .difference(DateTime.now());
            renderTime =
                "Kết thúc trong vòng ${_duration.inDays} ngày ${_duration.inHours % 24} giờ ${_duration.inMinutes % 60} phút ${_duration.inSeconds % 60} giây";
          });
          if (_duration <= Duration.zero) {
            displayBidBtn = false;
            timer.cancel();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    switch (widget.nft.typeFile) {
      case "video":
        flickManager.dispose();
        break;
      case "audio":
        audioPlayer.dispose();
        break;
      default:
        break;
    }
    if (subscription != null) {
      subscription = null;
    }
    if (_duration > Duration.zero) {
      _timer.cancel();
    }
    super.dispose();
  }

  TextEditingController quantityTXT = TextEditingController(text: "1");
  TextEditingController priceTXT = TextEditingController();
  TextEditingController initialPriceTXT = TextEditingController();
  TextEditingController limitTXT = TextEditingController(text: "1");
  TextEditingController startTime = TextEditingController(
      text: TimeOfDay.now()
          .toString()
          .substring(10, TimeOfDay.now().toString().length - 1));
  TextEditingController startDay = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  TextEditingController endTime = TextEditingController(
      text: TimeOfDay.now()
          .toString()
          .substring(10, TimeOfDay.now().toString().length - 1));
  TextEditingController endDay = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  TextEditingController initialPrice = TextEditingController();
  int reason = 0;
  double sumPrice = 0.0;
  final _formKey = GlobalKey<FormState>();
  dynamic subscription;
  List decode = [];
  late Timer _timer;
  Duration _duration = Duration(seconds: -1);
  bool _isExpanded = false;
  BuildContext? rootContext;
  @override
  Widget build(BuildContext context) {
    var contractLink = Provider.of<NFTMarketProvider>(context);
    rootContext = context;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: MediaQuery.of(context).size.width,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero,
                    shape: const CircleBorder()),
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(
                  Icons.arrow_back_ios_sharp,
                  size: 20,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    padding: const EdgeInsets.all(8),
                    minimumSize: Size.zero,
                    shape: const CircleBorder()),
                onPressed: () {
                  contractLink.fetchContentReport().then(
                      (value) => _dialogBuilder(context, value, contractLink));
                },
                child: const Icon(
                  Icons.flag,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
      body: loading || contractLink.isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: renderMedia(widget.nft.typeFile)),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.nft.name,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Thể loại: ${widget.nft.topics.replaceAll(RegExp(r'\[|\]'), '')}",
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            widget.nft.description.length > 50
                                ? Column(
                                    children: [
                                      RichText(
                                          text: TextSpan(
                                              style: TextStyle(
                                                  color: Colors.black),
                                              children: [
                                            TextSpan(
                                                text: _isExpanded
                                                    ? widget.nft.description
                                                    : '${widget.nft.description.substring(0, 50)}...'),
                                            TextSpan(
                                              style:
                                                  TextStyle(color: Colors.grey),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  // Xử lý sự kiện nhấp vào đây
                                                  setState(() {
                                                    _isExpanded = !_isExpanded;
                                                  });
                                                },
                                              text: _isExpanded
                                                  ? 'Rút gọn'
                                                  : 'Xem thêm',
                                            )
                                          ])),
                                    ],
                                  )
                                : Text(widget.nft.description),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              child: Row(
                                children: [
                                  Jazzicon.getIconWidget(
                                      Jazzicon.getJazziconData(25,
                                          address: widget.nft.author)),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        style: TextStyle(color: Colors.black),
                                        text: 'Tác giả ',
                                      ),
                                      TextSpan(
                                          style: TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold),
                                          text:
                                              "User_${widget.nft.author.substring(widget.nft.author.length - 4)}")
                                    ]),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      ProfileScreen(address: widget.nft.author),
                                ));
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            GestureDetector(
                              child: Row(
                                children: [
                                  Jazzicon.getIconWidget(
                                      Jazzicon.getJazziconData(25,
                                          address: widget.nft.auctionId != ""
                                              ? widget.nft.auctioneer
                                              : widget.nft.sender)),
                                  SizedBox(
                                    width: 15,
                                  ),
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        style: TextStyle(color: Colors.black),
                                        text: 'Người đăng ',
                                      ),
                                      TextSpan(
                                        style: TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold),
                                        text: widget.nft.auctionId != ""
                                            ? "User_${widget.nft.auctioneer.substring(widget.nft.auctioneer.length - 4)}"
                                            : "User_${widget.nft.sender.substring(widget.nft.sender.length - 4)}",
                                      )
                                    ]),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ProfileScreen(
                                    address: widget.nft.auctionId != ""
                                        ? widget.nft.auctioneer
                                        : widget.nft.sender,
                                  ),
                                ));
                              },
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            widget.nft.auctionId != ""
                                ? Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(width: 0.5)),
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(renderTime),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text("Giá hiện tại"),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "${widget.nft.lastBid} ETH",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          // Text(
                                          //     "changeCurrency(widget.nft.price).toString()"),
                                          // SizedBox(
                                          //   height: 5,
                                          // ),
                                          widget.nft.lastBidder !=
                                                  "0x0000000000000000000000000000000000000000"
                                              ? Row(
                                                  children: [
                                                    Text(
                                                        "Người đấu giá cuối cùng"),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Jazzicon.getIconWidget(
                                                        Jazzicon.getJazziconData(
                                                            25,
                                                            address: widget.nft
                                                                .lastBidder)),
                                                    SizedBox(
                                                      width: 5,
                                                    ),
                                                    Text(
                                                      "User_${widget.nft.lastBidder.substring(widget.nft.lastBidder.length - 4)}",
                                                      style: TextStyle(
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                )
                                              : SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(width: 0.5)),
                                    child: Padding(
                                      padding: EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              "Đăng lúc ${widget.nft.createAt}"),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text("Giá hiện tại"),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "${widget.nft.price} ETH",
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          // Text(
                                          //     "changeCurrency(widget.nft.price).toString()"),
                                          // SizedBox(
                                          //   height: 5,
                                          // ),
                                          Text(
                                            "Còn ${widget.nft.count} sản phẩm",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                            ExpansionTile(
                              tilePadding: EdgeInsets.all(0),
                              title: Text(
                                "Thông tin chi tiết",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              children: [
                                Divider(color: Colors.black, indent: 0.5),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Địa chỉ tác giả",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          "Token ID",
                                          style: TextStyle(
                                              fontSize: 16, height: 1.5),
                                        ),
                                        Text(
                                          "Loại tệp",
                                          style: TextStyle(
                                              fontSize: 16, height: 1.5),
                                        ),
                                        Text(
                                          "Chuẩn Token",
                                          style: TextStyle(
                                              fontSize: 16, height: 1.5),
                                        ),
                                        Text(
                                          "Tiền tệ",
                                          style: TextStyle(
                                              fontSize: 16, height: 1.5),
                                        ),
                                        Text(
                                          "Phí bản quyền",
                                          style: TextStyle(
                                              fontSize: 16, height: 1.5),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.nft.author.replaceRange(
                                              4,
                                              widget.nft.author.length - 3,
                                              "..."),
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(widget.nft.tokenId),
                                        Text(widget.nft.typeFile),
                                        Text("ERC-721",
                                            style: TextStyle(
                                                fontSize: 16, height: 1.5)),
                                        Text("Etherium",
                                            style: TextStyle(
                                                fontSize: 16, height: 1.5)),
                                        Text(
                                            widget.nft.royalties
                                                .toString()
                                                .replaceAll(".0", "%"),
                                            style: TextStyle(
                                                fontSize: 16, height: 1.5)),
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Section(
                          title: "Một số NFT khác",
                          detailsPath: "${Routes.home}/${Routes.nftDetails}",
                          nfts: contractLink.nfts
                              .where((element) => element.topics
                                  .replaceAll(RegExp(r'\[|\]'), '')
                                  .contains(widget.nft.topics
                                      .replaceAll(RegExp(r'\[|\]'), '')))
                              .toList()),
                      SizedBox(
                        height: 50,
                      )
                    ],
                  ),
                ),
                Positioned(
                    bottom: 0,
                    child: Container(
                        padding: const EdgeInsets.all(10),
                        width: MediaQuery.of(context).size.width,
                        color: Colors.white,
                        child: widget.nft.auctioneer != contractLink.sender &&
                                _duration <= Duration.zero &&
                                widget.nft.auctionId != ""
                            ? SizedBox.shrink()
                            : allBtn(contractLink)))
              ],
            ),
    );
  }

  Widget changeNum(TextEditingController txt, String label, max) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(
          height: 5,
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 20,
          child: TextFormField(
            readOnly: widget.nft.count == 1 ? true : false,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Vui lòng nhập trường này';
              } else if (value == '0' || value == '0.0') {
                return 'Số nhập vào phải lớn hơn 0';
              } else if (int.parse(value) > max) {
                return 'Số nhập vào phải > 0 và ≤ $max';
              }
              return null;
            },
            controller: txt,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                border: OutlineInputBorder(),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 5),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10)),
          ),
        ),
      ],
    );
  }

  bool compare(a, b) {
    if (int.parse(a) < int.parse(b)) {
      return true;
    }
    return false;
  }

  void _showModalResell(context, NFTMarketProvider function) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Form(
                key: _formKey,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 10,
                  runSpacing: 15,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 20,
                      child: Text(
                        "Điền thông tin",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Giá bán lại",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 20,
                          child: TextFormField(
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d{1,9}(\.\d{0,4})?$'))
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập trường này';
                              } else if (value == '0' || value == '0.0') {
                                return 'Số nhập vào phải lớn hơn 0';
                              }
                              return null;
                            },
                            controller: priceTXT,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 5),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10)),
                          ),
                        ),
                      ],
                    ),
                    changeNum(quantityTXT, "Số lượng", widget.nft.count),
                    changeNum(
                        limitTXT, "Giới hạn mua", int.parse(quantityTXT.text)),
                    error == true
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width - 30,
                            child: Text(
                              titleError,
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 13, horizontal: 25)),
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          } else if (int.parse(quantityTXT.text) <
                              int.parse(limitTXT.text)) {
                            setState(() {
                              error = true;
                              titleError = 'Giới hạn mua phải ≤ số lượng';
                            });
                          } else {
                            setState(() {
                              Navigator.of(context).pop();
                              error = false;
                              titleError = "";
                            });
                            launchUrlString(function.url,
                                mode: LaunchMode.externalApplication);

                            function
                                .resellNFT(
                              widget.nft,
                              double.parse(priceTXT.text),
                              int.parse(quantityTXT.text),
                            )
                                .then((value) {
                              function.fetchMyNFTs(function.sender).then(
                                  (value) => Navigator.of(rootContext!).pop());
                            });
                          }
                        },
                        child: Text(
                          "Bán lại",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((value) {
      error = false;
      titleError = "";
    });
  }

  _showModalBuy(context, NFTMarketProvider function) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            sumPrice = int.parse(quantityTXT.text) * widget.nft.price;
            int limit = widget.nft.count < widget.nft.limit
                ? widget.nft.count
                : widget.nft.limit;
            return Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Form(
                key: _formKey,
                child: Wrap(
                  runSpacing: 15,
                  spacing: 10,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      child: Text(
                        "Đơn giá",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      child: Text(
                        "Tổng",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      child: Text(
                        widget.nft.price.toString() + " ETH",
                        style: TextStyle(fontSize: 18),
                      ),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5)),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(
                        "$sumPrice ETH",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                    widget.nft.limit == 1 || widget.nft.only == true
                        ? SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Số lượng mua ≤ $limit",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width / 2 - 20,
                                child: TextFormField(
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.digitsOnly
                                  ],
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Vui lòng nhập trường này';
                                    } else if (value == '0') {
                                      return 'Số nhập vào phải lớn hơn 0';
                                    }
                                    return null;
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      sumPrice = int.parse(quantityTXT.text) *
                                          widget.nft.price;
                                    });
                                  },
                                  controller: quantityTXT,
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      errorBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: Colors.red, width: 5),
                                      ),
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 10)),
                                ),
                              ),
                            ],
                          ),
                    error == true
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Text(
                              titleError,
                              style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.w500),
                            ))
                        : SizedBox.shrink(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 13, horizontal: 25)),
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          } else if (int.parse(quantityTXT.text) > limit) {
                            setState(() {
                              error = true;
                              titleError =
                                  "Nhập số lượng mua nhỏ hơn hoặc bằng $limit ";
                            });
                          } else {
                            Navigator.pop(context);
                            setState(() {
                              error = false;
                              titleError = "";
                            });
                            launchUrlString(function.url,
                                    mode: LaunchMode.externalApplication)
                                .then((value) => print("a"));
                            function
                                .buyNFT(widget.nft, int.parse(quantityTXT.text))
                                .then((value) {
                              function.fetchMarketItems().then(
                                    (value) => Navigator.pop(rootContext!),
                                  );
                            });
                          }
                        },
                        child: Text(
                          "Thanh toán",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _dialogBuilder(
      BuildContext context, contents, NFTMarketProvider function) async {
    List<String> stringList = List<String>.from(
        contents.map((dynamic item) => item["description"].toString()));
    return await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tố cáo sản phẩm'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return DropdownButton<int>(
                value: reason,
                onChanged: (newValue) {
                  setState(() {
                    reason = newValue!;
                  });
                },
                items: stringList
                    .asMap()
                    .entries
                    .map<DropdownMenuItem<int>>((value) {
                  int index = value.key;
                  String option = value.value;
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(option),
                  );
                }).toList(),
              );
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                if (function.loged == false) {
                  function.loginUsingMetamask(context);
                } else {
                  function
                      .sendReport(reason, widget.nft.genealogy, context)
                      .then((value) => Navigator.pop(context));
                }
              },
              child: Text('Tố cáo'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  void _showModalAuction(context, NFTMarketProvider function) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Form(
                key: _formKey,
                child: Wrap(
                  alignment: WrapAlignment.start,
                  runSpacing: 15,
                  spacing: 10,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: Text(
                        "Nhập giá cược",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      child: TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập trường này';
                          } else if (value == '0' || value == '0.0') {
                            return 'Số nhập vào phải lớn hơn 0';
                          } else if (double.parse(value) <
                              double.parse(calBid(widget.nft.lastBid))) {
                            return 'Số nhập vào ≥ ${calBid(widget.nft.lastBid)}';
                          }
                          return null;
                        },
                        controller: priceTXT,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            errorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.red, width: 5),
                            ),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10)),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      child: Text(
                        'Giá nhập vào ≥ ${calBid(widget.nft.lastBid)} ETH',
                        style: TextStyle(color: Colors.blue, fontSize: 16),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 13, horizontal: 25)),
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          } else {
                            Navigator.pop(context);
                            launchUrlString(function.url,
                                mode: LaunchMode.externalApplication);
                            function.joinAuction(widget.nft.auctionId,
                                double.parse(priceTXT.text));
                          }
                        },
                        child: Text(
                          "Đấu giá",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
  // const calBid = (val) => {
  //   return parseFloat((val * 10) / 100) + parseFloat(val);
  // };

  String calBid(val) {
    var a = val * 10 / 100 + val;
    return a.toString();
  }

  void _showModalCreateAuction(context, NFTMarketProvider function) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Form(
                key: _formKey,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 10,
                  runSpacing: 15,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 20,
                      child: Text(
                        "Mở phiên đấu giá",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        child: Stack(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ngày bắt đầu",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: startDay,
                                readOnly: true,
                                onTap: () {
                                  _selectStartDate(context, startDay);
                                },
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.calendar_month_sharp,
                                      size: 35,
                                      color: Colors.blue,
                                    ),
                                    border: OutlineInputBorder(),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 5),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10)),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        child: Stack(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Thời gian bắt đầu",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: startTime,
                                readOnly: true,
                                onTap: () {
                                  _selectStartTime(context, startTime);
                                },
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.calendar_month_sharp,
                                      size: 35,
                                      color: Colors.blue,
                                    ),
                                    border: OutlineInputBorder(),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 5),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10)),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        child: Stack(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ngày Kết thúc",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: endDay,
                                readOnly: true,
                                onTap: () {
                                  _selectEndDate(context, endDay);
                                },
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.calendar_month_sharp,
                                      size: 35,
                                      color: Colors.blue,
                                    ),
                                    border: OutlineInputBorder(),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 5),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10)),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 20,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        child: Stack(children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Thời gian kết thúc",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              TextFormField(
                                controller: endTime,
                                readOnly: true,
                                onTap: () {
                                  _selectEndTime(context, endTime);
                                },
                                keyboardType: TextInputType.datetime,
                                decoration: InputDecoration(
                                    prefixIcon: Icon(
                                      Icons.calendar_month_sharp,
                                      size: 35,
                                      color: Colors.blue,
                                    ),
                                    border: OutlineInputBorder(),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 5),
                                    ),
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10)),
                              ),
                            ],
                          ),
                        ]),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Giá khởi điểm",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2 - 20,
                          child: TextFormField(
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d{1,9}(\.\d{0,4})?$'))
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập trường này';
                              } else if (value == '0' || value == '0.0') {
                                return 'Số nhập vào phải lớn hơn 0';
                              }
                              return null;
                            },
                            controller: initialPriceTXT,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Colors.red, width: 5),
                                ),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 10)),
                          ),
                        ),
                      ],
                    ),
                    error == true
                        ? SizedBox(
                            width: MediaQuery.of(context).size.width - 30,
                            child: Text(
                              titleError,
                              style: TextStyle(color: Colors.red),
                            ),
                          )
                        : SizedBox.shrink(),
                    SizedBox(
                      width: MediaQuery.of(context).size.width - 30,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 13, horizontal: 25)),
                        onPressed: () {
                          var y = int.parse(startDay.text.substring(6, 10));
                          var d = int.parse(startDay.text.substring(0, 2));
                          var m = int.parse(startDay.text.substring(3, 5));
                          var h = int.parse(startTime.text.substring(0, 2));
                          var min = int.parse(startTime.text.substring(3, 5));
                          var y2 = int.parse(endDay.text.substring(6, 10));
                          var d2 = int.parse(endDay.text.substring(0, 2));
                          var m2 = int.parse(endDay.text.substring(3, 5));
                          var h2 = int.parse(endTime.text.substring(0, 2));
                          var min2 = int.parse(endTime.text.substring(3, 5));
                          var finalStartTime =
                              DateTime(y, m, d, h, min).millisecondsSinceEpoch;
                          var finalEndTime = DateTime(y2, m2, d2, h2, min2)
                              .millisecondsSinceEpoch;
                          int now = DateTime.now().microsecondsSinceEpoch;
                          now = int.parse(now.toString().substring(0, 13));
                          if (!_formKey.currentState!.validate()) {
                            return;
                          } else if (finalStartTime > finalEndTime) {
                            setState(() {
                              error = true;
                              titleError =
                                  'Thời gian bắt đầu < Thời gian kết thúc';
                            });
                          } else if (finalStartTime < now ||
                              finalEndTime < now) {
                            print(finalStartTime < now);
                            setState(() {
                              error = true;
                              titleError =
                                  'Thời gian bắt đầu và Thời gian kết thúc ≥ Thời gian hiện tại ';
                            });
                          } else {
                            setState(() {
                              error = false;
                              titleError = "";
                            });
                            Navigator.pop(context, true);
                            launchUrlString(function.url,
                                mode: LaunchMode.externalApplication);
                            function
                                .createAuction(
                                    widget.nft.tokenId,
                                    double.parse(initialPriceTXT.text),
                                    finalStartTime,
                                    finalEndTime,
                                    widget.nft.name)
                                .then((value) {
                              function
                                  .fetchMyNFTs(function.sender)
                                  .then((value) => Navigator.pop(rootContext!));
                            });
                          }
                        },
                        child: Text(
                          "Hoàn tất",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((value) {
      error = false;
      titleError = "";
    });
  }

  renderMedia(typeFile) {
    switch (typeFile) {
      case "image":
        return CachedNetworkImage(
          imageBuilder: (context, imageProvider) => Container(
            width: 350,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(image: imageProvider, fit: BoxFit.contain),
            ),
          ),
          height: 350,
          imageUrl: widget.nft.image,
          placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(
            color: Colors.grey,
          )),
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.error)),
        );
      case "video":
        return SizedBox(
          width: 350,
          height: 350,
          child: FlickVideoPlayer(
            flickManager: flickManager,
          ),
        );
      case "audio":
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.amber,
                  image: DecorationImage(
                      image: AssetImage("assets/images/nft-music.png"))),
              height: 350,
              width: 350,
              child: Center(
                child: StreamBuilder(
                  stream: audioPlayer.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;
                    if (!(playing ?? false)) {
                      return IconButton(
                          onPressed: audioPlayer.play,
                          iconSize: 80,
                          color: Colors.white,
                          icon: Icon(Icons.play_arrow_rounded));
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                          onPressed: audioPlayer.pause,
                          iconSize: 80,
                          color: Colors.white,
                          icon: Icon(Icons.pause));
                    }
                    return const Icon(Icons.play_arrow_rounded);
                  },
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                child: SizedBox(
                  width: 350,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: StreamBuilder<PositionData>(
                      stream: _positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return ProgressBar(
                            barHeight: 8,
                            baseBarColor: Colors.grey[600],
                            bufferedBarColor: Colors.grey,
                            timeLabelTextStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            onSeek: audioPlayer.seek,
                            progress: positionData?.position ?? Duration.zero,
                            buffered:
                                positionData?.bufferedPosition ?? Duration.zero,
                            total: positionData?.duration ?? Duration.zero);
                      },
                    ),
                  ),
                ))
          ],
        );
      default:
        return Image.asset(
          "assets/images/nft-application.png",
          height: 350,
          width: 350,
        );
    }
  }

  Widget btnResell(contractLink) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 15,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0))),
            ),
            onPressed: () {
              _showModalResell(context, contractLink);
            },
            child: const Text("Bán lại"),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 15,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0))),
            ),
            onPressed: () {
              _showModalCreateAuction(context, contractLink);
            },
            child: const Text("Mở phiên đấu giá"),
          ),
        ),
      ],
    );
  }

  Widget btnBuy(contractLink) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widget.nft.only == true
            ? SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 15,
                child: ElevatedButton(
                    onPressed: () {
                      if (contractLink.loged == false) {
                        contractLink.loginUsingMetamask(context);
                      } else {
                        setState(() {
                          loading = true;
                        });
                        contractLink
                            .addToCart(
                                widget.nft.name,
                                widget.nft.tokenId,
                                widget.nft.image,
                                widget.nft.price,
                                widget.nft.typeFile,
                                widget.nft.author,
                                context)
                            .then((value) {
                          setState(() {
                            loading = false;
                            contractLink.lengthCarts =
                                contractLink.lengthCarts + 1;
                            print(contractLink.lengthCarts);
                          });
                        });
                      }
                    },
                    child: Text(
                      "Thêm vào giỏ",
                      style: TextStyle(fontWeight: FontWeight.w900),
                    )))
            : SizedBox.shrink(),
        SizedBox(
          width: widget.nft.only == true
              ? MediaQuery.of(context).size.width / 2 - 15
              : MediaQuery.of(context).size.width - 30,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0))),
            ),
            onPressed: () {
              if (contractLink.loged == false) {
                contractLink.loginUsingMetamask(context);
              } else {
                _showModalBuy(context, contractLink);
              }
            },
            child: Consumer<NFTMarketProvider>(
              builder: (context, value, child) {
                return Text(
                  value.loged == true ? "Mua ngay" : "Kết nối ví để mua",
                  style: TextStyle(fontWeight: FontWeight.w900),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget btnCancleAuc(NFTMarketProvider contractLink) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width / 2 - 15,
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0))),
            ),
            onPressed: () {
              Navigator.pop(context);
              launchUrlString(contractLink.url,
                  mode: LaunchMode.externalApplication);

              contractLink.endAuction(widget.nft.auctionId, true).then(
                  (value) => Future.wait([
                        contractLink.fetchMarketItems(),
                        contractLink.fetchAuction()
                      ]).then((value) => Navigator.pop(rootContext!)));
            },
            child: const Text("Hủy phiên"),
          ),
        ),
        widget.nft.lastBidder != "0x0000000000000000000000000000000000000000"
            ? SizedBox(
                width: MediaQuery.of(context).size.width / 2 - 15,
                child: ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0))),
                  ),
                  onPressed: () {
                    launchUrlString(contractLink.url,
                        mode: LaunchMode.externalApplication);
                    contractLink.endAuction(widget.nft.auctionId, false);
                  },
                  child: const Text("Kết thúc phiên"),
                ),
              )
            : SizedBox(),
      ],
    );
  }

  Widget btnJoinAuction(NFTMarketProvider contractLink) {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
      ),
      onPressed: () {
        if (contractLink.loged == false) {
          contractLink.loginUsingMetamask(context);
        } else {
          _showModalAuction(context, contractLink);
        }
      },
      child: Consumer<NFTMarketProvider>(
        builder: (context, value, child) {
          return Text(
            value.loged == true ? "Đấu giá" : "Kết nối ví để đặt giá",
            style: TextStyle(fontWeight: FontWeight.w900),
          );
        },
      ),
    );
  }

  Widget allBtn(NFTMarketProvider contractLink) {
    if (widget.nft.auctionId == "") {
      if (contractLink.sender == widget.nft.owner) {
        return btnResell(contractLink);
      } else if (widget.nft.sender != contractLink.sender) {
        return btnBuy(contractLink);
      } else {
        return SizedBox.shrink();
      }
    } else if (contractLink.sender == widget.nft.auctioneer) {
      return btnCancleAuc(contractLink);
    } else {
      if (displayBidBtn == true) {
        return btnJoinAuction(contractLink);
      }
      return SizedBox.shrink();
    }
  }
}
