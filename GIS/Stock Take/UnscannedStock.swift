//
//  UnscannedStock.swift
//  GIS
//
//  Created by Apple Hawkscode on 17/12/20.
//

import UIKit




class UnscannedStock: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    
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
  //  @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mSKUName: UILabel!
    @IBOutlet weak var mMetaTag: UILabel!
    @IBOutlet weak var mLocationName: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    //ScannedStock
    @IBOutlet weak var mCollectionName: UILabel!
    
    @IBOutlet weak var mMetalName: UILabel!
    
    @IBOutlet weak var mStoneName: UILabel!
    
    @IBOutlet weak var mSize: UILabel!
    
    var mIndex = -1
    @IBOutlet weak var mBottomView: UIView!
    @IBOutlet weak var mUnscannedTable: UITableView!
  
    @IBOutlet weak var mSearchStock: UITextField!
    
    var mUnscannedData = NSArray()
    var mDATA = NSMutableArray()
    @IBOutlet weak var mTotalCount: UILabel!
    var mCount = ""
    
    @IBOutlet weak var mTotalSkuLABEL: UILabel!
    @IBOutlet weak var mCollectionLABEL: UILabel!
    @IBOutlet weak var mStoneLABEL: UILabel!
    @IBOutlet weak var mSizeLABEL: UILabel!
    
    @IBOutlet weak var mMetalLABEL: UILabel!
    @IBOutlet weak var mShareLABEL: UILabel!
    
    @IBOutlet weak var mPrintLABEL: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
       

    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set total count label
        mTotalCount.text = "Unscanned (\(mCount))"

        // Set data for product details
        mDATA = NSMutableArray(array: mUnscannedData)
        if let mData = mDATA[0] as? NSDictionary {
            mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
            mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "")"
            mLocationName.text = "\(mData.value(forKey: "location_name") ?? "")"
            mCollectionName.text = "\(mData.value(forKey: "collection_name") ?? "")"
            mMetalName.text = "\(mData.value(forKey: "metalName") ?? "")"
            mStoneName.text = "\(mData.value(forKey: "stoneName") ?? "")"
            mSize.text = "\(mData.value(forKey: "size") ?? "")"
            mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
            mSKUName.text = "\(mData.value(forKey: "SKU") ?? "")"
        }
        // Add tap gesture to dismiss keyboard
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false

        // Configure bottom view
        mBottomView.layer.cornerRadius = 20
        mBottomView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // Configure product details view
        mProductDetailsView.layer.cornerRadius = 8
        mProductDetailsView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        // Configure summary bottom view
        mSummaryBottomView.layer.cornerRadius = 8
        mSummaryBottomView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]

        // Add done button to keyboard
        addDoneButtonOnKeyboard()

        // Set initial state
        mBottomView.isHidden = true

        // Set table delegate and reload data
        mUnscannedTable.delegate = self
        mUnscannedTable.dataSource = self
        mUnscannedTable.reloadData()
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
        
        if sender.text! == "" {
            mDATA = NSMutableArray(array:mUnscannedData)
            mUnscannedTable.reloadData()
            mTotalCount.text = "Unscanned (\(mCount))"
 
        }
    }
    
    @objc func doneButtonAction() {
        var mUnknown = false
        var mScannedCount = [Int]()
        
        guard let searchText = mSearchStock.text, !searchText.isEmpty else {
            mDATA = NSMutableArray(array: mUnscannedData)
            mUnscannedTable.reloadData()
            mSearchStock.resignFirstResponder()
            return
        }
        
        mDATA = NSMutableArray()
        for case let mValue as NSDictionary in mUnscannedData {
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
                mTotalCount.text = "Unscanned (\(totalCount))"
                
                mUnscannedTable.reloadData()
            }
        }
        
        if !mUnknown {
            mDATA = NSMutableArray(array: mUnscannedData)
            mTotalCount.text = "Unscanned (\(mCount))"
            mUnscannedTable.reloadData()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       
        return mDATA.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        var cell  = UITableViewCell()
        
        if tableView == mUnscannedTable {
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "TotalStockCell") as? TotalStockCell else {
                return cell
            }
            if let mData = mDATA[indexPath.row] as? NSDictionary {
                
                cells.mSno.text = "#\(indexPath.row + 1)"
                cells.mStockName.text = "\(mData.value(forKey: "SKU") ?? "")"
                cells.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
                cells.mQuantity.text = "\(mData.value(forKey: "po_QTY") ?? "") Pcs"
                cell = cells
                
                cells.mView.backgroundColor = (indexPath.row % 2 == 0) ? UIColor(named: "themeBackground") : #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
                
                if mIndex == indexPath.row {
                    mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                    mSKUName.text = "\(mData.value(forKey: "SKU") ?? "")"
                    mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "")"
                    mLocationName.text = "\(mData.value(forKey: "location_name") ?? "")"
                    mCollectionName.text = "\(mData.value(forKey: "collection_name") ?? "")"
                    mMetalName.text = "\(mData.value(forKey: "metalName") ?? "")"
                    mStoneName.text = "\(mData.value(forKey: "stoneName") ?? "")"
                    mSize.text = "\(mData.value(forKey: "size") ?? "")"
                    mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
                }
            }
        }
       
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 52
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    mIndex = indexPath.row
    mUnscannedTable.reloadData()
 
    }

}
