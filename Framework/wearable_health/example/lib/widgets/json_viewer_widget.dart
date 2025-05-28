import 'dart:convert'; // For JsonEncoder to pretty-print JSON.
import 'package:flutter/material.dart'; // Standard Flutter material design widgets and core functionalities.

/// A Flutter [StatelessWidget] designed to display dynamic JSON data in a
/// formatted and user-friendly way.
///
/// This widget takes any dynamic [jsonData] object, attempts to pretty-print it
/// as a JSON string with an indent of two spaces, and then displays this string
/// within a styled container.
///
/// Features:
///  - Optional title for the JSON view.
///  - Pretty-printing of JSON with indentation.
///  - Error handling for JSON encoding: if the provided data cannot be
///    converted to JSON, an error message is displayed along with the
///    string representation of the original data.
///  - The displayed JSON string is selectable.
///  - Uses a monospace font for better readability of JSON structure.
///  - Customizable padding and decoration for the container.
class JsonViewerWidget extends StatelessWidget {
  /// The dynamic data to be displayed as JSON. This can be any object
  /// that `JsonEncoder` can convert (e.g., Map, List, String, num, bool).
  final dynamic jsonData;

  /// An optional title string to be displayed above the JSON content.
  /// If null, no title is shown.
  final String? title;

  /// Creates an instance of [JsonViewerWidget].
  ///
  /// Parameters:
  ///  - [key]: Optional widget key, passed to the superclass.
  ///  - [jsonData]: Required. The data to be displayed as JSON.
  ///  - [title]: Optional. A title for this JSON view.
  const JsonViewerWidget({super.key, required this.jsonData, this.title});

  @override
  Widget build(BuildContext context) {
    // Initialize a JsonEncoder with an indent of two spaces for pretty-printing.
    const encoder = JsonEncoder.withIndent('  ');
    // Variable to hold the pretty-printed JSON string or an error message.
    String prettyString;

    try {
      // Attempt to convert the jsonData to a pretty-printed string.
      prettyString = encoder.convert(jsonData);
    } catch (e) {
      // If an error occurs during JSON encoding (e.g., jsonData contains
      // non-JSON-encodable objects like custom classes without toJson),
      // create an error message.
      prettyString = "Error encoding JSON: $e\n\nData: ${jsonData.toString()}";
    }

    // Return a Padding widget to provide some space around the content.
    return Padding(
      padding: const EdgeInsets.all(8.0), // Uniform padding on all sides.
      child: Column( // Arrange title (if any) and JSON content vertically.
        crossAxisAlignment: CrossAxisAlignment.start,
        // Align children to the start (left).
        children: [
          // Conditionally display the title if it's provided.
          if (title != null) ...[
            Text(
              title!, // Use '!' as null check is already done.
              style: TextStyle( // Style for the title.
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Theme
                    .of(context)
                    .colorScheme
                    .primary, // Use primary color from theme.
              ),
            ),
            const SizedBox(height: 4),
            // Small vertical space between title and JSON content.
          ],
          // Container to hold the JSON string with specific styling.
          Container(
            padding: const EdgeInsets.all(10.0),
            // Padding inside the container.
            decoration: BoxDecoration( // Styling for the container's border and background.
              color: Colors.grey.shade100, // Light grey background.
              borderRadius: BorderRadius.circular(8.0), // Rounded corners.
              border: Border.all(
                  color: Colors.grey.shade300), // Light grey border.
            ),
            // PageStorage is used here to potentially save the scroll position of the
            // SelectableText if this widget is part of a list that might be rebuilt
            // (e.g., in a PageView or a ListView with PageStorageKeys).
            // A new PageStorageBucket is created here, which means its scope is limited
            // to this instance of JsonViewerWidget.
            child: PageStorage(
              bucket: PageStorageBucket(),
              // Provides a storage bucket for descendants.
              child: SelectableText( // Allows the user to select and copy the JSON string.
                prettyString, // The pretty-printed JSON or error message.
                style: const TextStyle(fontFamily: 'monospace',
                    fontSize: 11.0), // Monospace font for JSON.
              ),
            ),
          ),
        ],
      ),
    );
  }
}