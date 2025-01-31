_Replace instruction (in italic style), 
You copy this document and share it openly so that everyone with the link can comment, not just within the organisation._
= Student Project Proposal (SPP)
_This document is intended to guide students to describe their SPPs for the 2dv50e course so that course management gets an idea of if it is suitable, or not. It should also guide the assignment of supervisors. This is not a contract, what you write here will most probably change._

We want to have projects that are:
#pad(left: 2em)[
  - Clearly and precisely defined, that can be understood.
  #pad(left: 2em)[
  - Written in English
  - Spellcheck and check grammar.
  - Proofread it! Read it aloud to check your language.
  - Let another human read it.
  - Practice your pitch to several people and ask them to explain your project back to you afterwards. 
  - Watch out for prepositions.
  ]
  - Projects within Computer Science
  #pad(left: 2em)[
  - Builds on previous research (Related Work) within computer science.
  - It’s research questions are interesting to the CS community
  ]
  - Realistic and manageable projects
  #pad(left: 2em)[
  - Can be done by one/two students within the timeframe of the thesis
  - Work to reduced risk of failure
  - Access to resources needed
  ]
  - Meaningful and motivated
  #pad(left: 2em)[
  - contribution to research
  - contribution to society
  - ethically motivated
  - has a target audience
  ]
  - Suitable for your program profile
  #pad(left: 2em)[
  - builds on courses you have taken
  ]
]

\
\
\
\
\
\
\
\
\
\
\
\
\


Your name(s): Gustav Näslund

LNU Supervisor:

Supervision status according to student
\ Check one of these:
\ [  ] Currently working with (Ongoing project)
\ [  ] Agreed but not started
\ [  ] Wish to work with ( or unclear of status )
\ [ X ] No preference, help me find one

Cooperative partners (Optional):
\ Company: Neurawave
\ Status: One telephone meeting and follow up e-mails.
\ Preliminary Title:
\ Designing a Crossplatform Mobile Framework for Normalizing and Integrating Wearable Health Data to Support Machine Learning Applications in Migraine Analysis.

\
== Elevator pitch:
Write this last… since its a summary of the rest. 

The proliferation of wearable health devices has created a fragmented data landscape where each platform uses different formats and APIs @impact-wearable-technologies, making it challenging for developers to create cross-platform applications that can effectively utilize this health data for several purposes. I intend to develop a mobile framework that standardizes the integration of health data from multiple wearable platforms into the Open mHealth format @open-mHealth-schemas, providing developers with a unified interface for accessing normalized wearable data suitable for their needs. The framework will be evaluated using Design Science methodology, including performance benchmarks and validation of data normalization accuracy across different platforms.

== Steps/Milestones/Actions

- Research and requirements gathering
#pad(left: 2em)[
  - Investigate wearable APIs (e.g Apple Healthkit, Fitbit API etc) and their data formats.
  - Study existing frameworks for data normalization and integration.
  - Define the functional and technical requirements for framework/app.
  - Identify key migraine-related data points to prioritize.
]
- Design the framework/app architecture
#pad(left: 2em)[

- Plan the overall architecture, including:
#pad(left: 2em)[
- Front end (client side API for collection)
- Back end (data processing)
- Data pipeline (normalization and integration)
]
- Define the data schema for the unified data model.
]
- Develop the data collection mechanism 
#pad(left: 2em)[
- Implement authentication to access wearable APIs.
- Build functionality to fetch data from at least one wearable device.
- Store raw data temporarily in the app or a local database.
]
- Implement data normalization and integration
#pad(left: 2em)[
- Develop a pipeline to normalize raw data
- Handle missing or inconsistent data
- Integrate data from multiple wearable devices into a unified format.
- Ensure the data is structured for machine learning
]
- Test and validate the framework/app
#pad(left: 2em)[
- Test end-to-end functionality with sample data from wearable devices.
- Validate the quality of the normalized and integrated data.
- Ensure the data is machine learning ready.
]
- Optional milestone
#pad(left: 2em)[
- Add support for additional wearable devices
- Demonstrate how processed data could be used for machine learning, e.g by generating a sample dataset with features and labels.
]

