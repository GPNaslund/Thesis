package se.lnu.thesis.wearable_health

import androidx.activity.ComponentActivity
import androidx.activity.result.ActivityResultLauncher
import androidx.activity.result.contract.ActivityResultContract

class PermissionLauncherWrapper {
    private var launcher: ActivityResultLauncher<Set<String>>? = null
    private var callback: ((Set<String>) -> Unit)? = null

    fun register(activity: ComponentActivity, contract: ActivityResultContract<Set<String>, Set<String>>, onResult: (Set<String>) -> Unit) {
        launcher = activity.registerForActivityResult(contract) { result ->
            onResult(result)
        }
        callback = onResult
    }

    fun launch(permissions: Set<String>) {
        launcher?.launch(permissions)
    }
}