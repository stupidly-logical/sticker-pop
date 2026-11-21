package dev.stickerpop.format

import java.time.LocalDateTime
import java.time.temporal.ChronoUnit
import kotlin.math.abs
import kotlin.math.roundToLong

/**
 * Content formats from the Sticker Pop spec: Indian rupees with Indian digit
 * grouping, compact amounts, and short dates and times. Amounts are `Long`
 * paise, never floating point. Output matches every other platform
 * (`parity/format-cases.json`).
 */
object PopFormat {
    private const val MINUS = "−" // −, a real minus sign

    /** How [formatInr] marks direction. */
    enum class Sign {
        /** Only negatives get a sign (−). */
        Auto,

        /** Money in gets "+", money out gets "−". */
        Always,

        /** No sign, even for negatives. */
        None,
    }

    /** Groups digits the Indian way: 1,25,000 and 12,34,56,789. */
    fun groupIndian(value: Long): String {
        val digits = abs(value).toString()
        if (digits.length <= 3) return digits
        val last3 = digits.takeLast(3)
        var rest = digits.dropLast(3)
        val parts = ArrayDeque<String>()
        while (rest.length > 2) {
            parts.addFirst(rest.takeLast(2))
            rest = rest.dropLast(2)
        }
        if (rest.isNotEmpty()) parts.addFirst(rest)
        return parts.joinToString(",") + "," + last3
    }

    /** ₹1,25,000 or ₹1,250.50. Paise show only when non-zero, unless [alwaysPaise]. */
    fun formatInr(paise: Long, sign: Sign = Sign.Auto, alwaysPaise: Boolean = false): String {
        val rupees = abs(paise) / 100
        val rem = abs(paise) % 100
        val body = if (rem != 0L || alwaysPaise) {
            "${groupIndian(rupees)}.${rem.toString().padStart(2, '0')}"
        } else {
            groupIndian(rupees)
        }
        return signFor(paise, sign) + "₹" + body
    }

    /** ₹950, ₹51.2k, ₹1.25L, ₹2.1Cr: at most three significant figures. */
    fun formatInrCompact(paise: Long, sign: Sign = Sign.Auto): String {
        val rupees = abs(paise) / 100.0
        val body = when {
            rupees >= 1e7 -> trim(rupees / 1e7) + "Cr"
            rupees >= 1e5 -> trim(rupees / 1e5) + "L"
            rupees >= 1e3 -> trim(rupees / 1e3) + "k"
            else -> groupIndian(rupees.roundToLong())
        }
        return signFor(paise, sign) + "₹" + body
    }

    private fun signFor(paise: Long, sign: Sign): String = when (sign) {
        Sign.None -> ""
        Sign.Auto -> if (paise < 0) MINUS else ""
        Sign.Always -> when {
            paise < 0 -> MINUS
            paise > 0 -> "+"
            else -> ""
        }
    }

    private fun trim(v: Double): String {
        val decimals = when {
            v >= 100 -> 0
            v >= 10 -> 1
            else -> 2
        }
        var s = String.format(java.util.Locale.ROOT, "%.${decimals}f", v)
        if (s.contains('.')) s = s.trimEnd('0').trimEnd('.')
        return s
    }

    private val months = listOf("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

    /** "Today", "Yesterday", or "18 Nov 2026". */
    fun formatPopDate(date: LocalDateTime, now: LocalDateTime): String {
        val days = ChronoUnit.DAYS.between(date.toLocalDate(), now.toLocalDate())
        return when (days) {
            0L -> "Today"
            1L -> "Yesterday"
            else -> "${date.dayOfMonth} ${months[date.monthValue - 1]} ${date.year}"
        }
    }

    /** "Nov 2026". */
    fun formatPopMonth(date: LocalDateTime): String = "${months[date.monthValue - 1]} ${date.year}"

    /** 12-hour time: "1:12 pm", "9:05 am", "12:00 pm". */
    fun formatPopTime(time: LocalDateTime): String {
        val h = if (time.hour % 12 == 0) 12 else time.hour % 12
        val m = time.minute.toString().padStart(2, '0')
        return "$h:$m ${if (time.hour < 12) "am" else "pm"}"
    }
}
