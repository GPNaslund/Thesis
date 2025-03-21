// lib/features/data_fetching/pages/data_display_page.dart

import 'package:flutter/material.dart';
import '../controllers/data_fetching_controller.dart';

class DataDisplayPage extends StatefulWidget {
  final String dataType;

  DataDisplayPage({required this.dataType});

  @override
  _DataDisplayPageState createState() => _DataDisplayPageState();
}

class _DataDisplayPageState extends State<DataDisplayPage> {
  String dataFormat = "Choose a data format"; 
  String dataBoxOutput = "Waiting for data...";
  final DataFetchingController _dataFetchingController = DataFetchingController();
  bool isLoading = false; // Loading indicator flag

  // Function to fetch data when a format is selected
  void updateFormat(String newFormat) async {
    setState(() {
      dataFormat = "Displaying ${widget.dataType} data in $newFormat format";
      dataBoxOutput = "Loading..."; // Temporary text while fetching
      isLoading = true; // Show loading
    });

    // Fetching data asynchronously
    String fetchedData = await _dataFetchingController.getHealthData(widget.dataType, newFormat);

    setState(() {
      dataBoxOutput = fetchedData; // Update with fetched data
      isLoading = false; // Hide loading
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.dataType} Data")),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DataFormatLabel(text: dataFormat), 
            SizedBox(height: 20),
            DataResultBox(dataOutput: dataBoxOutput, isLoading: isLoading),
            SizedBox(height: 10),
            DataFormatChoiceButton(dataFormat: "Raw", onSelected: updateFormat),
            SizedBox(height: 10),
            DataFormatChoiceButton(dataFormat: "Open mHealth", onSelected: updateFormat),
            SizedBox(height: 10),
            DataFormatChoiceButton(dataFormat: "JSON", onSelected: updateFormat),
            SizedBox(height: 10),
            DataFormatChoiceButton(dataFormat: "FHIR", onSelected: updateFormat),
          ],
        ),
      ),
    );
  }
}

// Label/Heading for result box
class DataFormatLabel extends StatelessWidget {
  final String text;

  DataFormatLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// Result box
class DataResultBox extends StatelessWidget {
  final String dataOutput;
  final bool isLoading;

  DataResultBox({required this.dataOutput, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
        ],
      ),
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: isLoading
          ? CircularProgressIndicator()
          : Text(
              dataOutput,
              style: TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
    );
  }
}

// Buttons
class DataFormatChoiceButton extends StatelessWidget {
  final String dataFormat;
  final Function(String) onSelected;

  DataFormatChoiceButton({required this.dataFormat, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onSelected(dataFormat);
      },
      child: Text(dataFormat),
    );
  }
}
