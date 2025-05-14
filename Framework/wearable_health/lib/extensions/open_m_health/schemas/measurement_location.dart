/// Represents anatomical locations for temperature measurements as defined by OpenMHealth.
///
/// These measurement locations conform to standardized body temperature measurement
/// sites used in clinical and consumer health contexts.
enum MeasurementLocation {
  /// The armpit region.
  axillary("axillary"),

  /// A digit on the hand.
  finger("finger"),

  /// The front part of the head.
  forehead("forehead"),

  /// Inside the mouth, typically under the tongue.
  oral("oral"),

  /// Inside the rectum.
  rectal("rectal"),

  /// The temporal artery, located on the side of the head.
  temporalArtery("temporal artery"),

  /// A digit on the foot.
  toe("toe"),

  /// The ear canal, near the eardrum.
  tympanic("tympanic"),

  /// The area where the hand meets the arm.
  wrist("wrist"),

  /// Inside the vagina.
  vagina("vagina");

  /// The string representation of the measurement location as defined by OpenMHealth.
  final String value;

  /// Creates a new measurement location with the specified string representation.
  const MeasurementLocation(this.value);

  /// Converts this measurement location to its JSON representation.
  ///
  /// Returns a map with the key "measurement-location" and the value as the
  /// string representation of this location.
  Map<String, dynamic> toJson() => {"measurement-location": value};
}
