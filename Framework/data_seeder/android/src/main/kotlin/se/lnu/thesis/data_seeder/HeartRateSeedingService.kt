package se.lnu.thesis.data_seeder

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.bluetooth.BluetoothClass
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.metadata.DataOrigin
import androidx.health.connect.client.records.metadata.Device
import androidx.health.connect.client.records.metadata.Metadata // Import Metadata
import kotlinx.coroutines.*
import java.time.Instant
import java.time.ZoneOffset
import kotlin.random.Random

class HeartRateSeedingService : Service() {

    private val serviceJob = SupervisorJob()
    private val serviceScope = CoroutineScope(Dispatchers.IO + serviceJob)
    private lateinit var healthConnectClient: HealthConnectClient

    private val notificationId = 12346
    private val channelId = "FitbitMimicHeartRateChannel" // Changed channel name slightly

    private var currentHeartRateBpm = 70.0
    private var lastActivitySimulationTime = System.currentTimeMillis()
    private val baselineMinHr = 60.0
    private val baselineMaxHr = 85.0
    private val activitySimulationChance = 0.03
    private val activitySimulationDurationMillis = 4 * 60 * 1000L
    private val activityHeartRateIncreaseAmount = 25.0
    private val recoveryRatePerTick = 0.15

    private fun getNextRealisticHeartRateBpm(): Long {
        val now = System.currentTimeMillis()
        if (now - lastActivitySimulationTime > activitySimulationDurationMillis && Random.nextDouble() < activitySimulationChance) {
            currentHeartRateBpm += activityHeartRateIncreaseAmount + Random.nextDouble(0.0, activityHeartRateIncreaseAmount / 2)
            lastActivitySimulationTime = now
        }
        if (currentHeartRateBpm > baselineMaxHr) {
            currentHeartRateBpm -= recoveryRatePerTick
            if (currentHeartRateBpm < baselineMaxHr) currentHeartRateBpm = Random.nextDouble(baselineMinHr, baselineMaxHr)
        } else {
            currentHeartRateBpm += Random.nextDouble(-1.5, 1.5)
            currentHeartRateBpm = currentHeartRateBpm.coerceIn(baselineMinHr - 3.0, baselineMaxHr + 3.0)
        }
        return currentHeartRateBpm.coerceIn(45.0, 190.0).toLong()
    }
    // --- End of Realistic Heart Rate Generation Logic ---

    override fun onCreate() {
        super.onCreate()
        healthConnectClient = HealthConnectClient.getOrCreate(this)
        createNotificationChannel()
        Log.d("FitbitMimicHRSeeder", "Service Created.")
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d("FitbitMimicHRSeeder", "Service Started.")
        startForeground(notificationId, createBarebonesNotification())

        serviceScope.launch {
            // MODIFICATION: Set DataOrigin to mimic Fitbit
            val fitbitDataOrigin = DataOrigin(packageName = "com.fitbit.FitbitMobile")

            var lastSampleEndTime = Instant.now().minusSeconds(10)

            try {
                while (isActive) {
                    val currentTime = Instant.now()
                    if (currentTime.isBefore(lastSampleEndTime.plusSeconds(1))) {
                        delay(200)
                        continue
                    }

                    val bpm = getNextRealisticHeartRateBpm()
                    val sampleStartTime = lastSampleEndTime.plusMillis(1)
                    val sampleEndTime = currentTime

                    if (sampleStartTime.isAfter(sampleEndTime) || sampleStartTime == sampleEndTime) {
                        Log.w("FitbitMimicHRSeeder", "Skipping due to invalid time: Start=$sampleStartTime, End=$sampleEndTime")
                        lastSampleEndTime = sampleEndTime
                        delay(100)
                        continue
                    }

                    val recordMetadata = Metadata.manualEntry();


                    val heartRateRecord = HeartRateRecord(
                        startTime = sampleStartTime,
                        startZoneOffset = ZoneOffset.systemDefault().rules.getOffset(sampleStartTime),
                        endTime = sampleEndTime,
                        endZoneOffset = ZoneOffset.systemDefault().rules.getOffset(sampleEndTime),
                        samples = listOf(HeartRateRecord.Sample(time = sampleStartTime, beatsPerMinute = bpm)),
                        metadata = recordMetadata
                    )

                    healthConnectClient.insertRecords(listOf(heartRateRecord))
                    Log.i("FitbitMimicHRSeeder", "Seeded HR (as Fitbit): $bpm bpm")
                    lastSampleEndTime = sampleEndTime

                    val randomDelayMillis = Random.nextLong(15000L, 30001L) // Generates a random Long between 15000 (inclusive) and 30001 (exclusive)
                    delay(randomDelayMillis)
                    Log.i("FitbitMimicHRSeeder", "Next seed in ${randomDelayMillis / 1000} seconds.") // Optional: for logging the delay
                }
            } catch (e: CancellationException) {
                Log.i("FitbitMimicHRSeeder", "Seeding cancelled.")
            } catch (e: Exception) {
                Log.e("FitbitMimicHRSeeder", "Error in Fitbit mimic seeding loop", e)
                stopSelf()
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceJob.cancel()
        Log.d("FitbitMimicHRSeeder", "Service Destroyed.")
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                channelId,
                "Background Fitbit Mimic Heart Rate Seeder",
                NotificationManager.IMPORTANCE_LOW
            )
            getSystemService(NotificationManager::class.java)?.createNotificationChannel(serviceChannel)
        }
    }

    private fun createBarebonesNotification(): Notification {
        val icon = android.R.drawable.ic_popup_sync

        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("Seeding Heart Rate (Fitbit Mimic)")
            .setContentText("Continuously adding 'Fitbit' heart rate data...")
            .setSmallIcon(icon)
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
}