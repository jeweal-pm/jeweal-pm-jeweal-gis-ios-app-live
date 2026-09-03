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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("🔥 SKUProductSummary OPEN")
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
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
            CommonClass.showFullLoader(view: self.view)

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

                    CommonClass.stopLoader()

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

                    CommonClass.stopLoader()

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

    func mSetData(mData: NSDictionary) {

        // Catalog uses `images`; Inventory uses `main_image`.
        let imageURL = "\(mData["main_image"] ?? mData["images"] ?? "")"
        mProductImage.downlaodImageFromUrl(urlString: imageURL)

        mMetatag.text = "\(mData["Matatag"] ?? "")"
        mProductInfo.text =
            "\(mData["name"] ?? mData["item_name"] ?? "")"

        mProductId.text =
            "\(mData["ID"] ?? mData["product_id"] ?? "")"

        mSKUName.text =
            "\(mData["SKU"] ?? "")"

        let stockId = "\(mData["stock_id"] ?? "")"
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