== Risks
- Lack of access to wearable data.
#pad(left: 2em)[
It might be challenging to access real world data from wearable devices due to API limitations (e.g restricted access, rate limit), privacy concerns and regulatory hurdles or difficulty recruiting users to share their wearable data. Can be mitigated by using publicly available datasets for prototyping. Synthetic datasets are also an alternative for mimicking real world data.
]
- Complexity of data normalization and integration
#pad(left: 2em)[
Due to the fact that wearable devices generate data in different formats, schemas, sampling rates which can make normalization and integration complex and time consuming. Can be mitigated by starting with one wearable device to simplify the initial implementation. The usage of existing libraries and tools can also aid in handling common normalization tasks.
]
- Data quality issue.
#pad(left: 2em)[
Incomplete, inconsistent or noisy data can affect the quality of the final dataset. Can be mitigated by implementing data validation checks (e.g range checks for heart rate). Missing data can be handled through removal or by using an average value.
]
- Privacy and regulatory compliance
#pad(left: 2em)[
Handling sensitive data requires compliance with strict privacy regulations (e.g GDPR) which can be complex and time consuming. Can be mitigated by usage of anonymized or synthetic data. Ensuring secure data transfer protocols as well as user consent might have to be obtained before collecting data.
]
- Time management and scope creep.
#pad(left: 2em)[
Since the project contains multiple components (data collection, normalization, integration, app development) there is a risk of scope creep or delays. Can be mitigated through definition of clear milestones and set deadlines for each milestone. Prioritizing core functionality can also ensure that the projects can get finished, as well as using an agile development practice. 
]
- Limited expertise in wearable APIs or data pipelines.
#pad(left: 2em)[
Unfamiliarity with wearable APIs or data pipeline development might have a steep learning curve. Can be mitigated through allocation of time for learning and experimentation with wearable APIs, as well as time allocation for thorough reading of documentation.
]
- Difficulty demonstrating machine learning readiness
#pad(left: 2em)[
There might be challenges associated with demonstrating machine learning readiness. Can be mitigated by the creation of a clear definition of what “machine learning-ready” means for this project.
]

== Background and Motivations 

The current state of health data holds substantial promise due to wearable devices. Wearable devices such as smart watches, smart rings and smart bracelets has evolved in the recent years and are able to give more accurate high quality data, earning an increased amount of clincally approved certifications @impact-wearable-technologies. This high quality longitudinal health monitoring provides new possibilities within health research, disease identification and treatment @wearable-devices-healthcare. The usage and market of wearable devices has grown significantly, with an expected compound annual growth rate of 14.6% from 2023 to 2030 @wearable-sales-statistics. Some of the most prominent actors within the wearable device market is Alphabet Inc/Google, Apple Inc, Garmin Ltd and Samsung Electronics Co., Ltd @wearable-sales-statistics.

While the growth of wearable devices brings unprecedented opportunities for health monitoring, it also introduces significant challenges. The different providers provide their own platforms for accessing and modifying data, with their own API's and restrictions, which poses a challenge for anyone who wants to aggregate data from multiple providers. The data itself differs also in structure, even if the same variable is being measured. Apple provides through its HealthKit a more general abstraction of a measurement such as HKQuantityType @apple-healthkit-hkquantitytype which represents a "quantity of something" such as stepCount, while Google Health represents the same variable in a more object oriented fashion with associated details included such as start and stop time for a step metric @google-health-step-record. These differences in data representation extend beyond simple metrics such as step counts to more complex physiological measurements such as heart rate variability, sleep stages and stress levels. The lack of standardized approaches for normalizing and integrating this heterogenous health data creates a significant barrier for developers and researchers trying to build cross platform health applications, particulary for those leveraging machine learning techniques.

Migraine is an episodic and complex sensory processing disturbance with a collection of different neurological symptoms where headache is the most common and primary symptom. Migraine is the most common cause of disability among young women, and the second most common cause of disability globally overall @migraine-review. Migraine can be classified both with or without the presense of aura, and also if the migraine is chronic or episodic @migraine-genetics-pathophysiology-diagnosis. The economic burden of migraine for society is profound, in the USA there has been estimated that direct costs associated with migraine is more than 17 billion USD @migraine-genetics-pathophysiology-diagnosis.

