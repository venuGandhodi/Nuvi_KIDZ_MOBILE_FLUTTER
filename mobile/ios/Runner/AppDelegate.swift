import Flutter
import UIKit
import ShopifyCheckoutSheetKit

public class ShopifyCheckoutPlugin: NSObject, FlutterPlugin, CheckoutDelegate {
  private let channel: FlutterMethodChannel
  // Guards against presenting a second checkout sheet on top of one that's
  // already open — without this, topViewController() below finds the
  // already-presented sheet and stacks a new one on top of it, so tapping
  // the close (X) button only dismisses the top layer and the original
  // sheet reappears underneath, looking like "close doesn't work."
  private var isPresentingCheckout = false
  // The view controller checkout was presented from — Shopify's SDK does not
  // dismiss its sheet automatically on cancel/complete/fail; per Shopify's
  // own docs, checkoutDidCancel() is "used to call dismiss(animated:)". This
  // was missing, which is why tapping the sheet's close (X) button visually
  // did nothing: the SDK notified us the checkout was cancelled, but nothing
  // ever told UIKit to dismiss the presented view controller.
  private weak var presentingViewController: UIViewController?

  public static func register(with registrar: FlutterPluginRegistrar) {
    print("[NUVI-IOS-CHECKOUT] Registering checkout MethodChannel")
    let channel = FlutterMethodChannel(name: "com.nuvikidz/checkout", binaryMessenger: registrar.messenger())
    let instance = ShopifyCheckoutPlugin(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
    print("[NUVI-IOS-CHECKOUT] Checkout MethodChannel registered")
  }

  init(channel: FlutterMethodChannel) {
    self.channel = channel
    super.init()
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    print("[NUVI-IOS-CHECKOUT] Received method: \(call.method)")

    switch call.method {
    case "preloadCheckout":
      guard let args = call.arguments as? [String: Any],
            let urlString = args["checkoutUrl"] as? String,
            let url = URL(string: urlString) else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing or invalid checkoutUrl", details: nil))
        return
      }
      print("[NUVI-IOS-CHECKOUT] Preloading Shopify Checkout")
      ShopifyCheckoutSheetKit.preload(checkout: url)
      result(true)

    case "presentCheckout":
      guard let args = call.arguments as? [String: Any],
            let urlString = args["checkoutUrl"] as? String,
            let url = URL(string: urlString) else {
        result(FlutterError(code: "INVALID_ARGS", message: "Missing or invalid checkoutUrl", details: nil))
        return
      }

      if isPresentingCheckout {
        print("[NUVI-IOS-CHECKOUT] Ignoring presentCheckout: a checkout sheet is already open")
        result(true)
        return
      }

      guard let rootVC = topViewController() else {
        print("[NUVI-IOS-CHECKOUT] ERROR: Root view controller not found")
        result(FlutterError(code: "NO_ROOT_VC", message: "Root view controller not found", details: nil))
        return
      }

      print("[NUVI-IOS-CHECKOUT] Presenting Shopify Checkout")
      isPresentingCheckout = true
      presentingViewController = rootVC
      DispatchQueue.main.async {
        ShopifyCheckoutSheetKit.present(checkout: url, from: rootVC, delegate: self)
      }
      result(true)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func topViewController() -> UIViewController? {
    let keyWindow = UIApplication.shared.connectedScenes
      .filter { $0.activationState == .foregroundActive }
      .compactMap { $0 as? UIWindowScene }
      .first?.windows
      .filter { $0.isKeyWindow }
      .first
      ?? UIApplication.shared.windows.first(where: { $0.isKeyWindow })
      ?? UIApplication.shared.keyWindow

    var topVC = keyWindow?.rootViewController
    while let presented = topVC?.presentedViewController {
      topVC = presented
    }
    return topVC
  }

  // MARK: - CheckoutDelegate

  public func checkoutDidComplete(event: CheckoutCompletedEvent) {
    print("[NUVI-IOS-CHECKOUT] checkoutDidComplete")
    isPresentingCheckout = false
    presentingViewController?.dismiss(animated: true)
    let orderId = event.orderDetails.id
    channel.invokeMethod("onCheckoutCompleted", arguments: ["orderId": orderId])
  }

  public func checkoutDidCancel() {
    print("[NUVI-IOS-CHECKOUT] checkoutDidCancel")
    isPresentingCheckout = false
    presentingViewController?.dismiss(animated: true)
    channel.invokeMethod("onCheckoutCancelled", arguments: nil)
  }

  public func checkoutDidFail(error: CheckoutError) {
    print("[NUVI-IOS-CHECKOUT] checkoutDidFail: \(error.localizedDescription)")
    isPresentingCheckout = false
    presentingViewController?.dismiss(animated: true)
    channel.invokeMethod("onCheckoutFailed", arguments: ["message": error.localizedDescription])
  }

  public func shouldRecoverFromError(error: CheckoutError) -> Bool {
    return error.isRecoverable
  }

  public func checkoutDidClickLink(url: URL) {
    if UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url)
    }
  }

  public func checkoutDidEmitWebPixelEvent(event: PixelEvent) {
    // Web Pixel telemetry
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    print("[NUVI-IOS-CHECKOUT] AppDelegate startup")
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = self.registrar(forPlugin: "ShopifyCheckoutPlugin") {
      ShopifyCheckoutPlugin.register(with: registrar)
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
