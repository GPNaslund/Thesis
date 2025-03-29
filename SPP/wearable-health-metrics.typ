= Wearable health metrics to measure for migraine prediction
This table comprises the most valuable wearable health metrics to measure for migraine prediction.
#table(
  columns: (1fr, auto, auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [],[*Metric*], [*Motivation*], [*References*],
  ),
  /* Skin conductivity */
  [],
  [Skin conductivity],
  [Skin conductivity is a measure of the electrical conductivity of the skin, which can be affected by changes in skin temperature, hydration, and other factors. It has been shown to be a useful biomarker for migraine prediction, as changes in skin conductivity is highly correlated with stress and the onset of migraine],
  [@wearables-measuring-eda-assess-stress-in-care, @machine-learning-wearable-technology, @forecasting-migraine, @triggers-protectors-predictors],
  /* Heart rate */
  [],
  [Heart rate],
  [Heart rate a measurement of the amount of heartbeats per time frame and is strongly correlated with the amount of stress of an individual. It has been shown to be a valuable metric in the analysis and prediction of onset of migraine],
  [@machine-learning-wearable-technology, @forecasting-migraine-with-ml-based-on-diary-wearable, @quantifying-stress-and-relaxation, @heart-rate-variability-percieved-stress, @triggers-protectors-predictors, @forecasting-migraine],
  /* Heart rate variability */
  [],
  [Heart rate variability],
  [Heart rate variability is a measurement of the variation in time between heartbeats and is a sensitive marker of autonomic balance. It has been shown to be a valuable metric of stress and thus is useful in the analysis when predicting onset of migraine],
  [@quantifying-stress-and-relaxation, @machine-learning-wearable-technology, @triggers-protectors-predictors, @forecasting-migraine],
  /* Skin temperature */
  [],
  [Skin temperature],
  [Skin temperature is a measure of the temperature of the skin and can be affected by changes in blood flow and other factors. It has been shown to be a useful biomarker for migraine prediction, as changes in skin temperature are highly correlated with stress and the onset of migraine],
  [@detection-and-monitoring-of-stress-using-wearables, @forecasting-migraine, @triggers-protectors-predictors, @machine-learning-wearable-technology],
)

#bibliography(("topics/migraine/refs.yml", "topics/machine-learning/refs.yml"))


