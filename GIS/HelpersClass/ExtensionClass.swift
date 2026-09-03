

import Foundation
import UIKit

//MARK:- UIView Extension for border color, border width and corner redius
class Animations {
    static func requireUserAtencion(on onView: UIView) {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: onView.center.x - 10, y: onView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: onView.center.x + 10, y: onView.center.y))
        onView.layer.add(animation, forKey: "position")
    }
}

@IBDesignable extension UIView
{
    @IBInspectable var masksToBounds: Bool
    {
        get
        { return layer.masksToBounds }
        set(value)
        { layer.masksToBounds = value }
    }
    
    @IBInspectable var borderColor:UIColor?
    {
        set
        { layer.borderColor = newValue!.cgColor }
        get
        {
            if layer.borderColor != nil
            { return UIColor(cgColor: layer.borderColor!) }
            else
            { return nil }
        }
    }
    
    @IBInspectable var borderWidth:CGFloat
    {
        set
        { layer.borderWidth = newValue }
        get
        { return layer.borderWidth }
    }
    
    @IBInspectable var cornerRadius:CGFloat
    {
        set
        {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get
        { return layer.cornerRadius }
    }
    
    /// The color of the shadow applied to the view
    @IBInspectable public var shadowColor: UIColor
    {
        get
        { return UIColor(cgColor: layer.shadowColor!) }
        set
        { layer.shadowColor = newValue.cgColor }
    }
    
    /// The offet of the shadow in the form (x, y)
    @IBInspectable public var shadowOffset: CGSize
    {
        get
        { return layer.shadowOffset }
        set
        { layer.shadowOffset = newValue }
    }
    
    /// The blur of the shadown
    @IBInspectable public var shadowRadius: CGFloat
    {
        get
        { return layer.shadowRadius }
        set
        { layer.shadowRadius = newValue }
    }
    
    /// The opacity of the shadow applied to the view
    @IBInspectable public var shadowOpacity: Float
    {
        get
        { return layer.shadowOpacity }
        set
        {
            layer.shadowOpacity = newValue
            layer.masksToBounds = false
        }
    }
    
    func setGradientBackground(firstColor: UIColor, secondColor: UIColor, cornerRadius: CGFloat)
    {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = cornerRadius
        gradientLayer.colors = [secondColor.cgColor, firstColor.cgColor ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.0)
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setImageWithText(title: String, message: String, image: UIImage, yPosition: CGFloat)
    {
        let customView = UIView(frame: CGRect.init(x: 0, y: yPosition, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let imageView = UIImageView(frame: CGRect.init(x: self.bounds.size.width/2-100, y: 0, width: 200, height: 200))
        imageView.image = image
        imageView.contentMode = .scaleAspectFill
        
        let labelTitle = UILabel(frame: CGRect.init(x: 20, y: imageView.frame.size.height+50, width: self.bounds.size.width-40, height: 50))
        labelTitle.textColor = UIColor.init(red: 73/255.0, green: 76/255.0, blue: 121/255.0, alpha: 1.0)
        labelTitle.font = UIFont(name: "Gotham-Bold", size: 35)
        labelTitle.textAlignment = .center
        labelTitle.text = title
        
        let textMessage = UITextView(frame: CGRect.init(x: 20, y: labelTitle.frame.origin.y+50, width: self.bounds.size.width-40, height: 200))
        textMessage.lineSpacing(text: message, spacing: 11)
        textMessage.textColor = UIColor.init(red: 73/255.0, green: 76/255.0, blue: 121/255.0, alpha: 0.8)
        textMessage.font = UIFont(name: "GothamBook", size: 18)
        textMessage.textAlignment = .center
        textMessage.isEditable = false
        
        customView.addSubview(imageView)
        customView.addSubview(labelTitle)
        customView.addSubview(textMessage)
        self.addSubview(customView)
    }
    
    func restoreDefaultView()
    {
        self.backgroundColor = .white
    }
}

extension UILabel
{
    func lineSpacing(text: String, spacing: CGFloat)
    {
        let attributedString = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = spacing
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
    
    func heightForLabel(text:String, font:UIFont, width:CGFloat) -> CGFloat
    {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
}

extension UITextField
{
    @IBInspectable var placeHolderColor: UIColor?
    {
        get
        { return self.placeHolderColor }
        set
        {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    func setLeftImage(imageName:String)
    {
        let imageView = UIImageView(frame: CGRect(x: 10, y: 0, width: 20, height: 20))
        imageView.image = UIImage(named: imageName)
        self.leftView = imageView
        self.leftViewMode = .always
    }
}

extension UITextView
{
    func lineSpacing(text: String, spacing: CGFloat)
    {
        let attributedString = NSMutableAttributedString(string: text)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = spacing
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:style, range:NSMakeRange(0, attributedString.length))
        self.attributedText = attributedString
    }
}

extension Data
{
    var html2AttributedString: NSAttributedString?
    {
        do
        {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch
        {
            return  nil
        }
    }
    
    var html2String: String
    { return html2AttributedString?.string ?? "" }
}

extension String
{
    func formatPrice () -> String{
        return String(format: "%.2f",locale:Locale.current, Double(self) ?? 0.00)
        
}
    
    
    var html2AttributedString: NSAttributedString?
    { return Data(utf8).html2AttributedString }
    
    var html2String: String
    { return html2AttributedString?.string ?? "" }
    
    var containsAlphabets: Bool
    { return !isEmpty && range(of: "[a-zA-Z@.]", options: .regularExpression) == nil }
    
    var containsNumbers: Bool
    { return !isEmpty && range(of: "[0123456789]", options: .regularExpression) == nil }
    
    func removeWhitespace() -> String
    { return self.replace(string: " ", replacement: "") }
    
    func replace(string:String, replacement:String) -> String
    { return self.replacingOccurrences(of: string, with: replacement, options: NSString.CompareOptions.literal, range: nil) }
    
    func capitalizingFirstLetter() -> String
    { return prefix(1).uppercased() + self.lowercased().dropFirst() }
    
    mutating func capitalizeFirstLetter()
    { self = self.capitalizingFirstLetter() }
    
    func getDateFromString(date str: String, currentFormat: String, desiredFormat: String) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = currentFormat
        let date = formatter.date(from: str)
        
        formatter.dateFormat = desiredFormat
        let strDate = formatter.string(from: date!)
        return strDate
    }
    
    func convertStringIntoDate(dateStr: String, desiredFormat: String) -> Date
    {
        let formatter = DateFormatter()
        formatter.dateFormat = desiredFormat
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: dateStr)!
    }
}

//MARK:- TextField Extension for left pedding
extension UITextField
{
    @IBInspectable var padding_left: CGFloat
    {
        get
        { return 0 }
        set (f)
        { layer.sublayerTransform = CATransform3DMakeTranslation(f, 0, 0) }
    }
    
    func setRightPadding(_ amount:CGFloat)
    {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension String {
     
    func base64ToImage() -> UIImage? {
    if let url = URL(string:self),
       let data = try? Data(contentsOf:url),
       let image = UIImage(data: data)
    {
        return image
    }
        return nil
    }
}
extension UIImage
{
  
    func  toBase64() -> String?
    {
        guard let imageData = self.pngData() else { return nil }
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
    func imageOrientation(_ src:UIImage)->UIImage
    {
        if src.imageOrientation == UIImage.Orientation.up {
            return src
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch src.imageOrientation {
        case UIImage.Orientation.down, UIImage.Orientation.downMirrored:
            transform = transform.translatedBy(x: src.size.width, y: src.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
            break
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored:
            transform = transform.translatedBy(x: src.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
            break
        case UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            transform = transform.translatedBy(x: 0, y: src.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
            break
        case UIImage.Orientation.up, UIImage.Orientation.upMirrored:
            break
        }
        
        switch src.imageOrientation {
        case UIImage.Orientation.upMirrored, UIImage.Orientation.downMirrored:
            transform.translatedBy(x: src.size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case UIImage.Orientation.leftMirrored, UIImage.Orientation.rightMirrored:
            transform.translatedBy(x: src.size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case UIImage.Orientation.up, UIImage.Orientation.down, UIImage.Orientation.left, UIImage.Orientation.right:
            break
        }
        
        let ctx:CGContext = CGContext(data: nil, width: Int(src.size.width), height: Int(src.size.height), bitsPerComponent: (src.cgImage)!.bitsPerComponent, bytesPerRow: 0, space: (src.cgImage)!.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        
        ctx.concatenate(transform)
        
        switch src.imageOrientation {
        case UIImage.Orientation.left, UIImage.Orientation.leftMirrored, UIImage.Orientation.right, UIImage.Orientation.rightMirrored:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.height, height: src.size.width))
            break
        default:
            ctx.draw(src.cgImage!, in: CGRect(x: 0, y: 0, width: src.size.width, height: src.size.height))
            break
        }
        
        let cgimg:CGImage = ctx.makeImage()!
        let img:UIImage = UIImage(cgImage: cgimg)
        
        return img
    }
}

extension UIImageView
{
    public func downlaodImageFromUrl(urlString: String) {

        let cleanURL = urlString
            .trimmingCharacters(in: .whitespacesAndNewlines)

//        print("🚨 IMAGE DOWNLOAD CALLED WITH =", cleanURL)

        guard !cleanURL.isEmpty,
              let url = URL(string: cleanURL),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https" else {

//            print("❌ INVALID IMAGE URL =", cleanURL)

            self.image = UIImage(named: "placeholder")
            return
        }

        self.sd_cancelCurrentImageLoad()

        self.sd_setImage(
            with: url,
            placeholderImage: UIImage(named: "placeholder"),
            options: [
                .retryFailed,
                .continueInBackground
            ]
        ) { image, error, cacheType, imageURL in

            if let error = error {

//                print("❌ IMAGE LOAD FAILED =", cleanURL)
//                print("ERROR =", error.localizedDescription)

                return
            }

//            print("✅ IMAGE LOAD SUCCESS =", imageURL?.absoluteString ?? "")
//            print("CACHE TYPE =", cacheType.rawValue)
        }
    }
        public func downlaodImageFromUrl1(urlString: String) {
//            print("🚨 IMAGE DOWNLOAD2 CALLED WITH =", urlString)
            self.tintColor = .lightGray
            guard let url = URL(string: urlString) else {
                self.image = UIImage(systemName: "photo") // fallback
                return
            }
            
            self.sd_setImage(
                with: url,
                placeholderImage: UIImage(systemName: "photo"), // system placeholder
                options: [.continueInBackground, .retryFailed],
                completed: nil
            )
        }
    
    class ImageCache {
        private let cache = NSCache<NSString, UIImage>()
        private var observer: NSObjectProtocol!
        
        static let shared = ImageCache()
        
        private init() {
            // make sure to purge cache on memory pressure
            
            observer = NotificationCenter.default.addObserver(forName: UIApplication.didReceiveMemoryWarningNotification, object: nil, queue: nil) { [weak self] notification in
                self?.cache.removeAllObjects()
            }
        }
        
        deinit {
            NotificationCenter.default.removeObserver(observer)
        }
        
        func image(forKey key: String) -> UIImage? {
            return cache.object(forKey: key as NSString)
        }
        
        func save(image: UIImage, forKey key: String) {
            cache.setObject(image, forKey: key as NSString)
        }
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize.init(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize.init(width: size.width * widthRatio, height:  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect.init(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 2.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if newImage != nil
        {
            return newImage!
        }
        else
        {
            return image
        }
    }
    
    public func resize(height: CGFloat) -> UIImage?
    {
        let scale = height / self.frame.size.height
        let width = self.frame.size.width * scale
        UIGraphicsBeginImageContext(CGSize(width: width, height: height))
        self.draw(CGRect(x:0, y:0, width:width, height:height))
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resultImage
    }
    
    func showIndicator(activity:UIActivityIndicatorView)
    {
        activity.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        activity.color = UIColor.lightGray
        activity.startAnimating()
        activity.hidesWhenStopped = true
        self.addSubview(activity)
    }
    
    private static var taskKey = 0
    private static var urlKey = 0
    
    private var currentTask: URLSessionTask? {
        get { return objc_getAssociatedObject(self, &UIImageView.taskKey) as? URLSessionTask }
        set { objc_setAssociatedObject(self, &UIImageView.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var currentURL: URL? {
        get { return objc_getAssociatedObject(self, &UIImageView.urlKey) as? URL }
        set { objc_setAssociatedObject(self, &UIImageView.urlKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func downloadImageAsync(with urlString: String?, defaultImage : String?, size:CGSize?)
    {
        let activity = UIActivityIndicatorView()
        weak var oldTask = currentTask
        currentTask = nil
        oldTask?.cancel()
        
        //Reset imageview's image
        self.image = nil
        
        //Allow supplying of `nil` to remove old image and then return immediately
        guard let urlString = urlString else { return }
        
        //Check cache
        if let cachedImage = ImageCache.shared.image(forKey: urlString)
        {
            self.image = cachedImage
            activity.stopAnimating()
            return
        }
        
        if defaultImage != nil && defaultImage != ""
        {
            self.image = UIImage(named: defaultImage!)
        }
        else
        {
            self.backgroundColor = UIColor.white

        }
        
        
        //Download image

        let url = URL(string: urlString.removeWhitespace())!
        currentURL = url
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            self?.currentTask = nil
            
            if let error = error
            {
                if (error as NSError).domain == NSURLErrorDomain && (error as NSError).code == NSURLErrorCancelled
                {
                    return
                }
                

                return
            }
            
            guard let data = data, let downloadedImage = UIImage(data: data) else
            {

                DispatchQueue.main.async
                {
                    if self != nil
                    {
                        activity.stopAnimating()
                        self!.image = UIImage(named: defaultImage!)
                        self?.contentMode = .center
                    }
                }
                return
            }
            
            ImageCache.shared.save(image: downloadedImage, forKey: urlString)
            
            if url == self?.currentURL
            {
                DispatchQueue.main.async
                {
                    self?.image = downloadedImage
                    if size != nil
                    {
                        self?.image = self?.resizeImage(image: downloadedImage, targetSize: size!)
                    }
                    else
                    {
                        self?.image = downloadedImage
                    }
                    
//                    self?.contentMode = .scaleAspectFill
                    self?.layer.masksToBounds = true
                    activity.stopAnimating()
                }
            }
        }
        
        //Save and start new task
        currentTask = task
        task.resume()
    }
    
    func loadImageUsingCache(withUrl urlString : String)
    {
        let imageCache = NSCache<NSString, UIImage>()
        let url = URL(string: urlString)
        if url == nil {return}
        self.image = nil
        
        //Check cached image
        if let cachedImage = imageCache.object(forKey: urlString as NSString)
        {
            self.image = cachedImage
            return
        }
        
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        addSubview(activityIndicator)
        activityIndicator.startAnimating()
//        activityIndicator.center = self.center
        activityIndicator.color = .red

        //Download Image from URL
        URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil
            {
                return
            }
            
            DispatchQueue.main.async
            {
                if let image = UIImage(data: data!)
                {
                    imageCache.setObject(image, forKey: urlString as NSString)
                    self.image = image
                    activityIndicator.removeFromSuperview()
                }
            }
            
        }).resume()
    }
}

extension Date
{
    
    static func getCurrentDate() -> String {

        let currentDate = Date()

        var dateComp = DateComponents()
        dateComp.day = 7

        let calendar = Calendar(identifier: .gregorian)

        guard let date = calendar.date(byAdding: dateComp, to: currentDate) else {
            return ""
        }

        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd/MM/yyyy"

        return formatter.string(from: date)
    }
    static func getCurrentDateGMT() -> Date {
        
        let currentDate = Date()
        var datecomp = DateComponents()
        let min = Calendar.init(identifier: .gregorian)
        datecomp.day = 7
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "dd/MM/yyyy"
        guard let minDates = min.date(byAdding: datecomp, to: currentDate)
        else {return Date()}

    
        return minDates
    }
//    static func getCurrentDate() -> String {
//
//        let currentDate = Date()
//
//        var dateComp = DateComponents()
//        dateComp.day = 7
//
//        let calendar = Calendar(identifier: .gregorian)
//
//        guard let date = calendar.date(byAdding: dateComp, to: currentDate) else {
//            return ""
//        }
//
//        let formatter = DateFormatter()
//        formatter.calendar = calendar
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.dateFormat = "dd/MM/yyyy"
//
//        return formatter.string(from: date)
//    }
    func dayOfTheWeek() -> String?
    {
        let weekdays =
            [ "Sunday",
              "Monday",
              "Tuesday",
              "Wednesday",
              "Thursday",
              "Friday",
              "Satudrday," ]
        
        let calendar: NSCalendar = NSCalendar.current as NSCalendar
        let components: NSDateComponents = calendar.components(.weekday, from: self as Date) as NSDateComponents
        return weekdays[components.weekday - 1]
    }
    
    static func toMillis() -> Int
    { return Int((Date().timeIntervalSince1970 * 1000.0).rounded()) }
    
    init(milliseconds:Int)
    { self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000) }
    
    func seconds(from date: Date) -> Int
    { return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0 }
    
    func minutes(from date: Date) -> Int
    { return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0 }
    
    func hours(from date: Date) -> Int
    { return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0 }
    
    func days(from date: Date) -> Int
    { return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0 }
    
    func weeks(from date: Date) -> Int
    { return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0 }
    
    func months(from date: Date) -> Int
    { return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0 }
    
    func years(from date: Date) -> Int
    { return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0 }
}

extension DateComponentsFormatter
{
    func difference(from fromDate: Date, to toDate: Date) -> String?
    {
        self.allowedUnits = [/*.year,.month,.weekOfMonth,*/.day]
        self.maximumUnitCount = 1
        self.unitsStyle = .full
        return self.string(from: fromDate, to: toDate)
    }
}

extension UIScrollView
{
    // Scroll to a specific view so that it's top is at the top our scrollview
    func scrollToView(view:UIView, animated: Bool)
    {
        if let origin = view.superview
        {
            // Get the Y position of your child view
            let childStartPoint = origin.convert(view.frame.origin, to: self)
            // Scroll to a rectangle starting at the Y of your subview, with a height of the scrollview
            self.scrollRectToVisible(CGRect(x:0, y:childStartPoint.y,width: 1,height: self.frame.height), animated: animated)
        }
    }
    
    // Bonus: Scroll to top
    func scrollToTop()
    {
        let topOffset = CGPoint(x: 0, y: 0)
        setContentOffset(topOffset, animated: true)
    }
    
    // Bonus: Scroll to bottom
    func scrollToBottom()
    {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
}

extension FloatingPoint
{
    var whole: Self { return modf(self).0 }
    var fraction: Self { return modf(self).1 }
}

extension UIView
{
    func makeCornersRound(corners: UIRectCorner, cornerRadius: CGFloat)
    {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: corners,
                                     cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}

extension UICollectionView
{
    func setEmptyMessage(_ message: String)
    {
        let messageTextView = UITextView()
        messageTextView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: 70)
        messageTextView.textColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
        messageTextView.textAlignment = .center
        messageTextView.backgroundColor = .clear
        messageTextView.text =  "\n\n\n\n\n\n" + message
        messageTextView.font = UIFont(name: "Helvetica", size: 17)
        self.backgroundView = messageTextView
    }
    
    func restore()
    {
        self.backgroundView = nil
    }
}

extension UITableView
{
    func setOffsetToBottom(animated: Bool)
    {
        self.setContentOffset(CGPoint(x: 0, y: self.contentSize.height - self.frame.size.height), animated: animated)
    }
    
    func scrollToLastRow(animated: Bool, section:Int)
    {
        if self.numberOfRows(inSection: section) > 0
        {
            self.scrollToRow(at: IndexPath(row: self.numberOfRows(inSection: section)-1, section: section ), at: .bottom, animated: animated)
        }
    }
    
    func setEmptyMessage(_ message: String)
    {
        let messageTextView = UITextView()
        messageTextView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.size.width, height: 70)
        messageTextView.textColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
        messageTextView.textAlignment = .center
        messageTextView.backgroundColor = .clear
        messageTextView.text =  "\n\n\n\n\n\n" + message
        messageTextView.font = UIFont(name: "Helvetica", size: 17)
        self.backgroundView = messageTextView
    }
    
    func restore()
    {
        self.backgroundView = nil
    }
}



extension UIView{
    
    func slideTop(){
        
        let slideTop = CATransition()
        slideTop.duration  = 0.7
        slideTop.type = CATransitionType.push
        slideTop.subtype = CATransitionSubtype.fromBottom
        slideTop.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.layer.add(slideTop, forKey: "slideTop")
        
        
        
    }
    
    func slideFromBottom(){
        
        let slideFromBottom = CATransition()
        slideFromBottom.duration  = 0.7
        slideFromBottom.type = CATransitionType.push
        slideFromBottom.subtype = CATransitionSubtype.fromTop
        slideFromBottom.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.layer.add(slideFromBottom, forKey: "slideFromBottom")
        
        
        
    }
}


typealias GradientPoints = (startPoint: CGPoint, endPoint: CGPoint)

enum GradientOrientation
{
    case topRightBottomLeft
    case topLeftBottomRight
    case bottomLeftTopRight
    case bottomRightTopLeft
    case horizontal
    case vertical
    case right
    case left
    case top
    case bottom
    
    var startPoint : CGPoint
    {
        return points.startPoint
    }
    
    var endPoint : CGPoint
    {
        return points.endPoint
    }
    
    var points : GradientPoints
    {
        get
        {
            switch(self)
            {
            case .topRightBottomLeft:
                return (CGPoint(x: 1.0,y: 0.0), CGPoint(x: 0.0,y: 1.0))
            case .topLeftBottomRight:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 0.65,y: 0.65))
            case .bottomLeftTopRight:
                return (CGPoint(x: 0.0,y: 1.0), CGPoint(x: 1.0,y: 0.0))
            case .bottomRightTopLeft:
                return (CGPoint(x: 1.0,y: 1.0), CGPoint(x: 0.0,y: 0.0))
            case .horizontal:
                return (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
            case .vertical:
                return (CGPoint(x: 0.0,y: 0.0), CGPoint(x: 0.0,y: 1.0))
            case .top:
                return (CGPoint(x: 0.5,y: 1.0), CGPoint(x: 0.5,y: 0.0))
            case .left:
                return (CGPoint(x: 1.0,y: 0.5), CGPoint(x: 0.0,y: 0.5))
            case .bottom:
                return (CGPoint(x: 0.5,y: 0.0), CGPoint(x: 0.5,y: 1.0))
            case .right:
                return (CGPoint(x: 0.0,y: 0.5), CGPoint(x: 1.0,y: 0.5))
            }
        }
    }
}

extension UIView
{
    func applyGradients(withColours colours: [UIColor], locations: [NSNumber]? = nil) -> Void
    {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func getGradientLayer(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation) -> CAGradientLayer
    {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        return gradient
    }
    
    func applyGradient(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation) -> Void {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        self.layer.insertSublayer(gradient, at: 0)
    }
    func applyGradientWithShadow(withColours colours: [UIColor], gradientOrientation orientation: GradientOrientation, shadowColor: UIColor, radius: CGFloat, opacity: Float, offset: CGSize, shadowRadius: CGFloat) -> Void
    {
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = orientation.startPoint
        gradient.endPoint = orientation.endPoint
        
        // Shadow
        gradient.shadowOffset = offset
        gradient.shadowColor = shadowColor.cgColor
        gradient.shadowOpacity = opacity
        gradient.shadowRadius = 10
        
        // Radius
        gradient.cornerRadius = radius
        self.layer.insertSublayer(gradient, at: 0)
    }
}

@IBDesignable class ShapeBgView: UIView
{
    var path: UIBezierPath!
    override func draw(_ rect: CGRect)
    {
        self.createRectShape()
        let gradient = getGradientLayer(withColours: [.blue, green], gradientOrientation: .vertical)
        gradient.frame = path.bounds
        let shapeMask = CAShapeLayer()
        shapeMask.path = path.cgPath
        gradient.mask = shapeMask
        self.layer.addSublayer(gradient)
    }
    
    func createRectShape()
    {
        // Initialize the path.
        path = UIBezierPath()
        
        // Specify the point that the path should start get drawn.
        path.move(to: CGPoint(x: 0.0, y: 0.0))
        
        // Create a line between the starting point and the bottom-left side of the view.
        path.addLine(to: CGPoint(x: 0.0, y: self.frame.size.height/2.1))
        
        // Create the bottom line (bottom-left to bottom-right).
        path.addLine(to: CGPoint(x: self.frame.size.width, y: self.frame.size.height/2.7))
        
        // Create the vertical line from the bottom-right to the top-right side.
        path.addLine(to: CGPoint(x: self.frame.size.width, y: 0.0))
        path.addClip()
        // Close the path. This will create the last line automatically.
        path.close()
    }
}

class TopView: UIView
{
    @IBInspectable public var curveColor: UIColor = .white
    override func draw(_ rect: CGRect)
    {
        let y:CGFloat = 20
        let curveTo:CGFloat = 100
        self.backgroundColor = .white
        let shadowOffset = CGSize.init(width: 0, height: -3.3)
        let myBezier = UIBezierPath()
        myBezier.move(to: CGPoint(x: 0, y: y))
        myBezier.addQuadCurve(to: CGPoint(x: rect.width, y: y), controlPoint: CGPoint(x: rect.width / 2, y: curveTo))
        myBezier.addLine(to: CGPoint(x: rect.width, y: rect.height))
        myBezier.addLine(to: CGPoint(x: 0, y: rect.height))
        
        myBezier.close()
        let context = UIGraphicsGetCurrentContext()
        let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        context!.setShadow(offset: shadowOffset, blur: 25, color: shadowColor.cgColor)
        context!.setLineWidth(50.0)
        curveColor.setFill()
        myBezier.fill()
        let degrees : Double = 180;
        self.transform = CGAffineTransform(rotationAngle: CGFloat(degrees * .pi/180))
        self.clipsToBounds = true
        self.backgroundColor = .clear
        self.layoutIfNeeded()
    }
}


class BottomView: UIView
{
    @IBInspectable public var curveColor: UIColor = .white
    override func draw(_ rect: CGRect)
    {
        let y:CGFloat = 20
        let curveTo:CGFloat = 100
        self.backgroundColor = .white
        
        let shadowOffset = CGSize.init(width: 0, height: -3.3)
        let myBezier = UIBezierPath()
        myBezier.move(to: CGPoint(x: 0, y: y))
        myBezier.addQuadCurve(to: CGPoint(x: rect.width, y: y), controlPoint: CGPoint(x: rect.width / 2, y: curveTo))
        myBezier.addLine(to: CGPoint(x: rect.width, y: rect.height))
        myBezier.addLine(to: CGPoint(x: 0, y: rect.height))
        
        myBezier.close()
        let context = UIGraphicsGetCurrentContext()
        let shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25)
        context!.setShadow(offset: shadowOffset, blur: 25, color: shadowColor.cgColor)
        context!.setLineWidth(50.0)
        curveColor.setFill()
        myBezier.fill()
        self.clipsToBounds = true
        self.backgroundColor = .clear
        self.layoutIfNeeded()
    }
}


extension UIView {
    class func initFromNib<T: UIView>() -> T {
            guard let view = Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)?.first as? T else {
                return T()
            }
            return view
        }
}
public extension UIView {
    func showAnimation(_ completionBlock: @escaping () -> Void) {
      isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear,
                       animations: { [weak self] in
                            self?.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
        }) {  (done) in
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveLinear,
                           animations: { [weak self] in
                                self?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { [weak self] (_) in
                self?.isUserInteractionEnabled = true
                completionBlock()
            }
        }
    }
}
extension String {
    
    var isValidEmail: Bool {
            NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
        }
    
    func isEmptyOrSpaces() -> Bool {
        
        if self.isEmpty {
            return true
        }
        
        return (self.trimmingCharacters(in: .whitespaces) == "")
    }
}

extension UITableView {

    func setError(_ message: String) {
        let lblMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        lblMessage.text = message
        lblMessage.textColor = .black
        lblMessage.numberOfLines = 0
        lblMessage.textAlignment = .center
        lblMessage.font = UIFont(name: "SegoeUI", size: 15)
        lblMessage.sizeToFit()

        self.backgroundView = lblMessage
        self.separatorStyle = .none
    }

    func clearBackground() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}

extension UICollectionView {

    func setError(_ message: String) {
        let lblMessage = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        lblMessage.text = message
        lblMessage.textColor = .black
        lblMessage.numberOfLines = 0
        lblMessage.textAlignment = .center
        lblMessage.font = UIFont(name: "SegoeUI", size: 15)
        lblMessage.sizeToFit()

        self.backgroundView = lblMessage
    
    }

    func clearBackground() {
        self.backgroundView = nil
       
    }
}
//Extension swipe to go back
extension UINavigationController {
    func handleSwipeBackGesture(enabled: Bool) {
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handleEdgePanGesture(_:)))
        edgePanGesture.edges = .left
        if enabled {
            view.addGestureRecognizer(edgePanGesture)
        } else {
            view.removeGestureRecognizer(edgePanGesture)
        }
    }
    
    @objc func handleEdgePanGesture(_ gesture: UIScreenEdgePanGestureRecognizer) {
        if gesture.state == .recognized {
            popViewController(animated: true)
        }
    }
}
