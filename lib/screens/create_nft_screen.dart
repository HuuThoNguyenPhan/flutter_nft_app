import 'package:flutter/material.dart';

class CreateNFTScreen extends StatefulWidget {
  const CreateNFTScreen(
      {required this.label, required this.detailsPath, Key? key})
      : super(key: key);
  final String label;
  final String detailsPath;

  @override
  State<CreateNFTScreen> createState() => _CreateNFTScreenState();
}

class _CreateNFTScreenState extends State<CreateNFTScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tạo NFT"),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 60),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        color: Colors.grey,
                        width: 350,
                        height: 350,
                      ),
                    ),
                    ElevatedButton(
                        onPressed: () {}, child: const Text("Chọn tệp")),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Form(
                        key: _formKey,
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 20,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.red, width: 5),
                                  ),
                                  hintText: "Tên sản phẩm",
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10)),
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  errorBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.red, width: 5),
                                  ),
                                  hintText: "Mô tả",
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10)),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              child: TextFormField(
                                readOnly: true,
                                decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.sd_card),
                                    border: OutlineInputBorder(),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 5),
                                    ),
                                    hintText: "Dung lượng",
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10)),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              child: TextFormField(
                                readOnly: true,
                                decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.attach_file),
                                    border: OutlineInputBorder(),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.red, width: 5),
                                    ),
                                    hintText: "Loại tệp",
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10)),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Số lượng",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
                                            20,
                                    child: Stack(children: [
                                      TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.red, width: 5),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10)),
                                      ),
                                      Positioned(
                                        left: 0,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.all(5),
                                              minimumSize: Size.zero,
                                            ),
                                            onPressed: () {},
                                            child: Icon(Icons.add)),
                                      ),
                                      Positioned(
                                        right: 0,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.all(5),
                                              minimumSize: Size.zero,
                                            ),
                                            onPressed: () {},
                                            child: Icon(Icons.remove)),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 2 - 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Giới hạn mua",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2 -
                                            20,
                                    child: Stack(children: [
                                      TextFormField(
                                        textAlign: TextAlign.center,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.red, width: 5),
                                            ),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    horizontal: 10)),
                                      ),
                                      Positioned(
                                        left: 0,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.all(5),
                                              minimumSize: Size.zero,
                                            ),
                                            onPressed: () {},
                                            child: Icon(Icons.add)),
                                      ),
                                      Positioned(
                                        right: 0,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: const EdgeInsets.all(5),
                                              minimumSize: Size.zero,
                                            ),
                                            onPressed: () {},
                                            child: Icon(Icons.remove)),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                    ),
                    onPressed: () {},
                    child: const Text("aa"),
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
