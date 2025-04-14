= 4 Research project - Implementation
// Introduce, describe and explain all activities you have realized to collect data for your study
// Describe all your designs and implementations
// For design science: Describe the design and the technique + implementation concerns + demonstration

== 4.1 Design and technique

We designed a Flutter plugin using the Dart programming language, with platform-specific implementations written in Swift for iOS and Kotlin for Android. The plugin exposes a public API that enables communication with the native health data stores. When a user invokes a method from this API, a MethodChannel is used internally to bridge the Dart code and the native platform code. The Dart layer is responsible for defining the public API, making method calls to the platform specific implementations, and performing data transformation. The native code handles permission requests and performs the actual data extraction.

The high level data flow is illustrated below:

#figure(
  image("flow-chart.jpeg", width: 80%),
  caption: [Data flow of requesting permissions and extracting health data],
)

Several standardization models exist for structuring health data, including Open mHealth, FHIR and IEEE P1752. We chose Open mHealth due to its lightweight nature, JSON-compatibility and its specific focus on mobile health data. While FHIR is a powerful and widely adopted clinical standard, it introduces significant overhead for mobile use cases, requiring modeling of patients, medications and other elements irrelevant to this project. Additionally, Open mHealth has begun incorporating elements from IEEE P1752, further reinforcing its suitability for mobile-focused applications.

This framework targets heart rate and skin temperature data. On Android, it extracts HeartRate @health-connect-heart-rate-type and SkinTemperature @health-connect-skin-temperature-type records from Google Health Connect. On iOS, it extracts HKQuantitySample objects with type heartRate @health-kit-heart-rate-type and bodyTemperature @health-kit-body-temperature-type, filtering for locations associated with skin contant measurements (e.g armpit, body, finger, toe, forehead). The extracted data is transformed into the Open mHealth Heart Rate schema @openmhealth-heart-rate-schema and a custom Skin Temperature schema modeled after the Open mHealth Body Temperature schema @openmhealth-body-temperature-schema.

== 4.2 Implementation concerns

To ensure interoperability, the plugin normalizes all extraced data into Open mHealth format regardless of the source platform or underlying API. Metadata not defined within the Open mHealth schema, such as device name or specific hardware information, is discarded to maintain consistency and reduce variability across platforms.

The plugin ensures that permission handling is performed correctly and that permission states are regularly verified, as users may revoke permissions at any time. Both HealthKit and Health Connect offer similar permission models, which posed minimal challenges during implementation.

Data granularity and sampling resolution is determined by the user via an input time window. The plugin adheres to the data limits and resolution supported by the respective health data store, returning data only within the requested time frame.

To account for situations where a health data store is not available (e.g the data store is not installed), the plugin includes logic to direct users to the respective app store to download the required app. Additionally, if a user attempts to use the plugin on an unsupported OS version, they are informed of the compatibility issue through user-facing feedback.

The plugin is designed with extensibility in mind. Its architecture allows for straightforward integration of additional data types, data providers (e.g Fitbit, Garmin) and health metrics in fututre iterations.

== 4.3 Demonstration

The plugin will be demonstrated through a dedicated test application built in Flutter. This application implements the full data flow, including permission requests and data extraction. In addition, the application includes automated tests that validate the correctness of the data transformation and adherence to the Open mHealth schema.

The test application will be evaluated using real devices including Apple Watch, Fitbit and Garmin Venu to simulate real-world usage and ensure compatibility across a range of wearables. The demonstration will showcase both real-time and historical data extraction, within the constraints of each data stores retention policy and access limitations.

The plugin will be considered succesful if it consistently provides accurate and correctly formatted Open mHealth data on both iOS and Android platforms, across a diverse set of wearable devices.

#bibliography("refs.yml")
