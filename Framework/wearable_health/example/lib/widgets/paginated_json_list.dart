import 'package:flutter/material.dart'; // Standard Flutter material design widgets and core functionalities.

import 'json_viewer_widget.dart'; // Widget for rendering JSON data in a user-friendly way.

/// A [StatefulWidget] that displays a list of dynamic JSON objects with pagination.
///
/// This widget is designed to present a potentially large list of JSON items
/// in a manageable way by breaking it down into pages. Each page shows a subset
/// of the items.
///
/// Features:
///  - Displays a list of JSON objects, where each object is shown within a
///    [JsonViewerWidget].
///  - Pagination controls (Previous/Next buttons, page indicator) to navigate
///    through the list.
///  - An optional title prefix for each item in the list.
///  - An optional [ExpansionTileKey] can be provided to manage the expansion
///    state if this widget itself is nested within an [ExpansionTile].
///  - Handles empty lists gracefully by showing an appropriate message.
///  - The main expansion tile (which contains the paginated list) shows the
///    total number of items and the current page/total pages.
class PaginatedJsonList extends StatefulWidget {
  /// The list of dynamic JSON objects to be displayed. Each item in the list
  /// is expected to be a data structure that [JsonViewerWidget] can render
  /// (e.g., Map, List).
  final List<dynamic> jsonDataList;

  /// An optional prefix string for the title of each item displayed in the list.
  /// For example, if set to "Item", items will be titled "Item 1", "Item 2", etc.
  /// Defaults to "Item".
  final String itemTitlePrefix;

  /// An optional [Key] to be passed to the main [ExpansionTile] that wraps this
  /// paginated list. This can be useful for controlling or preserving the
  /// expansion state from a parent widget.
  final Key? expansionTileKey;

  /// Creates an instance of [PaginatedJsonList].
  ///
  /// Parameters:
  ///  - [key]: Optional widget key, passed to the superclass.
  ///  - [jsonDataList]: Required. The list of JSON objects to display.
  ///  - [itemTitlePrefix]: Optional. The prefix for item titles. Defaults to "Item".
  ///  - [expansionTileKey]: Optional. A key for the encapsulating [ExpansionTile].
  const PaginatedJsonList({
    super.key, // Pass the key to the superclass.
    required this.jsonDataList,
    this.itemTitlePrefix = "Item", // Default value for itemTitlePrefix.
    this.expansionTileKey,
  });

  @override
  PaginatedJsonListState createState() => PaginatedJsonListState();
}

/// The state class for [PaginatedJsonList].
///
/// Manages the current page, total pages, the items displayed on the current page,
/// and handles pagination logic.
class PaginatedJsonListState extends State<PaginatedJsonList> {
  /// The current page number being displayed (1-indexed).
  int _currentPage = 1;

  /// The number of items to display per page.
  final int _itemsPerPage = 10; // Configurable: number of items per page.

  /// The total number of pages calculated based on [widget.jsonDataList] and [_itemsPerPage].
  late int _totalPages;

  /// The list of items currently visible on the [_currentPage].
  List<dynamic> _currentPageItems = [];

  @override
  void initState() {
    super.initState();
    // Initialize pagination and load the first page of items when the widget is first created.
    _calculatePaginationAndUpdatePage();
  }

  @override
  void didUpdateWidget(covariant PaginatedJsonList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the input jsonDataList changes (e.g., parent widget provides new data),
    // reset the current page to 1 and recalculate pagination.
    if (widget.jsonDataList != oldWidget.jsonDataList) {
      _currentPage = 1; // Reset to the first page.
      _calculatePaginationAndUpdatePage(); // Recalculate and load new data.
    }
  }

  /// Calculates the total number of pages and then loads the items for the current page.
  ///
  /// This method is called during initialization and when the input data list changes.
  void _calculatePaginationAndUpdatePage() {
    if (widget.jsonDataList.isEmpty) {
      _totalPages = 0; // No pages if the list is empty.
    } else {
      // Calculate total pages. Ensure at least 1 page if items exist.
      _totalPages = (widget.jsonDataList.length / _itemsPerPage).ceil();
      if (_totalPages == 0) _totalPages =
      1; // Should not happen if list is not empty, but as a safeguard.
    }
    _loadPageItems(); // Load items for the current page (usually page 1 after this method).
  }

  /// Loads the items for the [_currentPage] from the [widget.jsonDataList].
  ///
  /// Updates the [_currentPageItems] state variable, which triggers a UI rebuild.
  void _loadPageItems() {
    // If the main list is empty, there are no items to load for any page.
    if (widget.jsonDataList.isEmpty) {
      if (mounted) setState(() =>
      _currentPageItems = []); // Ensure widget is still mounted.
      return;
    }

    // Calculate the start and end indices for the sublist of items for the current page.
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage > widget.jsonDataList.length)
        ? widget.jsonDataList
        .length // Ensure endIndex does not exceed list length.
        : startIndex + _itemsPerPage;

