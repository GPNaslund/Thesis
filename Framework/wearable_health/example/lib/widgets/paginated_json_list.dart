import 'package:flutter/material.dart';

import 'json_viewer_widget.dart';

class PaginatedJsonList extends StatefulWidget {
  final List<dynamic> jsonDataList;
  final String itemTitlePrefix;
  final Key? expansionTileKey;

  const PaginatedJsonList({

    required this.jsonDataList,
    this.itemTitlePrefix = "Item",
    this.expansionTileKey,
  });

  @override
  PaginatedJsonListState createState() => PaginatedJsonListState();
}

class PaginatedJsonListState extends State<PaginatedJsonList> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  late int _totalPages;
  List<dynamic> _currentPageItems = [];

  @override
  void initState() {
    super.initState();
    _calculatePaginationAndUpdatePage();
  }

  @override
  void didUpdateWidget(covariant PaginatedJsonList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.jsonDataList != oldWidget.jsonDataList) {
      _currentPage = 1;
      _calculatePaginationAndUpdatePage();
    }
  }

  void _calculatePaginationAndUpdatePage() {
    if (widget.jsonDataList.isEmpty) {
      _totalPages = 0;
    } else {
      _totalPages = (widget.jsonDataList.length / _itemsPerPage).ceil();
      if (_totalPages == 0) _totalPages = 1;
    }
    _loadPageItems();
  }

  void _loadPageItems() {
    if (widget.jsonDataList.isEmpty) {
      if (mounted) setState(() => _currentPageItems = []);
      return;
    }

    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage > widget.jsonDataList.length)
        ? widget.jsonDataList.length
        : startIndex + _itemsPerPage;

    if (mounted) {
      setState(() {
        if (startIndex < widget.jsonDataList.length) {
          _currentPageItems = widget.jsonDataList.sublist(startIndex, endIndex);
        } else {
          _currentPageItems = [];
          if (_currentPage > 1) _currentPage = _totalPages > 0 ? _totalPages : 1;
        }
      });
    }
  }

  void _goToPage(int pageNumber) {
    if (pageNumber >= 1 && pageNumber <= _totalPages && pageNumber != _currentPage) {
      setState(() {
        _currentPage = pageNumber;
        _loadPageItems();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme = Theme.of(context);
    Color titleColor = currentTheme.primaryColorDark ?? currentTheme.primaryColor;
    if (currentTheme.brightness == Brightness.dark) {
      titleColor = Colors.tealAccent[100] ?? currentTheme.colorScheme.secondary;
    }

    if (widget.jsonDataList.isEmpty) {
      return ExpansionTile(
        key: widget.expansionTileKey,
        backgroundColor: currentTheme.colorScheme.surface.withOpacity(0.5),
        collapsedBackgroundColor: currentTheme.colorScheme.surfaceVariant.withOpacity(0.2),
        iconColor: titleColor,
        collapsedIconColor: titleColor.withOpacity(0.7),
        tilePadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
        title: Text(
          "View ${widget.jsonDataList.length} ${widget.itemTitlePrefix}s",
          style: TextStyle(fontSize: 13, color: titleColor.withOpacity(0.9)),
        ),
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("No items to display."),
          )
        ],
      );
    }

    return ExpansionTile(
      key: widget.expansionTileKey,
      backgroundColor: currentTheme.colorScheme.surface.withOpacity(0.5),
      collapsedBackgroundColor: currentTheme.colorScheme.surfaceVariant.withOpacity(0.2),
      iconColor: titleColor,
      collapsedIconColor: titleColor.withOpacity(0.7),
      tilePadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      childrenPadding: const EdgeInsets.symmetric(vertical: 8.0),
      title: Text(
        "View ${widget.jsonDataList.length} ${widget.itemTitlePrefix}s (Page $_currentPage/$_totalPages)",
        style: TextStyle(fontSize: 13, color: titleColor.withOpacity(0.9)),
      ),
      children: <Widget>[
        if (_currentPageItems.isNotEmpty)
          ..._currentPageItems.asMap().entries.map((entry) {
            final originalIndexInFullList = (_currentPage - 1) * _itemsPerPage + entry.key;
            return JsonViewerWidget(
              jsonData: entry.value,
              title: "${widget.itemTitlePrefix} ${originalIndexInFullList + 1}",
            );
          })
        else
          const Center(child: Padding(padding: EdgeInsets.all(8.0), child: Text("No items on this page."))),


        if (_totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  tooltip: "Previous OMH Page",
                  onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
                ),
                Text("Page: $_currentPage / $_totalPages", style: const TextStyle(fontSize: 12)),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  tooltip: "Next OMH Page",
                  onPressed: _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}