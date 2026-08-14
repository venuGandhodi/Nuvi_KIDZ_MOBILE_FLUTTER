package com.nuvikidz.nuvi_kidz

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.shopify.checkoutkit.ShopifyCheckoutSheetKit
import com.shopify.checkoutkit.CheckoutCallback
import com.shopify.checkoutkit.CheckoutCompletedEvent
import com.shopify.checkoutkit.CheckoutError

class MainActivity : FlutterActivity(), CheckoutCallback {
    private var checkoutChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        checkoutChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.nuvikidz/checkout")
        checkoutChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "preloadCheckout" -> {
                    val checkoutUrl = call.argument<String>("checkoutUrl")
                    if (checkoutUrl != null) {
                        ShopifyCheckoutSheetKit.preload(checkoutUrl, this)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "Missing checkoutUrl", null)
                    }
                }
                "presentCheckout" -> {
                    val checkoutUrl = call.argument<String>("checkoutUrl")
                    if (checkoutUrl != null) {
                        ShopifyCheckoutSheetKit.present(checkoutUrl, this, this)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGS", "Missing checkoutUrl", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onCheckoutCompleted(checkoutCompletedEvent: CheckoutCompletedEvent) {
        val orderId = checkoutCompletedEvent.orderDetails.id
        checkoutChannel?.invokeMethod("onCheckoutCompleted", mapOf("orderId" to orderId))
    }

    override fun onCheckoutCanceled() {
        checkoutChannel?.invokeMethod("onCheckoutCancelled", null)
    }

    override fun onCheckoutFailed(error: CheckoutError) {
        checkoutChannel?.invokeMethod("onCheckoutFailed", mapOf("message" to error.message))
    }
}
