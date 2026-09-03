

import UIKit

import NVActivityIndicatorView
import MaterialComponents.MaterialSnackbar




import SystemConfiguration

class RectangleDash: UIView {

    
    
    @IBInspectable var dashWidth: CGFloat = 0
    @IBInspectable var dashColor: UIColor = .clear
    @IBInspectable var dashLength: CGFloat = 0
    @IBInspectable var betweenDashesSpace: CGFloat = 0
    
    var dashBorder: CAShapeLayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dashBorder?.removeFromSuperlayer()
        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = dashWidth
        dashBorder.strokeColor = dashColor.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
        self.dashBorder = dashBorder
    }

}


public class Reachability {
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        guard let defaultRouteReachability = defaultRouteReachability else { return false }
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return false
        }
        
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
        
    }
}

extension UIView {
    func showToastss(toastMessage:String,duration:CGFloat) {

        let bgView = UIView(frame: self.frame)
        bgView.backgroundColor = UIColor(red: CGFloat(255.0/255.0), green: CGFloat(255.0/255.0), blue: CGFloat(255.0/255.0), alpha: CGFloat(0.6))
        bgView.tag = 555
        

        let lblMessage = UILabel()
        lblMessage.numberOfLines = 0
        lblMessage.lineBreakMode = .byWordWrapping
        lblMessage.textColor = .white
        lblMessage.backgroundColor = .black
        lblMessage.textAlignment = .center
        lblMessage.font = UIFont.init(name: "Helvetica Neue", size: 17)
        lblMessage.text = toastMessage
        
        let maxSizeTitle : CGSize = CGSize(width: self.bounds.size.width-16, height: self.bounds.size.height)
        var expectedSizeTitle : CGSize = lblMessage.sizeThatFits(maxSizeTitle)

        expectedSizeTitle = CGSize(width:maxSizeTitle.width.getminimum(value2:expectedSizeTitle.width), height: maxSizeTitle.height.getminimum(value2:expectedSizeTitle.height))
        lblMessage.frame = CGRect(x:((self.bounds.size.width)/2) - ((expectedSizeTitle.width+16)/2) , y: (self.bounds.size.height/2) - ((expectedSizeTitle.height+16)/2), width: expectedSizeTitle.width+16, height: expectedSizeTitle.height+16)
        lblMessage.layer.cornerRadius = 8
        lblMessage.layer.masksToBounds = true
        lblMessage.padding = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        bgView.addSubview(lblMessage)
        self.addSubview(bgView)
        lblMessage.alpha = 0
        
        UIView.animateKeyframes(withDuration:TimeInterval(duration) , delay: 0, options: [] , animations: {
            lblMessage.alpha = 1
        }, completion: {
            sucess in
            UIView.animate(withDuration:TimeInterval(duration), delay: 8, options: [] , animations: {
                lblMessage.alpha = 0
                bgView.alpha = 0
            })
            bgView.removeFromSuperview()
        })
    }
}

extension CGFloat {
    func getminimum(value2:CGFloat)->CGFloat {
        if self < value2 {
            return self
        }
        else {
            return value2
        }
    }
}

//MARK: Extension on UILabel for adding insets - for adding padding in top, bottom, right, left.
extension UIViewController{
    
    func hidekeyboardwhenTappedAround(){
        
        let tap =  UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing(_:))
        )
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
}

extension UILabel {
    private struct AssociatedKeys {
        static var padding = UIEdgeInsets()
    }
    
    var padding: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    override open func draw(_ rect: CGRect) {
        if let insets = padding {
            self.drawText(in: rect.inset(by: insets))
        } else {
            self.drawText(in: rect)
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        get {
            var contentSize = super.intrinsicContentSize
            if let insets = padding {
                contentSize.height += insets.top + insets.bottom
                contentSize.width += insets.left + insets.right
            }
            return contentSize
        }
    }
}

public class Node {
    static let kUsers = "Users"
    static let kMessageStore = "Messages_Store"
    static let kNotification = "notifications"
}

var mSESSION = ""
class CommonClass: NSObject {
    
    class func sessionExpired(isExpired : Bool, navigation:UINavigationController?) {
        
        guard let navController = navigation else {return}
        
        if mSESSION == "" {
            if isExpired {
                mSESSION = "1"
                AppLanguage.shared.set(index: .english)
                showSnackBar(message: "Session Expired!")
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                if let home = storyBoard.instantiateViewController(withIdentifier: "LoginController") as? LoginController {
                    navController.pushViewController(home, animated:true)
                }
            }
            
        }
    }
    
    class func showAlertView(strMessage : String) {
        let alertMessage = UIAlertController(title:"Alert", message: strMessage, preferredStyle: UIAlertController.Style.alert)
        alertMessage.addAction(UIAlertAction(title:"OK", style: UIAlertAction.Style.default, handler: nil))
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
           let rootViewController = appDelegate.window?.rootViewController {
          rootViewController.present(alertMessage, animated: true, completion: nil)
        }
    }

  
    
    class func showSnackBar(message: String) {
        
        let messageLine = MDCSnackbarMessage()
        messageLine.text = message
        MDCSnackbarManager.default.show(messageLine)
        MDCSnackbarManager.default.snackbarMessageViewBackgroundColor = #colorLiteral(red: 0.7725490196, green: 0.9019607843, blue: 0.8745098039, alpha: 1)
        MDCSnackbarManager.default.messageTextColor = #colorLiteral(red: 0, green: 0.4463768005, blue: 0.5147035718, alpha: 1)
         
         
    }
    
