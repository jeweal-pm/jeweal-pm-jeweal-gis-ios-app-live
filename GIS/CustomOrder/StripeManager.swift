//
//  StripeManager.swift
//  GIS
//
//  Created by Mayank Sharma on 23/12/24.
//  Copyright © 2024 Hawkscode. All rights reserved.
//

//
//import Foundation
//import Stripe
//import UIKit
//import StripePaymentSheet
//
///// A singleton class to manage Stripe payments.
//class StripeManager {
//    static let shared = StripeManager()
//
//    private init() {}
//
//    /// Set up Stripe with the publishable key.
//    func configureStripe(publishableKey: String) {
//        StripeAPI.defaultPublishableKey = publishableKey
//    }
//
//    /// Present the Stripe PaymentSheet for payment.
//    func presentPaymentSheet(clientSecret: String, paymentIntent: String, viewController: UIViewController, completion: @escaping (Result<PaymentSheetResult, Error>) -> Void) {
//        // Log details for debugging
//        print("Stripe PaymentSheet Debug Info:")
//        print("- Client Secret: \(clientSecret)")
//        print("- Payment Intent ID: \(paymentIntent)")
//
//        // Configure the PaymentSheet
//        var configuration = PaymentSheet.Configuration()
//        configuration.merchantDisplayName = "Mayank"
//
//        // Create the PaymentSheet instance using the provided client secret
//        let paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)
//
//        // Present the PaymentSheet UI
//        paymentSheet.present(from: viewController) { paymentResult in
//            switch paymentResult {
//            case .completed:
//                print("PaymentSheet Result: Payment succeeded.")
//                completion(.success(paymentResult))
//
//            case .failed(let error):
//                print("PaymentSheet Result: Payment failed with error.")
//                print("Error Details:")
//                print("- Error Description: \(error.localizedDescription)")
//                if let stripeError = error as? NSError {
//                    print("- Error Domain: \(stripeError.domain)")
//                    print("- Error Code: \(stripeError.code)")
//                    print("- Error UserInfo: \(stripeError.userInfo)")
//                }
//                completion(.failure(error))
//
//            case .canceled:
//                print("PaymentSheet Result: Payment was canceled by the user.")
//                let canceledError = NSError(domain: "StripeManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Payment was canceled."])
//                completion(.failure(canceledError))
//            }
//        }
//    }
//    func fetchPaymentIntentDetails(clientSecret: String) {
//        let client = STPAPIClient.shared
//        client.retrievePaymentIntent(withClientSecret: clientSecret) { paymentIntent, error in
//            if let error = error {
//                print("Error retrieving Payment Intent: \(error.localizedDescription)")
//                return
//            }
//            
//            if let paymentIntent = paymentIntent {
//                print("Payment Intent Status: \(paymentIntent.status.rawValue)")
//                if let lastPaymentError = paymentIntent.lastPaymentError {
//                    print("Last Payment Error: \(lastPaymentError.message ?? "No error message")")
//                    print("Payment Error Code: \(lastPaymentError.code ?? "No code")")
//                }
//            }
//        }
//    }
//
//}
//
// 


 
import Foundation
import Stripe
import UIKit
import StripePaymentSheet

/// A singleton class to manage Stripe payments.
class StripeManager {
    static let shared = StripeManager()

    private init() {}

    /// Set up Stripe with the publishable key.
    func configureStripe(publishableKey: String) {
        StripeAPI.defaultPublishableKey = publishableKey
    }

    /// Present the Stripe PaymentSheet for payment.
    func presentPaymentSheet(clientSecret: String, viewController: UIViewController, completion: @escaping (Result<PaymentSheetResult, Error>) -> Void) {
        // Log details for debugging
        print("Stripe PaymentSheet Debug Info:")
        print("- Client Secret: \(clientSecret)")

        // Configure the PaymentSheet
        var configuration = PaymentSheet.Configuration()
 
        // Create the PaymentSheet instance using the provided client secret
        let paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: configuration)

        // Present the PaymentSheet UI
        paymentSheet.present(from: viewController) { paymentResult in
            switch paymentResult {
            case .completed:
                print("Payment succeeded.")
                completion(.success(paymentResult))

            case .failed(let error):
                print("Payment failed with error: \(error.localizedDescription)")
                // Fetch payment intent details for debugging
                self.fetchPaymentIntentDetails(clientSecret: clientSecret)
                completion(.failure(error))

            case .canceled:
                print("Payment was canceled by the user.")
                let canceledError = NSError(domain: "StripeManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "Payment was canceled."])
                completion(.failure(canceledError))
            }
        }
    }

    /// Fetch PaymentIntent details using the client secret
    func fetchPaymentIntentDetails(clientSecret: String) {
        let client = STPAPIClient.shared
        client.retrievePaymentIntent(withClientSecret: clientSecret) { paymentIntent, error in
            if let error = error {
                print("Error retrieving Payment Intent: \(error.localizedDescription)")
                return
            }
            
            if let paymentIntent = paymentIntent {
                print("Payment Intent Status: \(paymentIntent.status.rawValue)")
                
                if let lastPaymentError = paymentIntent.lastPaymentError {
                    print("Last Payment Error: \(lastPaymentError.message ?? "No error message")")
                    print("Error Code: \(lastPaymentError.code ?? "No code")")
                    print("Error Type: \(lastPaymentError.type.rawValue)")
                }
            }
        }
    }

    
 
}

