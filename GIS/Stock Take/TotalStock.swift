//
//  TotalStock.swift
//  GIS
//
//  Created by Apple Hawkscode on 17/12/20.
//

import UIKit

class TotalStockCell: UITableViewCell {
    
    
    @IBOutlet weak var mSno: UILabel!
    @IBOutlet weak var mView: UIView!
    @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    
    @IBOutlet weak var isDesignView: UIView!
    let manualAddIcon = UIImageView()
//    override func awakeFromNib() {
//        super.awakeFromNib()
//    }
    override func awakeFromNib() {
        super.awakeFromNib()

        manualAddIcon.translatesAutoresizingMaskIntoConstraints = false
        manualAddIcon.image = UIImage(named: "stocktake_ic_manualadd")
        manualAddIcon.contentMode = .scaleAspectFit
        manualAddIcon.isHidden = true

        mView.addSubview(manualAddIcon)

        NSLayoutConstraint.activate([
            manualAddIcon.widthAnchor.constraint(equalToConstant: 20),
            manualAddIcon.heightAnchor.constraint(equalToConstant: 20),

            manualAddIcon.centerYAnchor.constraint(equalTo: mView.centerYAnchor),

            // วางก่อนจำนวน Pcs
            manualAddIcon.trailingAnchor.constraint(
                equalTo: mQuantity.leadingAnchor,
                constant: -12
            )
        ])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}


class TotalStock: UIViewController,UITableViewDelegate,UITableViewDataSource, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {
    
    
    //Product Summary
    
    @IBOutlet weak var mMaterialName: UILabel!
    @IBOutlet weak var mMaterialWeight: UILabel!
    
    @IBOutlet weak var mStoneOne: UILabel!
    @IBOutlet weak var mStoneOneWeight: UILabel!
    @IBOutlet weak var mStoneTwo: UILabel!
    @IBOutlet weak var mStoneTwoWeight: UILabel!
    
    @IBOutlet weak var mCertificateName: UILabel!
    @IBOutlet weak var mCertificateNumber: UILabel!
    @IBOutlet weak var mReferenceName: UILabel!
    @IBOutlet weak var mProductSummaryView: UIStackView!
    
    @IBOutlet weak var mShowHideButton: UIButton!
    @IBOutlet weak var mShowHideSummaryIcon: UIImageView!
    
    @IBOutlet weak var mProductDetailsView: UIView!
    @IBOutlet weak var mSummaryBottomView: UIView!
    
    
    @IBOutlet weak var mStockId: UILabel!
    
    @IBOutlet weak var mProductImage: UIImageView!
    
    @IBOutlet weak var mSKUName: UILabel!
    @IBOutlet weak var mMetaTag: UILabel!
    @IBOutlet weak var mLocationName: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    
    @IBOutlet weak var mCollectionName: UILabel!
    
    @IBOutlet weak var mMetalName: UILabel!
    
    @IBOutlet weak var mStoneName: UILabel!
    
    
    
    @IBOutlet weak var mSize: UILabel!
    
    var mIndex = -1
    @IBOutlet weak var mBottomView: UIView!
    @IBOutlet weak var mTotalStockTable: UITableView!
    
    @IBOutlet weak var mSearchStock: UITextField!
    
    var mTotalStockData = NSArray()
    var mDATA = NSMutableArray()
    @IBOutlet weak var mTotalCount: UILabel!
    var mCount = ""
    
    
    @IBOutlet weak var mCollectionLABEL: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    @IBOutlet weak var mSizeLABEL: UILabel!
    
    @IBOutlet weak var mMetalLABEL: UILabel!
    @IBOutlet weak var mShareLABEL: UILabel!
    
    @IBOutlet weak var mPrintLABEL: UILabel!
    
    @IBOutlet weak var mProductSummaryLABEL: UILabel!
    @IBOutlet weak var mMaterialLABEL: UILabel!
    @IBOutlet weak var mPStoneLABEL: UILabel!
    @IBOutlet weak var mReferenceNoLABEL: UILabel!
    @IBOutlet weak var mCertificateLABEL: UILabel!
    var mType = ""
    
