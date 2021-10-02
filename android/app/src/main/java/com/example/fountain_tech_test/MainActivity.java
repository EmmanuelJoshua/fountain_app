package com.example.fountain_tech_test;

import android.content.Intent;
import android.content.ClipData;
import android.content.ContentResolver;
import android.content.res.AssetFileDescriptor;
import android.net.Uri;
import android.os.Bundle;

import java.io.*;

import androidx.annotation.NonNull;

import io.flutter.plugin.common.MethodChannel;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private String sharedURI;
  private static final String CHANNEL = "app.channel.shared.data";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    Intent intent = getIntent();
    String action = intent.getAction();
    String type = intent.getType();

    if (Intent.ACTION_SEND.equals(action) && type != null) {
      if ("*/*".equals(type) || "text/xml".equals(type)) {
        handleSendURI(intent); // Handle text being sent
      }
    }
  }

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
      GeneratedPluginRegistrant.registerWith(flutterEngine);

      new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
              .setMethodCallHandler(
                      (call, result) -> {
                          if (call.method.contentEquals("getSharedURI")) {
                              result.success(sharedURI);
                              sharedURI = null;
                          }
                      }
              );
  }

  void handleSendURI(Intent intent) {

        Uri uri = intent.getParcelableExtra(Intent.EXTRA_STREAM);

         sharedURI = uri.toString();

  }
}
