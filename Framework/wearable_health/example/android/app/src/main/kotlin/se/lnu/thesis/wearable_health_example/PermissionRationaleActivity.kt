package se.lnu.thesis.wearable_health_example

import android.os.Bundle
import android.widget.Button
import androidx.appcompat.app.AppCompatActivity

class PermissionRationaleActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContentView(R.layout.permission_rationale_view)

        val goBackButton: Button = findViewById(R.id.goBackBtn)

        goBackButton.setOnClickListener {
            finish()
        }
    }
}