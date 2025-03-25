import 'package:health_plus/schemas/mobile_health_schema/mobile_health_schema.dart';

abstract class OpenMHealthSchema implements MobileHealthSchema {
  @override
  String get schemaVersion => "1.0";
}
