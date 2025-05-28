import 'package:flutter/cupertino.dart'; // Though not directly used in this widget, often included with Material.
import 'package:flutter/material.dart'; // Standard Flutter material design widgets and core functionalities.

/// A Flutter [StatelessWidget] designed to display a generic placeholder message
/// with an icon.
///
/// This widget is useful for indicating states where content is not yet available,
/// an action is required from the user, or an empty state needs to be represented.
/// It centers an icon and a message text vertically and horizontally on the screen.
///
class PlaceholderModule extends StatelessWidget {
  /// The message string to be displayed below the icon.
  final String message;

  /// The [IconData] for the icon to be displayed above the message.
  /// Example: `Icons.info`, `Icons.error`, `Icons.search_off`.
  final IconData icon;

  /// Creates a [PlaceholderModule] widget.
  ///
  /// Parameters:
  ///  - [key]: Optional widget key, passed to the superclass.
  ///  - [message]: Required. The text message to display.
  ///  - [icon]: Required. The icon to display.
  const PlaceholderModule({
    super.key, // Pass the key to the superclass.
    required this.message, // The placeholder message is mandatory.
    required this.icon,    // The placeholder icon is mandatory.
  });

  @override
  Widget build(BuildContext context) {
    // Center widget to align its child (the Column) in the middle of the available space.
    return Center(
      child: Column( // Column to arrange the icon and text vertically.
        mainAxisAlignment: MainAxisAlignment.center, // Center children vertically within the Column.
        children: [
          // Icon widget to display the provided icon.
          Icon(
            icon,                          // The specific icon to show.
            size: 64,                       // Define a fixed size for the icon.
            color: Colors.grey.shade400,    // Set a muted grey color for the icon.
          ),
          // SizedBox used to create a fixed vertical space between the icon and the text.
          const SizedBox(height: 16),
          // Text widget to display the placeholder message.
          Text(
            message,                       // The specific message string.
            style: TextStyle(              // Style the text.
              fontSize: 16,                // Define the font size.
              color: Colors.grey.shade600, // Set a slightly darker grey for text readability.
            ),
            textAlign: TextAlign.center,   // Center the text horizontally if it spans multiple lines.
          ),
        ],
      ),
    );
  }
}