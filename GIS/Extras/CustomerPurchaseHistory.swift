//
//  CustomerPurchaseHistory.swift
//  GIS
//
//  Created by Apple Hawkscode on 09/02/22.
//


import UIKit
import Alamofire
import DropDown

class CustomerPurchaseHistory: UIViewController , UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var TransactionTable: UITableView!
    
    
    
    @IBOutlet weak var mTransactionView: UIStackView!
    
    @IBOutlet weak var mCurrentDate: UITextField!
    
    var mSalespersonTransactionData = NSArray()
    
    var mCustomerId = ""
    var mCustomerName = ""
    
    var delegate:SalesPersonTransactionDelegate? = nil
    var mIndex = -1
    
    
    @IBOutlet weak var mHeadingLABEL: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        mUserLoginToken = UserDefaults.standard.string(forKey: "token")
        mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")
        
        TransactionTable.showsVerticalScrollIndicator = false
        TransactionTable.showsHorizontalScrollIndicator = false
        mHeadingLABEL.text =  "Purchase History".localizedString
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .medium
        
        let formatter2 = DateFormatter()
        formatter2.timeStyle = .short
        formatter2.dateStyle = .none
        
        let mMonthm = DateFormatter()
        mMonthm.dateFormat = "MMM"
        
        let mMonthInt = DateFormatter()
        mMonthInt.dateFormat = "MM"
        
        let mYeard = DateFormatter()
        mYeard.dateFormat = "yyyy"
        
        let mYearInt = DateFormatter()
        mYearInt.dateFormat = "yyyy"
        
        
        mGetTransactions()
        
        #if NFC_WRITER
        installMoreMenu()
        #endif
        
    }
    
    #if NFC_WRITER
    /// "⋮" menu on the header with the NFC Writer action.
    private func installMoreMenu() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis")?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)), for: .normal)
        button.tintColor = UIColor(named: "themeText") ?? .darkGray
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(mShowMoreMenu(_:)), for: .touchUpInside)
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: mHeadingLABEL.centerYAnchor),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func mShowMoreMenu(_ sender: UIButton) {
        // Dropdown card under the "⋮" button (icon + title rows, as in the design).
        let overlay = UIControl(frame: view.bounds)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.addTarget(self, action: #selector(mDismissMoreMenu(_:)), for: .touchUpInside)

        let nfcRow = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.title = "NFC Writer"
        config.image = UIImage(systemName: "dot.radiowaves.right")
        config.imagePadding = 14
        config.baseForegroundColor = UIColor(named: "themeText") ?? .darkGray
        config.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 20)
        nfcRow.configuration = config
        nfcRow.contentHorizontalAlignment = .leading
        nfcRow.addTarget(self, action: #selector(mOpenNFCWriter(_:)), for: .touchUpInside)

        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 10
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.15
        card.layer.shadowRadius = 8
        card.layer.shadowOffset = CGSize(width: 0, height: 2)
        card.translatesAutoresizingMaskIntoConstraints = false
        nfcRow.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(nfcRow)
        overlay.addSubview(card)
        view.addSubview(overlay)

        let anchor = sender.convert(sender.bounds, to: view)
        NSLayoutConstraint.activate([
            nfcRow.topAnchor.constraint(equalTo: card.topAnchor),
            nfcRow.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            nfcRow.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            nfcRow.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            card.topAnchor.constraint(equalTo: overlay.topAnchor, constant: anchor.maxY - 4),
            card.trailingAnchor.constraint(equalTo: overlay.trailingAnchor, constant: -(view.bounds.width - anchor.maxX) - 4)
        ])
    }
    
    @objc private func mDismissMoreMenu(_ sender: UIControl) {
        sender.removeFromSuperview()
    }
    
    @objc private func mOpenNFCWriter(_ sender: UIButton) {
        sender.superview?.superview?.removeFromSuperview()
        NFCWriterRouter.present(from: self, customerName: mCustomerName, orders: mSalespersonTransactionData)
    }
    #endif
    
    
    func mGetTransactions() {
        
        
        mGetData(url: mGetCustomerPurchaseList,headers: sGisHeaders,  params: ["customer_id":mCustomerId]) { response , status in
            if status {
                
                if let mArr = response.value(forKey: "data") as? NSArray {
                    if mArr.count > 0 {
                        self.mSalespersonTransactionData = mArr
                        self.TransactionTable.delegate = self
                        self.TransactionTable.dataSource = self
                        self.TransactionTable.reloadData()
                    }
                }
            }
        }
    }
    
    
    
    @IBAction func mBack(_ sender: Any) {
        self.dismiss(animated: true)
        
    }
    
    
    
    
    
    @IBAction func mChooseDate(_ sender: Any) {
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        
        return mSalespersonTransactionData.count
        
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        
        let cells = UITableViewCell()
        if tableView == TransactionTable {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CommonTransleCell") as? CommonTransleCell,
               let mData = mSalespersonTransactionData[indexPath.row] as? NSDictionary{
                cell.mOrderNo.text = "\(mData.value(forKey: "order_no") ?? "--")"
                cell.mLocation.text = "\(mData.value(forKey: "location") ?? "--"),"
                cell.mDate.text = "\(mData.value(forKey: "date") ?? "--")"
                cell.mType = "purchase"
                if let mCart = mData.value(forKey: "cart") as? NSArray {
                    if mCart.count > 0 {
                        cell.mCartData = mCart
                        cell.mParkItemsTable.delegate = cell
                        cell.mParkItemsTable.dataSource = cell
                        cell.mParkItemsTable.reloadData()
                        cell.mParkItemsTable.layoutIfNeeded()
                        cell.mParkItemsTable.isHidden = false
                        cell.mTableHeight.constant = cell.mParkItemsTable.contentSize.height + 80
                    }else{
                        cell.mParkItemsTable.isHidden = true
                        cell.mTableHeight.constant = 0
                        
                    }
                    
                }else{
                    cell.mParkItemsTable.isHidden = true
                    cell.mTableHeight.constant = 0
                    
                }
                
                return cell
            }
        }
        
        
        return cells
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        
        return 100
    }
    
    
}
