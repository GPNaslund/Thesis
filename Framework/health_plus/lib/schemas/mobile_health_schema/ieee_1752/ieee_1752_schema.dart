import 'package:health_plus/schemas/mobile_health_schema/mobile_health_schema.dart';

abstract class Ieee1752Schema implements MobileHealthSchema {
  @override
  String get schemaVersion => "1.0";
}
