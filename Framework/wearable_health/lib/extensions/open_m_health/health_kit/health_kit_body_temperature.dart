import 'dart:developer';

import 'package:wearable_health/extensions/open_m_health/schemas/body_temperature.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/descriptive_statistic.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/temperature_unit.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/ieee_1752/temperature_unit_value.dart';
import 'package:wearable_health/extensions/open_m_health/schemas/measurement_location.dart';
import 'package:wearable_health/model/health_kit/hk_body_temperature.dart';

import '../schemas/ieee_1752/time_frame.dart';

/// Extension to convert [HKBodyTemperature] data to OpenMHealth body temperature schema format.
extension OpenMHealthBodyTemperatureConverter on HKBodyTemperature {
  /// Converts this [HKBodyTemperature] instance to a list of [OpenMHealthBodyTemperature] objects.
  ///
  /// Returns a list containing a single [OpenMHealthBodyTemperature] object.
  /// The list format allows for consistency with other converters that may
  /// return multiple schema objects.
  List<OpenMHealthBodyTemperature> toOpenMHealthBodyTemperature() {
    List<OpenMHealthBodyTemperature> result = [];
    MeasurementLocation? measurementLocationValue;

    if (data.metadata != null) {
      if (data.metadata!.containsKey(
        "HKMetadataKeyBodyTemperatureSensorLocation",
      )) {
        var tempLocation =
            data.metadata!["HKMetadataKeyBodyTemperatureSensorLocation"];
        if (tempLocation is num) {
          switch (tempLocation) {
            case 0:
              measurementLocationValue = null;
            case 1:
              measurementLocationValue = MeasurementLocation.axillary;
            case 2:
              measurementLocationValue = null;
            case 3:
              measurementLocationValue = MeasurementLocation.tympanic;
            case 4:
              measurementLocationValue = MeasurementLocation.finger;
            case 5:
              measurementLocationValue = null;
            case 6:
              measurementLocationValue = MeasurementLocation.oral;
            case 7:
              measurementLocationValue = MeasurementLocation.rectal;
            case 8:
              measurementLocationValue = MeasurementLocation.toe;
            case 9:
              measurementLocationValue = MeasurementLocation.tympanic;
            case 10:
              measurementLocationValue = MeasurementLocation.temporalArtery;
            case 11:
              measurementLocationValue = MeasurementLocation.forehead;
            default:
              measurementLocationValue = null;
          }
        }
        log(
          "Expected value of HKMetadataKeyBodyTemperatureSensor to be a number",
        );
      }
    }

    var tempUnit = TemperatureUnit.C;
    var unitValue = TemperatureUnitValue(
      value: data.quantity.doubleValue,
      unit: tempUnit,
    );
    var timeFrame = TimeFrame(dateTime: data.startDate);
    var descriptiveStatistic = DescriptiveStatistic.count;
    result.add(
      OpenMHealthBodyTemperature(
        bodyTemperature: unitValue,
        effectiveTimeFrame: timeFrame,
        descriptiveStatistic: descriptiveStatistic,
        measurementLocation: measurementLocationValue,
      ),
    );
    return result;
  }
}
