package se.lnu.wearable_health

import android.os.Bundle
import android.view.Gravity
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ScrollView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

class HealthConnectPrivacyPolicyActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val mainLayout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.MATCH_PARENT
            )
            setPadding(32, 32, 32, 32)
        }

        val titleTextView = TextView(this).apply {
            text = "Privacy Policy"
            textSize = 24f
            setTextColor(getColor(android.R.color.black))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                bottomMargin = 32
            }
            gravity = Gravity.CENTER
        }

        val scrollView = ScrollView(this).apply {
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                0
            ).apply {
                weight = 1f
            }
        }

        val policyTextView = TextView(this).apply {
            text = "This app collects health data through Health Connect to provide you with insights about your health and fitness. We only access the specific data types you explicitly grant permission for. Your data remains on your device and is not shared with third parties or used for advertising purposes. You can revoke access at any time through the Health Connect settings."
            textSize = 16f
            setTextColor(getColor(android.R.color.darker_gray))
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            )
            setPadding(0, 0, 0, 16)
        }

        val closeButton = Button(this).apply {
            text = "Close"
            layoutParams = LinearLayout.LayoutParams(
                LinearLayout.LayoutParams.MATCH_PARENT,
                LinearLayout.LayoutParams.WRAP_CONTENT
            ).apply {
                topMargin = 32
            }
            setOnClickListener {
                finish()
            }
        }

        scrollView.addView(policyTextView)
        mainLayout.addView(titleTextView)
        mainLayout.addView(scrollView)
        mainLayout.addView(closeButton)

        setContentView(mainLayout)
    }
}