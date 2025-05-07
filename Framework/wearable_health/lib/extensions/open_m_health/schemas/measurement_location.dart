enum MeasurementLocation {
  axillary("axillary"),
  finger("finger"),
  forehead("forehead"),
  oral("oral"),
  rectal("rectal"),
  temporalArtery("temporal artery"),
  toe("toe"),
  tympanic("tympanic"),
  wrist("wrist"),
  vagina("vagina");

  final String value;

  const MeasurementLocation(this.value);

  Map<String, dynamic> toJson() => {
    "measurement-location": value
  };

}