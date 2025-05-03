import '../enums/datastore_availability.dart';

class DataStoreAvailabilityResponse {
  DataStoreAvailability availability;

  DataStoreAvailabilityResponse(this.availability);

  factory DataStoreAvailabilityResponse.fromString(String value) {
    DataStoreAvailability result = DataStoreAvailability.fromString(value);
    return DataStoreAvailabilityResponse(result);
  }
}