    class func showAndToast(controller: UIViewController, message: String , seconds: Double){
        
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert , animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds){
            
            alert.dismiss(animated: true)
        }
        
    }
    
    
    class func isValidEmail(emailString:String) -> Bool
    {
         let emailRegEx = "^[a-zA-Z0-9..!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
         let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
         return emailTest.evaluate(with: emailString)
     }
    
    
    
    class func impactFG(feedbackStyle:UIImpactFeedbackGenerator.FeedbackStyle)
    {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: feedbackStyle)
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()
    }
    
    class func notificationFG(feedbackType:UINotificationFeedbackGenerator.FeedbackType)
    {
        let notificationFeedbackGenerator = UINotificationFeedbackGenerator()
        notificationFeedbackGenerator.prepare()
        notificationFeedbackGenerator.notificationOccurred(feedbackType)
    }
    
    class func animateTable(tableView: UITableView)
    {
        tableView.reloadData()
        
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells
        {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1, delay: 0.05 * Double(index), usingSpringWithDamping: 0.6, initialSpringVelocity: 0, animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }
    
    static var darkview = UIView()
    static var transparentView = UIView()
    
//    class func showFullLoader(view userView: UIView) {
//        darkview.isHidden = false
//        darkview = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
//        darkview.backgroundColor = UIColor.black.withAlphaComponent(0.3)
//        
//        var loaderView = NVActivityIndicatorView(frame: CGRect(x: UIScreen.main.bounds.width/2-25, y: UIScreen.main.bounds.height/2, width: 40, height: 40))
//        loaderView.type = .circleStrokeSpin
//        loaderView.color = .white
//        userView.addSubview(darkview)
//        darkview.addSubview(loaderView)
//        loaderView.startAnimating()
//    }
    
    class func showFullLoader(view userView: UIView) {

        darkview.removeFromSuperview()

        darkview = UIView(frame: UIScreen.main.bounds)
        darkview.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        darkview.isUserInteractionEnabled = true   // รับ Touch ทั้งหมด

        let loaderView = NVActivityIndicatorView(
            frame: CGRect(
                x: UIScreen.main.bounds.midX - 20,
                y: UIScreen.main.bounds.midY - 20,
                width: 40,
                height: 40
            )
        )

        loaderView.type = .circleStrokeSpin
        loaderView.color = .white

        darkview.addSubview(loaderView)

        if let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?
            .windows
            .first(where: { $0.isKeyWindow }) {

            window.addSubview(darkview)
        }

        loaderView.startAnimating()
    }
    
    class func showHalfLoader(view userView: UIView) {
        transparentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        transparentView.backgroundColor = UIColor.clear
        userView.addSubview(transparentView)
        
        darkview.isHidden = false
        darkview = UIView(frame: CGRect(x: UIScreen.main.bounds.width/2-25, y: UIScreen.main.bounds.height/2-25, width: 50, height: 50))
        darkview.backgroundColor = UIColor.white.withAlphaComponent(1)
        darkview.layer.cornerRadius = 25
        darkview.layer.borderColor = UIColor.lightGray.cgColor
        darkview.layer.borderWidth = 0.2
        
        var loaderView = NVActivityIndicatorView(frame: CGRect(x: darkview.bounds.width/2-15, y: darkview.bounds.height/2-15, width: 30, height: 30))
        loaderView.type = .circleStrokeSpin //ballClipRotate
        loaderView.color = green
        transparentView.addSubview(darkview)
        darkview.addSubview(loaderView)
        loaderView.startAnimating()
    }
    
    class func showLoader(view userView: UIView) {
        transparentView.frame = userView.bounds  // Cover the entire userView
        transparentView.backgroundColor = UIColor.clear
        userView.addSubview(transparentView)
        
        let loaderView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))  // Set initial frame
        loaderView.center = transparentView.center  // Center the loaderView
        loaderView.type = .circleStrokeSpin //ballClipRotate
        loaderView.color = UIColor.white
        transparentView.addSubview(loaderView)
        loaderView.startAnimating()
    }

    class func stopLoader() {
        DispatchQueue.main.async {
            darkview.isHidden = true
            darkview.removeFromSuperview()
            transparentView.removeFromSuperview()
        }
    }
    
    class func makeNavigationBarTransparent(_ viewController:UIViewController)
    {
        viewController.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        viewController.navigationController?.navigationBar.shadowImage = UIImage()
        viewController.navigationController?.navigationBar.isTranslucent = true
        viewController.navigationController?.view.backgroundColor = UIColor.clear
    }
}


class DisabledOverlayView: UIView {
    //Add this view to disable views.
    var targetView: UIView
    
    init(on targetView: UIView) {
        self.targetView = targetView
        super.init(frame: targetView.frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = UIColor.black.withAlphaComponent(0.2)
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        let radius = targetView.cornerRadius
        layer.cornerRadius = radius
        
        let lockImageView = UIImageView(image: UIImage(systemName: "lock.fill"))
        lockImageView.tintColor = .white
        lockImageView.contentMode = .scaleAspectFit
        lockImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(lockImageView)
        
        NSLayoutConstraint.activate([
            lockImageView.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            lockImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            lockImageView.widthAnchor.constraint(equalToConstant: 20),
            lockImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frame = targetView.bounds
    }
    
    @objc private func handleTap() {}
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? { return self }
}
