package se.lnu.thesis.data_seeder

import android.content.Context
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.SkinTemperatureRecord
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import java.time.Duration
import java.time.Instant
import java.time.ZoneOffset
import java.time.temporal.ChronoUnit
import androidx.health.connect.client.records.metadata.Metadata
import androidx.health.connect.client.units.Temperature
import androidx.health.connect.client.units.TemperatureDelta
import kotlin.math.abs

/** DataSeederPlugin */
class DataSeederPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel

    private lateinit var healthConnectClient: HealthConnectClient
    private lateinit var context: Context

    private val pluginJob = SupervisorJob()
    private val pluginScope = CoroutineScope(Dispatchers.Main.immediate + pluginJob)


    private var activityPluginBinding: ActivityPluginBinding? = null
    private var requestPermissionLauncher: ActivityResultLauncher<Set<String>>? = null
    private var pendingPermissionsResult: Result? = null

    private val permissions = setOf(
        HealthPermission.getWritePermission(HeartRateRecord::class),
        HealthPermission.getWritePermission(SkinTemperatureRecord::class)
    )

    companion object {
        private const val GENERATION_PERIOD_DAYS = 7L
        private val RECORD_INTERVAL_AND_DURATION: Duration = Duration.ofMinutes(15)
        private val SAMPLE_INTERVAL: Duration = Duration.ofMinutes(1)

        private const val CLIENT_ID_PREFIX_HR = "SEEDER_HR_"
        private const val CLIENT_ID_PREFIX_SKIN_TEMP = "SEEDER_SKINTEMP_"

        private const val BASE_BPM = 70L
        private const val BASELINE_TEMP_CELSIUS = 34.0
        private const val BASE_DELTA_TEMP_CELSIUS = 0.3
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "data_seeder")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        healthConnectClient = HealthConnectClient.getOrCreate(context)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }

            "hasPermissions" -> {
                handleHasPermissions(result)
            }

            "requestPermissions" -> {
                handleRequestPermissions(result)
            }

            "seedData" -> {
                seedData(result)
            }

            else -> {
                result.notImplemented()
            }
        }
    }

    private fun seedData(result: Result) {
        pluginScope.launch {
            Log.d("DataSeederPlugin", "seedData called")
            val heartRateData = generateHistoricalHeartRateData()
            val skinTempData = generateHistoricalSkinTemperatureData()
            try {
                Log.d("DataSeederPlugin", "Inserting heart rate data..")
                healthConnectClient.insertRecords(heartRateData)
                Log.d("DataSeederPlugin", "Inserting skin temperature data..")
                healthConnectClient.insertRecords(skinTempData)
                Log.d("DataSeederPlugin", "Data inserted")
                result.success(true)
            } catch (e: Exception) {
                result.error("INSERT_ERROR", "${e.message}", null)
            }
        }
    }

    private fun generateHistoricalHeartRateData(): List<HeartRateRecord> {
        Log.d("DataSeederPlugin", "Generating historical heart rate data...")
        val records = mutableListOf<HeartRateRecord>()
        val overallEndTime = Instant.now()
        val overallStartTime = overallEndTime.minus(GENERATION_PERIOD_DAYS, ChronoUnit.DAYS)

        var recordStartTime = overallStartTime
        val systemZoneId = ZoneOffset.systemDefault()
        val rules = systemZoneId.rules

        while (recordStartTime.isBefore(overallEndTime)) {
            val recordEndTime = recordStartTime.plus(RECORD_INTERVAL_AND_DURATION).let {
                if (it.isAfter(overallEndTime)) overallEndTime else it
            }

            if (recordStartTime == recordEndTime || Duration.between(recordStartTime, recordEndTime) < SAMPLE_INTERVAL) {
                if (recordStartTime.isAfter(overallEndTime)) break
                recordStartTime = recordEndTime
                continue
            }


            val samples = mutableListOf<HeartRateRecord.Sample>()
            var sampleTime = recordStartTime

            while (!sampleTime.isAfter(recordEndTime)) {
                val variation = abs(sampleTime.epochSecond % 10 - 5)
                val bpm = BASE_BPM + variation

                samples.add(HeartRateRecord.Sample(time = sampleTime, beatsPerMinute = bpm))
                sampleTime = sampleTime.plus(SAMPLE_INTERVAL)
            }

            if (samples.isNotEmpty()) {
                val startOffset: ZoneOffset = rules.getOffset(recordStartTime)
                val endOffset: ZoneOffset = rules.getOffset(recordEndTime)
                val metadata = Metadata.manualEntryWithId("$CLIENT_ID_PREFIX_HR${recordStartTime.epochSecond}")

                records.add(
                    HeartRateRecord(
                        startTime = recordStartTime,
                        startZoneOffset = startOffset,
                        endTime = recordEndTime,
                        endZoneOffset = endOffset,
                        samples = samples,
                        metadata = metadata
                    )
                )
            }
            recordStartTime = recordEndTime
        }
        Log.d("DataSeederPlugin", "Generated ${records.size} heart rate records.")
        return records
    }

    private fun generateHistoricalSkinTemperatureData(): List<SkinTemperatureRecord> {
        Log.d("DataSeederPlugin", "Generating historical skin temperature data...")
        val records = mutableListOf<SkinTemperatureRecord>()
        val overallEndTime = Instant.now()
        val overallStartTime = overallEndTime.minus(GENERATION_PERIOD_DAYS, ChronoUnit.DAYS)

        var recordStartTime = overallStartTime
        val systemZoneId = ZoneOffset.systemDefault()
        val rules = systemZoneId.rules
        val baselineTemp = Temperature.celsius(BASELINE_TEMP_CELSIUS)

        while (recordStartTime.isBefore(overallEndTime)) {
            val recordEndTime = recordStartTime.plus(RECORD_INTERVAL_AND_DURATION).let {
                if (it.isAfter(overallEndTime)) overallEndTime else it
            }

            if (recordStartTime == recordEndTime || Duration.between(recordStartTime, recordEndTime) <= SAMPLE_INTERVAL) {
                if (recordStartTime.isAfter(overallEndTime)) break
                recordStartTime = recordEndTime
                continue
            }

            val deltas = mutableListOf<SkinTemperatureRecord.Delta>()
            var sampleTime = recordStartTime.plus(SAMPLE_INTERVAL)

            while (sampleTime.isBefore(recordEndTime)) {
                val minuteOfHour = sampleTime.atZone(systemZoneId).minute
                val deltaValue = BASE_DELTA_TEMP_CELSIUS + (minuteOfHour * 0.005)
                val deltaTemp = TemperatureDelta.celsius(deltaValue)

                deltas.add(
                    SkinTemperatureRecord.Delta(
                        time = sampleTime,
                        delta = deltaTemp
                    )
                )
                sampleTime = sampleTime.plus(SAMPLE_INTERVAL)
            }

            if (deltas.isNotEmpty()) {
                val startOffset: ZoneOffset = rules.getOffset(recordStartTime)
                val endOffset: ZoneOffset = rules.getOffset(recordEndTime)
                val metadata = Metadata.manualEntryWithId("$CLIENT_ID_PREFIX_SKIN_TEMP${recordStartTime.epochSecond}")

                val record = SkinTemperatureRecord(
                    startTime = recordStartTime,
                    startZoneOffset = startOffset,
                    endTime = recordEndTime,
                    endZoneOffset = endOffset,
                    baseline = baselineTemp,
                    deltas = deltas,
                    metadata = metadata
                )
                records.add(record)
            }
            recordStartTime = recordEndTime
        }
        Log.d("DataSeederPlugin", "Generated ${records.size} skin temperature records.")
        return records
    }

    private fun handleHasPermissions(result: Result) {
        Log.d("DataSeederPlugin", "handleHasPermissions called")

        pluginScope.launch {
            Log.d("DataSeederPlugin", "Coroutine started in pluginScope for hasPermissions")
            try {
                val granted =
                    withContext(Dispatchers.IO) {
                        Log.d("DataSeederPlugin", "Checking permissions on IO dispatcher")

                        if (!::healthConnectClient.isInitialized) {
                            result.error(
                                "NOT_INITIALIZED",
                                "Health connect client is not initialized",
                                null
                            )
                        }
                        healthConnectClient.permissionController.getGrantedPermissions()
                    }

                val hasPermissions = granted.containsAll(permissions)
                Log.d("DataSeederPlugin", "Has permissions: $hasPermissions")
                result.success(hasPermissions)
            } catch (e: CancellationException) {
                Log.d("DataSeederPlugin", "Coroutine cancelled")
            } catch (e: Exception) {
                Log.e("DataSeederPlugin", "Error checking permissions", e)
                result.error("ERROR", e.message, null)
            }
        }
    }


    private fun handleRequestPermissions(result: Result) {
        Log.d("DataSeederPlugin", "handleRequestPermissions called")
        if (pendingPermissionsResult != null) {
            result.error("ALREADY_REQUESTING", "A permission request is already in progress.", null)
            return
        }

        if (requestPermissionLauncher == null) {
            result.error("NOT_ATTACHED", "Plugin is not attached to an Activity.", null)
            Log.e(
                "DataSeederPlugin",
                "Request permissions called while not attached to activity!"
            )
            return
        }

        pendingPermissionsResult = result

        Log.d("DataSeederPlugin", "Launching Health Connect permission request")
        requestPermissionLauncher?.launch(permissions)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        Log.d("DataSeederPlugin", "onDetachedFromEngine")
        channel.setMethodCallHandler(null)
        try {
            pluginJob.cancel()
            Log.d("DataSeederPlugin", "Plugin job cancelled")
        } catch (e: Exception) {
            Log.e("DataSeederPlugin", "Error cancelling plugin job", e)
        }
    }


    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.activityPluginBinding = binding
        val activity = binding.activity
        if (activity is ComponentActivity) {
            requestPermissionLauncher =
                activity.registerForActivityResult(
                    PermissionController.createRequestPermissionResultContract()
                ) { grantedPermissions ->
                    Log.d(
                        "DataSeederPlugin",
                        "Permission result received: $grantedPermissions"
                    )
                    val resultToSend = pendingPermissionsResult
                    pendingPermissionsResult = null

                    if (resultToSend != null) {
                        val allGranted = grantedPermissions.containsAll(permissions)
                        Log.d(
                            "DataSeederPlugin",
                            "All requested permissions granted: $allGranted"
                        )
                        resultToSend.success(allGranted)
                    } else {
                        Log.w(
                            "DataSeederPlugin",
                            "Permission result received but no pending Flutter result found."
                        )
                    }
                }
            Log.d("DataSeederPlugin", "Permission launcher registered.")
        } else {
            Log.e(
                "DataSeederPlugin",
                "Activity is not a ComponentActivity, cannot register for result."
            )
        }
    }


    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        Log.d("DataSeederPlugin", "onDetachedFromActivity")
        activityPluginBinding = null
        requestPermissionLauncher = null
        pendingPermissionsResult = null
    }
}
