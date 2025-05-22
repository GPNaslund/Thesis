import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wearable_health/controller/wearable_health.dart';
import 'package:wearable_health/model/health_connect/enums/hc_health_metric.dart';
import 'package:wearable_health/model/health_kit/enums/hk_health_metric.dart';
import 'package:wearable_health/service/converters/json/json_converter.dart';
import 'package:wearable_health/service/converters/json/json_converter_interface.dart';
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
import 'package:wearable_health_example/widgets/display_data.dart';
import 'package:wearable_health_example/widgets/performance_module.dart';

import 'widgets/data_conversion.dart';
import 'widgets/data_retrieval.dart';

enum ExperimentMode { historical, realTime }

void main() {
  runApp(const HealthPluginExampleApp());
}

class HealthPluginExampleApp extends StatelessWidget {
  const HealthPluginExampleApp({super.key});

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

class _ExperimentPageState extends State<ExperimentPage> {
  int _selectedPageIndex = 0;
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _endDate = DateTime.now();
  bool _dataAvailable = false;
  bool _isLoading = false;
  bool _showExperimentControls = false;
  Map<String, List<Map<String, dynamic>>>? _data;
  final Stopwatch _stopWatch = Stopwatch();

  ConversionValidityResult? conversionValidityResult;
  PerformanceTestResult? performanceTestResult;
  RecordCountResult? recordCountResult;

  late HCDataConversionValidation hcConversionValidator;
  late HCPerformanceTest hcPerformanceTester;
  late HCRecordCount hcRecordCounter;
  late HCDataFactory hcDataFactory;

  late HKDataConversionValidation hkConversionValidator;
  late HKPerformanceTest hkPerformanceTester;
  late HKRecordCount hkRecordCounter;
  late HKDataFactory hkDataFactory;

  late ResultExporter resultExporter;

  ExperimentMode _currentMode = ExperimentMode.historical;
  bool _isRealTimeSessionRunning = false;
  Timer? _realTimeTimer;
  List<dynamic> _activeDataTypes = [];

  static const Duration _realTimePollingInterval = Duration(minutes: 1);
  static const Duration _realTimeFetchWindow = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    JsonConverter jsonConverter = JsonConverterImpl();
    hcDataFactory = HCDataFactoryImpl(jsonConverter);
    hkDataFactory = HKDataFactoryImpl(jsonConverter);
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
    _realTimeTimer?.cancel();
    super.dispose();
  }

  Widget _buildCurrentPageWidget() {
    switch (_selectedPageIndex) {
      case 0:
        return DataRetrievalModule(data: recordCountResult);
      case 1:
        return ConversionModule(stats: conversionValidityResult);
      case 2:
        return PerformanceModule(data: performanceTestResult);
      case 3:
        return DataDisplayModule(
          data: _data,
          hcDataFactory: hcDataFactory,
          hkDataFactory: hkDataFactory,
        );
      default:
        return const Center(child: Text("Page not found."));
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime initialDateTime = isStartDate ? _startDate : _endDate;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null || !mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDateTime),
    );

    if (pickedTime == null || !mounted) return;

