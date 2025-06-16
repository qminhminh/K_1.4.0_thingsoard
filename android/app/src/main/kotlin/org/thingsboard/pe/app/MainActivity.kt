package com.nedok.NedokCamera

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity()  {

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        registerTbWebAuth(flutterEngine)
    }

    fun registerTbWebAuth(flutterEngine: FlutterEngine) {
        val channel = MethodChannel(flutterEngine.dartExecutor, "tb_web_auth")
        channel.setMethodCallHandler(TbWebAuthHandler(this))
    }

}
