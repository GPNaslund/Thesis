enum DescriptiveStatistic {
  average("average"),
  count("count"),
  maximum("maximum"),
  median("median"),
  minimum("minimum"),
  standardDeviation("standard deviation"),
  sum("sum"),
  variance("variance"),
  percentile20("20th percentile"),
  percentile80("80th percentile"),
  lowerQuartile("lower quartile"),
  upperQuartile("upper quartile"),
  quartileDeviation("quartile deviation"),
  quintile1("1st quintile"),
  quintile2("2nd quintile"),
  quintile3("3rd quintile"),
  quintile4("4th quintile");

  final String value;

  const DescriptiveStatistic(this.value);

  Map<String, dynamic> toJson() => {
    "descriptive-statistic": value,
  };
}