package dev.flutter.plugins.integration_test;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.FlutterPlugin.FlutterPluginBinding;

/**
 * Release-only no-op stub.
 *
 * Flutter can regenerate GeneratedPluginRegistrant.java with dev-only native
 * test plugins after integration-test tooling has run. Release builds do not
 * include those dev plugin classes on the classpath, so this stub lets the
 * generated registrant compile without shipping test behavior.
 */
public final class IntegrationTestPlugin implements FlutterPlugin {
  @Override
  public void onAttachedToEngine(FlutterPluginBinding binding) {}

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {}
}
