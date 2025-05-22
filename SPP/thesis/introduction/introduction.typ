= 1 Introduction

This thesis is a 15 HEC Master's thesis in Software Engineering. It explores the domain of mobile application development, wearable health technology, and data normalization. As healthcare becomes increasingly more digital, wearable devices like smartwatches and fitness trackers are gaining traction as tools for collecting physiological and behavioral data.

The widespread adoption and acceptance of such devices offers insightful possibilities for health monitoring, especially for conditions like migraine. However, as of today that landscape is flawed due to data formats and APIs being differently interpreted depending on the different providers, making it difficult to integrate health data across platforms or use it effectively in research and machine learning. @impact-wearable-technologies

This thesis aims to investigate this challenge and contributes by exploring how a mobile software framework solution might help unify and normalize health data from various sources. The aim is to simplify data handling for researchers and developers while also hopefully enabling more effective use of health data in fields such as machine learning. 

== 1.1 Background

As digital health technologies advance, the integration of wearable devices into everyday life has become increasingly common. The market for devices such as smartwatches, fitness trackers, and other biometric sensors is something that has seen rapid growth in recent years, with big stakeholders such as Alphabet Inc/Google, Apple inc, Garmin Ltd and Samsung Electronics Co. Ltd being some of the most prominent players.  @wearable-sales-statistics. This has in turn led to a surge in the amount of possible health data being collected which has unlocked new potential within health research, disease identification and also potential treatment. @wearable-devices-healthcare

One medical area where this type of data collection posibillities can have a high impact in is migraine detection and prevention. Migraines are complex neurological conditions often triggered by combinations of both physiological and environmental factors @migraine-triggers. The ability to monitor physiological signals and important metrics that can potentially indicate an impending migraine attack could provide significant value. Wearable devices can provide possibilities for monitoring these signals, allowing for early detection and prevention. [REFERENS] This would in turn lead to a road of benefits for both patients and healthcare providers, including improved quality of life, reduced healthcare costs, and more effective treatment plans. [REFERENS]?

However, while the capabilities of individual wearable devices are improving, the broader ecosystem remains limited. Each device manufacturer typically provides its own proprietary API and data format. This inconsistency makes it difficult for software developers and researchers to combine data from multiple sources, interpret it uniformly, and without great effort make something meaningful out of it.

One major challenge in this area is the lack of a unified framework for integrating wearable health data in a standardized way, especially within mobile environments. There are some existing solutions closely related to these issues but none of those provides a full solution. For example solutions such as the health package and React Native Health @health-package @react-native-health are both libraries enabling access to health data, but none of the data is normalized or standardized. This means that the data collected is not in a format that can be easily used for machine learning or other data analysis tasks, where it is preferred to have structured data @structured-data. This lack of standardization poses a significant barrier to the effective use of wearable health data in both research and development.

== 1.2 Related work

In recent years, as the market for wearable devices has grown, so has the amount of research and development in this area. The current approaches to wearable data integration similar to what is proposed in this thesis can be divided into three categories: web-based solutions, data processing frameworks and data extracting solutions. One notable example is WearMerge @wear-merge, which was presented at IEEE International Conference on Pervasive Computing and Communications Workshops in 2022. WearMerge is a web-based approach which converts wearable data into Open Mhealth schemas. This solution offers similar data aggregation capabilities to our work but lacks the ability and support for mobile usage, which is highly relevant for potential wearable health monitoring.

Along similar research and works there is also Tasrif @tasrif. Tasrif is a Python based preprocessing framework for wearable data. It is designed to effectively handle and process data from widely used platforms such as Apple Health. More than just targeting bigger platforms, it also directly supports integration with machine learning libraries and focuses on offline data processing. Tasrif is a promising solution for data preprocessing purposes but just like WearMerge, it is not designed for mobile integration. 

In addition to web and data processing frameworks, there are also several libraries for extracting data from wearable devices which is closely related to the work in this thesis. The solutions that exist are platform specific and are designed to work for their respective platforms. Some examples for these solutions are the health package, @health-package, React Native Health @react-native-health and React Native Health Connect @react-native-health-connect. More than these libraries being designed to work with specific platforms, they also lack the ability to normalize and standardize the data.

== 1.3 Problem formulation

While wearable devices have become increasingly capable of capturing health related metrics, there is still room for growth and gaps that can be filled. This is primarily due to the fragmented landscape of health data platforms, where most providers offers its own proprietary data format and API. As discussed in the previous sections, although some server based frameworks like Shimmer support multi-provider integration, they are not designed for mobile environments or real time use.

Existing solutions like WearMerge and Tasrif focus on data aggregation and preprocessing but either lack mobile compatibility or do not address data normalization. Furthermore, platform specific libraries such as React Native Health and Health Connect provide access to raw data but without standardization. This leaves a significant technical gap, which can be summarized as the lack of a unified, mobile based framework capable of collecting and normalizing wearable health data from multiple providers. This gap between single platform solutions and server based frameworks has been identified as a significant barrier in the context of big data healthcare solutions. @big-data-in-healthcare.

To explore this gap, the thesis is structured by the following research questions:

1. How can wearable health data from different platforms be effectively normalized into a unified format suitable for migraine-focused machine learning applications?
2. What are the key requirements and challenges in implementing real-time data normalization for migraine-relevant wearable data in a mobile environment?
3. How effective is the Open mHealth schema as a standardized format for representing migraine-relevant physiological data from diverse wearable devices?

== 1.4 Motivation 

From a scientific perspective, by unifying heterogeneous data from wearable devices into a common format, the thesis contributes to ongoing research in health data integration and machine learning. The findings could potentially support and enable effective data analysis and machine learning applications in the different fields of health research. By proposing a mobile based approach that supports real time data collection and normalization, the thesis aims to address the limitations of existing solutions and provide a more practical framework that can be used for more efficient research. 

Additionally from a societal perspective, by enabling and effectively using wearable health data, wearables can be used to improve health monitoring and also be a tool for early detection and prevention of possible health issues. One of the areas that the thesis aims to focus on is migraine, which is a condition that can possibly be predicted and prevented due to the fact that migraine can be triggered by physiological and environmental factors @migraine-triggers. By enabling these insights through wearable devices, the project can potentially support better health outcomes and quality of life for individuals suffering from migraines or any other predictable health conditions.

Furthermore, from an industry standpoint, the proposed framework provides a robust and reusable solution for developers and potential healthtech companies by building a framework which has built in support for multiplatform integration along with data normalization. This greatly contributes to effective development in the field of health data management and machine learning. The framework can be used as a foundation for future applications, enabling developers to focus on building their solutions rather than dealing with the complexities of data integration and normalization. 

== 1.5 Results

== 1.6 Scope/Limitation

== 1.7 Target group

The primary target group are software developers and researchers working within the field of digital health, particularly those focusing on mobile application developments and wearable data integration. A challenge these stakeholders potentially face is working around the fragmented health data formats when developing solutions or preparing datasets for machine learning solutions.

Furthermore the framework can also be of interest for healthcare focused research teams aiming to collect and analyze physiological datapoints for conditions like migraine. By offering easier ways to access and normalize data across different platforms, the framework can support both development solutions but also research studies. 

== 1.8 Outline


#bibliography("refs.yml")