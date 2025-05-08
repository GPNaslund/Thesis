import 'hk_source.dart';

class HKSourceRevision {
  final HKSource source;
  final String? version;
  final String? productType;
  final String? operatingSystemVersion;

  const HKSourceRevision({
    required this.source,
    this.version,
    this.productType,
    this.operatingSystemVersion,
  });

  factory HKSourceRevision.fromJson(Map<String, dynamic> json) {
    return HKSourceRevision(
      source: HKSource.fromJson(json['source'] as Map<String, dynamic>),
      version: json['version'] as String?,
      productType: json['productType'] as String?,
      operatingSystemVersion: json['operatingSystemVersion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source.toJson(),
      'version': version,
      'productType': productType,
      'operatingSystemVersion': operatingSystemVersion,
    };
  }
}