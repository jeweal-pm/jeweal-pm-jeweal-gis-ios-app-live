//
//  SKUProductSummary.swift
//  GIS
//
//  Created by MacBook Hawkscode  on 13/12/22.
//  Copyright © 2022 Hawkscode. All rights reserved.
//

import UIKit
import Alamofire
class SKUStonesCell : UITableViewCell {
    
    
    @IBOutlet weak var mStoneName: UILabel!
    
    @IBOutlet weak var mShapeName: UILabel!
    
    @IBOutlet weak var mCut: UILabel!
    @IBOutlet weak var mClarity: UILabel!
    @IBOutlet weak var mColor: UILabel!
    @IBOutlet weak var mSize: UILabel!
    
    @IBOutlet weak var mPcs: UILabel!
    @IBOutlet weak var mWeight: UILabel!
    @IBOutlet weak var mSetting: UILabel!
    @IBOutlet weak var mCertificateName: UILabel!
    
    @IBOutlet weak var mOpenLinkButton: UIButton!
    @IBOutlet weak var mCertificateNumber: UILabel!
    
    @IBOutlet weak var mStoneLABEL: UILabel!
    @IBOutlet weak var mShapeLABEL: UILabel!
    @IBOutlet weak var mCutLABEL: UILabel!
    @IBOutlet weak var mClarityLABEL: UILabel!
    @IBOutlet weak var mColorLABEL: UILabel!
    @IBOutlet weak var mSizeLABEL: UILabel!
    @IBOutlet weak var mPcsLABEL: UILabel!
    
    @IBOutlet weak var mWeightLABEL: UILabel!
    @IBOutlet weak var mSettingLABEL: UILabel!
    @IBOutlet weak var mCertificateLABEL: UILabel!
    
    
    
}

class SKUProductSummary: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mTableHeight: NSLayoutConstraint!
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mMetatag: UILabel!
    @IBOutlet weak var mProductInfo: UILabel!
    @IBOutlet weak var mProductId: UILabel!
    @IBOutlet weak var mSKUName: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mVariantStatus: UIImageView!
    @IBOutlet weak var mCurrencyFlag: UIImageView!
    @IBOutlet weak var mPrice: UILabel!
    @IBOutlet weak var mLocation: UILabel!
    @IBOutlet weak var mMetal: UILabel!
    @IBOutlet weak var mColor: UILabel!
    @IBOutlet weak var mSize: UILabel!
    @IBOutlet weak var mGrossWeight: UILabel!
    @IBOutlet weak var mNetWeight: UILabel!
    
    @IBOutlet weak var mStoneTable: UITableView!
    
    private var mProductData = NSMutableArray()
    var mOriginalData = NSArray()
    var mStoneData = NSArray()
    
    var storeCurrency: String = ""
    var mKey = ""
