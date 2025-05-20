import 'package:wearable_health/extensions/open_m_health/health_kit/health-kit_heart_rate.dart';
import 'package:wearable_health/service/health_kit/data_factory_interface.dart';

bool isValidHKHeartRateConversion(
 Map<String, dynamic> rawData,
HKDataFactory hkDataFactory,
) {
  var isValid = true;
  var obj = hkDataFactory.createHeartRate(rawData);
  var openMHealth = obj.toOpenMHealthHeartRate();

  // Raw values
  var rawStartDate = DateTime
}