package dev.stickerpop

import app.cash.paparazzi.DeviceConfig
import app.cash.paparazzi.Paparazzi
import com.android.resources.Density
import dev.stickerpop.samples.PopGallery
import dev.stickerpop.samples.PopHomeSample
import dev.stickerpop.samples.PopSampleNow
import org.junit.Rule
import org.junit.Test

/**
 * Screenshot tests (Paparazzi). Record with `gradle :stickerpop:recordPaparazziDebug`,
 * check with `gradle :stickerpop:verifyPaparazziDebug`. Images live in
 * src/test/snapshots. The renderer needs x86, so they run on CI.
 */
class ScreensTest {
    @get:Rule
    val paparazzi = Paparazzi(deviceConfig = DeviceConfig.PIXEL_5.copy(screenHeight = 2340), maxPercentDifference = 0.1)

    @Test fun homeSample() = paparazzi.snapshot { PopHomeSample(now = PopSampleNow) }
}

/**
 * The whole gallery in one image, like the Flutter golden: a 390-wide screen
 * at 1× density, tall enough for every section, kept at full resolution
 * (Paparazzi otherwise shrinks images to 1000 px). The gallery grows with
 * every component: if the last section is cut off, raise the height.
 */
class GalleryTest {
    @get:Rule
    val paparazzi = Paparazzi(
        deviceConfig = DeviceConfig.PIXEL_5.copy(screenWidth = 390, screenHeight = 12000, xdpi = 160, ydpi = 160, density = Density.MEDIUM),
        useDeviceResolution = true,
        maxPercentDifference = 0.1,
    )

    @Test fun gallery() = paparazzi.snapshot { PopGallery() }
}
