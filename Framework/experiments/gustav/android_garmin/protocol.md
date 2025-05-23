# Flutter Health Plugin Testing Protocol

## Test Information

| Field | Value               |
|-------|---------------------|
| Test ID | `TEST-GN01`         |
| Date | `2025-05-23`        |
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
| Wearable Model | `Garmin Venu 2`                                        |
| Firmware Version | `19.05`                                                |
| Connection Method | `[X] Bluetooth  [ ] WiFi  [ ] Other: _______`          |
| Wearable Battery Level | `96%`                                                  |

## Test Environment

| Field | Value                                                                 |
|-------|-----------------------------------------------------------------------|
| Physical Activity Type | `[X] Resting  [] Walking  [ ] Running  [ ] Cycling  [ ] Other: ____` |
| Duration | `6 hrs`                                                              |
| Intensity (if applicable) | `[X] Low  [ ] Medium  [ ] High`                                       |
| Environmental Conditions | `Temperature: Approx 20°C, Humidity: - %, Other factors: _______`            |

## Health Data Parameters Tested

*Check all that apply:*

- [X] Heart Rate
- [ ] Heart rate variability
- [ ] Other: _______

## Test Procedure

1. **Setup**
    - _Description of how the test environment was prepared_
   ```
   Both the Samsung Galaxy S22 Ultra and the Garmin Venu 2 smartwatch were confirmed to be adequately charged (wearable at 96%). The Garmin Venu 2 was visually inspected for any physical damage or sensor obstructions. The 'plugin experiment app' (v0.0.1) was installed on the Samsung Galaxy S22 Ultra, and any cached data from prior tests within this app was cleared. Crucially, the 'Health Sync' third-party application was installed and configured on the smartphone to bridge data from the Garmin Connect platform to Google Health Connect. This involved ensuring the Garmin Connect app was also installed, logged in, and had recently synced with the Garmin Venu 2. Permissions for Health Sync to read from Garmin Connect and write to Google Health Connect were verified. The Garmin Venu 2 was then securely fitted to the tester's wrist for the duration of the data collection period.
   ```

2. **Data Collection Process**
    - _Steps taken to collect the health data_
   ```
   The Garmin Venu 2 was worn by the tester for a continuous period of 6 hours (approximately from 00:00 to 06:00, based on test time and data timestamps), during which it passively collected Heart Rate data in a 'Resting' state with 'Low' intensity. Following the 6-hour data collection period, the data synchronization process was initiated. First, data from the Garmin Venu 2 was synced to the Garmin Connect application on the Samsung Galaxy S22 Ultra. Once this was complete, the 'Health Sync' application was opened and a synchronization was manually triggered to transfer the newly acquired Heart Rate data from Garmin Connect into Google Health Connect. Sufficient time was allowed for this transfer to complete.

   After confirming data synchronization to Google Health Connect via 'Health Sync', the 'plugin experiment app' was launched on the Samsung Galaxy S22 Ultra. The app was then used to initiate the extraction of Heart Rate data from Health Connect, specifically targeting the 6-hour window corresponding to the test period. (Optional but recommended: If data outside the precise test window might have been synced to Health Connect by 'Health Sync', a manual review and sanitization of entries in Health Connect, similar to procedures with other platforms, would be advisable before extraction to ensure data integrity, though this step's necessity depends on Health Sync's behavior regarding timeframes.)

   ```

3. **Observations During Testing**
    - _Any notable observations during the testing process_
   ```
   The primary observation during this test (TEST-GN01) was the critical dependency on the 'Health Sync' third-party application to facilitate data flow from the Garmin Venu 2 ecosystem into Google Health Connect. This introduces an additional layer in the data pathway, which, as noted in the 'Additional Notes', may have implications for data validity and reliability if 'Health Sync' introduces transformations or delays. It was also observed that 'Health Sync', in its current configuration or version, appeared to limit the synchronization of Heart Rate Variability (HRV) data to Health Connect, even though the Garmin Venu 2 records HRV and Health Connect can store it. This highlights a potential limitation for comprehensive data analysis when relying on this specific third-party bridge. The 'plugin experiment app' itself performed stably during extraction from Health Connect.
   ```

## Results

### Data Extraction Performance

| Metric | Result                                      | Notes |
|--------|---------------------------------------------|-------|
| Connection Success | `[X] Success  [ ] Partial  [ ] Failed`      | |
| Data Retrieval Completeness | `[X] Complete  [ ] Partial  [ ] Failed`     | |
| Extraction Speed | `133 milliseconds`                          | |
| Battery Impact (device) | `1% drain`                                  | |
| Battery Impact (wearable) | `0-1% drain`                                | |
| App Stability | `[X] Stable  [ ] Minor Issues  [ ] Crahed` | |s

### Data Validation

| Data Type  | Expected Value | Actual Value   | Matches?         | Expected Timestamp      | Actual Timestamp        | Matches?         | Notes |
|------------|----------------|----------------|------------------|-------------------------|-------------------------|------------------|-------|
| Heart rate | 81 beats/min   | 81 beats/min   | `[X] Yes [ ] No` | 21-05-22 22:00:15 UTC | 21-05-23 00:00:15 UTC+2 | `[X] Yes [] No`  | -     |
| Heart rate | 81 beats/min   | 81 beats/min   | `[X] Yes [ ] No` | 21-05-22 22:00:30 UTC | 21-05-23 00:00:30 UTC+2 | `[X] Yes [] No`  | -     |
| Heart rate | 81 beats/min   | 81 beats/min   | `[X] Yes [ ] No` | 21-05-22 22:00:45 UTC | 21-05-23 00:00:45 UTC+2 | `[X] Yes [] No`  | -     |
| Heart rate | 81 beats/min   | 81 beats/min   | `[X] Yes [ ] No` | 21-05-22 22:01:00 UTC | 21-05-23 00:01:00 UTC+2 | `[X] Yes [] No`  | -     |

![datasum](./img/data-sum.jpg)
![store](./img/summary.jpg)



### Results Report



![Results Report](./experimentation_results.jpg)

Alternative link to report: [Report Link](url_or_path)

## Issues Encountered

| Issue | Severity | Description | Reproducible? |
|-------|----------|-------------|--------------|
| | `[ ] Low [ ] Medium [ ] High [ ] Critical` | | `[ ] Yes [ ] No [ ] Sometimes` |
| | `[ ] Low [ ] Medium [ ] High [ ] Critical` | | `[ ] Yes [ ] No [ ] Sometimes` |

## Additional Notes

```
   The necessity of using a third party application for extraction of data makes the validity and reliability of this test hard to evaluate. The correctness is uncertain.
```

## Conclusion

**Test Result:** `[X] Pass  [ ] Pass with Issues  [ ] Fail`

**Recommendations for Improvement:**
```
   Implement the ability to directly extract data from garmin to ensure correctness of experiment.
```

---

## Follow-up Actions

| Action Item | Assigned To | Due Date | Status |
|-------------|-------------|----------|--------|
| | | | `[ ] Open [ ] In Progress [ ] Completed` |
| | | | `[ ] Open [ ] In Progress [ ] Completed` |

---

*Protocol version: 1.0*