    final DateTime finalDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      if (isStartDate) {
        if (finalDateTime.isAfter(_endDate)) {
          _startDate = finalDateTime;
          _endDate = finalDateTime.add(const Duration(hours: 1));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Start date was after end date. End date adjusted accordingly.',
              ),
            ),
          );
        } else {
          _startDate = finalDateTime;
        }
      } else {
        if (finalDateTime.isBefore(_startDate)) {
          _endDate = finalDateTime;
          _startDate = finalDateTime.subtract(const Duration(hours: 1));
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'End date was before start date. Start date adjusted accordingly.',
              ),
            ),
          );
        } else {
          _endDate = finalDateTime;
        }
      }
    });
  }

  void _handlePrimaryButtonAction() {
    if (_currentMode == ExperimentMode.historical) {
      _runHistoricalExperiment();
    } else {
      if (_isRealTimeSessionRunning) {
        _stopRealTimeSession();
      } else {
        _startRealTimeSession();
      }
    }
  }

  Future<bool> _requestPlatformPermissions(List<dynamic> dataTypes) async {
    var wearableHealthController = WearableHealth();
    try {
      if (Platform.isAndroid) {
        final sut = wearableHealthController.getGoogleHealthConnect();
        await sut.requestPermissions(
          List<HealthConnectHealthMetric>.from(dataTypes),
        );
      } else {
        final sut = wearableHealthController.getAppleHealthKit();
        await sut.requestPermissions(
          List<HealthKitHealthMetric>.from(dataTypes),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission error: ${e.toString()}')),
        );
      }
      if (kDebugMode) {
        print("Error requesting permissions: $e");
      }
      return false;
    }
  }

  Future<Map<String, List<Map<String, dynamic>>>?> _fetchDataForRange(
    List<dynamic> dataTypes,
    DateTimeRange range,
  ) async {
    var wearableHealthController = WearableHealth();
    Map<String, List<Map<String, dynamic>>>? resultData;
    try {
      if (Platform.isAndroid) {
        final sut = wearableHealthController.getGoogleHealthConnect();
        final platformResult = await sut.getRawData(
          List<HealthConnectHealthMetric>.from(dataTypes),
          range,
        );
        resultData = platformResult.data;
      } else {
        final sut = wearableHealthController.getAppleHealthKit();
        final platformResult = await sut.getRawData(
          List<HealthKitHealthMetric>.from(dataTypes),
          range,
        );
        if (kDebugMode) {
          print('--- _fetchDataForRange DEBUG (Android) ---');
          print('platformResult from sut.getRawData: $platformResult');
        }
        resultData = platformResult.data;
      }
      return resultData;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching data: ${e.toString()}')),
        );
      }
      if (kDebugMode) {
        print("Error in _fetchDataForRange: $e");
      }
      return null;
    }
  }

  Future<void> _runHistoricalExperiment() async {
    if (_currentMode == ExperimentMode.realTime && _isRealTimeSessionRunning) {
      if (mounted) {
        setState(() {
          _stopRealTimeSession();
        });
      }
    }
    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _dataAvailable = false;
      _data = null;
      recordCountResult = null;
      conversionValidityResult = null;
      performanceTestResult = null;
    });

    _activeDataTypes =
        Platform.isAndroid
            ? [
              HealthConnectHealthMetric.heartRate,
              HealthConnectHealthMetric.heartRateVariability,
            ]
            : [
              HealthKitHealthMetric.heartRate,
              HealthKitHealthMetric.heartRateVariability,
            ];

    bool permissionsGranted = await _requestPlatformPermissions(
      _activeDataTypes,
    );
    if (!permissionsGranted) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    _stopWatch.reset();
    _stopWatch.start();
    final fetchedData = await _fetchDataForRange(
      _activeDataTypes,
      DateTimeRange(start: _startDate, end: _endDate),
    );
    _stopWatch.stop();

    if (mounted) {
      if (fetchedData != null) {
        _data = fetchedData;
        if (Platform.isAndroid) {
          recordCountResult = hcRecordCounter.calculateRecordCount(_data!);
          conversionValidityResult = hcConversionValidator
              .performConversionValidation(_data!);
          performanceTestResult = hcPerformanceTester.getPerformanceResults(
            _data!,
            _stopWatch.elapsedMilliseconds,
            _stopWatch,
          );
        } else {
          recordCountResult = hkRecordCounter.calculateRecordCount(_data!);
          conversionValidityResult = hkConversionValidator
              .performConversionValidation(_data!);
          performanceTestResult = hkPerformanceTester.getPerformanceResults(
            _data!,
            _stopWatch.elapsedMilliseconds,
            _stopWatch,
          );
        }
        _dataAvailable = _data!.values.any((list) => list.isNotEmpty);
      } else {
        _dataAvailable = false;
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startRealTimeSession() async {
    setState(() {
      _isLoading = true;
    });

    _activeDataTypes =
        Platform.isAndroid
            ? [
              HealthConnectHealthMetric.heartRate,
              HealthConnectHealthMetric.heartRateVariability,
            ]
            : [
              HealthKitHealthMetric.heartRate,
              HealthKitHealthMetric.heartRateVariability,
            ];

    bool permissionsGranted = await _requestPlatformPermissions(
      _activeDataTypes,
    );
    if (!permissionsGranted) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) {
      setState(() {
        _data = {};
        recordCountResult = null;
        conversionValidityResult = null;
        performanceTestResult =
            null;
        _dataAvailable = false;
        _isRealTimeSessionRunning = true;
        _isLoading = false;
      });
    }

    await _fetchAndProcessRealTimeData();

    _realTimeTimer?.cancel();
    _realTimeTimer = Timer.periodic(_realTimePollingInterval, (timer) {
      if (!_isRealTimeSessionRunning || !mounted) {
        timer.cancel();
        return;
      }
      _fetchAndProcessRealTimeData();
    });
  }

  Future<void> _fetchAndProcessRealTimeData() async {
    if (!mounted || !_isRealTimeSessionRunning) {
      return;
    }

    final DateTime endTime = DateTime.now();
    final DateTime startTime = endTime.subtract(_realTimeFetchWindow);

    final Map<String, List<Map<String, dynamic>>>? newlyFetchedChunk =
    await _fetchDataForRange(
      _activeDataTypes,
      DateTimeRange(start: startTime, end: endTime),
    );

    if (kDebugMode) {
      print('--- REAL-TIME FETCH DEBUG ---');
      print('Platform: ${Platform.operatingSystem}');
      print('Timestamp: ${DateTime.now()}');
      print('Newly Fetched Chunk: $newlyFetchedChunk');
    }

    if (mounted && newlyFetchedChunk != null && newlyFetchedChunk.isNotEmpty) {
      Map<String, List<Map<String, dynamic>>> workingDataCopy = Map.from(
        _data ?? {},
      );
      bool newUniqueDataWasAddedThisPollOverall = false;

      newlyFetchedChunk.forEach((dataTypeKey, incomingSampleList) {
        workingDataCopy[dataTypeKey] ??= [];

        final Set<String> existingUUIDs = workingDataCopy[dataTypeKey]!
            .map((sample) {
          String uuid;
          if (Platform.isIOS) {
            uuid = sample['uuid'] as String? ?? '';
          } else {
            final metadataRaw = sample['metadata'];
            final Map<String, dynamic>? metadata = metadataRaw == null
                ? null
                : Map<String, dynamic>.from(metadataRaw as Map);
            uuid = metadata?['id'] as String? ?? '';
          }
          return uuid;
        })
            .where((uuid) => uuid.isNotEmpty)
            .toSet();

        int addedThisKeyCount = 0;
        for (final newSample in incomingSampleList) {
          String newSampleUUID;
          if (Platform.isIOS) {
            newSampleUUID = newSample['uuid'] as String? ?? '';
          } else {
            final metadataRaw = newSample['metadata'];
            final Map<String, dynamic>? metadata = metadataRaw == null
                ? null
                : Map<String, dynamic>.from(metadataRaw as Map);
            newSampleUUID = metadata?['id'] as String? ?? '';
          }

          bool isNewAndValid =
              newSampleUUID.isNotEmpty && !existingUUIDs.contains(newSampleUUID);

          if (isNewAndValid) {
            workingDataCopy[dataTypeKey]!.add(newSample);
            addedThisKeyCount++;
          }
        }

        if (addedThisKeyCount > 0) {
          newUniqueDataWasAddedThisPollOverall = true;
        }
      });

      if (newUniqueDataWasAddedThisPollOverall) {
        setState(() {
          _data = workingDataCopy;
          final bool hasAnyDataNow = _data!.values.any((list) => list.isNotEmpty);

          if (hasAnyDataNow) {
            _dataAvailable = true;
            if (Platform.isAndroid) {
              recordCountResult = hcRecordCounter.calculateRecordCount(_data!);
              conversionValidityResult =
                  hcConversionValidator.performConversionValidation(_data!);
            } else {
              recordCountResult = hkRecordCounter.calculateRecordCount(_data!);
              conversionValidityResult =
                  hkConversionValidator.performConversionValidation(_data!);
            }
          } else {
            _dataAvailable = false;
            recordCountResult = null;
            conversionValidityResult = null;
          }
          performanceTestResult = null;
        });
      }
    } else if (mounted) {
      bool shouldClearDisplayedData =
          _data != null && _data!.values.any((list) => list.isNotEmpty);

      if (shouldClearDisplayedData &&
          (_dataAvailable || recordCountResult != null)) {
        setState(() {
          _data = {};
          _dataAvailable = false;
          recordCountResult = null;
          conversionValidityResult = null;
          performanceTestResult = null;
        });
      }
    }
  }

  void _stopRealTimeSession() {
    _realTimeTimer?.cancel();
    _realTimeTimer = null;
    if (mounted) {
      setState(() {
        _isRealTimeSessionRunning = false;
      });
    }
  }

  Future<void> _exportDataToFile() async {
    bool canExportHistorical =
        _currentMode == ExperimentMode.historical &&
        recordCountResult != null &&
        conversionValidityResult != null &&
        performanceTestResult != null;
    bool canExportRealTime =
        _currentMode == ExperimentMode.realTime &&
        _dataAvailable &&
        recordCountResult != null &&
        conversionValidityResult != null;

    if (!canExportHistorical && !canExportRealTime) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No complete data set available to export for the current mode.',
            ),
          ),
        );
      }
      return;
    }

    String exportMessage = "Exporting results...";
    if (_currentMode == ExperimentMode.realTime &&
        performanceTestResult == null &&
        canExportRealTime) {
      exportMessage =
          'Exporting accumulated real-time data (session performance metrics not applicable).';
    }
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(exportMessage)));
    }

    try {
      var results = ExperimentationResult(
        amountOfRecords: recordCountResult!.totalAmountOfRecords,
        amountOfHRRecords: recordCountResult!.amountOfHRRecords,
        amountOfValidatedHR:
            conversionValidityResult!.correctlyConvertedHeartRateObjects,
        amountOfHRVRecords: recordCountResult!.amountOfHRVRecords,
        amountOfValidatedHRV:
            conversionValidityResult!
                .correctlyConvertedHeartRateVariabilityObjects,
        totalFetchTimeMs:
            performanceTestResult?.totalExecutionTimeMs ??
            0,
        rawDataFetchTimeMs:
            performanceTestResult?.dataFetchExecutionInMs ??
            0,
        conversionFetchTimeMs:
            performanceTestResult?.conversionExecutionInMs ??
            0,
      );
      await resultExporter.createAndShareResults(results, context);
    } catch (e) {
      if (kDebugMode) {
        print("Error exporting data: $e");
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error exporting results: $e')));
      }
    }
  }

  Future<void> _exportDataToFileWithFeedback() async {
    await _exportDataToFile();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> pageDestinations = [
      {'title': 'Data Retrieval', 'icon': Icons.storage_rounded},
      {'title': 'Conversion Metrics', 'icon': Icons.transform_rounded},
      {'title': 'Performance Metrics', 'icon': Icons.speed_rounded},
      {'title': 'Inspect Data', 'icon': Icons.table_chart_outlined},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Plugin Experiment'),
        actions: [
          IconButton(
            icon: Icon(
              _showExperimentControls ? Icons.expand_less : Icons.expand_more,
            ),
            tooltip: _showExperimentControls ? 'Hide Setup' : 'Show Setup',
            onPressed: () {
              setState(() {
                _showExperimentControls = !_showExperimentControls;
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Text(
                'Experiment Modules',
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            for (int i = 0; i < pageDestinations.length; i++)
              ListTile(
                leading: Icon(
                  pageDestinations[i]['icon'] as IconData,
                  color:
                      _selectedPageIndex == i
                          ? Theme.of(context).colorScheme.primary
                          : (_dataAvailable
                              ? Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color?.withOpacity(0.8)
                              : Colors.grey[600]),
                ),
                title: Text(
                  pageDestinations[i]['title'] as String,
                  style: TextStyle(
                    fontWeight:
                        _selectedPageIndex == i
                            ? FontWeight.bold
                            : FontWeight.normal,
                    color:
                        _selectedPageIndex == i
                            ? Theme.of(context).colorScheme.primary
                            : (_dataAvailable
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Colors.grey[700]),
                  ),
                ),
                selected: _selectedPageIndex == i,
                selectedTileColor: Theme.of(
                  context,
                ).colorScheme.primary.withOpacity(0.1),
                onTap: () {
                  if (mounted) {
                    setState(() {
                      _selectedPageIndex = i;
                    });
                  }
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _buildCurrentPageWidget()),
          AnimatedCrossFade(
            crossFadeState:
                _showExperimentControls
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
            firstChild: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: SegmentedButton<ExperimentMode>(
                      segments: const <ButtonSegment<ExperimentMode>>[
                        ButtonSegment<ExperimentMode>(
                          value: ExperimentMode.historical,
                          label: Text('Historical'),
                          icon: Icon(Icons.history),
                        ),
                        ButtonSegment<ExperimentMode>(
                          value: ExperimentMode.realTime,
                          label: Text('Real-time'),
                          icon: Icon(Icons.timer_sharp),
                        ),
                      ],
                      selected: <ExperimentMode>{_currentMode},
                      onSelectionChanged: (Set<ExperimentMode> newSelection) {
                        setState(() {
                          _currentMode = newSelection.first;
                          if (_currentMode == ExperimentMode.historical &&
                              _isRealTimeSessionRunning) {
                            _stopRealTimeSession();
                          }
                          _data = null;
                          _dataAvailable = false;
                          recordCountResult = null;
                          conversionValidityResult = null;
                          performanceTestResult = null;
                          _isLoading = false;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.2),
                        selectedForegroundColor:
                            Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  if (_currentMode == ExperimentMode.historical)
                    Column(
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
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        _isLoading
                            ? Icons.hourglass_empty_rounded
                            : _currentMode == ExperimentMode.historical
                            ? Icons.play_arrow_rounded
                            : _isRealTimeSessionRunning
                            ? Icons.stop_rounded
                            : Icons.play_circle_filled_rounded,
                      ),
                      onPressed: _isLoading ? null : _handlePrimaryButtonAction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isRealTimeSessionRunning &&
                                    _currentMode == ExperimentMode.realTime
                                ? Colors.redAccent.shade200
                                : Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      label: Text(
                        _isLoading
                            ? 'Processing...'
                            : _currentMode == ExperimentMode.historical
                            ? 'Fetch Historical Data'
                            : _isRealTimeSessionRunning
                            ? 'Stop Real-time Session'
                            : 'Start Real-time Session',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed:
                          (_dataAvailable &&
                                  recordCountResult != null &&
                                  conversionValidityResult != null)
                              ? _exportDataToFileWithFeedback
                              : null,
                      icon: const Icon(Icons.file_download_outlined),
                      label: const Text('Export Results'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        disabledForegroundColor: Colors.grey.shade400,
                        side: BorderSide(
                          color:
                              (_dataAvailable &&
                                      recordCountResult != null &&
                                      conversionValidityResult != null)
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            secondChild: const SizedBox.shrink(),
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
    final formattedDate = DateFormat('MMM dd, yy HH:mm').format(date);
    bool dateSelectorEnabled =
        _currentMode == ExperimentMode.historical &&
        !_isRealTimeSessionRunning &&
        !_isLoading;

    return InkWell(
      onTap: dateSelectorEnabled ? onTap : null,
      child: Opacity(
        opacity: dateSelectorEnabled ? 1.0 : 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color:
                        dateSelectorEnabled
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color:
                            dateSelectorEnabled
                                ? Theme.of(context).textTheme.bodyLarge?.color
                                : Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
