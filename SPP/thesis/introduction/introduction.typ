= 1 Introduction

This thesis is a 15 HEC Master's thesis in Software Engineering. It explores the domain of mobile application development, wearable health technology, and data normalization. As healthcare becomes increasingly more digital, wearable devices like smartwatches and fitness trackers are gaining traction as tools for collecting physiological and behavioral data.

The widespread adoption and acceptance of such devices offers insightful possibilities for health monitoring, especially for conditions like migraine that could benefit from health monitoring. However, as of today that landscape is flawed due to data formats and APIs beeing differently interpreted depending on the different providers, making it difficult to integrate health data across platforms or use it effectively in research and machine learning. @impact-wearable-technologies

This thesis aims to investigate this challenge and contributes by exploring how a mobile software framework solution might help unify and normalize health data from various sources. The aim is to simplify data handling for researchers and developers while also hopefully enabling more effective use of health data in fields such as machine learning. 

== 1.1 Background

As digital health technologies advance, the integration of wearable devices into everyday life has become increasingly common. The market for devices such as smartwatches, fitness trackers, and other biometric sensors is something that has seen rapid growth in recent years, with big stakeholders such as Alphabet Inc/Google, Apple inc, Garmin Ltd and Samsung Electronics Co. Ltd being some of the most prominent players.  @wearable-sales-statistics. This has in turn led to a surge in the amount of possible health data being collected which has unlocked new potential within health research, disease identification and also potential treatment. @wearable-devices-healthcare

One medical area where this type of data collection posibillities can have a high impact in is migraine detection and prevention. Migraines are complex neurological conditions often triggered by combinations of both physiological and environmental factors @migraine-triggers. The ability to monitor physiological signals and important metrics that can potentially indiciate an impending migraine attack could be a game changer. Wearable devices can provide possibilities for monitoring these signals, allowing for early detection and prevention. This would in turn lead to a road of benefits for both patients and healthcare providers, including improved quality of life, reduced healthcare costs, and more effective treatment plans.

However, while the capabilities of individual wearable devices are improving, the broader ecosystem remains limited. Each device manufacturer typically provides its own proprietary API and data format. This inconsistency makes it difficult for software developers and researchers to combine data from multiple sources, interpret it uniformly, and make something meaningful out of it.

One major challenge in this area is the lack of a unified framework for integrating wearable health data in a standardized way, especially within mobile environments. There are some existing solutions closely related to these issues but none of those provides a full solution. For example solutions such as the health package and React Native Health @health-package @react-native-health are both libraries enabling access to health data, but none of the data is normalized or standardized. This means that the data collected is not in a format that can be easily used for machine learning or other data analysis tasks. This lack of standardization poses a significant barrier to the effective use of wearable health data in both research and development.

== 1.2 Related work


#bibliography("refs.yml")