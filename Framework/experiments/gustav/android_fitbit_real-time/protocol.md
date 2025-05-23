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
    The test environment was established in a controlled indoor setting at the specified testing location (Stockholm, Sweden) to minimize external interference. The Samsung Galaxy S22 Ultra (OS: Android 14) was confirmed to have the 'plugin experiment app' (App Build: 0.0.1, Flutter Plugin: 3.29.2) installed, with all necessary permissions granted for Health Connect access and real-time data retrieval. Any cached data from previous test runs within the 'plugin experiment app' was cleared. The Fitbit Sense 2 (Firmware: 60.20001.194.86) was visually inspected, confirmed to have an adequate battery level (recorded: 96%), and securely fitted to the tester's wrist according to manufacturer guidelines to ensure optimal sensor contact for accurate readings. Bluetooth connectivity was active, and it was verified that no other potentially interfering Bluetooth devices were actively connected to the smartphone.

   ```

2. **Data Collection Process**
    - _Steps taken to collect the health data_
   ```
    To enable more continuous heart rate updates suitable for real-time data gathering, the "Walking" activity (workout mode) was manually initiated directly on the Fitbit Sense 2. A stable Bluetooth connection between the Fitbit Sense 2 and the Fitbit companion application on the Samsung Galaxy S22 Ultra was confirmed, and data flow to Google Health Connect was implicitly verified by ensuring the Fitbit app had sync permissions for Health Connect. Once these preparatory conditions were met and the wearable was actively in workout mode, the real-time heart rate data collection was initiated within the 'plugin experiment app'. The app was set to record data for the planned test duration of 10 minutes.

    During the 10-minute data collection period, the 'plugin experiment app' actively recorded real-time heart rate data transmitted from the Fitbit Sense 2 (via the Flutter Health Plugin and Health Connect). The tester remained in a 'Resting' state with 'Low' intensity physical activity as specified. Where possible, the heart rate displayed on the Fitbit Sense 2's screen was casually monitored as a basic reference against the data being captured by the application, looking for any immediate, obvious discrepancies, though formal validation was reserved for post-test analysis. The stability of the 'plugin experiment app' and the Bluetooth connection was also passively monitored throughout the 10-minute test.
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
| Heart rate             | 69 beats/min  | 69 beats/min | `[X] Yes [ ] No` | 2025-05-23 12:39:51 UTC     | 2025-05-23 14:39 UTC+2     | `[X] Yes [] No` |  |![HR Data 1](./img/hr1/hr1.jpg)|![HR - Data store](./img/summary.jpg)|
| Heart rate             | 67 beats/min  | 67 beats/min | `[X] Yes [ ] No` | 2025-05-23 12:40:50 UTC     | 2025-05-23 14.40 UTC+2     | `[X] Yes [] No` |  |![HR Data 2](./img/hr2/hr2.jpg)|![HR - Data store](./img/summary.jpg)|
| Heart rate | 70 beats/min          | 70 beats/min         | `[X] Yes [ ] No` | 2025-05-23 12:42:25 UTC    | 2025-05-23 14:42 UTC+2     | `[X] Yes [] No` |  |![HRV Data 1](./img/hr3/hr3.jpg)|![HRV - Datastore](./img/hr3/hr3.jpg)|
| Heart rate | 71 beats/min          | 71 beats/min         | `[X] Yes [ ] No` | 2025-05-23 12:43:36 UTC     | 2025-05-23 12:43     | `[X] Yes [X] No` |  |![HRV Data 2](./img/hr4/hr4.jpg)|![HRV - Datastore](./img/summary2.jpg)|

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