import 'dart:io';

import 'package:flutter/material.dart';

import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/health_connect/health_connect_heart_rate_variability.dart';
import 'package:wearable_health/extensions/open_m_health/health_kit/health-kit_heart_rate.dart';
import 'package:wearable_health/extensions/open_m_health/health_kit/health_kit_heart_rate_variability.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';
import 'package:wearable_health_example/widgets/placeholder.dart';

import '../models/displayable_record.dart';
import 'json_viewer_widget.dart';


class DataDisplayModule extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>>? data;
  final HCDataFactory hcDataFactory;
  final HKDataFactory hkDataFactory;

  const DataDisplayModule({
    super.key,
    this.data,
    required this.hcDataFactory,
    required this.hkDataFactory,
  });

  @override
  State<DataDisplayModule> createState() => _DataDisplayModuleState();
}

class _DataDisplayModuleState extends State<DataDisplayModule> {
  String? _selectedMetricKey;
  List<String> _availableMetricKeys = [];

  List<DisplayableRecord> _displayedPageRecords = [];
  int _currentPage = 1;
  int _totalPages = 0;
  final int _recordsPerPage = 15;

  bool _isLoadingPage = false;

  @override
  void initState() {
    super.initState();
    _initializeModule();
  }

  @override
  void didUpdateWidget(DataDisplayModule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _initializeModule();
    }
  }

  void _initializeModule() {
    if (widget.data != null && widget.data!.isNotEmpty) {
      _availableMetricKeys = widget.data!.keys.toList()..sort();
      if (_selectedMetricKey == null || !widget.data!.containsKey(_selectedMetricKey)) {
        _selectedMetricKey = _availableMetricKeys.isNotEmpty ? _availableMetricKeys.first : null;
      }
    } else {
      _availableMetricKeys = [];
      _selectedMetricKey = null;
    }
    _currentPage = 1;
    _loadPageDataForSelectedMetric();
  }

  void _onMetricSelected(String? newMetricKey) {
    if (newMetricKey != null && newMetricKey != _selectedMetricKey) {
      setState(() {
        _selectedMetricKey = newMetricKey;
        _currentPage = 1;
        _loadPageDataForSelectedMetric();
      });
    }
  }

  Future<void> _loadPageDataForSelectedMetric() async {
    if (_selectedMetricKey == null || widget.data == null || widget.data![_selectedMetricKey] == null) {
      if (mounted) {
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
        _isLoadingPage = true;
      });
    }
    await Future.delayed(const Duration(milliseconds: 50));


    final allRawRecordsForSelectedMetric = widget.data![_selectedMetricKey]!;
    _totalPages = (allRawRecordsForSelectedMetric.length / _recordsPerPage).ceil();
    if (_totalPages == 0 && allRawRecordsForSelectedMetric.isNotEmpty) _totalPages = 1;
    if (allRawRecordsForSelectedMetric.isEmpty) _totalPages = 0;


    final startIndex = (_currentPage - 1) * _recordsPerPage;
    final endIndex = (startIndex + _recordsPerPage > allRawRecordsForSelectedMetric.length)
        ? allRawRecordsForSelectedMetric.length
        : startIndex + _recordsPerPage;

    final List<Map<String, dynamic>> rawRecordsForPage;
    if (startIndex < allRawRecordsForSelectedMetric.length) {
      rawRecordsForPage = allRawRecordsForSelectedMetric.sublist(startIndex, endIndex);
    } else {
      rawRecordsForPage = [];
    }


    final List<DisplayableRecord> pageDisplayRecords = [];
    for (int i = 0; i < rawRecordsForPage.length; i++) {
      final rawRecord = rawRecordsForPage[i];
      final originalRecordIndexInMetric = startIndex + i + 1;

      Map<String, dynamic> convertedJson = {};
      List<Map<String, dynamic>> omhJsonList = [];

      try {

        if (Platform.isAndroid) {
          if (_selectedMetricKey == HealthConnectHealthMetric.heartRate.definition) {
            var hcHr = widget.hcDataFactory.createHeartRate(rawRecord);
            convertedJson = hcHr.toJson();
            omhJsonList = hcHr.toOpenMHealthHeartRate().map((e) => e.toJson()).toList();
          } else if (_selectedMetricKey == HealthConnectHealthMetric.heartRateVariability.definition) {
            var hcHrv = widget.hcDataFactory.createHeartRateVariability(rawRecord);
            convertedJson = hcHrv.toJson();
            omhJsonList = hcHrv.toOpenMHealthHeartRateVariabilityRmssd().map((e) => e.toJson()).toList();
          }
        } else {
          if (_selectedMetricKey == HealthKitHealthMetric.heartRate.definition) {
            var hkHr = widget.hkDataFactory.createHeartRate(rawRecord);
            convertedJson = hkHr.toJson();
            omhJsonList = hkHr.toOpenMHealthHeartRate().map((e) => e.toJson()).toList();
          } else if (_selectedMetricKey == HealthKitHealthMetric.heartRateVariability.definition) {
            var hkHrv = widget.hkDataFactory.createHeartRateVariability(rawRecord);
            convertedJson = hkHrv.toJson();
            omhJsonList = hkHrv.toOpenMHealthHeartRateVariability().map((e) => e.toJson()).toList();
          }
        }
      } catch (e) {
        debugPrint("Error processing record for $_selectedMetricKey (Index: $originalRecordIndexInMetric): $e");
        convertedJson = {'error': 'Failed to process: ${e.toString()}'};
        omhJsonList = [{'error': 'Failed to process: ${e.toString()}'}];
      }
      pageDisplayRecords.add(DisplayableRecord(
        rawData: rawRecord,
        convertedData: convertedJson,
        omhDataList: omhJsonList,
        recordIndex: originalRecordIndexInMetric,
      ));
    }

    if (mounted) {
      setState(() {
        _displayedPageRecords = pageDisplayRecords;
        _isLoadingPage = false;
      });
    }
  }

  void _goToPage(int pageNumber) {
    if (pageNumber >= 1 && pageNumber <= _totalPages && pageNumber != _currentPage) {
      setState(() {
        _currentPage = pageNumber;
        _loadPageDataForSelectedMetric();
      });
    }
  }

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
    if (widget.data == null || widget.data!.isEmpty) {
      return const PlaceholderModule(
        message: 'No data available to run experiment.',
        icon: Icons.science_outlined,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Data Type',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            ),
            value: _selectedMetricKey,
            isExpanded: true,
            items: _availableMetricKeys.map((key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(_getMetricDisplayName(key), overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: _onMetricSelected,
            hint: const Text('Select a data type'),
          ),
        ),

        Expanded(
          child: _selectedMetricKey == null
              ? const PlaceholderModule(message: "Please select a data type above.", icon: Icons.category)
              : _isLoadingPage
              ? const Center(child: CircularProgressIndicator())
              : _displayedPageRecords.isEmpty
              ? PlaceholderModule(
              message: "No records found for '${_getMetricDisplayName(_selectedMetricKey!)}'\nfor the selected period or category.",
              icon: Icons.hourglass_empty)
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            itemCount: _displayedPageRecords.length,
            itemBuilder: (context, index) {
              final record = _displayedPageRecords[index];
              final String pageStorageKeyBase = '${_selectedMetricKey}_${record.recordIndex}';
              return Card(
                elevation: 2.0,
                margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            record.recordIndex.toString(),
                            style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer, fontSize: 12),
                          ),
                        ),
                        title: Text(
                          '${_getMetricDisplayName(_selectedMetricKey!)} - Record #${record.recordIndex}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        dense: true,
                      ),
                      const SizedBox(height: 8.0),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildDataColumn(context, "Raw Data", record.rawData, PageStorageKey('raw_$pageStorageKeyBase')),
                              _buildDataColumn(context, "Converted Object", record.convertedData, PageStorageKey('converted_$pageStorageKeyBase')),
                              _buildDataColumn(context, "Open mHealth", record.omhDataList.isEmpty ? {"info": "No OMH data"} : (record.omhDataList.length == 1 ? record.omhDataList.first : record.omhDataList), PageStorageKey('omh_$pageStorageKeyBase'), isList: record.omhDataList.length > 1),
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

        if (_selectedMetricKey != null && _totalPages > 0 && !_isLoadingPage)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
                  tooltip: "Previous Page",
                ),
                Text('Page $_currentPage of $_totalPages'),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
                  tooltip: "Next Page",
                ),
              ],
            ),
          ),
      ],
    );
  }


  Widget _buildDataColumn(BuildContext context, String title, dynamic jsonData, Key expansionTileKey, {bool isList = false}) {
    ThemeData currentTheme = Theme.of(context);
    Color titleColor = currentTheme.primaryColorDark ?? currentTheme.primaryColor;
    if (currentTheme.brightness == Brightness.dark) {
      titleColor = Colors.tealAccent[100] ?? currentTheme.colorScheme.secondary;
    }


    return Container(
      width: 300,
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      decoration: BoxDecoration(
          border: Border(
            right: BorderSide(color: Colors.grey.shade300, width: 0.5),
            left: BorderSide(color: Colors.grey.shade300, width: 0.5),
          )
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 2.0, left: 8.0, right: 8.0),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: titleColor),
            ),
          ),
          ExpansionTile(
            key: expansionTileKey,
            backgroundColor: currentTheme.colorScheme.surface.withOpacity(0.5),
            collapsedBackgroundColor: currentTheme.colorScheme.surfaceVariant.withOpacity(0.2),
            iconColor: titleColor,
            collapsedIconColor: titleColor.withOpacity(0.7),
            tilePadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
            childrenPadding: EdgeInsets.zero,
            title: Text(
              isList && jsonData is List ? "View ${jsonData.length} items" : "View JSON",
              style: TextStyle(fontSize: 13, color: titleColor.withOpacity(0.9)),
            ),
            children: <Widget>[
              if (isList && jsonData is List)
                ...jsonData.asMap().entries.map((entry) => JsonViewerWidget(
                  jsonData: entry.value,
                  title: "Item ${entry.key + 1}",
                ))
              else if (jsonData != null)
                JsonViewerWidget(jsonData: jsonData)
              else
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text("No data"),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
