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

Backend connector for providing an endpoint to post the data to.
```dart
  final backend = HealthDataBackend.http(
    endpoint: "https://mybackend.com/api/health",
    authHeaders: {"Authorization": "Bearer token"},
  );
```

Sync configuration for deciding on the interval of posting health data to backend.
```dart
  final syncConfig = SyncConfig(
    interval: Duration(minutes: 15),
    batchSize: 100,
    networkRequirement: NetworkType.wifiOnly,
    batteryRequirement: BatteryLevel.aboveThirtyPercent,
  );
```

Create the actual class
```dart
  final healthData = WearableHealth(
  provider: provider,
  transformer: transformer,
  backend: backend,
  syncConfig: syncConfig,
  errorHandler: (error) => print("Error: $error"),
  );
```

Request permissions
```dart
  await healthData.requestPermissions()
```

Start collecting
```dart
  healthData.startCollecting()
```

Stop collection
```dart
    healthData.stopCollecting()
```

Provide logging/status stream
```dart
  healthData.statusStream.listen((status) {
    print("Sync status: $status");
  });
``
