package se.lnu.thesis.wearable_health.enums

import androidx.health.connect.client.records.HeartRateRecord
import androidx.health.connect.client.records.Record
import androidx.health.connect.client.records.SkinTemperatureRecord
import kotlin.reflect.KClass

enum class HealthDataType(val value: String, val readDefinition: String) {
    HEART_RATE("heartRate", "android.permission.health.READ_HEART_RATE") {
        override fun toRecord(): KClass<out Record> {
            return HeartRateRecord::class
        }
    },
    SKIN_TEMPERATURE("skinTemperature", "android.permission.health.READ_SKIN_TEMPERATURE") {
        override fun toRecord(): KClass<out Record> {
           return SkinTemperatureRecord::class
        }
    },
    UNKNOWN("unknown", "unknown") {
        override fun toRecord(): KClass<out Record> {
            return Record::class
        }
    };

    companion object {
        fun getDataTypeByValue(value: String): HealthDataType {
            val healthDataType = HealthDataType.values().find { it.value == value }
            if (healthDataType == null) {
                return UNKNOWN
            }
            return healthDataType
        }

        fun getDataTypeByReadDefinition(readDefinition: String): HealthDataType {
            val healthDataType = HealthDataType.values().find { it.readDefinition == readDefinition}
            if (healthDataType == null) {
                return UNKNOWN
            }
            return healthDataType
        }
    }

    abstract fun toRecord(): KClass<out Record>
}