import 'package:flutter/material.dart';
// Standard Flutter material design widgets.

import 'package:wearable_health_example/widgets/placeholder.dart';
// Imports the PlaceholderModule widget, used when no conversion stats are available.

import '../models/conversion_validity_result.dart';
// Imports the data model that holds the statistics about conversion validity.

/// A Flutter [StatelessWidget] designed to display the results of a data
/// conversion accuracy test.
///
/// This widget takes a [ConversionValidityResult] object as input.
/// If the results are available, it calculates and displays:
///  - The overall conversion accuracy percentage.
///  - The total number of heart rate records processed and how many were validated.
///  - The total number of heart rate variability records processed and how many were validated.
///
/// If no results are provided (i.e., [stats] is null), it displays a
/// [PlaceholderModule] prompting the user to run an experiment.
class ConversionModule extends StatelessWidget {
/// Holds the statistics from a conversion validity test.
/// This can be null if no experiment has been run or no results are available.
final ConversionValidityResult? stats;

/// Creates a [ConversionModule] widget.
///
/// Requires [stats], which contains the data conversion accuracy results.
/// The [key] is an optional parameter inherited from [Widget].
const ConversionModule({
super.key, // Pass the key to the superclass.
required this.stats, // The conversion validity statistics are required.
});

@override
Widget build(BuildContext context) {
// Check if conversion statistics are available.
if (stats == null) {
// If no stats, display a placeholder message prompting the user to run an experiment.
return PlaceholderModule(
message: 'Run an experiment to see conversion accuracy results',
icon: Icons.transform, // Icon representing transformation/conversion.
);
} else {
// If stats are available, calculate overall accuracy metrics.
// Total number of records processed (sum of HR and HRV records).
var totalAmountOfRecords =
stats!.totalAmountOfHeartRateObjects +
stats!.totalAmountOfHeartRateVariabilityObjects;
// Total number of records successfully validated (sum of correctly converted HR and HRV).
var totalValidated =
stats!.correctlyConvertedHeartRateObjects +
stats!.correctlyConvertedHeartRateVariabilityObjects;

// Calculate the accuracy percentage.
// Handle potential division by zero if totalAmountOfRecords is 0, though
// the structure implies counts should be >= 0. If totalAmountOfRecords is 0,
// accuracyPercentage would be NaN, then fixed to "NaN%".
// A check for totalAmountOfRecords > 0 before division might be more robust
// if counts can legitimately be zero across the board for an "empty" experiment.
var accuracyPercentage = (totalAmountOfRecords > 0)
? (totalValidated / totalAmountOfRecords * 100)
    : 0.0; // Default to 0.0% if no records to avoid NaN.


// Build the UI to display the conversion accuracy results.
return Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center, // Center content vertically.
children: [
// Icon representing data conversion/transformation.
const Icon(Icons.transform, size: 64, color: Colors.green),
const SizedBox(height: 16), // Spacing.

// Display the module title and overall accuracy percentage.
Text(
'Conversion Module\nAccuracy: ${accuracyPercentage.toStringAsFixed(1)}%',
style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
textAlign: TextAlign.center, // Center the text.
),
const SizedBox(height: 8), // Spacing.

// Display details for heart rate records.
Text(
"Got ${stats!.totalAmountOfHeartRateObjects} amount of heart rate records.\n${stats!.correctlyConvertedHeartRateObjects} got validated.",
style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
textAlign: TextAlign.center,
),
const SizedBox(height: 8), // Spacing.

// Display details for heart rate variability records.
Text(
"Got ${stats!.totalAmountOfHeartRateVariabilityObjects} amount of heart rate variability records.\n${stats!.correctlyConvertedHeartRateVariabilityObjects} got validated.",
style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
textAlign: TextAlign.center,
),
],
),
);
}
}
}