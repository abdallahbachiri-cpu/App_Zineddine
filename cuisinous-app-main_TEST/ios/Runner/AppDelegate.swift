import Flutter
import UIKit
import GoogleMaps
import Stripe  

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyDZmv9tvMdw3rHZRtUA4-_GTc2A02fXk_A")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }


  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    StripeAPI.defaultPublishableKey = "pk_test_51SsAlALq8wr0gdZNcypS5QzPO280LOUpeHhU2eebuKLbyyxmjEKPc3bgrp984ZQCVf9XJzz8qfKCr9a2x1r6VN1u00Swp7DvNe"
    return StripeAPI.handleURLCallback(with: url)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}