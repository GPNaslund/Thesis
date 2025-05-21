import 'dart:io';

import 'package:flutter/foundation.dart';
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
  Map<String, List<DisplayableRecord>>? _categorizedData;
  bool _isLoading = true;
  String? _processingError;

  @override
  void initState() {
    super.initState();
    _initiateDataProcessing();
  }

  @override
  void didUpdateWidget(covariant DataDisplayModule oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _initiateDataProcessing();
    }
  }

  void _initiateDataProcessing() {
    if (widget.data == null || widget.data!.isEmpty) {
      setState(() {
        _isLoading = false;
        _categorizedData = null;
        _processingError = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _categorizedData = null;
      _processingError = null;
    });
    _processDataAsync();
  }

  Future<void> _processDataAsync() async {
    await Future.delayed(Duration.zero);

    try {
      final Map<String, List<DisplayableRecord>> processedResult = {};
      int tempGlobalRecordIndex = 0;

      widget.data!.forEach((metricKey, records) {
        final List<DisplayableRecord> displayRecords = [];
        for (int i = 0; i < records.length; i++) {
          final rawRecord = records[i];
          Map<String, dynamic> convertedJson = {};
          List<Map<String, dynamic>> omhJsonList = [];

          if (Platform.isAndroid) {
            if (metricKey == HealthConnectHealthMetric.heartRate.definition) {
              var hcHr = widget.hcDataFactory.createHeartRate(rawRecord);
              convertedJson = hcHr.toJson();
              omhJsonList = hcHr.toOpenMHealthHeartRate().map((e) => e.toJson()).toList();
            } else if (metricKey == HealthConnectHealthMetric.heartRateVariability.definition) {
              var hcHrv = widget.hcDataFactory.createHeartRateVariability(rawRecord);
              convertedJson = hcHrv.toJson();
              omhJsonList = hcHrv.toOpenMHealthHeartRateVariabilityRmssd().map((e) => e.toJson()).toList();
            }
          } else { // iOS
            if (metricKey == HealthKitHealthMetric.heartRate.definition) {
              var hkHr = widget.hkDataFactory.createHeartRate(rawRecord);
              convertedJson = hkHr.toJson();
              omhJsonList = hkHr.toOpenMHealthHeartRate().map((e) => e.toJson()).toList();
            } else if (metricKey == HealthKitHealthMetric.heartRateVariability.definition) {
              var hkHrv = widget.hkDataFactory.createHeartRateVariability(rawRecord);
              convertedJson = hkHrv.toJson();
              omhJsonList = hkHrv.toOpenMHealthHeartRateVariability().map((e) => e.toJson()).toList();
            }
          }

          displayRecords.add(DisplayableRecord(
            rawData: rawRecord,
            convertedData: convertedJson,
            omhDataList: omhJsonList,
            recordIndex: i + 1,
          ));
          tempGlobalRecordIndex++;
        }
        if (displayRecords.isNotEmpty) {
          processedResult[metricKey] = displayRecords;
        }
      });

      if (mounted) {
        setState(() {
          _categorizedData = processedResult;
          _isLoading = false;
          _processingError = null;
        });
      }
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print("Error processing data for display: $e");
        print(stackTrace);
      }
      if (mounted) {
        setState(() {
          _processingError = "An error occurred while preparing data: $e";
          _isLoading = false;
        });
      }
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
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Processing data, please wait..."),
          ],
        ),
      );
    }

    if (_processingError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                "Could not display data:",
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _processingError!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ),
        ),
      );
    }

    if (_categorizedData == null || _categorizedData!.isEmpty) {
      return const PlaceholderModule(
        message: 'No data available or processed.',
        icon: Icons.info_outline,
      );
    }

    int recordGlobalIndex = 0;
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _categorizedData!.keys.length,
      itemBuilder: (context, index) {
        final metricKey = _categorizedData!.keys.elementAt(index);
        final recordsForMetric = _categorizedData![metricKey]!;
        final String metricDisplayName = _getMetricDisplayName(metricKey);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: Text(
                  metricDisplayName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recordsForMetric.length,
                itemBuilder: (context, recordIdx) {
                  final record = recordsForMetric[recordIdx];
                  recordGlobalIndex++;

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
                                style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer),
                              ),
                            ),
                            title: Text(
                              '$metricDisplayName - Record #${record.recordIndex}',
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
                                  _buildDataColumn(
                                    context,
                                    "Raw Data",
                                    record.rawData,
                                    PageStorageKey('raw_$metricKey\_${record.recordIndex}_$recordGlobalIndex'),
                                  ),
                                  _buildDataColumn(
                                    context,
                                    "Converted Plugin Object",
                                    record.convertedData,
                                    PageStorageKey('converted_$metricKey\_${record.recordIndex}_$recordGlobalIndex'),
                                  ),
                                  _buildDataColumn(
                                    context,
                                    "Open mHealth Format",
                                    record.omhDataList.isEmpty ? {"info": "No OMH data generated"} : (record.omhDataList.length == 1 ? record.omhDataList.first : record.omhDataList),
                                    PageStorageKey('omh_$metricKey\_${record.recordIndex}_$recordGlobalIndex'),
                                    isList: record.omhDataList.length > 1,
                                  ),
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataColumn(BuildContext context, String title, dynamic jsonData, Key expansionTileKey, {bool isList = false}) {
    ThemeData currentTheme = Theme.of(context);
    Color titleColor = currentTheme.brightness == Brightness.dark ? Colors.tealAccent[100]! : currentTheme.primaryColorDark;

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

