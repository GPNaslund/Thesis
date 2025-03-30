class UnitValue {
  final num value;
  final String unit;

  UnitValue({required this.value, required this.unit});

  Map<String, dynamic> toJson() {
    return {"value": value, "unit": unit};
  }
}
