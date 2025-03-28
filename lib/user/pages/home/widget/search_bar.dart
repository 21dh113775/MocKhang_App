import 'package:flutter/material.dart';

class HomeSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function()? onReset;
  final String initialValue;

  const HomeSearchBar({
    Key? key,
    required this.onSearch,
    this.onReset,
    this.initialValue = '',
  }) : super(key: key);

  @override
  _HomeSearchBarState createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _hasText = widget.initialValue.isNotEmpty;
    _controller.addListener(_updateHasText);
  }

  void _updateHasText() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateHasText);
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    if (widget.onReset != null) {
      widget.onReset!();
    } else {
      widget.onSearch('');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm sản phẩm...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon:
              _hasText
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    color: Colors.grey[600],
                    onPressed: _clearSearch,
                  )
                  : IconButton(
                    icon: Icon(Icons.filter_list, color: Colors.grey[600]),
                    onPressed: () {
                      // Có thể mở dialog lọc nâng cao ở đây nếu cần
                    },
                  ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.brown[300]!, width: 1),
          ),
        ),
        onChanged: (value) {
          // Tìm kiếm ngay khi người dùng nhập
          widget.onSearch(value);
        },
        onSubmitted: widget.onSearch,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