    var mProductIdForImage = ""
    var mSKUForImage = ""
    
    
    @IBOutlet weak var loader: UIProgressView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        mCollectionLABEL.text = "Collection".localizedString
        mMetalLABEL.text = "Metal".localizedString
        mStoneLABEL.text = "Stone".localizedString
        mSizeLABEL.text = "Size".localizedString
        
        mProductSummaryLABEL.text = "Product Summary".localizedString
        mMaterialLABEL.text = "Material".localizedString
        mPStoneLABEL.text = "Stone".localizedString
        mReferenceNoLABEL.text = "Reference No.".localizedString
        mCertificateLABEL.text = "Certificate".localizedString
        
        mSearchStock.placeholder =  "Search by SKU / Stock ID".localizedString
        
        //ProgressView style
        loader.progressViewStyle = .bar
        loader.trackTintColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
        //Enable back gesture
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mTotalCount.text = "\(mType.localizedString) (\(mCount))"
        
        mDATA = NSMutableArray(array:mTotalStockData)
        print("TotalStock viewDidLoad mDATA = \(mDATA)")
        if let mData = mDATA[0] as? NSDictionary,
           let id = mData.value(forKey: "_id") as? String,
           let sku = mData.value(forKey: "SKU") as? String,
           !id.isEmpty {
            getItemDetails(id: id)
            self.mProductIdForImage = id
            self.mSKUForImage = sku
        }
        
