package se.lnu.thesis.wearable_health.provider

import androidx.activity.ComponentActivity
import io.flutter.plugin.common.MethodChannel


interface Provider {
    fun setupPermissionsLauncher(activity: ComponentActivity)
    fun requestPermissions(permissions: Set<String>, result: MethodChannel.Result)
    fun hasPermissions(permissions: Set<String>): Boolean
    fun installProviderApp()
}