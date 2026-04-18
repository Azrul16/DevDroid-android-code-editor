package com.example.devdroid

import android.app.Activity
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicInteger

class MainActivity : FlutterActivity() {
    private val channel = "devdroid/termux"

    private val executionCounter = AtomicInteger(1000)
    private val pendingResults = ConcurrentHashMap<Int, MethodChannel.Result>()
    private val timeoutRunnables = ConcurrentHashMap<Int, Runnable>()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var permissionRequestResult: MethodChannel.Result? = null

    private val termuxResultReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent == null) {
                return
            }

            val executionId = intent.getIntExtra(EXTRA_EXECUTION_ID, -1)
            val methodResult = pendingResults.remove(executionId) ?: return

            timeoutRunnables.remove(executionId)?.let { mainHandler.removeCallbacks(it) }

            val resultBundle = intent.getBundleExtra(EXTRA_PLUGIN_RESULT_BUNDLE)
                ?: intent.getBundleExtra(EXTRA_PLUGIN_RESULT_BUNDLE_FALLBACK)
            val stdout: String
            val stderr: String
            val exitCode: Int
            val errCode: Int
            val errMsg: String

            if (resultBundle != null) {
                stdout = pickString(
                    resultBundle,
                    EXTRA_PLUGIN_RESULT_BUNDLE_STDOUT,
                    EXTRA_PLUGIN_RESULT_BUNDLE_STDOUT_FALLBACK,
                )
                stderr = pickString(
                    resultBundle,
                    EXTRA_PLUGIN_RESULT_BUNDLE_STDERR,
                    EXTRA_PLUGIN_RESULT_BUNDLE_STDERR_FALLBACK,
                )
                exitCode = pickInt(
                    resultBundle,
                    EXTRA_PLUGIN_RESULT_BUNDLE_EXIT_CODE,
                    EXTRA_PLUGIN_RESULT_BUNDLE_EXIT_CODE_FALLBACK,
                    0,
                )
                errCode = pickInt(
                    resultBundle,
                    EXTRA_PLUGIN_RESULT_BUNDLE_ERR,
                    EXTRA_PLUGIN_RESULT_BUNDLE_ERR_FALLBACK,
                    Activity.RESULT_OK,
                )
                errMsg = pickString(
                    resultBundle,
                    EXTRA_PLUGIN_RESULT_BUNDLE_ERRMSG,
                    EXTRA_PLUGIN_RESULT_BUNDLE_ERRMSG_FALLBACK,
                )
            } else {
                // Fallback for devices/versions sending values directly in intent extras.
                stdout = pickString(intent.extras, EXTRA_PLUGIN_RESULT_BUNDLE_STDOUT, EXTRA_PLUGIN_RESULT_BUNDLE_STDOUT_FALLBACK)
                stderr = pickString(intent.extras, EXTRA_PLUGIN_RESULT_BUNDLE_STDERR, EXTRA_PLUGIN_RESULT_BUNDLE_STDERR_FALLBACK)
                exitCode = pickInt(intent.extras, EXTRA_PLUGIN_RESULT_BUNDLE_EXIT_CODE, EXTRA_PLUGIN_RESULT_BUNDLE_EXIT_CODE_FALLBACK, 0)
                errCode = pickInt(intent.extras, EXTRA_PLUGIN_RESULT_BUNDLE_ERR, EXTRA_PLUGIN_RESULT_BUNDLE_ERR_FALLBACK, Activity.RESULT_OK)
                errMsg = pickString(intent.extras, EXTRA_PLUGIN_RESULT_BUNDLE_ERRMSG, EXTRA_PLUGIN_RESULT_BUNDLE_ERRMSG_FALLBACK)
            }

            val outputParts = mutableListOf<String>()
            if (stdout.isNotBlank()) {
                outputParts.add(stdout.trimEnd())
            }
            if (stderr.isNotBlank()) {
                outputParts.add(stderr.trimEnd())
            }
            if (errCode != Activity.RESULT_OK && errMsg.isNotBlank()) {
                outputParts.add("Termux error ($errCode): $errMsg")
            }
            if (outputParts.isEmpty()) {
                outputParts.add("Exit code: $exitCode")
            }

            methodResult.success(outputParts.joinToString("\n"))
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)

        val filter = IntentFilter(ACTION_TERMUX_RESULT)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(termuxResultReceiver, filter, RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("DEPRECATION")
            registerReceiver(termuxResultReceiver, filter)
        }
    }

    override fun onDestroy() {
        try {
            unregisterReceiver(termuxResultReceiver)
        } catch (_: Exception) {
        }
        super.onDestroy()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "runCommand" -> {
                        val command = call.argument<String>("command") ?: ""
                        val workingDir = call.argument<String>("workingDir")
                            ?: "/data/data/com.termux/files/home"

                        try {
                            runTermuxCommand(command, workingDir, result)
                        } catch (error: Exception) {
                            result.error("TERMUX_ERROR", error.message, null)
                        }
                    }
                    "hasRunCommandPermission" -> {
                        result.success(hasRunCommandPermission())
                    }
                    "requestRunCommandPermission" -> {
                        requestRunCommandPermission(result)
                    }
                    "openAppSettings" -> {
                        openAppSettings()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode != REQUEST_RUN_COMMAND_PERMISSION) {
            return
        }

        val pendingResult = permissionRequestResult ?: return
        permissionRequestResult = null
        val granted = grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED
        pendingResult.success(granted)
    }

    private fun runTermuxCommand(
        command: String,
        workingDir: String,
        result: MethodChannel.Result,
    ) {
        val executionId = executionCounter.incrementAndGet()

        val callbackIntent = Intent(ACTION_TERMUX_RESULT).apply {
            `package` = packageName
            putExtra(EXTRA_EXECUTION_ID, executionId)
        }

        val pendingIntentFlags = PendingIntent.FLAG_ONE_SHOT or
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) PendingIntent.FLAG_MUTABLE else 0

        val pendingIntent = PendingIntent.getBroadcast(
            this,
            executionId,
            callbackIntent,
            pendingIntentFlags,
        )

        val intent = Intent().apply {
            setClassName("com.termux", "com.termux.app.RunCommandService")
            action = "com.termux.RUN_COMMAND"
            putExtra("com.termux.RUN_COMMAND_PATH", "/data/data/com.termux/files/usr/bin/bash")
            putExtra("com.termux.RUN_COMMAND_ARGUMENTS", arrayOf("-c", command))
            putExtra("com.termux.RUN_COMMAND_WORKDIR", workingDir)
            // Prefer explicit runner because RUN_COMMAND_BACKGROUND is deprecated in newer Termux.
            putExtra("com.termux.RUN_COMMAND_RUNNER", "app-shell")
            putExtra("com.termux.RUN_COMMAND_BACKGROUND", true)
            putExtra("com.termux.RUN_COMMAND_PENDING_INTENT", pendingIntent)
        }

        pendingResults[executionId] = result

        val timeoutRunnable = Runnable {
            val timedOutResult = pendingResults.remove(executionId) ?: return@Runnable
            timeoutRunnables.remove(executionId)
            timedOutResult.success(
                "No output received yet. Check Termux setup: allow-external-apps=true, " +
                    "RUN_COMMAND permission granted, and Termux opened at least once."
            )
        }

        timeoutRunnables[executionId] = timeoutRunnable
        mainHandler.postDelayed(timeoutRunnable, COMMAND_TIMEOUT_MS)

        try {
            startService(intent)
        } catch (error: SecurityException) {
            pendingResults.remove(executionId)
            timeoutRunnables.remove(executionId)?.let { mainHandler.removeCallbacks(it) }
            result.success(
                "Missing permission: $TERMUX_RUN_COMMAND_PERMISSION. " +
                    "Grant it in Android Settings -> Apps -> DevDroid -> Permissions -> Additional permissions."
            )
        } catch (error: Exception) {
            pendingResults.remove(executionId)
            timeoutRunnables.remove(executionId)?.let { mainHandler.removeCallbacks(it) }
            throw error
        }
    }

    companion object {
        private const val ACTION_TERMUX_RESULT = "com.example.devdroid.TERMUX_RESULT"
        private const val EXTRA_EXECUTION_ID = "execution_id"
        private const val TERMUX_RUN_COMMAND_PERMISSION = "com.termux.permission.RUN_COMMAND"
        private const val REQUEST_RUN_COMMAND_PERMISSION = 3109

        private const val EXTRA_PLUGIN_RESULT_BUNDLE = "com.termux.app.extra.RESULT_BUNDLE"
        private const val EXTRA_PLUGIN_RESULT_BUNDLE_FALLBACK = "result"
        private const val EXTRA_PLUGIN_RESULT_BUNDLE_STDOUT = "stdout"
        private const val EXTRA_PLUGIN_RESULT_BUNDLE_STDOUT_FALLBACK = "com.termux.app.extra.RESULT_STDOUT"
        private const val EXTRA_PLUGIN_RESULT_BUNDLE_STDERR = "stderr"
        private const val EXTRA_PLUGIN_RESULT_BUNDLE_STDERR_FALLBACK = "com.termux.app.extra.RESULT_STDERR"
        private const val EXTRA_PLUGIN_RESULT_BUNDLE_EXIT_CODE = "exitCode"
        private const val EXTRA_PLUGIN_RESULT_BUNDLE_EXIT_CODE_FALLBACK = "com.termux.app.extra.RESULT_EXIT_CODE"
        private const val EXTRA_PLUGIN_RESULT_BUNDLE_ERR = "err"
        private const val EXTRA_PLUGIN_RESULT_BUNDLE_ERR_FALLBACK = "com.termux.app.extra.RESULT_ERR"
        private const val EXTRA_PLUGIN_RESULT_BUNDLE_ERRMSG = "errmsg"
        private const val EXTRA_PLUGIN_RESULT_BUNDLE_ERRMSG_FALLBACK = "com.termux.app.extra.RESULT_ERRMSG"

        private const val COMMAND_TIMEOUT_MS = 120_000L
    }

    private fun hasRunCommandPermission(): Boolean {
        return ContextCompat.checkSelfPermission(this, TERMUX_RUN_COMMAND_PERMISSION) == PackageManager.PERMISSION_GRANTED
    }

    private fun requestRunCommandPermission(result: MethodChannel.Result) {
        if (hasRunCommandPermission()) {
            result.success(true)
            return
        }

        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) {
            result.success(false)
            return
        }

        if (permissionRequestResult != null) {
            result.success(false)
            return
        }

        permissionRequestResult = result
        requestPermissions(arrayOf(TERMUX_RUN_COMMAND_PERMISSION), REQUEST_RUN_COMMAND_PERMISSION)
    }

    private fun openAppSettings() {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
            data = Uri.fromParts("package", packageName, null)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    private fun pickString(bundle: android.os.Bundle?, primary: String, fallback: String): String {
        if (bundle == null) return ""
        return bundle.getString(primary)
            ?: bundle.getString(fallback)
            ?: ""
    }

    private fun pickInt(bundle: android.os.Bundle?, primary: String, fallback: String, defaultValue: Int): Int {
        if (bundle == null) return defaultValue
        return if (bundle.containsKey(primary)) {
            bundle.getInt(primary, defaultValue)
        } else {
            bundle.getInt(fallback, defaultValue)
        }
    }
}
