//
//  ScannedStock.swift
//  GIS
//
//  Created by Apple Hawkscode on 17/12/20.
//

import UIKit
class ScannedStockCell: UITableViewCell {
    
    @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mStockId: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    
    private let manualAddIcon = UIImageView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        manualAddIcon.translatesAutoresizingMaskIntoConstraints = false
        manualAddIcon.image = UIImage(named: "stocktake_ic_manualadd")
        manualAddIcon.contentMode = .scaleAspectFit
        manualAddIcon.isHidden = true
        manualAddIcon.isUserInteractionEnabled = false
        contentView.addSubview(manualAddIcon)
        
        NSLayoutConstraint.activate([
            manualAddIcon.widthAnchor.constraint(equalToConstant: 20),
            manualAddIcon.heightAnchor.constraint(equalToConstant: 20),
            manualAddIcon.centerYAnchor.constraint(equalTo: mQuantity.centerYAnchor),
            manualAddIcon.trailingAnchor.constraint(equalTo: mQuantity.leadingAnchor, constant: -10)
        ])
    }
    
    func configureManualAddIcon(isManual: Bool) {
        manualAddIcon.isHidden = !isManual
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
class ScannedStock: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mStockId: UILabel!
    
    @IBOutlet weak var mProductImage: UIImageView!
    @IBOutlet weak var mStockName: UILabel!
    @IBOutlet weak var mSKUName: UILabel!
    @IBOutlet weak var mMetaTag: UILabel!
    @IBOutlet weak var mLocationName: UILabel!
    @IBOutlet weak var mQuantity: UILabel!
    
    @IBOutlet weak var mCollectionName: UILabel!
    
    @IBOutlet weak var mMetalName: UILabel!
    
    @IBOutlet weak var mStoneName: UILabel!
    
    @IBOutlet weak var mSize: UILabel!
    
    var mIndex = -1
    
    @IBOutlet weak var mTotalUnits: UILabel!
    
    
    @IBOutlet weak var mBottomView: UIView!
    @IBOutlet weak var mScannedStockTable: UITableView!
    var mScannedData = NSArray()
    @IBOutlet weak var mTotalCount: UILabel!
    var mCount = ""
    @IBOutlet weak var mSearchStock: UITextField!
    var mDATA = NSMutableArray()
    
    
    
    @IBOutlet weak var mScannedLABEL: UILabel!
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
            mDATA = NSMutableArray(array:mScannedData)
            mScannedStockTable.reloadData()
            mTotalCount.text = mCount
            mTotalUnits.text = mCount
        }
    }
    @objc func doneButtonAction(){
        var mUnknown = false
        var mScannedCount = [Int]()
        
        if mSearchStock.text! == "" {
            mDATA = NSMutableArray(array:mScannedData)
            mScannedStockTable.reloadData()
        }else{
            mDATA = NSMutableArray()
            for i in mScannedData {
                if let mValue = i as? NSDictionary {
                    if "\(mValue.value(forKey: "stock_id") ?? "")" == mSearchStock.text ?? ""  || "\(mValue.value(forKey: "SKU") ?? "")" == mSearchStock.text ?? "" {
                        mUnknown = true
                        
                        mDATA.add(mValue)
                        mScannedCount.append(Int("\(mValue.value(forKey: "QTY") ?? "0")") ?? 0)
                        mTotalCount.text = "\(mScannedCount.reduce(0, {$0 + $1}))"
                        mTotalUnits.text = "\(mScannedCount.reduce(0, {$0 + $1}))"
                        mScannedStockTable.reloadData()
                    }
                }
            }

        }
        
        
        if  !mUnknown {
            mDATA = NSMutableArray(array:mScannedData)
            mScannedStockTable.reloadData()
            mTotalCount.text = mCount
            mTotalUnits.text = mCount
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
        
        if tableView == mScannedStockTable {
            guard let cells = tableView.dequeueReusableCell(withIdentifier: "ScannedStockCell") as? ScannedStockCell else {
                return cell
            }
            if let mData = mDATA[indexPath.row] as? NSDictionary {
                
                cells.mStockName.text = "\(mData.value(forKey: "SKU") ?? "")"
                cells.mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
                cells.mQuantity.text = "\(mData.value(forKey: "po_QTY") ?? "")"
                let scanSource = "\(mData.value(forKey: "scan_source") ?? "")".lowercased()
                cells.configureManualAddIcon(isManual: scanSource == "manual")
                cell = cells
                
                if mIndex == indexPath.row {
                    mProductImage.downlaodImageFromUrl(urlString: "\(mData.value(forKey: "main_image") ?? "")")
                    mSKUName.text = "\(mData.value(forKey: "Matatag") ?? "")"
                    mMetaTag.text = "\(mData.value(forKey: "Matatag") ?? "")"
                    mLocationName.text = "\(mData.value(forKey: "location_name") ?? "")"
                    mQuantity.text = "QTY : \(mData.value(forKey: "po_QTY") ?? "")"
                    mCollectionName.text = "\(mData.value(forKey: "Collection_name") ?? "")"
                    mMetalName.text = "\(mData.value(forKey: "metalName") ?? "")"
                    mStoneName.text = "\(mData.value(forKey: "stoneName") ?? "")"
                    mSize.text = "\(mData.value(forKey: "size") ?? "")"
                    mStockId.text = "\(mData.value(forKey: "stock_id") ?? "")"
                    mStockName.text = "\(mData.value(forKey: "SKU") ?? "")"
                }
            }
        }
        
        
        
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 35
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mIndex = indexPath.row
        mScannedStockTable.reloadData()
        
    }
    
}
