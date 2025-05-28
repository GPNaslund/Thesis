import 'dart:io'; // Used to check the current platform (Android/iOS) for platform-specific logic.

import 'package:flutter/material.dart'; // Standard Flutter material design widgets and core functionalities.

// Imports related to OpenMHealth extensions for Health Connect data types.
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate_variability.dart';

// Imports related to OpenMHealth extensions for HealthKit data types.
import 'package:wearable_health/extensions/open_m_health/health_kit/health-kit_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/health_kit/health_kit_heart_rate_variability.dart';

// Enum definitions for Health Connect and HealthKit metric types.
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';

// Data factory interfaces for creating structured data objects from raw data.
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';

// Custom widgets used within this module.
import 'package:wearable_health_example/widgets/paginated_json_list.dart'; // For displaying lists of JSON with pagination.
import 'package:wearable_health_example/widgets/placeholder.dart'; // For displaying placeholder messages.

// Local project imports.
import '../models/displayable_record.dart'; // Data model for records being displayed.
import 'json_viewer_widget.dart'; // Widget for rendering JSON data in a user-friendly way.


/// A [StatefulWidget] that provides an interface for displaying health data records.
///
/// This module allows users to:
///  - Select a specific health metric type from a dropdown.
///  - View records for the selected metric in a paginated list.
///  - For each record, see the raw data, a converted object representation (platform-specific),
///    and its OpenMHealth (OMH) equivalent(s).
///
/// It handles data processing, pagination logic, and dynamic UI updates based on
/// user selections and data availability.
class DataDisplayModule extends StatefulWidget {
  /// The raw health data, structured as a map where keys are metric type strings
  /// (e.g., "HEART_RATE") and values are lists of raw record maps.
  /// Can be null if no data is available.
  final Map<String, List<Map<String, dynamic>>>? data;

  /// A factory for creating Health Connect specific data objects (e.g., [HCHeartRate])
  /// from raw data maps. Used on Android.
  final HCDataFactory hcDataFactory;

  /// A factory for creating HealthKit specific data objects (e.g., [HKHeartRate])
  /// from raw data maps. Used on iOS.
  final HKDataFactory hkDataFactory;

  /// Creates a [DataDisplayModule] instance.
  ///
  /// Parameters:
  ///  - [key]: Optional widget key.
  ///  - [data]: The health data to be displayed.
  ///  - [hcDataFactory]: Required factory for Health Connect data processing.
  ///  - [hkDataFactory]: Required factory for HealthKit data processing.
  const DataDisplayModule({
    super.key,
    this.data,
    required this.hcDataFactory,
    required this.hkDataFactory,
  });

  @override
  State<DataDisplayModule> createState() => _DataDisplayModuleState();
}

/// The state class for [DataDisplayModule].
///
/// Manages the currently selected metric, pagination, data loading, and transformations
/// for display.
class _DataDisplayModuleState extends State<DataDisplayModule> {
  /// The key of the currently selected health metric (e.g., "HEART_RATE").
  String? _selectedMetricKey;

  /// A list of available metric keys derived from the input [widget.data].
  List<String> _availableMetricKeys = [];

  /// The list of [DisplayableRecord] objects currently shown on the page.
  List<DisplayableRecord> _displayedPageRecords = [];

  /// The current page number for pagination (1-indexed).
  int _currentPage = 1;

  /// The total number of pages for the selected metric.
  int _totalPages = 0;

  /// The number of records to display per page.
  final int _recordsPerPage = 15;

  /// A flag indicating whether data for the current page is being loaded.
  /// Used to show a loading indicator.
  bool _isLoadingPage = false;

  @override
  void initState() {
    super.initState();
    // Initialize the module's state when it's first created.
    _initializeModule();
  }

  @override
  void didUpdateWidget(DataDisplayModule oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the input data changes, re-initialize the module.
    // This handles scenarios where the parent widget provides new data.
    if (widget.data != oldWidget.data) {
      _initializeModule();
    }
  }