    if (mounted) { // Ensure the widget is still in the tree before calling setState.
      setState(() {
        if (startIndex < widget.jsonDataList.length) {
          // If startIndex is valid, extract the sublist for the current page.
          _currentPageItems = widget.jsonDataList.sublist(startIndex, endIndex);
        } else {
          // If startIndex is out of bounds (e.g., data shrunk and currentPage is now too high),
          // set current page items to empty and adjust currentPage.
          _currentPageItems = [];
          // Adjust current page to the last available page, or 1 if no pages exist.
          if (_currentPage > 1)
            _currentPage = _totalPages > 0 ? _totalPages : 1;
        }
      });
    }
  }

  /// Navigates to a specific [pageNumber].
  ///
  /// If the [pageNumber] is valid (within the range of total pages and different
  /// from the current page), it updates [_currentPage] and loads items for the new page.
  void _goToPage(int pageNumber) {
    // Check if the requested page number is valid and different from the current page.
    if (pageNumber >= 1 && pageNumber <= _totalPages &&
        pageNumber != _currentPage) {
      setState(() {
        _currentPage = pageNumber;
        _loadPageItems(); // Load items for the newly selected page.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData currentTheme = Theme.of(context);
    // Determine the title color for the ExpansionTile based on the current theme brightness.
    Color titleColor = currentTheme.primaryColorDark ??
        currentTheme.primaryColor;
    if (currentTheme.brightness == Brightness.dark) {
      // Use a lighter, more visible color for dark themes.
      titleColor = Colors.tealAccent[100] ?? currentTheme.colorScheme.secondary;
    }

    // Handle the case where the input list of JSON data is empty.
    if (widget.jsonDataList.isEmpty) {
      return ExpansionTile(
        key: widget.expansionTileKey,
        // Use the provided key.
        // Styling for the ExpansionTile when the list is empty.
        backgroundColor: currentTheme.colorScheme.surface.withOpacity(0.5),
        collapsedBackgroundColor: currentTheme.colorScheme.surfaceVariant
            .withOpacity(0.2),
        iconColor: titleColor,
        collapsedIconColor: titleColor.withOpacity(0.7),
        tilePadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
        title: Text( // Title indicating the number of items (which is 0).
          "View ${widget.jsonDataList.length} ${widget.itemTitlePrefix}s",
          style: TextStyle(fontSize: 13, color: titleColor.withOpacity(0.9)),
        ),
        children: const <Widget>[ // Content displayed when expanded.
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("No items to display."), // Message for empty list.
          )
        ],
      );
    }

    // Build the UI when the JSON data list is not empty.
    return ExpansionTile(
      key: widget.expansionTileKey,
      // Use the provided key.
      // Styling for the ExpansionTile.
      backgroundColor: currentTheme.colorScheme.surface.withOpacity(0.5),
      collapsedBackgroundColor: currentTheme.colorScheme.surfaceVariant
          .withOpacity(0.2),
      iconColor: titleColor,
      collapsedIconColor: titleColor.withOpacity(0.7),
      tilePadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
      childrenPadding: const EdgeInsets.symmetric(vertical: 8.0),
      // Padding for children when expanded.
      title: Text( // Title indicating total items and current page/total pages.
        "View ${widget.jsonDataList.length} ${widget
            .itemTitlePrefix}s (Page $_currentPage/$_totalPages)",
        style: TextStyle(fontSize: 13, color: titleColor.withOpacity(0.9)),
      ),
      children: <Widget>[
        // Conditionally display the list of items for the current page or a message if the page is empty.
        if (_currentPageItems.isNotEmpty)
        // Use 'asMap().entries.map' to get both index and value for each item.
        // This allows calculating the original index of the item in the full jsonDataList.
          ..._currentPageItems
              .asMap()
              .entries
              .map((entry) {
            // Calculate the item's original index in the full list.
            final originalIndexInFullList = (_currentPage - 1) * _itemsPerPage +
                entry.key;
            // Create a JsonViewerWidget for each item on the current page.
            return JsonViewerWidget(
              jsonData: entry.value,
              title: "${widget.itemTitlePrefix} ${originalIndexInFullList +
                  1}", // Title includes original index.
            );
          })
        else
        // Display a message if the current page has no items (should only happen if list is empty or logic error).
          const Center(child: Padding(padding: EdgeInsets.all(8.0),
              child: Text("No items on this page."))),

        // Display pagination controls only if there is more than one page.
        if (_totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              // Space out controls.
              children: [
                // "Previous Page" button.
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  // Remove default padding.
                  visualDensity: VisualDensity.compact,
                  // Make the button more compact.
                  constraints: const BoxConstraints(),
                  // Remove default constraints.
                  tooltip: "Previous OMH Page",
                  // Tooltip for accessibility.
                  // Disable if on the first page.
                  onPressed: _currentPage > 1 ? () =>
                      _goToPage(_currentPage - 1) : null,
                ),
                // Text displaying current page and total pages.
                Text("Page: $_currentPage / $_totalPages",
                    style: const TextStyle(fontSize: 12)),
                // "Next Page" button.
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  iconSize: 24,
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                  constraints: const BoxConstraints(),
                  tooltip: "Next OMH Page",
                  // Disable if on the last page.
                  onPressed: _currentPage < _totalPages ? () =>
                      _goToPage(_currentPage + 1) : null,
                ),
              ],
            ),
          ),
      ],
    );
  }
}