There have been several potential triggers of migraine identified, such as stress, hormonal changes, hunger, sleep disturbance, etc @migraine-triggers. Many of these triggers are associated to lifestyle factors and are essential to manage in the preventive treatment @state-of-migraine. Identification of these triggers is mainly up to the patient itself, and relies on the observations and recollection of the patient. This self reporting might suffer from flaws of subjectivity and faulty perceptions as indicated by Casanova et al @self-reported-triggers where "even the most commonly endorsed triggers were statistically associated with in fewer than one third of individuals suspecting each trigger". The need for more objective measurements with a more detailed analysis is a glaring.

In terms of migraine, there is a possibility that the data obtained from wearable devices could provide invaluable insight into triggers both on an individual and societal level. The current digital treatment aids for headache mainly revolves around headache calendars, instructions for relaxation and endurance sports, chatbots aswell as providing structured data for the treating medical team of a patient @digitalization-headache. The analysis of the captured data could be handled through machine learning to enable the processing of large amounts of data and for a greater chance of discovering new patterns and insights of the data. There have been several studies examining the use of machine learning in the process of diagnosing and classifying migraines @migraine-classification-ml, @migraine-detection-ml, @migraine-classification-ml-data-augmention, as an aid when prescribing medicine @migraine-machine-learning-medications and for predicting migraine episodes with the data from wearable devices in combination with a digital headache diary @machine-learning-forecasting.


There are multiple health platforms such as Apple Health @apple-health, Google Health @google-health and Samsung Health @samsung-health. They are all closely integrated with their respective companies products, but can also be used to collect data with compatible third-party devices. The closest thing available as to a uniform platform that combines the data of different health platforms is Shimmer @shimmer, which is "the first and only open-source health data aggregator". Shimmer allows for fetching data from multiple different health platforms in an Open mHealth compliant format. This uniformity of the data structure is important because semantics of complex health data makes a huge difference, such as if blood glucose is measured fasting or non fasting @open-mHealth-schemas. Shimmer @shimmer is built in Java and is composed of several different components: individual shims, a resource server and a console @shimmer-github. A shim is defined as "an adapter between an Open mHealth API and the API of a third-party data provider" @shim. This server architecture allows for a uniform API for the user that is extracting data, and Shimmer handles many of the pitfalls such as authentication. While Shimmer provides invaluable service for data integration, its server-based architecture presents challenges for mobile application development. Modern health applications often require real-time data access, offline functionality and direct integration with platform specific SDKs. The need for a server intermediary can introduce latency, connectivity dependencies and additional complexity in mobile applications. 

Health data can be categorized as structured and unstructured. Unstructured data is data that does not follow a standardized structure and could encompass a clients own description of how they are feeling. Structured data follows a standardized structure and has both a clear structure and meaning behind it. When training machine learning models with health related data, it is generally considered to be easier to do with structured data @challenges-opportunities-beyond-structured-data compared to with unstructured data. For clarity there has been shown that unstructured data can contain very valuable information and if handled correctly in accordance with structured data, the combination can potentially provide additional benefits @combining-structured-and-unstrctured-data. Due to the fact that Open mHealth provides this structured format for health measurements performed by wearable devices, that can be considered to be a good preparation of the data for machine learning aswell.

The knowledge gap lies in the combination of the gathering of the relevant health data through wearable devices, the utilization of the data for predicting migraines and the standardization of the data to a common format that could be used for machine learning as a part of the solution. The application of all of these components into a cross platform mobile framework does not exist to date. The framework is important due to the potential of enabling better health for those suffering of migraine, and aswell for the potential societal impact of alleviating resources that otherwise would be consumed by migraine patients.

The target group for this thesis is health informatics developers, mobile developers and machine learning & artifical intelligence researches in health care.

_The closest solutions_
#table(
  columns: (1fr, auto, auto),
  inset: 5pt,
  align: horizon,
  table.header(
    [*Name*], [*Features*], [*Missing features*]
  ),
  [health 12.0.1], [Enables reading and writing health \ data to and from Apple Health and \ Google Health Connect.], [Single provider, non standardization],
  [React Native Health], [Package to interact with Apple HealthKit \ for iOS.], [Single provider, non standardization],
  [React Native Health Connect], [Package to interact with Health Connect \ for Android], [Single provider, non standardization],
  [Shimmer], [Facade for multiple providers to extract \ normalized data.], [Non mobile multiplatform]
)