//    var mType = "inventory"

    // mType controls which API Product Summary uses.
    // "catalog" -> /Mobile/catalog/getCatalogDetail
    // anything else -> /Mobile/pos/customOrder/productDetail
    var mType = "inventory"

    // Required by Catalog getCatalogDetail. These are only used when
    // mType == "catalog".
    var catalogSKU: String = ""
    var catalogType: String = "catalog"
    var catalogLocation: String = ""
    var catalogIsWishlist: String = "0"
    
    
    @IBOutlet weak var mProductIdLABEL: UILabel!
    @IBOutlet weak var mSKULABEL: UILabel!
    @IBOutlet weak var mStockIdLABEL: UILabel!
    @IBOutlet weak var mPriceLABEL: UILabel!
    @IBOutlet weak var mLocationLABEL: UILabel!
    @IBOutlet weak var mMetalLABEL: UILabel!
    @IBOutlet weak var mColorLABEL: UILabel!
    @IBOutlet weak var mSizeLABEL: UILabel!
    @IBOutlet weak var mGrossWeightLABEL: UILabel!
    @IBOutlet weak var mNetWeightLABEL: UILabel!

    // Local loader for Product Summary API loading.
    // This is intentionally kept separate from CommonClass loader so the
    // loading indicator is always visible on this screen.
    private var mLoadingOverlay: UIView?
    private var mLoadingIndicator: UIActivityIndicatorView?
    private var productShareButton: UIButton?
    private var productShareOptionsOverlay: UIView?
    private var productPDFURL: URL?

    private func showProductLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.mLoadingOverlay == nil else { return }

            let overlay = UIView(frame: self.view.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.35)
            overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            overlay.isUserInteractionEnabled = true

            let indicator = UIActivityIndicatorView(style: .large)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.hidesWhenStopped = true

            overlay.addSubview(indicator)
            self.view.addSubview(overlay)

            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor)
            ])

            self.mLoadingOverlay = overlay
            self.mLoadingIndicator = indicator
            indicator.startAnimating()
        }
    }

    private func stopProductLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mLoadingIndicator?.stopAnimating()
            self.mLoadingOverlay?.removeFromSuperview()
            self.mLoadingIndicator = nil
            self.mLoadingOverlay = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔥 SKUProductSummary OPEN")
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        installProductHeader()
        installProductShareButton()
        // Keep the product content visually separated from the modal header.
        view.subviews.compactMap { $0 as? UIScrollView }.forEach {
            $0.contentInset.top = 12
            $0.verticalScrollIndicatorInsets.top = 12
        }
        
        mProductIdLABEL.text = "Product ID".localizedString
        mSKULABEL.text = "SKU".localizedString
        mStockIdLABEL.text = "Stock ID".localizedString
        mPriceLABEL.text = "Price".localizedString
        mLocationLABEL.text = "Location".localizedString
        mMetalLABEL.text = "Metal".localizedString
        mColorLABEL.text = "Color".localizedString
        mSizeLABEL.text = "Size".localizedString
        mGrossWeightLABEL.text = "Gross Wt".localizedString
        mNetWeightLABEL.text = "Net Wt".localizedString
        
        
        if !mKey.isEmpty {
            // Start the local loader before starting the API request.
            // Dispatching to the next main-loop turn allows the spinner to render.
            showProductLoading()

            print("🔥 SKUProductSummary mType =", mType)

            if mType.lowercased() == "catalog" {

                let location = catalogLocation.isEmpty
                    ? (UserDefaults.standard.string(forKey: "location") ?? "")
                    : catalogLocation

                let params: [String: Any] = [
                    "product_id": mKey,
                    "search": "",
                    "sku": catalogSKU,
                    "type": catalogType,
                    "metal": [],
                    "size": [],
                    "stone": [],
                    "location": location,
                    "shape": [],
                    "pointer": [],
                    "isWishlist": catalogIsWishlist
                ]

                let catalogDetailURL =
                    "https://api2uat.gis247.net/api/v1/Mobile/catalog/getCatalogDetail"

                print("========== CATALOG PRODUCT DETAIL START ==========")
                print("Catalog product_id =", mKey)
                print("Catalog SKU =", catalogSKU)
                print("Catalog Detail URL =", catalogDetailURL)
                print("Catalog Detail Request =", params)
                print("===================================================")

                mGetData(
                    url: catalogDetailURL,
                    headers: sGisHeaders,
                    params: params
                ) { [weak self] response, status in

                    guard let self = self else { return }

                    self.stopProductLoading()

                    print("========== CATALOG PRODUCT DETAIL RESPONSE ==========")
                    print("Catalog Product Summary response =", response)
                    print("Catalog Product Summary status =", status)
                    print("======================================================")

                    guard status else {
                        CommonClass.showSnackBar(message: "Product info not available!")
                        return
                    }

                    guard
                        "\(response.value(forKey: "code") ?? "")" == "200",
                        let data = response.value(forKey: "data") as? NSDictionary,
                        let productDetails =
                            data.value(forKey: "productdata_details") as? NSDictionary
                    else {
                        CommonClass.showSnackBar(message: "Product info not available!")
                        return
                    }

                    // Map Catalog response into the same dictionary shape
                    // used by the existing Product Summary UI.
                    let mappedDetails = NSMutableDictionary(dictionary: productDetails)

                    // Catalog: images -> existing UI expects main_image.
                    if mappedDetails["main_image"] == nil {
                        mappedDetails["main_image"] =
                            mappedDetails["images"] ?? ""
                    }

                    // Catalog location is outside productdata_details.
                    if let locations = data["location_arr"] as? NSArray,
                       let firstLocation = locations.firstObject as? NSDictionary,
                       let locationName = firstLocation["location_name"] as? String,
                       !locationName.isEmpty {
                        mappedDetails["location_name"] = locationName
                    }

                    // Catalog Product Summary has no stock_id.
                    if mappedDetails["stock_id"] == nil {
                        mappedDetails["stock_id"] = ""
                    }

                    self.mSetData(mData: mappedDetails)
                }

            } else {

                let params: [String: Any] = [
                    "id": mKey
                ]

                let inventoryDetailURL =
                    "https://api2uat.gis247.net/api/v1/Mobile/pos/customOrder/productDetail"

                print("========== INVENTORY PRODUCT DETAIL START ==========")
                print("Inventory product_id =", mKey)
                print("Inventory Detail URL =", inventoryDetailURL)
                print("Inventory Detail Request =", params)
                print("=====================================================")

                mGetData(
                    url: inventoryDetailURL,
                    headers: sGisHeaders,
                    params: params
                ) { [weak self] response, status in

                    guard let self = self else { return }

                    self.stopProductLoading()

                    print("========== INVENTORY PRODUCT DETAIL RESPONSE ==========")
                    print("Inventory Product Summary response =", response)
                    print("Inventory Product Summary status =", status)
                    print("========================================================")

                    guard status else {
                        CommonClass.showSnackBar(message: "Product info not available!")
                        return
                    }

                    if let data = response.value(forKey: "data") as? NSDictionary {
                        self.mSetData(mData: data)
                    } else if
                        let dataArray = response.value(forKey: "data") as? NSArray,
                        let data = dataArray.firstObject as? NSDictionary {
                        self.mSetData(mData: data)
                    } else {
                        CommonClass.showSnackBar(message: "Product info not available!")
                    }
                }
            }
        }else{
            mProductData = NSMutableArray(array: mOriginalData )
            if let mData = mProductData[0] as? NSDictionary {
                mSetData(mData: mData)
            }
        }
        
        
        
        
    }

    private func installProductHeader() {
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.tintColor = UIColor(named: "themeText") ?? .darkGray
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.accessibilityLabel = "Close Product Detail"
        closeButton.addTarget(self, action: #selector(closeProductDetail), for: .touchUpInside)
        view.addSubview(closeButton)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Product Detail"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textColor = UIColor(named: "themeText") ?? .darkGray
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            closeButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            closeButton.widthAnchor.constraint(equalToConstant: 32),
            closeButton.heightAnchor.constraint(equalToConstant: 32),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // This detail page has its own close button, so the system sheet
        // grabber is redundant and would overlap the custom header.
        sheetPresentationController?.prefersGrabberVisible = false
    }

    @objc private func closeProductDetail() {
        if let navigationController, navigationController.viewControllers.first !== self {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private func installProductShareButton() {
        guard productShareButton == nil else { return }

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor(named: "themeText") ?? .darkGray
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.accessibilityLabel = "Share Product"
        button.addTarget(self, action: #selector(shareProductDetail), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            button.widthAnchor.constraint(equalToConstant: 32),
            button.heightAnchor.constraint(equalToConstant: 32)
        ])
        productShareButton = button
    }

    @objc private func shareProductDetail() {
        let productId = mKey.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !productId.isEmpty else {
            CommonClass.showSnackBar(message: "Product info not available!")
            return
        }

        let websiteURL = (UserDefaults.standard.string(forKey: "website_url") ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let params: [String: Any] = [
            "product_id": productId,
            "website_url": websiteURL.isEmpty ? "ios.gis247.net" : websiteURL
        ]

        showProductLoading()
        mGetData(
            url: BaseUrl + "Mobile/catalog/getProductDetailPdf",
            headers: sGisHeaders,
            params: params
        ) { [weak self] response, status in
            guard let self else { return }
            self.stopProductLoading()

            guard status,
                  "\(response.value(forKey: "code") ?? "")" == "200",
                  let pdfURLString = response.value(forKey: "url") as? String,
                  let pdfURL = URL(string: pdfURLString) else {
                CommonClass.showSnackBar(
                    message: "\(response.value(forKey: "message") ?? "Unable to create product PDF")"
                )
                return
            }

            DispatchQueue.main.async {
                self.productPDFURL = pdfURL
                // Use the system share sheet so every installed sharing app
                // is available and the actions remain fully interactive.
                self.presentSystemShareSheet()
            }
        }
    }

    private func showProductShareOptions() {
        productShareOptionsOverlay?.removeFromSuperview()

        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissProductShareOptions))
        dismissTap.cancelsTouchesInView = false
        overlay.addGestureRecognizer(dismissTap)
        view.addSubview(overlay)

        let card = UIView()
        card.translatesAutoresizingMaskIntoConstraints = false
        card.backgroundColor = .white
        card.layer.cornerRadius = 22
        card.clipsToBounds = true
        overlay.addSubview(card)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Share"
        title.textAlignment = .center
        title.font = .systemFont(ofSize: 17, weight: .semibold)
        card.addSubview(title)

        let openButton = shareOptionButton(
            icon: "globe",
            title: "Open in Browser",
            subtitle: "Open this page in your web browser",
            action: #selector(openProductPDFInBrowser)
        )
        let copyButton = shareOptionButton(
            icon: "link",
            title: "Copy Link",
            subtitle: "Copy the link to clipboard",
            action: #selector(copyProductPDFLink)
        )
        card.addSubview(openButton)
        card.addSubview(copyButton)

        let appStack = UIStackView()
        appStack.translatesAutoresizingMaskIntoConstraints = false
        appStack.axis = .horizontal
        appStack.distribution = .fillEqually
        appStack.spacing = 9
        [
            shareAppButton(title: "LINE", symbol: "LINE", color: UIColor(red: 0.02, green: 0.76, blue: 0.31, alpha: 1), action: #selector(shareToLine)),
            shareAppButton(title: "WhatsApp", symbol: "WA", color: UIColor(red: 0.15, green: 0.78, blue: 0.31, alpha: 1), action: #selector(shareToWhatsApp)),
            shareAppButton(title: "Messages", symbol: "message.fill", color: UIColor(red: 0.20, green: 0.84, blue: 0.34, alpha: 1), action: #selector(shareToMessages)),
            shareAppButton(title: "Mail", symbol: "envelope.fill", color: UIColor(red: 0.12, green: 0.47, blue: 0.94, alpha: 1), action: #selector(shareToMail)),
            shareAppButton(title: "More", symbol: "ellipsis", color: UIColor(white: 0.9, alpha: 1), action: #selector(shareToMoreApps))
        ].forEach { appStack.addArrangedSubview($0) }
        card.addSubview(appStack)

        NSLayoutConstraint.activate([
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            card.leadingAnchor.constraint(equalTo: overlay.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -24),
            card.bottomAnchor.constraint(equalTo: overlay.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            card.heightAnchor.constraint(equalToConstant: 282),
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            title.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            openButton.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            openButton.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            openButton.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            openButton.heightAnchor.constraint(equalToConstant: 52),
            copyButton.leadingAnchor.constraint(equalTo: openButton.leadingAnchor),
            copyButton.trailingAnchor.constraint(equalTo: openButton.trailingAnchor),
            copyButton.topAnchor.constraint(equalTo: openButton.bottomAnchor),
            copyButton.heightAnchor.constraint(equalToConstant: 52),
            appStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            appStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            appStack.topAnchor.constraint(equalTo: copyButton.bottomAnchor, constant: 20),
            appStack.heightAnchor.constraint(equalToConstant: 74)
        ])
        productShareOptionsOverlay = overlay
        card.transform = CGAffineTransform(translationX: 0, y: 220)
        UIView.animate(withDuration: 0.25) { card.transform = .identity }
    }

    private func shareOptionButton(icon: String, title: String, subtitle: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(white: 0.98, alpha: 1)
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.tintColor = UIColor(named: "themeText") ?? .darkGray
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        button.addTarget(self, action: action, for: .touchUpInside)

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = UIColor(named: "themeText") ?? .darkGray
        titleLabel.isUserInteractionEnabled = false
        button.addSubview(titleLabel)

        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .systemGray
        subtitleLabel.isUserInteractionEnabled = false
        button.addSubview(subtitleLabel)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.translatesAutoresizingMaskIntoConstraints = false
        chevron.tintColor = .systemGray3
        chevron.isUserInteractionEnabled = false
        button.addSubview(chevron)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 54),
            titleLabel.topAnchor.constraint(equalTo: button.topAnchor, constant: 7),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            chevron.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -16),
            chevron.centerYAnchor.constraint(equalTo: button.centerYAnchor)
        ])
        return button
    }

    private func shareAppButton(title: String, symbol: String, color: UIColor, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: action, for: .touchUpInside)

        let icon = UILabel()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.textAlignment = .center
        icon.textColor = symbol == "ellipsis" ? .black : .white
        icon.font = symbol == "LINE" || symbol == "WA"
            ? .systemFont(ofSize: 13, weight: .bold)
            : .systemFont(ofSize: 24, weight: .medium)
        if symbol == "LINE" || symbol == "WA" {
            icon.text = symbol
        } else {
            switch symbol {
            case "message.fill": icon.text = "●●●"
            case "envelope.fill": icon.text = "✉︎"
            default: icon.text = "•••"
            }
        }
        icon.backgroundColor = color
        icon.layer.cornerRadius = 12
        icon.clipsToBounds = true
        button.addSubview(icon)

        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 10)
        label.textColor = UIColor(named: "themeText") ?? .darkGray
        button.addSubview(label)

        NSLayoutConstraint.activate([
            icon.topAnchor.constraint(equalTo: button.topAnchor),
            icon.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            icon.widthAnchor.constraint(equalToConstant: 54),
            icon.heightAnchor.constraint(equalToConstant: 54),
            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 3),
            label.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: -8),
            label.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: 8)
        ])
        return button
    }

    @objc private func dismissProductShareOptions() {
        productShareOptionsOverlay?.removeFromSuperview()
        productShareOptionsOverlay = nil
    }

    @objc private func openProductPDFInBrowser() {
        guard let productPDFURL else { return }
        dismissProductShareOptions()
        UIApplication.shared.open(productPDFURL)
    }

    @objc private func copyProductPDFLink() {
        guard let productPDFURL else { return }
        UIPasteboard.general.url = productPDFURL
        dismissProductShareOptions()
        showProductLinkCopiedToast()
    }

    @objc private func shareToLine() { openShareURL("line://msg/text/") }
    @objc private func shareToWhatsApp() { openShareURL("whatsapp://send?text=") }

    private func openShareURL(_ prefix: String) {
        guard let productPDFURL else { return }
        let link = productPDFURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: prefix + link) else { return }
        dismissProductShareOptions()
        UIApplication.shared.open(url) { [weak self] opened in
            if !opened { self?.presentSystemShareSheet() }
        }
    }

    @objc private func shareToMessages() {
        guard let productPDFURL else { return }
        let link = productPDFURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        dismissProductShareOptions()
        UIApplication.shared.open(URL(string: "sms:&body=\(link)")!)
    }

    @objc private func shareToMail() {
        guard let productPDFURL else { return }
        let link = productPDFURL.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        dismissProductShareOptions()
        UIApplication.shared.open(URL(string: "mailto:?body=\(link)")!)
    }

    @objc private func shareToMoreApps() {
        dismissProductShareOptions()
        presentSystemShareSheet()
    }

    private func presentSystemShareSheet() {
        guard let productPDFURL else { return }
        let shareSheet = UIActivityViewController(activityItems: [productPDFURL], applicationActivities: nil)
        if let popover = shareSheet.popoverPresentationController {
            popover.sourceView = productShareButton ?? view
            popover.sourceRect = productShareButton?.bounds ?? view.bounds
        }
        present(shareSheet, animated: true)
    }

    private func showProductLinkCopiedToast() {
        // The share picker is an overlay inside this modal.  Add the toast to
        // its window instead, so it remains visible after that overlay closes.
        let toastHost: UIView = view.window ?? view
        let toast = UIView()
        toast.translatesAutoresizingMaskIntoConstraints = false
        toast.backgroundColor = UIColor(red: 0.05, green: 0.76, blue: 0.73, alpha: 1)
        toast.layer.cornerRadius = 8
        toast.alpha = 0

        let closeIcon = UIImageView(image: UIImage(systemName: "xmark.circle"))
        closeIcon.translatesAutoresizingMaskIntoConstraints = false
        closeIcon.tintColor = .white
        toast.addSubview(closeIcon)

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.text = "Public link copied to your clipboard"
        title.font = .systemFont(ofSize: 13, weight: .semibold)
        title.textColor = .white
        toast.addSubview(title)

        let subtitle = UILabel()
        subtitle.translatesAutoresizingMaskIntoConstraints = false
        subtitle.text = "Anyone with this link can see this product"
        subtitle.font = .systemFont(ofSize: 11)
        subtitle.textColor = .white
        toast.addSubview(subtitle)
        toastHost.addSubview(toast)
        toastHost.bringSubviewToFront(toast)

        NSLayoutConstraint.activate([
            toast.leadingAnchor.constraint(equalTo: toastHost.leadingAnchor, constant: 16),
            toast.trailingAnchor.constraint(equalTo: toastHost.trailingAnchor, constant: -16),
            toast.bottomAnchor.constraint(equalTo: toastHost.safeAreaLayoutGuide.bottomAnchor, constant: -18),
            toast.heightAnchor.constraint(equalToConstant: 58),
            closeIcon.leadingAnchor.constraint(equalTo: toast.leadingAnchor, constant: 14),
            closeIcon.centerYAnchor.constraint(equalTo: toast.centerYAnchor),
            closeIcon.widthAnchor.constraint(equalToConstant: 20),
            closeIcon.heightAnchor.constraint(equalToConstant: 20),
            title.leadingAnchor.constraint(equalTo: closeIcon.trailingAnchor, constant: 10),
            title.topAnchor.constraint(equalTo: toast.topAnchor, constant: 12),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 2)
        ])
        UIView.animate(withDuration: 0.2) { toast.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            UIView.animate(withDuration: 0.2, animations: { toast.alpha = 0 }) { _ in
                toast.removeFromSuperview()
            }
        }
    }
    
    private func getStoneData(from data: NSDictionary) -> NSArray {

        // Catalog: productdata_details.stones
        if let stones = data["stones"] as? NSArray,
           stones.count > 0 {
            return stones
        }

        // Inventory compatibility.
        if let stones = data["stoneData"] as? NSArray,
           stones.count > 0 {
            return stones
        }

        if let stones = data["Stones"] as? NSArray,
           stones.count > 0 {
            return stones
        }

        if let product = data["product_details"] as? NSDictionary,
           let stones = product["Stones"] as? NSArray,
           stones.count > 0 {
            return stones
        }

        return NSArray()
    }

    private func stockID(from data: NSDictionary) -> String {
        let keys = ["stock_id", "stockId", "StockId", "Stock_ID", "stock_no", "stock_number", "stock"]

        for key in keys {
            let value = "\(data[key] ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
            if !value.isEmpty && value != "<null>" { return value }
        }

        // The detail API may omit Stock ID. Preserve it from the item that
        // opened this summary so the header does not incorrectly show "--".
        for source in [mOriginalData, mProductData] {
            for case let row as NSDictionary in source {
                for key in keys {
                    let value = "\(row[key] ?? "")".trimmingCharacters(in: .whitespacesAndNewlines)
                    if !value.isEmpty && value != "<null>" { return value }
                }
            }
        }
        return ""
    }

    func mSetData(mData: NSDictionary) {

        // Catalog uses `images`; Inventory uses `main_image`.
        let imageURL = "\(mData["main_image"] ?? mData["images"] ?? "")"
        mProductImage.downlaodImageFromUrl(urlString: imageURL)

        mMetatag.text = "\(mData["Matatag"] ?? "")"
        mProductInfo.text =
            "\(mData["name"] ?? mData["item_name"] ?? "")"

        // Catalog detail currently returns `product_id` as an internal UUID.
        // Do not show it as the user-facing Product ID; wait for the API's
        // display ID field instead.
        let displayProductID = "\(mData["ID"] ?? mData["display_id"] ?? mData["product_code"] ?? "")"
        mProductId.text = displayProductID.isEmpty ? "--" : displayProductID

        mSKUName.text =
            "\(mData["SKU"] ?? "")"

        let stockId = stockID(from: mData)
        mStockId.text = stockId.isEmpty ? "--" : stockId

        if let priceString = mData["price"] as? String,
           !priceString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {

            // Catalog already returns formatted price, e.g. "฿ 5,000.00".
            if priceString.contains("฿") ||
                priceString.contains("$") ||
                priceString.contains("€") ||
                priceString.contains("£") {
                mPrice.text = priceString
            } else {
                mPrice.text = formatPriceString(priceString)
            }

        } else if let price = mData["price"] as? NSNumber {
            mPrice.text = formatPriceNumber(price.doubleValue)
        } else if let price = mData["price"] as? Double {
            mPrice.text = formatPriceNumber(price)
        } else {
            mPrice.text = "\(storeCurrency) 0.00"
        }

        mLocation.text =
            "\(mData["location_name"] ?? "--")"

        mMetal.text =
            "\(mData["metal_name"] ?? "--")"

        mColor.text =
            "\(mData["color"] ?? mData["Color_name"] ?? "--")"

        mSize.text =
            "\(mData["size_name"] ?? mData["Size"] ?? "--")"

        mGrossWeight.text =
            "\(mData["GrossWt"] ?? mData["gross_weight"] ?? "--")"

        mNetWeight.text =
            "\(mData["NetWt"] ?? mData["net_weight"] ?? "--")"

        let isVariant =
            (mData["is_variant"] as? Int)
            ?? (mData["isVariant"] as? Int)
            ?? 0

        let isDesign =
            (mData["is_design"] as? Int)
            ?? (mData["isDesign"] as? Int)
            ?? 0

        if isVariant == 1 && isDesign == 1 {
            mVariantStatus.image = UIImage(named: "diamond_ic")
        } else if isVariant == 1 {
            mVariantStatus.image = UIImage(named: "variantic")
        } else if isDesign == 1 {
            mVariantStatus.image = UIImage(named: "diamond_ic")
        } else {
            mVariantStatus.image = nil
        }

        let variantType =
            "\(mData["product_variants_enable"] ?? "0")"

        switch variantType {
        case "1":
            mVariantStatus.image = UIImage(named: "variantic")
        case "2", "3":
            mVariantStatus.image = UIImage(named: "diamond_ic")
        default:
            break
        }

        print("========== MAPPED PRODUCT SUMMARY ==========")
        print("🔥 mType =", mType)
        print("🔥 Product ID =", mData["product_id"] ?? mData["ID"] ?? "")
        print("🔥 SKU =", mData["SKU"] ?? "")
        print("🔥 Name =", mData["name"] ?? mData["item_name"] ?? "")
        print("🔥 Price =", mData["price"] ?? "")
        print("🔥 Location =", mData["location_name"] ?? "")
        print("🔥 Metal =", mData["metal_name"] ?? "")
        print("🔥 Size =", mData["size_name"] ?? "")
        print("🔥 GrossWt =", mData["GrossWt"] ?? "")
        print("🔥 NetWt =", mData["NetWt"] ?? "")
        print("🔥 Stones count =", getStoneData(from: mData).count)
        print("============================================")

        mStoneData = getStoneData(from: mData)

        mStoneTable.delegate = self
        mStoneTable.dataSource = self
        mStoneTable.reloadData()
        mStoneTable.isScrollEnabled = false
        mStoneTable.separatorColor =
            UIColor(named: "themeTextExtraLight1")
        mStoneTable.separatorStyle = .singleLine

        mStoneTable.layoutIfNeeded()
        mTableHeight.constant =
            mStoneTable.contentSize.height + 300
    }

    private func formatPriceNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return "\(storeCurrency) \(formatter.string(from: NSNumber(value: value)) ?? "0.00")"
    }

    private func formatPriceString(_ value: String) -> String {
        if let number = Double(
            value.replacingOccurrences(of: ",", with: "")
        ) {
            return formatPriceNumber(number)
        }

        return "\(storeCurrency) \(value)"
    }

    @IBAction func mOpenLink(_ sender: UIButton) {

        guard let data = mStoneData[sender.tag] as? NSDictionary else {
            return
        }

        var link = ""

        if let certificate = data["certificate"] as? NSDictionary {
            link = certificate["url"] as? String ?? ""
        } else {
            link = data["certificateLink"] as? String
                ?? data["certificate_link"] as? String
                ?? ""
        }

        guard !link.isEmpty,
              let url = URL(string: link) else {
            CommonClass.showSnackBar(message: "No links found!")
            return
        }

        UIApplication.shared.open(url)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mStoneData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        guard let cells = tableView.dequeueReusableCell(withIdentifier: "SKUStonesCell") as? SKUStonesCell else {
            return UITableViewCell()
        }
        
        cells.mStoneLABEL.text = "Stone".localizedString
        cells.mShapeLABEL.text = "Shape".localizedString
        cells.mCutLABEL.text = "Cut".localizedString
        cells.mClarityLABEL.text = "Clarity".localizedString
        cells.mColorLABEL.text = "Color".localizedString
        cells.mSizeLABEL.text = "Size".localizedString
        cells.mPcsLABEL.text = "Pcs".localizedString
        cells.mWeightLABEL.text = "Weight".localizedString
        cells.mSettingLABEL.text = "Setting".localizedString
        cells.mCertificateLABEL.text = "Certificate".localizedString
        
        if let mData = mStoneData[indexPath.row] as? NSDictionary {

            // Catalog: stone_name / Shape_name / Cut_name /
            // Clarity_name / Color_name / Setting_type_name.
            // Inventory fallbacks are retained.
            cells.mStoneName.text =
                "\(mData["stone_name"] ?? mData["stone"] ?? "--")"

            cells.mShapeName.text =
                "\(mData["Shape_name"] ?? mData["shape_name"] ?? mData["shape"] ?? "--")"

            cells.mCut.text =
                "\(mData["Cut_name"] ?? mData["cut"] ?? "--")"

            cells.mClarity.text =
                "\(mData["Clarity_name"] ?? mData["clarity_name"] ?? mData["clarity"] ?? "--")"

            cells.mColor.text =
                "\(mData["Color_name"] ?? mData["color"] ?? "--")"

            cells.mSize.text =
                "\(mData["size_name"] ?? mData["Size_name"] ?? mData["Size"] ?? "--")"

            cells.mPcs.text =
                "\(mData["Pcs"] ?? "--")"

            let cts =
                Double("\(mData["Cts"] ?? 0)") ?? 0

            cells.mWeight.text =
                String(format: "%.2f", cts)

            cells.mSetting.text =
                "\(mData["Setting_type_name"] ?? mData["setting_type"] ?? "--")"

            if let certificate = mData["certificate"] as? NSDictionary {

                cells.mCertificateName.text =
                    "\(certificate["type"] ?? "--")"

                cells.mCertificateNumber.text =
                    "\(certificate["number"] ?? "--")"

            } else {

                cells.mCertificateName.text =
                    "\(mData["certificate_type"] ?? mData["certificateName"] ?? "--")"

                cells.mCertificateNumber.text =
                    "\(mData["certificate_number"] ?? mData["certificateNo"] ?? "--")"
            }

            cells.mOpenLinkButton.tag = indexPath.row
        }
        self.mStoneTable.layoutIfNeeded()
        self.mTableHeight.constant = self.mStoneTable.contentSize.height + 300
        return cells
    }
    
    
    
    
}
