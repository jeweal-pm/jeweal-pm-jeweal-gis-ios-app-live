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
}
