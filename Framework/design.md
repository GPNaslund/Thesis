# FRAMEWORK DESIGN
## API DESIGN
### EXAMPLE

Provider for selecting the health data provider, set the data collection scope as well as an authentication config.\n
```dart
  final provider = HealthProvider.googleFit(
    scopes: [HealthDataType.heartRate, healthDataType.steps],
    authConfig: GoogleFitAuthConfig(clientId: "your-client-id")
);
```

Transformer for adding the logic for data transformation.
```dart
  final transformer = HealthDataTransformer.standard(
    outputFormat: HealthDataFormat.openMHealth,
  );
```

Create the actual class
```dart
  final healthData = WearableHealth(
  provider: provider,
  transformer: transformer,
  errorHandler: (error) => print("Error: $error"),
  );
```

Request permissions
```dart
  await healthData.requestPermissions()
```

Collect specified data
```dart
    await healthData.collectData()
```
