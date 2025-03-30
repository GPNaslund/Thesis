import 'package:health/health.dart';
import 'package:health_plus/provider/health_provider.dart';
import 'package:health_plus/schemas/mobile_health_schema/mobile_health_schema.dart';
import 'package:health_plus/services/mobile_health_schema_converter.dart';

class GoogleHealthConnect implements HealthProvider {
  late final Health health;
  var isInitialized = false;
  var types = <HealthDataType>[];
  late final MobileHealthSchemaConverter schemaConverter;

  GoogleHealthConnect(this.types, this.schemaConverter) {
    health = Health();
  }

  Future<void> initialize() async {
    await health.configure();
    isInitialized = true;
  }

  @override
  Future<bool?> checkPermissions() async {
    _validateInitializedState();
    return health.hasPermissions(types);
  }

  @override
  Future<bool> requestPermissions() async {
    _validateInitializedState();
    bool requested = await health.requestAuthorization(types);
    return requested;
  }

  void _validateInitializedState() {
    if (!isInitialized) {
      throw Exception("Class must be initialized before use");
    }
  }

  @override
  Future<List<HealthDataPoint>> getData() {
    var now = DateTime.now();
    return health.getHealthDataFromTypes(
      types: types,
      startTime: now.subtract(Duration(days: 1)),
      endTime: now,
    );
  }

  @override
  Future<List<MobileHealthSchema>> getDataInMobileHealthSchemaFormat() async {
    var now = DateTime.now();
    var dataPoints = await health.getHealthDataFromTypes(
      types: types,
      startTime: now.subtract(Duration(days: 1)),
      endTime: now,
    );
    List<MobileHealthSchema> result = [];
    for (final dataPoint in dataPoints) {
      var mobileHealthSchema = schemaConverter
          .healthDataPointToMobileHealthSchema(dataPoint);
      result.add(mobileHealthSchema);
    }
    return result;
  }
}
