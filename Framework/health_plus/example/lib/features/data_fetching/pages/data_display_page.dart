import 'package:flutter/material.dart';
import '../controllers/data_fetching_controller.dart';
import '../../../constants/metrics.dart';

class DataDisplayPage extends StatefulWidget {
  final HealthMetric dataType;

  const DataDisplayPage({super.key, required this.dataType});

  @override
  DataDisplayPageState createState() => DataDisplayPageState();
}

class DataDisplayPageState extends State<DataDisplayPage> {
  String dataFormat = "Choose a data format";
  String dataBoxOutput = "Waiting for data...";
  final DataFetchingController _dataFetchingController = DataFetchingController();
  bool isLoading = false;

  // Only support these for now based on plugin capability
  final List<String> supportedFormats = ["Raw", "Open mHealth"];

  void updateFormat(String newFormat) async {
    setState(() {
      dataFormat = "Displaying ${widget.dataType.displayName} data in $newFormat format";
      dataBoxOutput = "Loading...";
      isLoading = true;
    });

    final fetchedData = await _dataFetchingController.getHealthData(widget.dataType, newFormat);

    setState(() {
      dataBoxOutput = fetchedData;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.dataType.displayName} Data")),
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
            ...supportedFormats.map((format) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: DataFormatChoiceButton(
                dataFormat: format,
                onSelected: updateFormat,
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class DataFormatLabel extends StatelessWidget {
  final String text;

  const DataFormatLabel({super.key, required this.text});

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

class DataResultBox extends StatelessWidget {
  final String dataOutput;
  final bool isLoading;

  const DataResultBox({super.key, required this.dataOutput, required this.isLoading});

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

class DataFormatChoiceButton extends StatelessWidget {
  final String dataFormat;
  final Function(String) onSelected;

  const DataFormatChoiceButton({super.key, required this.dataFormat, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => onSelected(dataFormat),
      child: Text(dataFormat),
    );
  }
}
