package se.lnu.thesis.data_seeder

import java.time.ZoneId
import kotlin.math.PI
import kotlin.math.sin
import kotlin.random.Random
import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContracts
import androidx.core.content.ContextCompat
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.HeartRateVariabilityRmssdRecord
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.metadata.Metadata
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import java.time.Duration
import java.time.Instant
import java.time.LocalDateTime
import java.time.ZoneOffset

class DataSeederPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private lateinit var healthConnectClient: HealthConnectClient

    private val pluginJob = SupervisorJob()
    private val pluginScope = CoroutineScope(Dispatchers.Main.immediate + pluginJob)
    private var activityPluginBinding: ActivityPluginBinding? = null
    private var hcRequestPermissionLauncher: ActivityResultLauncher<Set<String>>? = null
    private var pendingHcPermissionsResult: Result? = null
    private var systemRequestPermissionLauncher: ActivityResultLauncher<Array<String>>? = null
    private var pendingSystemPermissionsResult: Result? = null

    private val healthConnectPermissionsSet = setOf(
        HealthPermission.getWritePermission(HeartRateRecord::class),
        HealthPermission.getWritePermission(HeartRateVariabilityRmssdRecord::class),
    )

    private val requiredSystemPermissionsArray = mutableListOf<String>().apply {
        add(Manifest.permission.BODY_SENSORS)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            add(Manifest.permission.POST_NOTIFICATIONS)
        }
    }.toTypedArray()

    companion object {
        private const val TAG = "DataSeederPlugin"

        // --- Configuration for Specific Scenario ---
        private const val TARGET_YEAR = 2025
        private const val TARGET_MONTH = 5 // May
        private const val TARGET_DAY = 21  // Date for seeding

        // Time Window: 00:00 to 10:00
        private const val START_HOUR = 0   // Local time (midnight)
        private const val START_MINUTE = 0
        private const val END_HOUR = 10    // Local time (morning)
        private const val END_MINUTE = 0

        // Wake-up time (end of sleep HRV recording)
        private const val WAKE_UP_HOUR = 6
        private const val WAKE_UP_MINUTE = 0

        // Heart Rate: 1 sample per record, every 5 seconds
        val HR_GENERATION_INTERVAL: Duration = Duration.ofSeconds(5)

        // Physiological Ranges & Variation Parameters
        // SLEEP PHASE (00:00 - 06:00)
        private const val BASE_SLEEP_HR_AVG = 55L
        private const val SLEEP_HR_JITTER_MAX = 5L
        private const val SLEEP_HR_MIN = 40L
        private const val SLEEP_HR_MAX = 90L

        private const val BASE_SLEEP_RMSSD_AVG_MS = 55.0   // Average RMSSD during sleep
        private const val SLEEP_RMSSD_JITTER_MAX_MS = 10.0 // Variation for hourly sleep RMSSD
        private const val SLEEP_RMSSD_MIN_MS = 25.0
        private const val SLEEP_RMSSD_MAX_MS = 120.0

        // WAKING UP & AWAKE PHASE (06:00 - 10:00)
        private const val WAKE_UP_HR_BOOST_AMOUNT = 15L
        private const val MORNING_HR_STABILIZE_DURATION_MINUTES = 15
        private const val BASE_AWAKE_MORNING_HR_AVG = 75L
        private const val AWAKE_HR_SLOW_WAVE_AMPLITUDE = 8L
        private const val AWAKE_HR_RAPID_JITTER_MAX = 4L
        private const val AWAKE_HR_MIN = 50L
        private const val AWAKE_HR_MAX = 130L

        // Other constants
        private const val INSERT_CHUNK_SIZE = 500
        private const val CLIENT_ID_PREFIX_HR_SPECIFIC = "SEEDER_HR_NIGHT_DAY_"
        private const val CLIENT_ID_PREFIX_HRV_HOURLY = "SEEDER_HRV_HOURLY_SLEEP_" // Updated prefix
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine")
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "data_seeder")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        healthConnectClient = HealthConnectClient.getOrCreate(context)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        Log.d(TAG, "onMethodCall: ${call.method}")
        when (call.method) {
            "getPlatformVersion" -> result.success("Android ${Build.VERSION.RELEASE}")
            "hasHealthConnectPermissions" -> handleHasHealthConnectPermissions(result)
            "requestHealthConnectPermissions" -> handleRequestHealthConnectPermissions(result)
            "hasSystemPermissions" -> handleHasSystemPermissions(result)
            "requestSystemPermissions" -> handleRequestSystemPermissions(result)
            "seedData" -> seedData(result)
            "seedLive" -> seedLive(result)
            "stopSeedLive" -> stopLiveSeedingService(result)
            else -> result.notImplemented()
        }
    }

    private fun handleHasHealthConnectPermissions(result: Result) {
        Log.d(TAG, "handleHasHealthConnectPermissions called")
        pluginScope.launch {
            try {
                val granted = healthConnectClient.permissionController.getGrantedPermissions()
                val hasPermissions = granted.containsAll(healthConnectPermissionsSet)
                Log.d(TAG, "Has Health Connect permissions: $hasPermissions")
                result.success(hasPermissions)
            } catch (e: Exception) {
                Log.e(TAG, "Error checking Health Connect permissions", e)
                result.error("ERROR_HC_CHECK", e.message ?: "Unknown error", e.toString())
            }
        }
    }

    private fun handleRequestHealthConnectPermissions(result: Result) {
        Log.d(TAG, "handleRequestHealthConnectPermissions called")
        if (pendingHcPermissionsResult != null) {
            result.error("ALREADY_REQUESTING_HC", "A Health Connect permission request is already in progress.", null)
            return
        }
        if (hcRequestPermissionLauncher == null) {
            result.error("NOT_ATTACHED_HC", "Plugin is not attached to an Activity for HC permissions.", null)
            Log.e(TAG, "Request HC permissions called while not attached to activity!")
            return
        }
        pendingHcPermissionsResult = result
        Log.d(TAG, "Launching Health Connect permission request for: $healthConnectPermissionsSet")
        hcRequestPermissionLauncher?.launch(healthConnectPermissionsSet)
    }

    private fun handleHasSystemPermissions(result: Result) {
        Log.d(TAG, "handleHasSystemPermissions called")
        var allGranted = true
        for (permission in requiredSystemPermissionsArray) {
            if (ContextCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                allGranted = false
                Log.d(TAG, "System permission NOT granted: $permission")
                break
            }
            Log.d(TAG, "System permission GRANTED: $permission")
        }
        Log.d(TAG, "Has all required system permissions: $allGranted")
        result.success(allGranted)
    }

    private fun handleRequestSystemPermissions(result: Result) {
        Log.d(TAG, "handleRequestSystemPermissions called")
        if (pendingSystemPermissionsResult != null) {
            result.error("ALREADY_REQUESTING_SYS", "A system permission request is already in progress.", null)
            return
        }
        if (systemRequestPermissionLauncher == null || activityPluginBinding == null) {
            result.error("NOT_ATTACHED_SYS", "Plugin is not attached to an Activity for system permissions.", null)
            Log.e(TAG, "Request system permissions called while not attached to activity!")
            return
        }

        val permissionsNeeded = requiredSystemPermissionsArray.filter {
            ContextCompat.checkSelfPermission(context, it) != PackageManager.PERMISSION_GRANTED
        }.toTypedArray()

        if (permissionsNeeded.isEmpty()) {
            Log.d(TAG, "All required system permissions already granted.")
            result.success(true)
            return
        }

        pendingSystemPermissionsResult = result
        Log.d(TAG, "Launching system permission request for: ${permissionsNeeded.joinToString()}")
        systemRequestPermissionLauncher?.launch(permissionsNeeded)
    }

    private fun seedLive(result: Result) {
        Log.d(TAG, "seedLive called")
        try {
            val serviceIntent = Intent(context, HeartRateSeedingService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                context.startForegroundService(serviceIntent)
            } else {
                context.startService(serviceIntent)
            }
            Log.i(TAG, "HeartRateSeedingService start command sent.")
            result.success(true)
        } catch (e: SecurityException) {
            Log.e(TAG, "SecurityException trying to start HeartRateSeedingService.", e)
            result.error("SERVICE_SECURITY_EXCEPTION", "SecurityException: ${e.message}", e.toString())
        } catch (e: Exception) {
            Log.e(TAG, "Failed to start HeartRateSeedingService", e)
            result.error("SERVICE_START_FAILED", "Error starting service: ${e.message}", e.toString())
        }
    }

    private fun stopLiveSeedingService(result: Result) {
        Log.d(TAG, "stopLiveSeedingService called")
        try {
            val serviceIntent = Intent(context, HeartRateSeedingService::class.java)
            val stopped = context.stopService(serviceIntent)
            if (stopped) {
                Log.i(TAG, "HeartRateSeedingService stop command sent successfully.")
                result.success(true)
            } else {
                Log.w(TAG, "HeartRateSeedingService stop command sent, but service might not have been running.")
                result.success(false)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to stop HeartRateSeedingService", e)
            result.error("SERVICE_STOP_FAILED", "Failed to stop seeding service: ${e.message}", e.toString())
        }
    }

    private suspend fun <T : Record> insertRecordsInChunks(
        records: List<T>,
        recordTypeName: String
    ) {
        if (records.isEmpty()) {
            Log.d(TAG, "No $recordTypeName records to insert.")
            return
        }
        Log.d(TAG, "Total $recordTypeName records to insert: ${records.size}. Chunk size: $INSERT_CHUNK_SIZE")

        records.chunked(INSERT_CHUNK_SIZE).forEachIndexed { index, chunk ->
            try {
                Log.d(TAG, "Inserting $recordTypeName chunk ${index + 1} of ${records.chunked(INSERT_CHUNK_SIZE).size}, actual size: ${chunk.size}")
                healthConnectClient.insertRecords(chunk)
                Log.d(TAG, "$recordTypeName chunk ${index + 1} inserted successfully.")
            } catch (e: Exception) {
                Log.e(TAG, "Error inserting $recordTypeName chunk ${index + 1} (${chunk.size} records)", e)
                throw e
            }
        }
    }

    private fun seedData(result: Result) {
        pluginScope.launch {
            Log.d(TAG, "seedData called - generating night/day data for $TARGET_DAY/$TARGET_MONTH/$TARGET_YEAR...")

            val heartRateData = generateHistoricalHeartRateData()
            val heartRateVariabilityData = generateHistoricalHeartRateVariabilityData() // Now a list of multiple HRV records

            try {
                Log.d(TAG, "Preparing to insert data in chunks...")
                insertRecordsInChunks(heartRateData, "HeartRate (Night/Day)")
                insertRecordsInChunks(heartRateVariabilityData, "HRV (Hourly Sleep)")

                Log.d(TAG, "Data insertion process completed. Generated HR: ${heartRateData.size}, Generated HRV: ${heartRateVariabilityData.size}")
                result.success(true)
            } catch (e: Exception) {
                Log.e(TAG, "Error during bulk insertion of historical data", e)
                result.error("INSERT_ERROR", "Failed during chunked insert: ${e.message}", e.toString())
            }
        }
    }

    private fun generateHistoricalHeartRateData(): List<HeartRateRecord> {
        val targetZoneId = ZoneId.systemDefault()
        val overallStartTime = LocalDateTime.of(TARGET_YEAR, TARGET_MONTH, TARGET_DAY, START_HOUR, START_MINUTE, 0).atZone(targetZoneId).toInstant()
        val overallEndTime = LocalDateTime.of(TARGET_YEAR, TARGET_MONTH, TARGET_DAY, END_HOUR, END_MINUTE, 0).atZone(targetZoneId).toInstant()
        val wakeUpTime = LocalDateTime.of(TARGET_YEAR, TARGET_MONTH, TARGET_DAY, WAKE_UP_HOUR, WAKE_UP_MINUTE, 0).atZone(targetZoneId).toInstant()
        val morningStabilizeEndTime = wakeUpTime.plus(Duration.ofMinutes(MORNING_HR_STABILIZE_DURATION_MINUTES.toLong()))

        Log.d(TAG, "Generating Heart Rate data from $overallStartTime to $overallEndTime, waking up around $wakeUpTime")
        val records = mutableListOf<HeartRateRecord>()
        val systemZoneRules = ZoneOffset.systemDefault().rules

        var currentTime = overallStartTime
        var lastSleepHr = BASE_SLEEP_HR_AVG

        if (HR_GENERATION_INTERVAL.isZero || HR_GENERATION_INTERVAL.isNegative) {
            Log.w(TAG, "HR_GENERATION_INTERVAL for HR is zero or negative. No HR records generated.")
            return records
        }

        while (currentTime.isBefore(overallEndTime)) {
            var bpm: Long

            if (currentTime.isBefore(wakeUpTime)) {
                // --- SLEEP PHASE ---
                val sleepJitter = Random.nextLong(-SLEEP_HR_JITTER_MAX, SLEEP_HR_JITTER_MAX + 1)
                bpm = BASE_SLEEP_HR_AVG + sleepJitter
                bpm = bpm.coerceIn(SLEEP_HR_MIN, SLEEP_HR_MAX)
                lastSleepHr = bpm
            } else {
                // --- AWAKE PHASE (including wake-up boost) ---
                if (currentTime.isBefore(morningStabilizeEndTime)) {
                    // Wake-up boost period
                    val elapsedSinceWakeUp = Duration.between(wakeUpTime, currentTime).seconds.toDouble()
                    val stabilizeDurationSeconds = Duration.between(wakeUpTime, morningStabilizeEndTime).seconds.toDouble()
                    val proportionOfStabilization = if (stabilizeDurationSeconds > 0) elapsedSinceWakeUp / stabilizeDurationSeconds else 1.0
                    val initialBoostedHr = lastSleepHr + WAKE_UP_HR_BOOST_AMOUNT
                    bpm = (initialBoostedHr * (1.0 - proportionOfStabilization) + BASE_AWAKE_MORNING_HR_AVG * proportionOfStabilization).toLong()
                } else {
                    // Normal morning awake HR after stabilization
                    val awakeDurationSeconds = Duration.between(wakeUpTime, overallEndTime).seconds.toDouble() // Total duration of awake period for sine wave
                    val elapsedInAwakePeriodSinceStabilization = Duration.between(morningStabilizeEndTime, currentTime).seconds.toDouble()
                    // Adjust timeProportion to start sine wave after stabilization period
                    val timeProportion = if (awakeDurationSeconds - Duration.between(wakeUpTime, morningStabilizeEndTime).seconds > 0)
                        elapsedInAwakePeriodSinceStabilization / (awakeDurationSeconds - Duration.between(wakeUpTime, morningStabilizeEndTime).seconds)
                    else 0.0

                    val slowWaveOffset = (sin(timeProportion * 2.0 * PI) * AWAKE_HR_SLOW_WAVE_AMPLITUDE).toLong()
                    val rapidJitter = Random.nextLong(-AWAKE_HR_RAPID_JITTER_MAX, AWAKE_HR_RAPID_JITTER_MAX + 1)
                    bpm = BASE_AWAKE_MORNING_HR_AVG + slowWaveOffset + rapidJitter
                }
                bpm = bpm.coerceIn(AWAKE_HR_MIN, AWAKE_HR_MAX)
            }

            val sample = HeartRateRecord.Sample(time = currentTime, beatsPerMinute = bpm)
            val metadata = Metadata.manualEntry()
            val currentLocalDateTime = LocalDateTime.ofInstant(currentTime, targetZoneId)

            records.add(
                HeartRateRecord(
                    startTime = currentTime,
                    startZoneOffset = systemZoneRules.getOffset(currentLocalDateTime),
                    endTime = currentTime,
                    endZoneOffset = systemZoneRules.getOffset(currentLocalDateTime),
                    samples = listOf(sample),
                    metadata = metadata
                )
            )
            currentTime = currentTime.plus(HR_GENERATION_INTERVAL)
        }
        Log.d(TAG, "Generated ${records.size} Heart Rate records for the night/day period.")
        return records
    }

    private fun generateHistoricalHeartRateVariabilityData(): List<HeartRateVariabilityRmssdRecord> {
        val targetZoneId = ZoneId.systemDefault()
        Log.d(TAG, "Generating hourly HRV RMSSD records during sleep (00:00 - 06:00)")
        val records = mutableListOf<HeartRateVariabilityRmssdRecord>()
        val systemZoneRules = ZoneOffset.systemDefault().rules

        // Loop through each hour of the sleep period: 00:00, 01:00, 02:00, 03:00, 04:00, 05:00
        // An HRV record will be generated for the hour ending at H+1.
        // So, for hour 0 (00:00-01:00), record is at 01:00. For hour 5 (05:00-06:00), record is at 06:00.
        for (hour in START_HOUR until WAKE_UP_HOUR) {
            // Timestamp the HRV record at the END of the current hour
            val hrvRecordTime = LocalDateTime.of(TARGET_YEAR, TARGET_MONTH, TARGET_DAY, hour + 1, 0, 0)
                .atZone(targetZoneId).toInstant()

            // Simulate some variation for each hour's average RMSSD
            val rmssdJitter = (Random.nextDouble() * 2.0 - 1.0) * SLEEP_RMSSD_JITTER_MAX_MS
            var rmssdValue = BASE_SLEEP_RMSSD_AVG_MS + rmssdJitter
            rmssdValue = rmssdValue.coerceIn(SLEEP_RMSSD_MIN_MS, SLEEP_RMSSD_MAX_MS)

            val metadata = Metadata.manualEntry()
            val recordLocalDateTime = LocalDateTime.ofInstant(hrvRecordTime, targetZoneId)

            records.add(
                HeartRateVariabilityRmssdRecord(
                    time = hrvRecordTime,
                    zoneOffset = systemZoneRules.getOffset(recordLocalDateTime),
                    heartRateVariabilityMillis = rmssdValue,
                    metadata = metadata
                )
            )
            Log.d(TAG, "Generated HRV record for hour ending ${hour + 1}:00 with RMSSD: $rmssdValue ms")
        }

        Log.d(TAG, "Generated ${records.size} hourly HRV records for the sleep period.")
        return records
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        Log.d(TAG, "onAttachedToActivity")
        this.activityPluginBinding = binding
        val activity = binding.activity
        if (activity is ComponentActivity) {
            hcRequestPermissionLauncher =
                activity.registerForActivityResult(PermissionController.createRequestPermissionResultContract()) { grantedPermissions ->
                    Log.d(TAG, "Health Connect Permission result: $grantedPermissions")
                    pendingHcPermissionsResult?.let { result ->
                        val allGranted = grantedPermissions.containsAll(healthConnectPermissionsSet)
                        Log.d(TAG, "All Health Connect permissions granted: $allGranted")
                        result.success(allGranted)
                    }
                    pendingHcPermissionsResult = null
                }
            Log.d(TAG, "Health Connect Permission launcher registered.")

            systemRequestPermissionLauncher =
                activity.registerForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { grants: Map<String, Boolean> ->
                    Log.d(TAG, "System Permissions result: $grants")
                    pendingSystemPermissionsResult?.let { result ->
                        var allRequiredSystemPermissionsGranted = true
                        for (permission in requiredSystemPermissionsArray) {
                            if (ContextCompat.checkSelfPermission(context, permission) != PackageManager.PERMISSION_GRANTED) {
                                allRequiredSystemPermissionsGranted = false
                                break
                            }
                        }
                        Log.d(TAG, "All required system permissions granted: $allRequiredSystemPermissionsGranted")
                        result.success(allRequiredSystemPermissionsGranted)
                    }
                    pendingSystemPermissionsResult = null
                }
            Log.d(TAG, "System Permissions launcher registered.")
        } else {
            Log.e(TAG, "Activity is not a ComponentActivity, cannot register for results.")
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges")
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges")
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity")
        activityPluginBinding = null
        hcRequestPermissionLauncher?.unregister()
        hcRequestPermissionLauncher = null
        pendingHcPermissionsResult = null
        systemRequestPermissionLauncher?.unregister()
        systemRequestPermissionLauncher = null
        pendingSystemPermissionsResult = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d(TAG, "onDetachedFromEngine")
        channel.setMethodCallHandler(null)
        pluginJob.cancel()
        Log.d(TAG, "Plugin job cancelled")
    }
}
