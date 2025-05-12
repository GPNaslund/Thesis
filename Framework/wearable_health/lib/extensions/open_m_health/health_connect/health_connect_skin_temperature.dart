import 'package:wearable_health/extensions/open_m_health/schemas/body_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/descriptive_statistic.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/temperature_unit_value.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/time_frame.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/measurement_location.dart';
import 'package:wearable_health/model/health_connect/hc_entities/skin_temperature.dart';

import '../schemas/ieee_1752/temperature_unit.dart';

extension OpenMHealthBodyTemperatureConverter on HealthConnectSkinTemperature {
  List<OpenMHealthBodyTemperature> toOpenMHealthBodyTemperature() {
    List<OpenMHealthBodyTemperature> result = [];
    var baseTemp = baseline;
    num? previousTemp;
    MeasurementLocation? measurementLocationValue;
    switch (measurementLocation) {
      case 1:
        measurementLocationValue = MeasurementLocation.finger;
      case 2:
        measurementLocationValue = MeasurementLocation.toe;
      case 0:
        measurementLocationValue = null;
      case 3:
        measurementLocationValue = MeasurementLocation.wrist;
      default:
        measurementLocationValue = null;
    }

    for (final element in deltas) {
      var finalTemp = 0.0;
      if (baseTemp != null) {
        finalTemp = baseTemp.inCelsius + element.delta.inCelsius;
      } else if (previousTemp != null) {
        finalTemp = previousTemp + element.delta.inCelsius;
      } else {
        finalTemp = element.delta.inCelsius;
        previousTemp = element.delta.inCelsius;
      }

      var tempUnit = TemperatureUnit.C;
      var unitValue = TemperatureUnitValue(value: finalTemp, unit: tempUnit);
      var timeFrame = TimeFrame(dateTime: element.time);
      var descriptiveStatistic = DescriptiveStatistic.count;
      result.add(
        OpenMHealthBodyTemperature(
          bodyTemperature: unitValue,
          effectiveTimeFrame: timeFrame,
          descriptiveStatistic: descriptiveStatistic,
          measurementLocation: measurementLocationValue,
        ),
      );
    }
    return result;
  }
}