  /// Initializes or re-initializes the module's state based on [widget.data].
  ///
  /// Sets up available metric keys, selects a default metric if necessary,
  /// resets pagination, and loads the first page of data for the selected metric.
  void _initializeModule() {
    if (widget.data != null && widget.data!.isNotEmpty) {
      // Get and sort the available metric keys from the input data.
      _availableMetricKeys = widget.data!.keys.toList()
        ..sort();
      // If no metric is selected or the previously selected one is no longer available,
      // select the first available metric.
      if (_selectedMetricKey == null ||
          !widget.data!.containsKey(_selectedMetricKey)) {
        _selectedMetricKey =
        _availableMetricKeys.isNotEmpty ? _availableMetricKeys.first : null;
      }
    } else {
      // If no data is available, clear metric keys and selection.
      _availableMetricKeys = [];
      _selectedMetricKey = null;
    }
    _currentPage = 1; // Reset to the first page.
    _loadPageDataForSelectedMetric(); // Load data for the (newly) selected metric.
  }

  /// Handles the selection of a new metric from the dropdown.
  ///
  /// Updates the [_selectedMetricKey], resets pagination to the first page,
  /// and triggers loading data for the newly selected metric.
  void _onMetricSelected(String? newMetricKey) {
    // Check if a new, valid metric key is selected and it's different from the current one.
    if (newMetricKey != null && newMetricKey != _selectedMetricKey) {
      setState(() {
        _selectedMetricKey = newMetricKey;
        _currentPage = 1; // Reset to the first page for the new metric.
        _loadPageDataForSelectedMetric(); // Load data.
      });
    }
  }