        // Make only the green SKU text at the top tappable.
        mSKUName.isUserInteractionEnabled = true
        mSKUName.gestureRecognizers?.forEach {
            mSKUName.removeGestureRecognizer($0)
        }
        let tapTopSKU = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTopSKUTap(_:))
        )
        mSKUName.addGestureRecognizer(tapTopSKU)

        let tap =  UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(onTapImage))
        tap1.delegate = self
        mProductImage.isUserInteractionEnabled = true
        mProductImage.addGestureRecognizer(tap1)
        
        mBottomView.layer.cornerRadius = 20
        mBottomView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        mProductDetailsView.layer.cornerRadius = 8
        mProductDetailsView.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        
        mSummaryBottomView.layer.cornerRadius = 8
        mSummaryBottomView.layer.maskedCorners = [.layerMaxXMaxYCorner , .layerMinXMaxYCorner]
        
        addDoneButtonOnKeyboard()
        
        mBottomView.isHidden = true
        mTotalStockTable.delegate = self
        mTotalStockTable.dataSource = self
        mTotalStockTable.reloadData()
    }
    
    @objc
    func onTapImage() {
        if mProductIdForImage != "" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
            if let mGlobalImageViewer = storyBoard.instantiateViewController(withIdentifier: "GlobalImageViewer") as? GlobalImageViewer {
                mGlobalImageViewer.modalPresentationStyle = .overFullScreen
                mGlobalImageViewer.mProductId = mProductIdForImage
                mGlobalImageViewer.mSKUName = mSKUForImage
                mGlobalImageViewer.transitioningDelegate = self
                self.present(mGlobalImageViewer,animated: false)
            }
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 1
    }
    
    @IBAction func mOpenLink(_ sender: Any) {
    }
    
    @IBAction func mShowHideProductSummary(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            mShowHideSummaryIcon.image = UIImage(named: "top_ic")
            UIView.animate(withDuration: 1.0) {
                self.mProductSummaryView.isHidden = false
                self.view.layoutIfNeeded()
            }
        }else{
            
            mShowHideSummaryIcon.image = UIImage(named: "bottomic")
            UIView.animate(withDuration: 1.0) {
                self.mProductSummaryView.isHidden = true
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func addDoneButtonOnKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Search", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        mSearchStock.inputAccessoryView = doneToolbar
    }
    
    
    @IBAction func mSearchText(_ sender: UITextField) {
        
        if sender.text == "" {
            mDATA = NSMutableArray(array:mTotalStockData)
            mTotalStockTable.reloadData()
            mTotalCount.text = "\(mType) (\(mCount))"
            
        }
    }
    
    @objc func doneButtonAction() {
        var mUnknown = false
        var mScannedCount = [Int]()
        
        guard let searchText = mSearchStock.text, !searchText.isEmpty else {
            mDATA = NSMutableArray(array: mTotalStockData)
            mTotalStockTable.reloadData()
            mSearchStock.resignFirstResponder()
            return
        }
        
        mDATA = NSMutableArray()
        for case let mValue as NSDictionary in mTotalStockData {
            guard let stockID = mValue.value(forKey: "stock_id") as? String,
                  let sku = mValue.value(forKey: "SKU") as? String,
                  let poQTYString = mValue.value(forKey: "po_QTY") as? String,
                  let poQTY = Int(poQTYString) else {
                continue
            }
            
            if stockID == searchText || sku == searchText {
                mUnknown = true
                mDATA.add(mValue)
                
                mScannedCount.append(poQTY)
                let totalCount = mScannedCount.reduce(0, +)
                mTotalCount.text = "\(mType) (\(totalCount))"
                
                mTotalStockTable.reloadData()
            }
        }
        
        if !mUnknown {
            mDATA = NSMutableArray(array: mTotalStockData)
            mTotalCount.text = "\(mType) (\(mCount))"
            mTotalStockTable.reloadData()
        }
        
        mSearchStock.resignFirstResponder()
    }
    
    @IBAction func mBack(_ sender: Any) {
        self.navigationController?.popViewController(animated:true)
    }
    
    
    @IBAction func mShare(_ sender: Any) {
    }
    
    @IBAction func mPrint(_ sender: Any) {
        
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Test", bundle: nil)
        
        if let mPrint = storyBoard.instantiateViewController(withIdentifier: "PrintItem") as? PrintItem {
            self.navigationController?.pushViewController(mPrint, animated:true)
        }
    }
    
    @objc private func handleTopSKUTap(_ gesture: UITapGestureRecognizer) {
        guard !mProductIdForImage.isEmpty else { return }

        let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)

        if let home = storyBoard.instantiateViewController(withIdentifier: "SKUProductSummary") as? SKUProductSummary {
            print(mProductIdForImage)

            home.mKey = mProductIdForImage
            home.mType = mType
            home.modalPresentationStyle = .automatic
            home.transitioningDelegate = self

            self.present(home, animated: true)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return mDATA.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell  = UITableViewCell()
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        if tableView == mTotalStockTable {
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "TotalStockCell") as? TotalStockCell,
                  let mData = mDATA[indexPath.row] as? NSDictionary else {
                return cell
            }
            
//            cells.mSno.text = "#\(indexPath.row + 1)"
//            cells.mStockName.text = "\(mData.value(forKey: "SKU") ?? "")"
//            cells.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
//            cells.mQuantity.text = "\(mData.value(forKey: "po_QTY") ?? "") Pcs"
            cells.mSno.text = "#\(indexPath.row + 1)"
            cells.mStockName.text = "\(mData.value(forKey: "SKU") ?? "")"
            cells.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
            cells.mQuantity.text = "\(mData.value(forKey: "po_QTY") ?? "") Pcs"

            // A typed/manual search is recorded with scan_source = "manual".
            // Normalize the value because older API/local data may differ only
            // by casing or whitespace.
            let scanSource = "\(mData.value(forKey: "scan_source") ?? "")"
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .lowercased()
            cells.manualAddIcon.isHidden = (scanSource != "manual")
            cell = cells
            
            
            if (indexPath.row % 2 == 0) {
                cells.mView.backgroundColor = UIColor(named: "themeBackground")
            }else{
                cells.mView.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                
            }
        }
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mIndex = indexPath.row
        
        guard let mData = mDATA[mIndex] as? NSDictionary,
              let id = mData.value(forKey: "_id") as? String,
              let sku = mData.value(forKey: "SKU") as? String else {
            return
        }
        
        if !id.isEmpty {
            getItemDetails(id: id)
            self.mProductIdForImage = id
            self.mSKUForImage = sku
        }
    }
    
    func getItemDetails(id: String){
        let params: [String: Any] = [
            "id": id
        ]
        loader.isHidden = false
        loader.setProgress(0.0, animated: true)
        mGetData(url: sSkuDetail, headers: sGisHeaders, params: params) { response, status in
            self.loader.isHidden = true
            self.loader.setProgress(1.0, animated: false)
            print("getItemDetails response = \(response)")
            guard status else {
                CommonClass.showSnackBar(message: "Oops, something went wrong!")
                return
            }
            
            if let mCode = response.value(forKey: "code") as? Int, mCode == 403 {
                CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                return
            }
            
            if let code = response.value(forKey: "code") as? Int, code == 200 {
                if let mData = response.value(forKey: "data") as? NSDictionary {
                    
                    self.mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                    self.mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "")"
                    self.mLocationName.text = "\(mData.value(forKey: "location_name") ?? "")"
                    self.mCollectionName.text = "\(mData.value(forKey: "collection_name") ?? "")"
                    self.mMetalName.text = "\(mData.value(forKey: "metal_name") ?? "")"
                    self.mStoneName.text = "\(mData.value(forKey: "stone_name") ?? "")"
                    self.mSize.text = "\(mData.value(forKey: "size_name") ?? "")"
                    self.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
                    self.mSKUName.text = "\(mData.value(forKey: "SKU") ?? "")"
                    self.mReferenceName.text = "\(mData.value(forKey: "SKU") ?? "")"
                    if let certificate = mData.value(forKey: "certificate") as? NSDictionary {
                           self.mCertificateNumber.text = "\(certificate.value(forKey: "number") ?? "")"
                           self.mCertificateName.text = "\(certificate.value(forKey: "type") ?? "")"
                       }
                    self.mMaterialName.text = "\(mData.value(forKey: "metal_name") ?? "--")"
                    
                    if let weight = Double("\(mData.value(forKey: "metal_weight") ?? "0")") {
                        self.mMaterialWeight.text = String(format: "%.2f g", weight)
                    } else {
                        self.mMaterialWeight.text = "--"
                    }
//                    self.mMaterialWeight.text = "\(mData.value(forKey: "metal_weight") ?? "--")"

//                    self.mStoneOne.text = "--"
//                    self.mStoneOneWeight.text = "--"
//                    self.mStoneTwo.text = "--"
//                    self.mStoneTwoWeight.text = "--"

//                    if let stones = mData.value(forKey: "stones") as? [NSDictionary] {
//
//                        if stones.indices.contains(0) {
//                            let stone1 = stones[0]
//                            self.mStoneOne.text = "\(stone1.value(forKey: "stone_name") ?? "--")"
//                            self.mStoneOneWeight.text = "\(stone1.value(forKey: "cts") ?? "--")"
//                        }
//
//                        if stones.indices.contains(1) {
//                            let stone2 = stones[1]
//                            self.mStoneTwo.text = "\(stone2.value(forKey: "stone_name") ?? "--")"
//                            self.mStoneTwoWeight.text = "\(stone2.value(forKey: "cts") ?? "--")"
//                        }
//                    }
                    
                    if let stones = mData.value(forKey: "stones") as? [NSDictionary] {

                        if stones.indices.contains(0) {
                            let stone1 = stones[0]

                            self.mStoneOne.text = "\(stone1.value(forKey: "stone_name") ?? "--")"

                            let pcs = "\(stone1.value(forKey: "pcs") ?? stone1.value(forKey: "Pcs") ?? "--")"
                            let cts = "\(stone1.value(forKey: "cts") ?? stone1.value(forKey: "Cts") ?? "--")"

                            self.mStoneOneWeight.text = "\(pcs)        \(cts) c"
                        }

                        if stones.indices.contains(1) {
                            let stone2 = stones[1]

                            self.mStoneTwo.text = "\(stone2.value(forKey: "stone_name") ?? "")"

                            let pcs = "\(stone2.value(forKey: "pcs") ?? stone2.value(forKey: "Pcs") ?? "")"
                            let cts = "\(stone2.value(forKey: "cts") ?? stone2.value(forKey: "Cts") ?? "")"

                            self.mStoneTwoWeight.text = "\(pcs)        \(cts) c"
                        }
                    }
                    self.mProductIdForImage = id
                    self.mSKUForImage = "\(mData.value(forKey: "SKU") ?? "" )"
                    
                    
                    
                    
                } else {
                    CommonClass.showSnackBar(message: "No data found in JSON response")
                }
            } else {
                if let error = response.value(forKey: "error") as? String, error == "Authorization has been expired" {
                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                } else {
                    CommonClass.showSnackBar(message: "\(response.value(forKey: "code") ?? "")")
                }
            }
        }
    }
    
}
