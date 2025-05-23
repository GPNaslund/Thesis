# Flutter Health Plugin Testing Protocol

## Test Information

| Field | Value        |
|-------|--------------|
| Test ID | `TEST-GN03`  |
| Date | `2025-05-23` |
| Time | `14:39`      |
| Tester Name | `Gustav Näslund`           |
| Testing Location | `Stockholm, Sweden`      |

## Device Configuration

| Field | Value                      |
|-------|----------------------------|
| Phone Model | `Samsung Galaxy S22 Ultra` |
| OS Type | `[X] Android  [ ] iOS`     |
| OS Version | `14`                       |
| Flutter Plugin Version | `3.29.2`                   |
| App Build Number | `0.0.1`                    |

## Wearable Device

| Field | Value                                                  |
|-------|--------------------------------------------------------|
| Wearable Type | `[X] Smartwatch  [ ] Fitness Band  [ ] Other: _______` |
| Wearable Model | `Fitbit Sense 2`                                       |
| Firmware Version | `60.20001.194.86`                                      |
| Connection Method | `[X] Bluetooth  [ ] WiFi  [ ] Other: _______`          |
| Wearable Battery Level | `96%`                                                  |

## Test Environment

| Field | Value |
|-------|-------|
| Physical Activity Type | `[X] Resting  [ ] Walking  [ ] Running  [ ] Cycling  [ ] Other: _______` |
| Duration | `10 minutes` |
| Intensity (if applicable) | `[X] Low  [ ] Medium  [ ] High` |
| Environmental Conditions | `Temperature: 16°C, Humidity: ___%, Other factors: _______` |

## Health Data Parameters Tested

*Check all that apply:*

- [X] Heart Rate
- [ ] Heart rate variability
- [ ] Other: _______

## Test Procedure

1. **Setup**
    - _Description of how the test environment was prepared_
   ```
   The test environment was prepared to ensure consistent and reliable data collection. This involved setting up the Samsung Galaxy S22 Ultra running the custom heart rate extraction application in a controlled indoor setting, minimizing potential interference and ensuring the equipment was configured for optimal performance prior to each session.
   ```

2. **Data Collection Process**
    - _Steps taken to collect the health data_
   ```
    The data collection process commenced with establishing a connection between the wearable device and its companion application on the designated smartphone. Subsequently, data synchronization was verified between the wearable's application and Google Health Connect to ensure seamless data flow. The smartwatch was then worn strictly according to the manufacturer's guidelines to promote accurate sensing. Once these preparatory steps were completed, the real-time heart rate data collection was initiated using the dedicated experiment application. Prior usage and testing of the real time data gathering revealed the need for fitbit to be in workout mode, to more continously update the application with health data, so the fitbit activity walking was activated during this experiment.
   ```

3. **Observations During Testing**
    - _Any notable observations during the testing process_
   ```
   
   ```

## Results

### Data Extraction Performance

| Metric | Result | Notes |
|--------|--------|-------|
| Connection Success | `[X] Success  [ ] Partial  [ ] Failed` | |
| Data Retrieval Completeness | `[X] Complete  [ ] Partial  [ ] Failed` | |
| Extraction Speed | `_____ seconds` | |
| Battery Impact (device) | `5% drain` | |
| Battery Impact (wearable) | `3% drain` | |
| App Stability | `[X] Stable  [ ] Minor Issues  [ ] Crashed` | |

### Data Validation

| Data Type              | Expected Value | Actual Value  | Matches?         | Expected Timestamp | Actual Timestamp   | Matches?         | Notes                                | Image reference in app    | Image reference in HealthKit                |
|------------------------|----------------|---------------|------------------|--------------------|--------------------|------------------|--------------------------------------|---------------------------|---------------------------------------------|
| Heart rate             | 69 beats/min  | 69 beats/min | `[X] Yes [ ] No` | 2025-05-23 12:39:51 UTC     | 2025-05-23 14:39 UTC+2     | `[X] Yes [] No` |  |![HR Data 1](./img/hr1/hr1.jpg)|![HR - HK Data 1](./img/summary.jpg)|
| Heart rate             | 67 beats/min  | 67 beats/min | `[X] Yes [ ] No` | 2025-05-23 12:40:50 UTC     | 2025-05-23 14.40 UTC+2     | `[X] Yes [] No` |  |![HR Data 2](./img/hr2/hr2.jpg)|![HR - HK Data 2](./img/summary.jpg)|
| Heart rate | 70 ms          | 70 ms         | `[X] Yes [ ] No` | 2025-05-23 12:42:25 UTC    | 2025-05-23 14:42 UTC+2     | `[X] Yes [] No` |  |![HRV Data 1](./img/hr3/hr3.jpg)|![HRV - HK Data 1](./img/hr3/hr3.jpg)|
| Heart rate | 71 ms          | 71 ms         | `[X] Yes [ ] No` | 2025-05-23 12:43:36 UTC     | 2025-05-23 12:43     | `[X] Yes [X] No` |  |![HRV Data 2](./img/hr4/hr4.jpg)|![HRV - HK Data 2](./img/summary2.jpg)|

### Results Report

![Results Report](./experimentation_results.jpg)


## Issues Encountered

| Issue | Severity | Description | Reproducible? |
|-------|----------|-------------|--------------|
| | `[ ] Low [ ] Medium [ ] High [ ] Critical` | | `[ ] Yes [ ] No [ ] Sometimes` |
| | `[ ] Low [ ] Medium [ ] High [ ] Critical` | | `[ ] Yes [ ] No [ ] Sometimes` |

## Additional Notes

```

```

## Conclusion

**Test Result:** `[X] Pass  [ ] Pass with Issues  [ ] Fail`

**Recommendations for Improvement:**
```

```

---

## Follow-up Actions

| Action Item | Assigned To | Due Date | Status |
|-------------|-------------|----------|--------|
| | | | `[ ] Open [ ] In Progress [ ] Completed` |
| | | | `[ ] Open [ ] In Progress [ ] Completed` |

---

*Protocol version: 1.0*