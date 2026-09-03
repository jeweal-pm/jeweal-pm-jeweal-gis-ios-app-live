//
//  SelectedServiceLabour.swift
//  GIS
//
//  Created by Macbook Pro on 26/07/23.
//  Copyright © 2023 Hawkscode. All rights reserved.
//

import UIKit

class SelectedServiceLabour: UIViewController , UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mTableView: UITableView!

    var mMasterData  = NSArray()
    @IBOutlet weak var mServiceLabourHeadingLABEL: UILabel!
    @IBOutlet weak var mServiceLabourLABEL: UILabel!
    @IBOutlet weak var mRemarks: UITextField!
    var mProductData = NSDictionary()
    override func viewDidLoad() {
        super.viewDidLoad()
            
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
               
        mServiceLabourHeadingLABEL.text = "Service Labour".localizedString
        mServiceLabourLABEL.text = "Service Labour".localizedString
        mRemarks.placeholder = "Remarks".localizedString

        self.mServiceLabourLABEL.textColor = UIColor(named: "themeColor")
        self.mServiceLabourLABEL.text = "Applied Service Labour".localizedString
        self.mRemarks.text = mProductData.value(forKey: "service_remark") as? String ?? ""
        
        if let mServiceItems = self.mProductData.value(forKey: "service_laburelist") as? NSArray {
            self.mMasterData = mServiceItems
            mTableView.separatorColor = .clear
            self.mTableView.delegate = self
            self.mTableView.dataSource = self
            self.mTableView.reloadData()
        }else{
            self.mTableView.delegate = self
            self.mTableView.dataSource = self
            self.mTableView.reloadData()
        }
        
        
     
    }
    
    @IBAction func mBack(_ sender: Any) {
        
        self.dismiss(animated: true)
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if  mMasterData.count == 0 {
             tableView.setError("No items found!")
         }else{
             tableView.clearBackground()
         }
        return mMasterData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ServiceLabourItems") as? ServiceLabourItems else {
            return UITableViewCell()
        }
        
        if let mData = mMasterData[indexPath.row] as? NSDictionary {
            cell.mCode.text = mData.value(forKey: "code") as? String ?? "--"
            cell.mName.text = mData.value(forKey: "name") as? String ?? "--"
            cell.mCurrency.text = "\(UserDefaults.standard.string(forKey: "currencySymbol") ?? "$")"
            if mData.value(forKey: "scrviceamount") as? Double ?? 0.00 == 0 {
                cell.mAmount.text = ""
            }else{
                cell.mAmount.text = "\(mData.value(forKey: "scrviceamount") as? Double ?? 0.00)"
            }
            
            cell.mAmount.isEnabled = false
            if (indexPath.row % 2 == 0) {
                cell.backgroundColor = UIColor(named: "themeBackground")
            }else{
                cell.backgroundColor = #colorLiteral(red: 0.9568627451, green: 0.9568627451, blue: 0.9568627451, alpha: 1)
            }
        }
         
        return cell
    }
    
}
