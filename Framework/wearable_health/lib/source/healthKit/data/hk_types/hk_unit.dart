class HKUnit {
  final String unitString;

  static const HKUnit _count = HKUnit('count');
  static const HKUnit _minute = HKUnit('min');
  static const HKUnit _degreeCelsius = HKUnit('degC');
  static const HKUnit _degreeFahrenheit = HKUnit('degF');

  static HKUnit get count => _count;
  static HKUnit get minute => _minute;
  static HKUnit get degreeCelsius => _degreeCelsius;
  static HKUnit get degreeFahrenheit => _degreeFahrenheit;

  static final HKUnit heartRateUnit = _count.divided(_minute);
  static final HKUnit bodyTemperatureCelsiusUnit = _degreeCelsius;
  static final HKUnit bodyTemperatureFahrenheitUnit = _degreeFahrenheit;

  const HKUnit(this.unitString);

  HKUnit divided(HKUnit otherUnit) {
    return HKUnit('$unitString/${otherUnit.unitString}');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is HKUnit &&
              runtimeType == other.runtimeType &&
              unitString == other.unitString;

  @override
  int get hashCode => unitString.hashCode;

  @override
  String toString() {
    return unitString;
  }
}