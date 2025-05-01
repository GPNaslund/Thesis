import 'package:flutter/services.dart';
import 'package:wearable_health/provider/dto/check_permissions_request.dart';
import 'package:wearable_health/provider/dto/check_permissions_response.dart';
import 'package:wearable_health/provider/dto/datastore_availability_response.dart';
import 'package:wearable_health/provider/dto/get_data_response.dart';
import 'package:wearable_health/provider/dto/get_data_request.dart';
import 'package:wearable_health/provider/dto/request_permissions_request.dart';
import 'package:wearable_health/provider/dto/request_permissions_response.dart';
import 'package:wearable_health/provider/enums/health_data_type.dart';
import 'package:wearable_health/provider/provider.dart';

import '../method_type.dart';

abstract class NativeProvider implements Provider {
  final methodChannel = MethodChannel("wearable_health");


  @override
  Future<DataStoreAvailabilityResponse> checkDataStoreAvailability() async {
    final result = await methodChannel.invokeMethod<String>(
      MethodType.dataStoreAvailability.value,
    );

    if (result == null) {
      throw Exception("[checkDataStoreAvailability] received null result");
    }

    return DataStoreAvailabilityResponse.fromString(result);
  }

  @override
  Future<GetDataResponse> getData(GetDataRequest req) async {
    _validateDataTypes(req.dataTypes);

    Map<String, dynamic> serializedRequest = req.toMap();
    final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
      MethodType.getData.value,
      serializedRequest,
    );

    if (result == null) {
      throw Exception("[getData] received null result");
    }

    return GetDataResponse.fromMap(result);
  }

  @override
  Future<String> getPlatformVersion() async {
    final platformVersion = await methodChannel.invokeMethod<String>(
      MethodType.getPlatformVersion.value,
    );
    return platformVersion ?? "";
  }

  @override
  Future<CheckPermissionsResponse> checkPermissions(CheckPermissionsRequest req) async {
    _validateDataTypes(req.dataTypes);

    Map<String, dynamic> serializedRequest = req.toMap();
    final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
      MethodType.checkPermissions.value,
      serializedRequest
    );
    
    if (result == null) {
      throw Exception("[checkPermissions] received null response");
    }
    
    return CheckPermissionsResponse.fromMap(result);
  }

  @override
  Future<RequestPermissionsResponse> requestPermissions(RequestPermissionsRequest req) async {
    _validateDataTypes(req.dataTypes);

    Map<String, dynamic> serializedRequest = req.toMap();
    final result = await methodChannel.invokeMethod<Map<String, dynamic>>(
      MethodType.requestPermissions.value,
      serializedRequest
    );

    if (result == null) {
      throw Exception("[requestPermissions] received null response");
    }

    return RequestPermissionsResponse.fromMap(result);
  }

  bool isDataTypeSupported(HealthDataType type);

  void _validateDataTypes(List<HealthDataType> dataTypes) {
    for (final dataType in dataTypes) {
      if (!isDataTypeSupported(dataType)) {
        throw ArgumentError("HealthDataType $dataType is not supported by this provider.");
      }
    }
  }
}
