import 'package:flutter/material.dart';

class SearchInput extends StatefulWidget {
  SearchInput(
      {Key? key, required this.searchContent, this. onChanged,})
      : super(key: key);
  final TextEditingController searchContent;
  final ValueChanged<String>?  onChanged;
  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.searchContent,
      onChanged: widget. onChanged,
      decoration: InputDecoration(
          suffixIcon: widget.searchContent.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    widget.searchContent.clear();
                    setState(() {});
                  },
                  icon: Icon(Icons.clear),
                )
              : null,
          prefixIcon: const Icon(Icons.search),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10))),
          hintText: "Tìm kiếm",
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 17)),
    );
  }
}
