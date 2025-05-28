import 'package:flutter/material.dart';
// Standard Flutter material design widgets.

import 'package:wearable_health_example/models/record_count_result.dart';
// Imports the data model that holds the counts of different types of records.

import 'package:wearable_health_example/widgets/placeholder.dart';
// Imports the PlaceholderModule widget, used when no data retrieval results are available.

/// A Flutter [StatelessWidget] designed to display the results of a data retrieval operation,
/// specifically showing the total number of records retrieved.
///
/// This widget takes a [RecordCountResult] object as input.
/// If the results are available (i.e., [data] is not null), it displays an icon
/// and a message indicating the total number of records successfully retrieved.
///
/// If no results are provided (i.e., [data] is null), it displays a
/// [PlaceholderModule] prompting the user to run an experiment to see
/// data retrieval results.
class DataRetrievalModule extends StatelessWidget {
  /// Holds the results from a data retrieval operation, specifically the counts
  /// of records. This can be null if no experiment has been run or no data
  /// has been retrieved yet.
  final RecordCountResult? data;

  /// Creates a [DataRetrievalModule] widget.
  ///
  /// Requires [data], which contains the record count results from a data retrieval process.
  /// The [key] is an optional parameter inherited from [Widget].
  const DataRetrievalModule({
    super.key, // Pass the key to the superclass.
    required this.data, // The record count results are required.
  });

  @override
  Widget build(BuildContext context) {
    // Check if data retrieval results are available.
    if (data == null) {
      // If no data is available, display a placeholder message
      // prompting the user to run an experiment.
      return PlaceholderModule(
        message: 'Run an experiment to see data retrieval results',
        icon: Icons.storage, // Icon representing data storage/retrieval.
      );
    } else {
      // If data is available, build the UI to display the retrieval results.
      return Center( // Center the content on the screen.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // Center content vertically within the Column.
          children: [
            // Icon representing data storage or retrieval.
            const Icon(Icons.storage, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            // Vertical spacing.

            // Display the module title and the total number of records retrieved.
            // Accesses 'totalAmountOfRecords' getter from the RecordCountResult object.
            Text(
              'Data Retrieval Module\n${data!
                  .totalAmountOfRecords} records retrieved',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center, // Center the text.
            ),
            // Note: The original SizedBox(height: 8) was here. It can be kept for spacing
            // or removed if no further elements are planned below this Text.
            // For this commenting, I'll assume it might be for future elements or consistent spacing.
            const SizedBox(height: 8),
            // Additional vertical spacing.
          ],
        ),
      );
    }
  }
}