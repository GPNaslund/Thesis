/// Represents statistical measures defined by the IEEE 1752 mHealth standard.
///
/// These descriptive statistics can be used to characterize health measurement data
/// when converting to standardized formats.
enum DescriptiveStatistic {
  /// The mean value of a set of measurements.
  average("average"),

  /// The number of measurements in a set.
  count("count"),

  /// The highest value in a set of measurements.
  maximum("maximum"),

  /// The middle value that separates the higher half from the lower half of a data set.
  median("median"),

  /// The lowest value in a set of measurements.
  minimum("minimum"),

  /// A measure of the amount of variation or dispersion of a set of values.
  standardDeviation("standard deviation"),

  /// The total of all values in a set of measurements.
  sum("sum"),

  /// The average of the squared differences from the mean.
  variance("variance"),

  /// The value below which 20% of observations may be found.
  percentile20("20th percentile"),

  /// The value below which 80% of observations may be found.
  percentile80("80th percentile"),

  /// The first quartile (Q1), or 25th percentile.
  lowerQuartile("lower quartile"),

  /// The third quartile (Q3), or 75th percentile.
  upperQuartile("upper quartile"),

  /// Half the difference between the upper and lower quartiles (Q3-Q1)/2.
  quartileDeviation("quartile deviation"),

  /// The 20th percentile.
  quintile1("1st quintile"),

  /// The 40th percentile.
  quintile2("2nd quintile"),

  /// The 60th percentile.
  quintile3("3rd quintile"),

  /// The 80th percentile.
  quintile4("4th quintile");

  /// The string representation of the statistic as defined by IEEE 1752.
  final String value;

  /// Creates a new descriptive statistic with the specified string representation.
  const DescriptiveStatistic(this.value);

  /// Converts this descriptive statistic to its JSON representation.
  ///
  /// Returns a map with the key "descriptive-statistic" and the value as the
  /// string representation of this statistic.
  Map<String, dynamic> toJson() => {"descriptive-statistic": value};
}