Application areas: Healthcare analytics, digital health platforms, machine learning for healthcare.
Research area: Data integration and interoperability
\


== Related work

This work positions itself in the area of Data integration and interoperability, specifically focusing on frameworks for normalizing heterogenous health data from wearable devices.

There was an article published in 2022 in IEEE International Conference on Pervasive Computing and Communications Workshops and other Affiliated Events about a web based framework called WearMerge with a similar scope as this thesis. The framework processes input from wearables performs several steps towards converting the input data to Open mHealth schemas. This is close to the data aggregation and handling that i intend to implement, with the major difference of my framework being a mobile crossplatform framework. The authors conclusions was centered around the challenges of data transformation due to deprecation on behalf of Open mHealth, and the authors urges researchers to contribute to this open source standard @wear-merge.

Another example of a wearable data preprocessing framework is Tasrif @tasrif. Tasrif is a python framework with the purpose of fascilitating the processing of wearable data. The framework has the ability to preprocess large datasets aswell as data from commerical third party device data from for example Apple Health. Tasrif provides functionality to integrate the processed data directly into popular machine learning frameworks. The authors concludes that the propsed system removes the barrier of entry for clinical researchers and practitioners @tasrif. Similarly to WearMerge @wear-merge, Tasrif is not designed to be directly integrated into a multi platform mobile application but still provides many of the similar functions as the framework i plan on implementing.

No more articles describing a framework of similar functionality was found, so the research area seems to be quite novel. Both frameworks were presented in the same computer science conference paper published 2022 which leads to the conclusion that its a research area that is active and newly emerging.


== Knowledge Gap/Challenge/Problem

There is a challenge present for mobile developers to be able to collect data obtained from wearable devices from different third party providers in a standardized way within the application itself. This framework will produce a solution to the gap between singular vendor mobile frameworks and the multi vendor data processing applications that is not available as cross platform mobile frameworks. No reference was found describing this specific challenge, but more general issue with uniform collection and processing of the collected data has been described @big-data-in-healthcare.

== Knowledge Contribution/Action
This thesis aims to develop a mobile framework that standardizes the integration and normalization of health data from multiple wearable platforms (Apple HealthKit, Google Heatlh, etc.) into the Open mHealth format, which provides the ability to easier use the data in machine learning. The framework will provide developers with a unified interface for accessing normalized wearable data across platforms while handling the complexity of different data formats and sampling rates. 

The contribution described as a set of research questions:
- How can wearable health data from different platforms be effectively normalized into a unified format suitable for machine learning applications?
- What are the key requirements and challenges in implementing real-time data normalization for wearable health data in a mobile environment?
- How effective is the Open mHealth schema as a standardized format for representing diverse wearable health data in machine learning applications?


== Empirical Evidence/Evaluation
This thesis will follow the Design Science Research methodology as outlined by Peffers et al. @design-science-research-methodology, which is suitable for developing and evaluating IT artifacts. The research will follow DSR's key phases:
1) Problem identification
- Literature review of current health data integration challenges
- Analysis of existing solutions and their limitations

2) Define objectives
- Established requirements for cross-platform data normalization
- Define success criteria for the framework

3) Design & development
- Iterative development of the framework
- Implementation of data normalization components
- Integration with health platforms

4) Demonstration
- Development of a proof of concept application

5) Evaluation
- Technical performance assessment
- Validation of data normalization accuracy
- Testing with multiple data sources

Supporting methods will consist of:
1) Literature review
- To identify current challenges and solutions
- To establish state-of-the-art in health data integration for mobile applications

2) Controlled experimentation
- To measure framework performance
- To validate data normalization accuracy

#let references = ("general-healthcare-data-refs.yml", "migraine-references.yml", "wearable-references.yml", "machine-learning-refs.yml", "current-technical-state-refs.yml", "related-work-refs.yml", "empirical-evidence-refs.yml")
#bibliography(references, title: "References", style: "ieee")
