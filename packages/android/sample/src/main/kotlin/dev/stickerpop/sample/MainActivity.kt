package dev.stickerpop.sample

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import dev.stickerpop.samples.PopGallery
import dev.stickerpop.samples.PopHomeSample

/** Opens the component gallery; its yellow home button opens the Home sample. */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            var home by rememberSaveable { mutableStateOf(false) }
            if (home) {
                BackHandler { home = false }
                PopHomeSample()
            } else {
                PopGallery(onOpenHome = { home = true })
            }
        }
    }
}
