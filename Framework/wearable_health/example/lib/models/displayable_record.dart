/// A data model class designed to hold various representations of a single health data record
/// for display or debugging purposes.
///
/// This class aggregates:
///  - The original raw data (typically a map).
///  - A "converted" version of the raw data (which might be an intermediate structured object, also as a map).
///  - A list of OpenMHealth (OMH) compliant data representations derived from the record.
///  - An index indicating the record's position within a larger dataset.
///
/// It's useful for scenarios where you need to inspect or compare different stages
/// of data transformation for a single logical health record.
class DisplayableRecord {
  /// The original, unprocessed data for the record, typically sourced directly
  /// from a health data platform (e.g., Health Connect, HealthKit) as a map.
  /// Keys are usually strings, and values can be of various dynamic types.
  final Map<String, dynamic> rawData;

  /// A structured or "converted" representation of the [rawData]. This could be,
  /// for example, the output of a platform-specific data factory (like
  /// [HCDataFactory] or [HKDataFactory]) before it's transformed into an
  /// OpenMHealth schema. It's also stored as a map for easy inspection.
  final Map<String, dynamic> convertedData;

  /// A list containing one or more OpenMHealth (OMH) compliant data objects,
  /// represented as maps. A single raw record might translate to multiple
  /// OMH data points if it spans a duration or contains multiple observations.
  final List<Map<String, dynamic>> omhDataList;

  /// The original index of this record within a larger list or sequence from which
  /// it was processed. This helps in correlating the displayable record back to its
  /// source position, especially useful in lists or when debugging specific entries.
  final int recordIndex;

  /// Creates an instance of [DisplayableRecord].
  ///
  /// All parameters are required to fully populate the displayable record's state.
  ///
  /// Parameters:
  ///  - [rawData]: The original raw data map.
  ///  - [convertedData]: The intermediate converted data map.
  ///  - [omhDataList]: The list of OpenMHealth data maps.
  ///  - [recordIndex]: The original index of this record.
  DisplayableRecord({
    required this.rawData,
    required this.convertedData,
    required this.omhDataList,
    required this.recordIndex,
  });
}