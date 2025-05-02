import 'package:wearable_health/provider/dto/check_permissions_request.dart';
import 'package:wearable_health/provider/dto/check_permissions_response.dart';
import 'package:wearable_health/provider/dto/datastore_availability_response.dart';
import 'dto/get_data_response.dart';
import 'dto/get_data_request.dart';
import 'dto/request_permissions_request.dart';
import 'dto/request_permissions_response.dart';

abstract class Provider {
  Future<String> getPlatformVersion();
  Future<CheckPermissionsResponse> checkPermissions(CheckPermissionsRequest request);
  Future<RequestPermissionsResponse> requestPermissions(RequestPermissionsRequest request);
  Future<DataStoreAvailabilityResponse> checkDataStoreAvailability();
  Future<GetDataResponse> getData(GetDataRequest request);
}
