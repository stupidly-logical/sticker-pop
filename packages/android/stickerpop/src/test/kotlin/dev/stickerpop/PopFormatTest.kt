package dev.stickerpop

import dev.stickerpop.format.PopFormat
import java.io.File
import java.time.LocalDateTime
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Test

/** Runs the shared cases in parity/format-cases.json; every platform must match them. */
class PopFormatTest {
    private val cases: JSONObject = run {
        var dir: File? = File("").absoluteFile
        while (dir != null && !File(dir, "parity/format-cases.json").exists()) dir = dir.parentFile
        requireNotNull(dir) { "parity/format-cases.json not found above ${File("").absolutePath}" }
        JSONObject(File(dir, "parity/format-cases.json").readText())
    }

    private fun each(name: String, block: (JSONObject) -> Unit) {
        val list = cases.getJSONArray(name)
        require(list.length() > 0)
        for (i in 0 until list.length()) block(list.getJSONObject(i))
    }

    private fun sign(c: JSONObject) = when (c.optString("sign", "auto")) {
        "always" -> PopFormat.Sign.Always
        "none" -> PopFormat.Sign.None
        else -> PopFormat.Sign.Auto
    }

    @Test fun formatInr() = each("formatInr") { c ->
        assertEquals(c.toString(), c.getString("out"), PopFormat.formatInr(c.getLong("paise"), sign(c), c.optBoolean("alwaysPaise")))
    }

    @Test fun formatInrCompact() = each("formatInrCompact") { c ->
        assertEquals(c.toString(), c.getString("out"), PopFormat.formatInrCompact(c.getLong("paise"), sign(c)))
    }

    @Test fun formatPopDate() = each("formatPopDate") { c ->
        assertEquals(c.toString(), c.getString("out"), PopFormat.formatPopDate(LocalDateTime.parse(c.getString("date")), LocalDateTime.parse(c.getString("now"))))
    }

    @Test fun formatPopMonth() = each("formatPopMonth") { c ->
        assertEquals(c.getString("out"), PopFormat.formatPopMonth(LocalDateTime.parse(c.getString("date"))))
    }

    @Test fun formatPopTime() = each("formatPopTime") { c ->
        assertEquals(c.getString("out"), PopFormat.formatPopTime(LocalDateTime.parse(c.getString("time"))))
    }
}
