import 'package:health/health.dart';
import 'package:health_plus/schemas/mobile_health_schema/mobile_health_schema.dart';

abstract class MobileHealthSchemaConverter {
  MobileHealthSchema healthDataPointToMobileHealthSchema(
    HealthDataPoint dataPoint,
  );
}
