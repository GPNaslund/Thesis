import 'package:flutter/material.dart';
import 'package:wearable_health/provider/data_converter.dart';
import '../enums/health_data_type.dart';


class GetDataRequest {
  DateTimeRange timeRange;
  List<HealthDataType> dataTypes;
  DataConverter? converter;

  GetDataRequest(this.timeRange, this.dataTypes, {this.converter} );

  Map<String, dynamic> toMap() {
    List<String> dataTypeString = [];
    for (final dataType in dataTypes) {
      dataTypeString.add(dataType.value);
    }
    return {
      "start": timeRange.start.toUtc().toIso8601String(),
      "end": timeRange.end.toUtc().toIso8601String(),
      "dataTypes": dataTypeString,
    };
  }
}