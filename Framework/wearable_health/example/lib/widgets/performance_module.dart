import 'package:flutter/material.dart';
// Standard Flutter material design widgets and core functionalities.

import 'package:wearable_health_example/models/performance_test_result.dart';
// Imports the data model that holds the results of a performance test.

import 'package:wearable_health_example/widgets/placeholder.dart';
// Imports the PlaceholderModule widget, used when no performance data is available.

/// A Flutter [StatelessWidget] designed to display the results of a performance test.
///
/// This module visualizes metrics such as:
///  - Total execution time for the tested operations.
///  - Time taken for fetching raw data.
///  - Time taken for data conversion processes.
///  - The number of elements converted.
///
/// If no performance data is provided (i.e., [data] is null), it displays a
/// [PlaceholderModule] prompting the user to run an experiment.
class PerformanceModule extends StatelessWidget {
/// Holds the results from a performance test.
/// This can be null if no experiment has been run or no results are available yet.
final PerformanceTestResult? data;

/// Creates a [PerformanceModule] widget.
///
/// Requires [data], which contains the performance test results.
/// The [key] is an optional parameter inherited from [Widget].
const PerformanceModule({super.key, required this.data });

@override
Widget build(BuildContext context) {
// Check if performance test data is available.
if (data == null) {
// If no data, display a placeholder message prompting the user to run an experiment.
return PlaceholderModule(
message: 'Run an experiment to see performance metrics',
icon: Icons.speed, // Icon representing speed/performance.
);
} else {
// If data is available, build the UI to display the performance metrics.
return Center( // Center the content on the screen.
child: Column(
mainAxisAlignment: MainAxisAlignment.center, // Center content vertically within the Column.
children: [
// Icon representing performance or speed.
const Icon(Icons.speed, size: 64, color: Colors.purple),
const SizedBox(height: 16), // Vertical spacing.

// Display the module title and the total execution time.
// Uses the getter 'totalExecutionTimeMs' from PerformanceTestResult.
Text(
'Performance Module\nTotal time: ${data!.totalExecutionTimeMs}ms',
style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
textAlign: TextAlign.center, // Center the text.
),
const SizedBox(height: 8), // Vertical spacing.

// Display detailed breakdown of execution times and elements converted.
Text(
'Fetching raw data took ${data!.dataFetchExecutionInMs}ms\nConversion to openMHealth took ${data!.conversionExecutionInMs}ms\nConverted ${data!.amountOfElementsConverted} objects',
style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
textAlign: TextAlign.center, // Center the text.
),
],
),
);
}
}
}

// Note: The ConversionStats class below seems unrelated to PerformanceModule
// and might be from a different context or an old leftover.
// If it's not used by PerformanceModule or elsewhere in this file's direct context,
// consider moving or removing it.
// For the purpose of this commenting task, I will comment it assuming it was
// intended to be related or for future use within this file's scope.

/// A data class intended to hold statistics about a conversion process.
///
/// Specifically, it stores:
///  - The time taken for the conversion in milliseconds.
///  - The number of elements that were converted.
///
/// Note: This class is not directly used by the [PerformanceModule] above
/// in its current implementation.
class ConversionStats {
/// The time taken for a conversion process, measured in milliseconds.
int conversionTimeInMs;

/// The number of individual elements that were converted.
int amountOfElementsConverted;

/// Creates an instance of [ConversionStats].
///
/// Parameters:
///  - [conversionTimeInMs]: The duration of the conversion in milliseconds.
///  - [amountOfElementsConverted]: The count of converted elements.
ConversionStats(this.conversionTimeInMs, this.amountOfElementsConverted);
}