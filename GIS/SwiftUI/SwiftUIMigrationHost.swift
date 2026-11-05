import UIKit
import SwiftUI

enum GISSwiftUIMigrationHost {
    static func push<Content: View>(
        _ content: Content,
        from viewController: UIViewController,
        animated: Bool = true
    ) {
        let hostingController = UIHostingController(rootView: content)
        hostingController.hidesBottomBarWhenPushed = true
        viewController.navigationController?.pushViewController(hostingController, animated: animated)
    }

    /// Keeps the existing UIKit routes as the coordinator while the Profile UI
    /// itself is migrated. Each destination remains the same storyboard screen.
    static func pushProfile(from viewController: UIViewController) {
        let defaults = UserDefaults.standard
        let profile = GISProfileSummary(
            userName: defaults.string(forKey: "userName") ?? "",
            storeName: defaults.string(forKey: "store_name") ?? defaults.string(forKey: "location_name") ?? ""
        )

        push(
            GISProfileView(
                profile: profile,
                onBack: { [weak viewController] in
                    viewController?.navigationController?.popViewController(animated: true)
                },
                onCustomerProfile: { [weak viewController] in
                    pushCustomerSearch(from: viewController)
                },
                onPurchaseHistory: { [weak viewController] in
                    pushCustomerSearch(from: viewController)
                },
                onPayment: { [weak viewController] in
                    pushCustomerSearch(from: viewController)
                },
                onWishlist: { [weak viewController] in
                    guard let viewController,
                          let wishlist = UIStoryboard(name: "Main", bundle: nil)
                            .instantiateViewController(withIdentifier: "WishListController") as? WishListController
                    else { return }
                    viewController.navigationController?.pushViewController(wishlist, animated: true)
                },
                onSettings: { [weak viewController] in
                    guard let viewController else { return }
                    push(
                        GISSettingsView(onBack: { [weak viewController] in
                            viewController?.navigationController?.popViewController(animated: true)
                        }),
                        from: viewController
                    )
                }
            ),
            from: viewController
        )
    }

    private static func pushCustomerSearch(from viewController: UIViewController?) {
        guard let viewController,
              let customerSearch = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "CustomerSearch") as? CustomerSearch
        else { return }
        viewController.navigationController?.pushViewController(customerSearch, animated: true)
    }
}
