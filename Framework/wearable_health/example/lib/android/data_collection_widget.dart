import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wearable_health/wearable_health.dart';

class DataCollectionWidget extends StatefulWidget {
  final WearableHealth wearableHealthPlugin;
  final bool isEnabled;
  final bool isCollecting;
  final Function(bool isCollecting) onCollectionStateChange;

  const DataCollectionWidget({
    super.key,
    required this.wearableHealthPlugin,
    required this.isEnabled,
    required this.isCollecting,
    required this.onCollectionStateChange,
  });

  @override
  State<DataCollectionWidget> createState() => _DataCollectionWidgetState();
}

class _DataCollectionWidgetState extends State<DataCollectionWidget> {
  String _collectionStatus = 'Not started';
  final List<String> _collectedData = [];
  StreamSubscription? _dataSubscription;

  Future<void> _startDataCollection() async {
    if (!widget.isEnabled) {
      setState(() {
        _collectionStatus = 'Cannot start: No permissions';
      });
      return;
    }

    try {
      // Set up status stream listener before starting collection
      _dataSubscription = widget.wearableHealthPlugin.statusStream.listen(
            (status) {
          setState(() {
            _collectedData.add('${DateTime.now()}: ${status.toString()}');
            // Keep only the last 10 entries to avoid memory issues
            if (_collectedData.length > 10) {
              _collectedData.removeAt(0);
            }

            // Update the collection status based on the SyncStatus enum
            switch (status) {
              case SyncStatus.collecting:
                _collectionStatus = 'Actively collecting data...';
                widget.onCollectionStateChange(true);
                break;
              case SyncStatus.transforming:
                _collectionStatus = 'Transforming collected data...';
                break;
              case SyncStatus.completed:
                _collectionStatus = 'Collection cycle completed';
                break;
              case SyncStatus.error:
                _collectionStatus = 'Error during collection';
                break;
              default:
                _collectionStatus = 'Status: $status';
            }
          });
        },
        onError: (error) {
          setState(() {
            _collectionStatus = 'Error: $error';
            widget.onCollectionStateChange(false);
          });
        },
      );

      // Start the data collection
      final bool started = await widget.wearableHealthPlugin.startCollecting();

      setState(() {
        if (started) {
          _collectionStatus = 'Collection started';
        } else {
          _collectionStatus = 'Failed to start collection';
          widget.onCollectionStateChange(false);
        }
      });
    } catch (e) {
      setState(() {
        _collectionStatus = 'Error starting collection: $e';
        widget.onCollectionStateChange(false);
      });
    }
  }


  @override
  void dispose() {
    _dataSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Data Collection Test',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text('Status: $_collectionStatus'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: widget.isEnabled && !widget.isCollecting
                      ? _startDataCollection
                      : null,
                  child: const Text('Start Collecting'),
                ),
                const SizedBox(width: 20),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _collectedData.isEmpty
                  ? const Center(child: Text('No data collected yet'))
                  : ListView.builder(
                itemCount: _collectedData.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_collectedData[index]),
                    dense: true,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}