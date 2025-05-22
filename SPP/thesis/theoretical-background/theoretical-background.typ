= Theoretical background
// Demonstrate that you have a broad knowledge of the area of investigation
// Introduce, describe and explain theories to the reader
// Identify and describe relevant challenges in the area of investigation and describe related work to these challenges
// Formulate a reasearch gap and discuss, argue and motivate it as a research problem

The current landscape of health data has seen a significant transformation due to the proliferation of wearable devices. Devices such as smartwatches, smart rings and fitness trackers have advanced rapidly in recent years, now offering high-quality, clinically certified data collection capabilities @impact-wearable-technologies. This longitudinal and increasingly accurate health monitoring opens up new possibilities in health research, disease detection and personalized treatment strategies @wearable-devices-healthcare. The global wearable device market continues to grow at a substantial rate, with an estimated compound annual growth rate of 14.6% between 2023 and 2030 @wearable-sales-statistics. Leading industry actors include Alphabet Inc./Google, Apple Inc., Garmin Ltd., and Samsung Electronics Co., Ltd. @wearable-sales-statistics.

While the growth of wearable technologies presents valuable opportunities, it also introduces significant technical and interoperability challenges. Each provider typically offers its own platforms for accessing and modifying health data, with unique APIs, data models and permission systems. This fragmentation complicates efforts to aggregate data from multiple providers. For instance, Apple's HealthKit provides a generalized abstraction for measurements via types such as HKQuantityType @apple-healthkit-hkquantitytype, representing quantities like step counts. In contrast, Google Health structures similar metrics as domain-specific records such as StepRecord @google-health-step-record, including associated metadata like start and end times. These inconsistencies in data modeling extend beyond simple metrics such as step counts to more complex physiological measurements such as heart rate variability, sleep stages and stress levels. The absence of standardized approaches for normalizing and integrating such heterogenous health data represents a significant obstacle for developers and researchers building cross platform applications, particulary for those leveraging machine learning techniques.

== Existing frameworks for collecting health data

The existing frameworks for collecting health data are outlined below:

#table(
  columns: (1fr, auto, auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [], [*Framework*], [*Features*], [*Missing features*],
  ),
  /* HEALTH FLUTTER PACKAGE */
  [], [*Health 12.0.1, Flutter package*], [Enables reading and writing health data to and from Apple health and Google Health Connect.], [ - Lacks support for several providers (Fitbit, garmin etc) \ - No support for Open mHealth data format.],
  /* REACT NATIVE HEALTH */
  [], [*React Native Health, React native package*], [Package for interacting with Apple HealthKit for iOS.], [ - Lacks support for several providers (e.g., Google Health connect). \ - No support for Open mHealth.],
  /* REACT NATIVE HEALTH CONNECT */
  [], [*React native health connect, React native package*], [Package for interacting with Health Connect for Android.], [- Lacks support for several providers (e.g Apple HealthKit for iOS) \
  - No support for Open mHealth.],
  /* SHIMMER */
  [], [*Shimmer, web platform*], [Application for extracting health data from multiple providers into Open mHealth data format.], [- Is not natively supported on mobile.],
  /* TASRIF */
  [], [*Tasrif, python application*], [Application for extracting health data from multiple providers. Integrates with existing python ML libraries.], [- Is not natively supported on mobile. \ - Does not support Open mHealth.],
)

While each of these frameworks fulfills part of the requirements for multi-provider health data integration, none currently provide a complete, mobile-native, cross-platform solution that supports standardized output such as Open mHealth format.

== Health data standards

The current state of e-health data standards are outlined below:

#table(
  columns: (1fr, auto, auto, auto),
  inset: 10pt,
  align: horizon,
  table.header(
    [], [*Standard*], [*Description*], [*Reference*],
  ),
  /* FHIR */
  [], [*Fast Health Interoperability Resources - FHIR*], [Data standard for exchaning health care information digitally. Modular specification with focus on health care, with modules such as medications, diagnostics, etc.], [ @fhir ],
  /* Open mHealth */
  [], [*Open mHealth*], [Data standard for mobile health data. Provides schemas for creating a uniform data structure for health data recorded by wearable devices.], [ @openmhealth],
  /* IEEE P1752 */
  [], [*IEEE P1752 - Standard for mobile health data working group*], [Provides data standard for representing physical activity, sleep and metadata.], [@ieeep1752],
)

Efforts toward standardizing mobile health data are ongoing. Babu et al. @wearable-devices-healthcare highlight the importance of cross-organizational collaboration to enhance data quality, consistency and interoperability.

== Health data stores and API

The plugin developed in this thesis targets two major health data stores: Apple HealthKit @apple-healthkit on iOS and Google Health Connect @health-connect (formerly Google Fit) on Android. While both APIs offer similar capabilities for reading and writing data, they differ significantly in internal structure and terminology.

Access to these data stores requires explicit user permission, granted per-app and per-data-type, ensuring user privacy and control. Once permissions are granted, both platforms expose APIs for querying health data.

Google Health Connect uses specific record classes, such as Steps @health-connect-step-type or HeartRate @health-connect-heart-rate-type, each containing metadata like startTime, endTime and a value field. In contrast, Apple HealthKit uses types such as HKQuantityType @apple-healthkit-quantity-type or HKWorkoutType @apple-healthkit-workout-type. When requesting step data, for example, a HKQuantitySample @apple-healthkit-quantity-sample is returned containing the step count as an HKQuantity along with metadata like the measurement time window and data source.

== Selected software

One requirement for this framework is that it must be cross-platform and mobile-native. Several development frameworks support this, including React Native @react-native, Flutter @flutter, LynxJS @lynx-js and Kotlin Multiplatform @kotlin-multi-platform.

Flutter was selected for this project due to existing infrastructure and developer experience within the organization (Neurawave). Flutter uses the Dart programming language, with native platform functionality implemented in Swift (iOS) and Kotlin (Android). Platform-specific functionality is accessed via MethodChannels, which allow Flutter code to call native APIs directly.

No additional third-party plugins will be used beyond what is required to interface with HealthKit and Health Connect.

== Research gap and problem formulation

Despite the growing availability of health data APIs and frameworks, there is no existing mobile-native, cross-platform plugin capable of aggregating health data from multiple providers and exporting it in a standardized format such as Open mHealth. While it is theoretically possible to combine mutiple existing tools to achieve similar results, this approach is highly impractical and prone to compability issues, platform-specific limitations, and increased development complexity.

This fragmentation presents a significant barrier for developers and researchers who wish to build cross-platform health solutions or apply machine learning techniques to unified health datasets. The framework developed in this thesis aims to address this gap by offering a native, extensible solution for standardized mobile health data integration.

#bibliography("refs.yml")
