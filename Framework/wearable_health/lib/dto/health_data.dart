abstract class HealthData<T> {
  T get healthMetric;
  Map<String, dynamic> toJson();
}
