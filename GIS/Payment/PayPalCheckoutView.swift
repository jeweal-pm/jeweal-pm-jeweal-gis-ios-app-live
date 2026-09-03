import SwiftUI

struct PayPalCheckoutView: View {

    let showCreditCardButton: Bool

    var paypalAction: (() -> Void)?
    var creditCardAction: (() -> Void)?

    var body: some View {

        VStack(spacing: 10) {

            Button {

                paypalAction?()

            } label: {

                Image("paypal_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        Color(
                            red: 1.0,
                            green: 0.77,
                            blue: 0.0
                        )
                    )
                    .cornerRadius(4)

            }

            if showCreditCardButton {

                Button {

                    creditCardAction?()

                } label: {

                    HStack {

                        Image(systemName: "creditcard")

                        Text("Debit or Credit Card")

                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color.black)
                    .cornerRadius(4)

                }
            }

            HStack(spacing: 0) {

                Text("Powered by ")
                    .foregroundColor(.gray)

                Text("PayPal")
                    .foregroundColor(
                        Color(
                            red: 0.0,
                            green: 0.19,
                            blue: 0.56
                        )
                    )

            }
            .font(.caption)
        }
        .padding()
        .background(Color.white)
    }
}
