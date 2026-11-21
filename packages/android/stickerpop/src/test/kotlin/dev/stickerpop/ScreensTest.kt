package dev.stickerpop

import app.cash.paparazzi.DeviceConfig
import app.cash.paparazzi.Paparazzi
import dev.stickerpop.samples.PopGallery
import dev.stickerpop.samples.PopHomeSample
import dev.stickerpop.samples.PopSampleNow
import org.junit.Rule
import org.junit.Test

/**
 * Screenshot tests (Paparazzi). Record with `gradle :stickerpop:recordPaparazziDebug`,
 * check with `gradle :stickerpop:verifyPaparazziDebug`. Images live in
 * src/test/snapshots.
 */
class ScreensTest {
    @get:Rule
    val paparazzi = Paparazzi(deviceConfig = DeviceConfig.PIXEL_5.copy(screenHeight = 2340), maxPercentDifference = 0.1)

    @Test fun homeSample() = paparazzi.snapshot { PopHomeSample(now = PopSampleNow) }

    @Test fun gallery() = paparazzi.snapshot { PopGallery() }
}
