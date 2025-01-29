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
\ Designing a Framework for Normalizing and Integrating Wearable Health Data to Support Machine Learning Applications in Migraine Analysis.

\
== Elevator pitch:
Write this last… since its a summary of the rest. 

_Describe with one or two sentences the background, how the world is today, try to find support with at least one reference. Describe what is the challenge in this background. Describe what the project is intending to do about it. Describe how the effort is going to be evaluated._


- Background (this may be both application and research area )
- Challenge ( describe why the background is problematic or needs to change), here we prefer research area since it makes it easier to motivate your work.
- Action: What you intend to do about it.
- Evaluation: How you intend to evaluate what you intend to do about it (must be DV)




=== Example
_Feedback is important for learning[1]. Students learn programming at home during Covid. Students learning on their own lack synchronous and supportive feedback from their teachers[2]. I intend to deploy an existing automated programming tutor[3] in my 1dv610 class. I'm going to interview my students to see if they were supported by the automated feedback._
 
_Iterate on this story so that this alone describes the gist of your idea and make sure it is within computer science. Try to get a few references in the background part. This is also copy pasted into the submission form to provide a base for finding a supervisor._

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
_Description of the background of the research and the application areas of your work. Max 2 pages excluding references_

Migraine is an episodic and complex sensory processing disturbance with a collection of different neurological symptoms where headache is the most common and primary symptom. Migraine is the most common cause of disability among young women, and the second most common cause of disability overall. @migraine-review

_Define both application area and research area. Think funnel so go from broad to specific (as discussed during Workshop 1). 
Application areas = areas outside of CS that CS is applied to.
Research area = area within CS that you do a knowledge contribution to._


_Use references especially on the CS parts._

_Describe the current knowledge or state and describe why a change or new knowledge is needed. Motivate from a societal OR economic OR ethical points of view._

_Think of what is the target group for your thesis? Try to make this as wide as possible and this target group must be within computer science community. Also make sure it is beyond a specific target ( such as a company)._

_If you are going to develop something (eg. prototype, app, web app, …) then describe the closest solutions. If there are many have a table. You can show the important features._

== Related work
_Position yourself in a research area within Computer Science according to instructions given during workshop. So in this section you only focus on CS!!!_

_Minimum two articles published in CS conferences or journals. However do make sure you find the important and most relevant works and that it is enough to motivate a knowledge gap or that your problem is a CS problem._

_Summarize what others have done as well as not have done with one or two sentences. Summarize their conclusion with one or two sentences. Then finally position yourself in relation to these related works eg. “this is close to what I intend to do”, “I build on top of this”, “my work is different from this” as discussed in Workshop 1 and 2._

_Again make sure this is within CS and on topic of your research area. Check the conference or journal so that it is a scientific CS venue._

_Is there active research in this area? Answer this question by looking at when the papers were published._



== Knowledge Gap/Challenge/Problem
_Describe what is missing in the current knowledge as described in the related work, “the gap”. Motivate from a CS research point of view why this gap needs to be bridged. As discussed in Workshop 2 and 3._

_A literature review article may be a good reference here if it describes a gap._ 



== Knowledge Contribution/Action
_Describe what you intend to do about the knowledge gap/problem/challenge and what you hope to accomplish with that action. Describe with precision as discussed in workshop 2. Think about the “zoom-levels”. 
Make sure this contribution is within Computer Science and suitable for your program profile._

_The contribution can be described as a set of research questions that can be answered._


== Empirical Evidence/Evaluation
_Briefly describe how you intend to gather new knowledge, or how you intend to evaluate the action you are going to make in a credible way. Can your findings be used for more than the specific case you investigated?
For example, interviews, observations, experiments, simulations, etc.  This is and should be a draft that you continue to work on in future steps. (Population/Sampling/Reliability/Validity/Bias/Generalizability)
It is good to write about what methodology you intend to use here. Check course homepage for this: https://coursepress.lnu.se/courses/thesis-projects/02-course-content/02-research-methods
If you can cite a method paper it is a good place to do so._

#bibliography("references.yml", title: "References", style: "ieee")