import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wearable_health/controller/wearable_health.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/service/converters/json/json_converter.dart';
import 'package:wearable_health/service/health_connect/data_factory.dart';
import 'package:wearable_health/service/health_connect/data_factory_interface.dart';
import 'package:wearable_health/service/health_kit/data_factory.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';
import 'package:wearable_health_example/models/conversion_validity_result.dart';
import 'package:wearable_health_example/models/experimentation_result.dart';
import 'package:wearable_health_example/models/performance_test_result.dart';
import 'package:wearable_health_example/models/record_count_result.dart';
import 'package:wearable_health_example/services/data_export.dart';
import 'package:wearable_health_example/services/health_connect/hc_data_conversion_validation.dart';
import 'package:wearable_health_example/services/health_connect/hc_performance_test.dart';
import 'package:wearable_health_example/services/health_connect/hc_record_count.dart';
import 'package:wearable_health_example/services/health_kit/hk_data_conversion_validation.dart';
import 'package:wearable_health_example/services/health_kit/hk_performance_test.dart';
import 'package:wearable_health_example/services/health_kit/hk_record_count.dart';
import 'package:wearable_health_example/widgets/performance_module.dart';

import 'widgets/data_conversion.dart';
import 'widgets/data_retrieval.dart';

void main() {
  runApp(const HealthPluginExampleApp());
}

class HealthPluginExampleApp extends StatelessWidget {
  const HealthPluginExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Plugin Experiment',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ExperimentPage(),
    );
  }
}

class ExperimentPage extends StatefulWidget {
  const ExperimentPage({super.key});

  @override
  State<ExperimentPage> createState() => _ExperimentPageState();
}

class _ExperimentPageState extends State<ExperimentPage>
    with SingleTickerProviderStateMixin {
  // General setup
  late TabController _tabController;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  bool _dataAvailable = false;
  bool _isLoading = false;
  Map<String, List<Map<String, dynamic>>>? _data;
  Stopwatch stopWatch = Stopwatch();

  //Result models
  ConversionValidityResult? conversionValidityResult;
  PerformanceTestResult? performanceTestResult;
  RecordCountResult? recordCountResult;

  // Android specific services
  late HCDataConversionValidation hcConversionValidator;
  late HCPerformanceTest hcPerformanceTester;
  late HCRecordCount hcRecordCounter;

  // Ios specific services
  late HKDataConversionValidation hkConversionValidator;
  late HKPerformanceTest hkPerformanceTester;
  late HKRecordCount hkRecordCounter;

  // Result exporter
  late ResultExporter resultExporter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    var jsonConverter = JsonConverterImpl();
    HCDataFactory hcDataFactory = HCDataFactoryImpl(jsonConverter);
    HKDataFactory hkDataFactory = HKDataFactoryImpl(jsonConverter);
    hcConversionValidator = HCDataConversionValidation(hcDataFactory);
    hcPerformanceTester = HCPerformanceTest(hcDataFactory);
    hcRecordCounter = HCRecordCount();
    resultExporter = ResultExporter();
    hkConversionValidator = HKDataConversionValidation(hkDataFactory);
    hkPerformanceTester = HKPerformanceTest(hkDataFactory);
    hkRecordCounter = HKRecordCount();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _runExperiment() async {
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // try {
      if (Platform.isAndroid) {
        await _fetchDataAndroid();
      } else {
        await _fetchDataIOS();
      }

      setState(() {
        _dataAvailable = true;
        _isLoading = false;
      });
    /* } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error running experiment: ${e.toString()}')),
      );
    } */
  }

  _fetchDataAndroid() async {
    var dataTypes = [
      HealthConnectHealthMetric.heartRate,
      HealthConnectHealthMetric.heartRateVariability,
    ];
    var sut = WearableHealth().getGoogleHealthConnect();
    await sut.requestPermissions(dataTypes);
    stopWatch.start();
    var result = await sut.getRawData(
      dataTypes,
      DateTimeRange(start: _startDate, end: _endDate),
    );
    stopWatch.stop();

    setState(() {
      _data = result.data;
      recordCountResult = hcRecordCounter.calculateRecordCount(_data!);
      conversionValidityResult = hcConversionValidator.performConversionValidation(_data!);
      performanceTestResult = hcPerformanceTester.getPerformanceResults(_data!, stopWatch.elapsedMilliseconds, stopWatch);
      stopWatch.reset();
    });
  }

  _fetchDataIOS() async {
    var dataTypes = [
      HealthKitHealthMetric.heartRate,
      HealthKitHealthMetric.heartRateVariability,
    ];
    var sut = WearableHealth().getAppleHealthKit();
    await sut.requestPermissions(dataTypes);
    stopWatch.start();
    var result = await sut.getRawData(
      dataTypes,
      DateTimeRange(start: _startDate, end: _endDate),
    );
    stopWatch.stop();

    setState(() {
      _data = result.data;
      recordCountResult = hkRecordCounter.calculateRecordCount(_data!);
      conversionValidityResult = hkConversionValidator.performConversionValidation(_data!);
      performanceTestResult = hkPerformanceTester.getPerformanceResults(_data!, stopWatch.elapsedMilliseconds, stopWatch);
    });
  }

  Future<void> _exportDataToFile() async {
    try {
      var results = ExperimentationResult(
          amountOfRecords: recordCountResult!.totalAmountOfRecords,
          amountOfHRRecords: recordCountResult!.amountOfHRRecords,
          amountOfValidatedHR: conversionValidityResult!.correctlyConvertedHeartRateObjects,
          amountOfHRVRecords: recordCountResult!.amountOfHRVRecords,
          amountOfValidatedHRV: conversionValidityResult!.correctlyConvertedHeartRateVariabilityObjects,
          totalFetchTimeMs: performanceTestResult!.totalExecutionTimeMs,
          rawDataFetchTimeMs: performanceTestResult!.dataFetchExecutionInMs,
          conversionFetchTimeMs: performanceTestResult!.conversionExecutionInMs
      );

      await resultExporter.createAndShareResults(results, context);
    } catch (e) {
      print("Error exporting data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting results: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Plugin Experiment'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(
                Icons.storage,
                color: _dataAvailable ? Colors.blue : Colors.grey,
              ),
              text: 'Data Retrieval',
            ),
            Tab(
              icon: Icon(
                Icons.transform,
                color: _dataAvailable ? Colors.blue : Colors.grey,
              ),
              text: 'Conversion',
            ),
            Tab(
              icon: Icon(
                Icons.speed,
                color: _dataAvailable ? Colors.blue : Colors.grey,
              ),
              text: 'Performance',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Experiment tabs content area
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                DataRetrievalModule(data: recordCountResult),
                ConversionModule(stats: conversionValidityResult),
                PerformanceModule(data: performanceTestResult),
              ],
            ),
          ),

          // Date selection and experiment controls
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildDateSelector(
                        context,
                        'Start Date',
                        _startDate,
                        () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDateSelector(
                        context,
                        'End Date',
                        _endDate,
                        () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _runExperiment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child:
                        _isLoading
                            ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                            : const Text(
                              'Start Experiment',
                              style: TextStyle(fontSize: 16),
                            ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed:
                        _dataAvailable
                            ? () {
                              _exportDataToFile();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Exporting results...'),
                                ),
                              );
                            }
                            : null,
                    icon: const Icon(Icons.file_download),
                    label: const Text('Export Results to File'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      disabledForegroundColor: Colors.grey.shade400,
                      side: BorderSide(
                        color:
                            _dataAvailable ? Colors.blue : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime date,
    VoidCallback onTap,
  ) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(formattedDate, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