  /// Asynchronously loads and processes data for the currently selected metric and page.
  ///
  /// This method:
  ///  1. Sets [_isLoadingPage] to true to show a loading indicator.
  ///  2. Retrieves all raw records for the [_selectedMetricKey].
  ///  3. Calculates [_totalPages] based on [_recordsPerPage].
  ///  4. Extracts the subset of raw records for the [_currentPage].
  ///  5. For each raw record in the page:
  ///     a. Converts it using the appropriate platform-specific factory ([hcDataFactory] or [hkDataFactory]).
  ///     b. Transforms the converted object into its OpenMHealth representation(s).
  ///     c. Creates a [DisplayableRecord] containing the raw, converted, and OMH data.
  ///  6. Updates [_displayedPageRecords] with the processed records.
  ///  7. Sets [_isLoadingPage] to false.
  ///
  /// Includes error handling for data processing steps.
  Future<void> _loadPageDataForSelectedMetric() async {
    // If no metric is selected or data is unavailable, clear display and stop.
    if (_selectedMetricKey == null || widget.data == null ||
        widget.data![_selectedMetricKey] == null) {
      if (mounted) { // Ensure the widget is still in the tree before calling setState.
        setState(() {
          _displayedPageRecords = [];
          _totalPages = 0;
          _isLoadingPage = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoadingPage = true; // Show loading indicator.
      });
    }
    // Short delay to allow the UI to update and show the loading indicator
    // before intensive processing begins.
    await Future.delayed(const Duration(milliseconds: 50));


    final allRawRecordsForSelectedMetric = widget.data![_selectedMetricKey]!;
    // Calculate total pages. Ensure at least 1 page if records exist, 0 if empty.
    _totalPages =
        (allRawRecordsForSelectedMetric.length / _recordsPerPage).ceil();
    if (_totalPages == 0 && allRawRecordsForSelectedMetric.isNotEmpty)
      _totalPages = 1;
    if (allRawRecordsForSelectedMetric.isEmpty) _totalPages = 0;


    // Determine the start and end indices for the current page's records.
    final startIndex = (_currentPage - 1) * _recordsPerPage;
    final endIndex = (startIndex + _recordsPerPage >
        allRawRecordsForSelectedMetric.length)
        ? allRawRecordsForSelectedMetric.length
        : startIndex + _recordsPerPage;

    // Extract the raw records for the current page.
    final List<Map<String, dynamic>> rawRecordsForPage;
    if (startIndex < allRawRecordsForSelectedMetric.length) {
      rawRecordsForPage =
          allRawRecordsForSelectedMetric.sublist(startIndex, endIndex);
    } else {
      rawRecordsForPage =
      []; // Should not happen if _currentPage is within _totalPages range.
    }


    final List<DisplayableRecord> pageDisplayRecords = [];
    // Process each raw record for the current page.
    for (int i = 0; i < rawRecordsForPage.length; i++) {
      final rawRecord = rawRecordsForPage[i];
      // Calculate the original index of the record in the full dataset for this metric.
      final originalRecordIndexInMetric = startIndex + i + 1;

      Map<String, dynamic> convertedJson = {};
      List<Map<String, dynamic>> omhJsonList = [];

      try {
        // Platform-specific processing using the appropriate data factory.
        if (Platform.isAndroid) { // Health Connect on Android
          if (_selectedMetricKey ==
              HealthConnectHealthMetric.heartRate.definition) {
            var hcHr = widget.hcDataFactory.createHeartRate(rawRecord);
            convertedJson =
                hcHr.toJson(); // Convert Health Connect object to JSON.
            omhJsonList = hcHr
                .toOpenMHealthHeartRate()
                .map((e) => e.toJson())
                .toList(); // Convert to OMH JSON.
          } else if (_selectedMetricKey ==
              HealthConnectHealthMetric.heartRateVariability.definition) {
            var hcHrv = widget.hcDataFactory.createHeartRateVariability(
                rawRecord);
            convertedJson = hcHrv.toJson();
            omhJsonList =
                hcHrv.toOpenMHealthHeartRateVariabilityRmssd().map((e) =>
                    e.toJson()).toList();
          }
          // Add more Health Connect metric types here if needed.
        } else { // HealthKit on iOS (or other platforms by default)
          if (_selectedMetricKey ==
              HealthKitHealthMetric.heartRate.definition) {
            var hkHr = widget.hkDataFactory.createHeartRate(rawRecord);
            convertedJson = hkHr.toJson(); // Convert HealthKit object to JSON.
            omhJsonList = hkHr
                .toOpenMHealthHeartRate()
                .map((e) => e.toJson())
                .toList(); // Convert to OMH JSON.
          } else if (_selectedMetricKey ==
              HealthKitHealthMetric.heartRateVariability.definition) {
            var hkHrv = widget.hkDataFactory.createHeartRateVariability(
                rawRecord);
            convertedJson = hkHrv.toJson();
            omhJsonList = hkHrv
                .toOpenMHealthHeartRateVariability()
                .map((e) => e.toJson())
                .toList();
          }
          // Add more HealthKit metric types here if needed.
        }
      } catch (e) {
        // Log error and provide error information in the displayable record.
        debugPrint(
            "Error processing record for $_selectedMetricKey (Index: $originalRecordIndexInMetric): $e");
        convertedJson = {'error': 'Failed to process: ${e.toString()}'};
        omhJsonList = [{'error': 'Failed to process: ${e.toString()}'}];
      }
      // Create a DisplayableRecord with all data representations.
      pageDisplayRecords.add(DisplayableRecord(
        rawData: rawRecord,
        convertedData: convertedJson,
        omhDataList: omhJsonList,
        recordIndex: originalRecordIndexInMetric,
      ));
    }

    if (mounted) { // Ensure widget is still active before updating state.
      setState(() {
        _displayedPageRecords = pageDisplayRecords;
        _isLoadingPage = false; // Hide loading indicator.
      });
    }
  }

  /// Navigates to a specific page number if it's valid.
  ///
  /// Updates [_currentPage] and triggers loading data for the new page.
  void _goToPage(int pageNumber) {
    if (pageNumber >= 1 && pageNumber <= _totalPages &&
        pageNumber != _currentPage) {
      setState(() {
        _currentPage = pageNumber;
        _loadPageDataForSelectedMetric(); // Load data for the new page.
      });
    }
  }

  /// Formats a metric key string for display (e.g., "HEART_RATE" -> "Heart Rate").
  ///
  /// Replaces underscores with spaces and capitalizes each word.
  String _getMetricDisplayName(String metricKey) {
    if (metricKey.isEmpty) return '';
    String spacedKey = metricKey.replaceAll('_', ' ');
    List<String> words = spacedKey.split(' ');
    return words.map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // If no data is available at all, show a placeholder.
    if (widget.data == null || widget.data!.isEmpty) {
      return const PlaceholderModule(
        message: 'No data available to run experiment.',
        icon: Icons.science_outlined, // Icon indicating experimental data.
      );
    }

    // Main layout for the data display module.
    return Column(
      children: [
        // Dropdown for selecting the health metric type.
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Data Type',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12.0, vertical: 8.0),
            ),
            value: _selectedMetricKey,
            isExpanded: true,
            // Allow the dropdown to expand to full width.
            items: _availableMetricKeys.map((key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(_getMetricDisplayName(key),
                    overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: _onMetricSelected,
            // Callback for when a new metric is selected.
            hint: const Text(
                'Select a data type'), // Placeholder text when no metric is selected.
          ),
        ),

        // Expanded section to display the list of records or placeholders.
        Expanded(
          child: _selectedMetricKey == null
              ? const PlaceholderModule(
              message: "Please select a data type above.", icon: Icons.category)
              : _isLoadingPage
              ? const Center(
              child: CircularProgressIndicator()) // Show loading indicator while data loads.
              : _displayedPageRecords.isEmpty
              ? PlaceholderModule( // Show if no records are found for the selected metric/period.
              message: "No records found for '${_getMetricDisplayName(
                  _selectedMetricKey!)}'\nfor the selected period or category.",
              icon: Icons.hourglass_empty)
              : ListView.builder( // Display the list of records.
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: _displayedPageRecords.length,
            itemBuilder: (context, index) {
              final record = _displayedPageRecords[index];
              // Generate a unique PageStorageKey for each data column's ExpansionTile
              // to preserve its expanded/collapsed state across rebuilds and page changes.
              final String pageStorageKeyBase = '${_selectedMetricKey}_${record
                  .recordIndex}';
              return Card( // Each record is displayed in a Card.
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(
                    vertical: 6.0, horizontal: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header for the record card.
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme
                              .of(context)
                              .colorScheme
                              .primaryContainer,
                          child: Text(
                            record.recordIndex.toString(),
                            style: TextStyle(color: Theme
                                .of(context)
                                .colorScheme
                                .onPrimaryContainer, fontSize: 12),
                          ),
                        ),
                        title: Text(
                          '${_getMetricDisplayName(
                              _selectedMetricKey!)} - Record #${record
                              .recordIndex}',
                          style: Theme
                              .of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        dense: true, // Make the ListTile more compact.
                      ),
                      const SizedBox(height: 8.0),
                      // Horizontally scrollable row containing data columns.
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: IntrinsicHeight( // Ensure all columns have the same height.
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Column for Raw Data.
                              _buildDataColumn(
                                  context, "Raw Data", record.rawData,
                                  PageStorageKey('raw_$pageStorageKeyBase')),
                              // Column for Converted Platform-Specific Object.
                              _buildDataColumn(context, "Converted Object",
                                  record.convertedData, PageStorageKey(
                                      'converted_$pageStorageKeyBase')),
                              // Column for OpenMHealth Data.
                              // Handles cases where OMH data might be empty or a list of multiple items.
                              _buildDataColumn(context, "Open mHealth",
                                  record.omhDataList.isEmpty ? {
                                    "info": "No OMH data"
                                  } : (record.omhDataList.length == 1 ? record
                                      .omhDataList.first : record.omhDataList),
                                  PageStorageKey('omh_$pageStorageKeyBase'),
                                  isList: record.omhDataList.length > 1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Pagination controls (Previous/Next buttons and page indicator).
        // Only show if a metric is selected, data is loaded, and there are pages.
        if (_selectedMetricKey != null && _totalPages > 0 && !_isLoadingPage)
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 10.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _currentPage > 1 ? () =>
                      _goToPage(_currentPage - 1) : null,
                  // Disable if on the first page.
                  tooltip: "Previous Page",
                ),
                Text('Page $_currentPage of $_totalPages'),
                // Display current page and total pages.
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _currentPage < _totalPages ? () =>
                      _goToPage(_currentPage + 1) : null,
                  // Disable if on the last page.
                  tooltip: "Next Page",
                ),
              ],
            ),
          ),
      ],
    );
  }


  /// Builds a single column for displaying a category of data (Raw, Converted, OMH).
  ///
  /// Each column has a title and an expandable section ([ExpansionTile] or [PaginatedJsonList])
  /// to view the JSON data.
  ///
  /// Parameters:
  ///  - [context]: The build context.
  ///  - [title]: The title for the data column.
  ///  - [jsonData]: The JSON data to be displayed (can be a Map or List).
  ///  - [expansionTileKey]: A unique [PageStorageKey] to preserve the expansion state.
  ///  - [isList]: A boolean indicating if [jsonData] is a list that should be handled by [PaginatedJsonList].
  ///
  /// Returns:
  ///  A [Widget] representing the data column.
  Widget _buildDataColumn(BuildContext context, String title, dynamic jsonData,
      Key expansionTileKey, {bool isList = false}) {
    ThemeData currentTheme = Theme.of(context);
    // Determine title color based on theme brightness for better visibility.
    Color titleColor = currentTheme.primaryColorDark ??
        currentTheme.primaryColor;
    if (currentTheme.brightness == Brightness.dark) {
      titleColor = Colors.tealAccent[100] ?? currentTheme.colorScheme.secondary;
    }

    Widget contentWidget; // The widget that will display the JSON content.

    // If data is a list and 'isList' is true, use PaginatedJsonList.
    if (isList && jsonData is List) {
      contentWidget = PaginatedJsonList(
        jsonDataList: jsonData,
        itemTitlePrefix: "OMH Item", // Prefix for items in the paginated list.
        expansionTileKey: expansionTileKey, // Pass the key for state preservation.
      );
    } else if (jsonData != null) { // If data is a single JSON object (Map).
      contentWidget = ExpansionTile(
        key: expansionTileKey,
        // Key for state preservation.
        backgroundColor: currentTheme.colorScheme.surface.withOpacity(0.5),
        collapsedBackgroundColor: currentTheme.colorScheme.surfaceVariant
            .withOpacity(0.2),
        iconColor: titleColor,
        collapsedIconColor: titleColor.withOpacity(0.7),
        tilePadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
        childrenPadding: EdgeInsets.zero,
        title: Text( // Title for the ExpansionTile.
          "View JSON",
          style: TextStyle(fontSize: 13, color: titleColor.withOpacity(0.9)),
        ),
        children: <Widget>[
          JsonViewerWidget(jsonData: jsonData)
        ], // JSON viewer widget as content.
      );
    } else { // If jsonData is null.
      contentWidget = ExpansionTile(
        key: expansionTileKey,
        backgroundColor: currentTheme.colorScheme.surface.withOpacity(0.5),
        collapsedBackgroundColor: currentTheme.colorScheme.surfaceVariant
            .withOpacity(0.2),
        iconColor: titleColor,
        collapsedIconColor: titleColor.withOpacity(0.7),
        tilePadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
        title: Text("View JSON",
            style: TextStyle(fontSize: 13, color: titleColor.withOpacity(0.9))),
        children: const [
          Padding(padding: EdgeInsets.all(8.0), child: Text("No data"))
        ], // Display "No data".
      );
    }

    // Container for the entire data column with styling.
    return Container(
      width: 300, // Fixed width for each data column.
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      decoration: BoxDecoration( // Add subtle borders between columns.
          border: Border(
            right: BorderSide(color: Colors.grey.shade300, width: 0.5),
            left: BorderSide(color: Colors.grey.shade300, width: 0.5),
          )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        // Make children stretch to fill width.
        children: [
          // Column title text.
          Padding(
            padding: const EdgeInsets.only(
                top: 4.0, bottom: 2.0, left: 8.0, right: 8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: titleColor),
            ),
          ),
          contentWidget,
          // The actual content (ExpansionTile or PaginatedJsonList).
        ],
      ),
    );
  }
}