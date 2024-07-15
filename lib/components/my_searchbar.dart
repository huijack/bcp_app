import 'package:flutter/material.dart';

class MySearchBar extends StatefulWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;

  const MySearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  _MySearchBarState createState() => _MySearchBarState();
}

class _MySearchBarState extends State<MySearchBar> {
  final FocusNode _focusNode = FocusNode();
  final ValueNotifier<bool> _hasText = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      _hasText.value = widget.controller.text.isNotEmpty;
    });
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _hasText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ValueListenableBuilder<bool>(
        valueListenable: _hasText,
        builder: (context, hasText, child) {
          return TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Search by Request No.',
              labelStyle: TextStyle(
                color: _focusNode.hasFocus
                    ? const Color.fromRGBO(191, 0, 6, 0.815)
                    : Colors.grey,
              ),
              prefixIcon: const Icon(Icons.search),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(
                  color: Color.fromRGBO(191, 0, 6, 0.815),
                  width: 2.0,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 2.0,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: BorderSide(
                  color: _focusNode.hasFocus
                      ? const Color.fromRGBO(191, 0, 6, 0.815)
                      : Colors.grey.shade400,
                ),
              ),
              suffixIcon: hasText
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onChanged!('');
                        _hasText.value = false;
                      },
                    )
                  : null,
            ),
            onChanged: widget.onChanged,
          );
        },
      ),
    );
  }
}
