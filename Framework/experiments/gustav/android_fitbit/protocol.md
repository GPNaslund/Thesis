# Flutter Health Plugin Testing Protocol

## Test Information

| Field | Value               |
|-------|---------------------|
| Test ID | `TEST-GN02`         |
| Date | `2025-05-21`        |
| Time | `00:00`             |
| Tester Name | `Gustav Näslund`    |
| Testing Location | `Stockholm, Sweden` |

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

| Field | Value                                                                    |
|-------|--------------------------------------------------------------------------|
| Physical Activity Type | `[X] Resting  [] Walking  [ ] Running  [ ] Cycling  [ ] Other: _______` |
| Duration | `10 hours`                                                               |
| Intensity (if applicable) | `[X] Low  [ ] Medium  [ ] High`                                          |
| Environmental Conditions | `Temperature: 9°C, Humidity: 28%, Other factors: _______`                |

## Health Data Parameters Tested

*Check all that apply:*

- [X] Heart Rate
- [X] Heart Rate Variability
- [ ] Other: _______

## Test Procedure

1. **Setup**
    - _Description of how the test environment was prepared_
   ```
   The Fitbit Sense 2 smartwatch was visually inspected for any physical damage or sensor obstructions that could potentially interfere with data collection. The device was confirmed to be adequately charged (96%) prior to test commencement. To ensure a clean dataset for the current test, any cached or locally stored health data within the 'plugin experiment app' (v0.0.1) from previous sessions was cleared. On the Samsung Galaxy S22 Ultra, it was verified that no other Bluetooth devices (especially other smartwatches or fitness trackers) were actively connected that could interfere with wearable data transmission. The necessary mobile applications were ensured to be installed and correctly configured on the Samsung Galaxy S22 Ultra: this included the Fitbit app (logged in, device paired, and recently synced), Google Fit (for visual data verification, configured with Health Connect), and the 'plugin experiment app' (v0.0.1) with all required permissions granted. Finally, the Fitbit Sense 2 was securely attached to the tester's left wrist, ensuring good skin contact.
   ```

2. **Data Collection Process**
    - _Steps taken to collect the health data_
   ```
   Health data (Heart Rate and Heart Rate Variability) was actively captured by the Fitbit Sense 2, worn by the tester overnight, specifically between approximately 23:00 and 10:00 the following day. Post-recording, the collected data was synchronized from the smartwatch to the Fitbit mobile application on the Samsung Galaxy S22 Ultra. It was ensured that the Fitbit app was configured to share its data with Google's Health Connect, and sufficient time was allowed for this secondary synchronization to complete, making the data available in Health Connect.
   ```

3. **Observations During Testing**
    - _Any notable observations during the testing process_
   ```
   The Fitbit Sense 2 was worn as intended on the left wrist from approximately 23:00 to 10:00 to specifically capture nocturnal Heart Rate (HR) and Heart Rate Variability (HRV), as HRV is primarily recorded by Fitbit devices during sleep. Synchronization of data from the watch to the Fitbit app, and subsequently to Health Connect (prior to manual sanitization), proceeded smoothly. Google Fit provided a convenient way to visually confirm that data was populating Health Connect as expected before the sanitization and extraction steps. No other significant issues or deviations from the planned procedure were noted during the setup, collection, or extraction phases beyond the necessity for manual data window trimming in Health Connect.
   ```

## Results

### Data Extraction Performance

| Metric | Result                                      | Notes |
|--------|---------------------------------------------|-------|
| Connection Success | `[X] Success  [ ] Partial  [ ] Failed`      | |
| Data Retrieval Completeness | `[X] Complete  [ ] Partial  [ ] Failed`     | |
| Extraction Speed | `1289 ms`                             | |
| Battery Impact (device) | `1% drain`                                  | |
| Battery Impact (wearable) | `0-1% drain`                                | |
| App Stability | `[X] Stable  [ ] Minor Issues  [ ] Crashed` | |

### Data Validation

| Data Type              | Expected Value | Actual Value  | Matches?         | Expected Timestamp | Actual Timestamp   | Matches?         | Notes                                | Image reference in app    | Image reference data store                |
|------------------------|----------------|---------------|------------------|--------------------|--------------------|------------------|--------------------------------------|---------------------------|---------------------------------------------|
| Heart rate             | 53 beats/min  | 53 beats/min | `[X] Yes [ ] No` | 21-05-21 00:00 UTC+2     | 21-05-20 22:00 UTC   | `[X] Yes [] No` | -  |![HR Data 1](./img/hr1/h1.jpg)|![HR - HK Data 1](./img/fitref.jpg)|
| Heart rate             | 58 beats/min  | 58 beats/min | `[X] Yes [ ] No` | 21-05-21 00:00 UTC+2    | 21-05-20 22:00:05 UTC      | `[X] Yes [X] No` | - |![HR Data 2](./img/hr2/h2.jpg)|![HR - HK Data 2](./img/fitref.jpg)|
| Heart rate variability | 64,349849764 ms          | 64,349849764 ms         | `[X] Yes [ ] No` | 21-05-21 01:00 UTC+2     | 21-05-20 23:00UTC     | `[X] Yes [] No` | - |![HRV Data 1](./img/hrv1/hrv1.jpg)|![HRV - HK Data 1](./img/hrvref.jpg)|
| Heart rate variability | 47,64536305577525 ms          | 47,64536305577525 ms         | `[X] Yes [ ] No` | 22-05-21 02:00 UTC+2     | 21-05-21 00:00 UTC     | `[X] Yes [] No` |  |![HRV Data 2](./img/hrv2/hrv2.jpg)|![HRV - HK Data 2](./img/hrvref.jpg)|

### Results Report

*Attach screenshot or link to the formal results report generated by the test software*

![Results Report](./experimentation_results.jpg)

Alternative link to report: [Report Link](url_or_path)

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