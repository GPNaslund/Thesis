import 'package:health/health.dart';
import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/physical_activity.dart';
import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/time_frame.dart';
import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/time_interval.dart';
import 'package:health_plus/schemas/mobile_health_schema/ieee_1752/unit_value.dart';
import 'package:health_plus/schemas/mobile_health_schema/mobile_health_schema.dart';
import 'package:health_plus/schemas/mobile_health_schema/open_m_health_schema/heart_rate.dart';
import 'package:health_plus/services/mobile_health_schema_converter.dart';

class DefaultMobileHealthSchemaConverter
    implements MobileHealthSchemaConverter {
  @override
  MobileHealthSchema healthDataPointToMobileHealthSchema(
    HealthDataPoint dataPoint,
  ) {
    HealthDataType dataType = dataPoint.type;
    if (dataType == HealthDataType.STEPS) {
      return _convertSteps(dataPoint);
    } else if (dataType == HealthDataType.HEART_RATE) {
      return _convertHeartRate(dataPoint);
    } else {
      throw ArgumentError("Invalid or unimplemented datapoint type");
    }
  }

  MobileHealthSchema _convertSteps(HealthDataPoint stepsData) {
    TimeInterval timeInterval = TimeInterval.startAndEnd(
      stepsData.dateFrom,
      stepsData.dateTo,
    );
    TimeFrame timeFrame = TimeFrame(timeInterval: timeInterval);
    NumericHealthValue healthVal = stepsData.value as NumericHealthValue;
    num steps = healthVal.numericValue;

    return PhysicalActivity(
      activityName: "steps",
      effectiveTimeFrame: timeFrame,
      baseMovementQuantity: UnitValue(value: steps, unit: "steps"),
    );
  }

  MobileHealthSchema _convertHeartRate(HealthDataPoint hrData) {
    TimeInterval timeInterval = TimeInterval.startAndEnd(
      hrData.dateFrom,
      hrData.dateTo,
    );
    TimeFrame timeFrame = TimeFrame(timeInterval: timeInterval);
    NumericHealthValue healthValue = hrData.value as NumericHealthValue;
    num heartRate = healthValue.numericValue;
    return HeartRate(
      heartRate: UnitValue(value: heartRate, unit: "heart_rate"),
      effectiveTimeFrame: timeFrame,
    );
  }

  MobileHealthSchema _convertRrInterval(HealthDataPoint rrIntervalData) {

}
