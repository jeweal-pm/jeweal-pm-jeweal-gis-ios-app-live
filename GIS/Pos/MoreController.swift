//
//  MoreController.swift
//  GIS
//
//  Created by Apple Hawkscode on 30/03/21.
//

import UIKit
import Alamofire
class MoreController: UIViewController, OpenCustomerMixMatchDelegate, UIViewControllerTransitioningDelegate {
    //Labels
    @IBOutlet weak var mExchangeLABEL: UILabel!
    @IBOutlet weak var mRefundLABEL: UILabel!
    @IBOutlet weak var mCustomOrderLABEL: UILabel!
    @IBOutlet weak var mRepairLABEL: UILabel!
    @IBOutlet weak var mWishListLABEL: UILabel!
    @IBOutlet weak var mReceiveLABEL: UILabel!
    @IBOutlet weak var mGiftCardLABEL: UILabel!
    @IBOutlet weak var mReserveLABEL: UILabel!
    @IBOutlet weak var mQuotationLABEL: UILabel!
    //View Outlets
    @IBOutlet weak var sCustomView: UIView!
    @IBOutlet weak var sRepairView: UIView!
    @IBOutlet weak var sExchangeView: UIView!
    @IBOutlet weak var sRefundView: UIView!
    @IBOutlet weak var sReceiveView: UIView!
    @IBOutlet weak var sGiftCardView: UIView!
    @IBOutlet weak var sReserveView: UIView!
    @IBOutlet weak var sWishlistView: UIView!
    //Other views
    @IBOutlet weak var mQuotationView: UIView!
    @IBOutlet weak var mDepositImage: UIImageView!
    @IBOutlet weak var mQUOTATIONBUTTON: UIButton!
    //ViewsDisabled
    private var disableCustomOrderView = false
    private var disableMixNmatchView = false
    private var disableDepositView = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mGiftCardLABEL.text = "Gift Card".localizedString
        mReserveLABEL.text = "Reserve".localizedString

        mExchangeLABEL.text = "Exchange".localizedString
        mRefundLABEL.text = "Refund".localizedString
        mRepairLABEL.text = "Repair".localizedString
        mCustomOrderLABEL.text = "Custom".localizedString
        mWishListLABEL.text = "Wishlist".localizedString
        mReceiveLABEL.text = "Receive".localizedString
        mQuotationLABEL.text = "Quotation".localizedString
        
        //Check Vouchers
        sCheckVouchers()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        let linkedCartId = UserDefaults.standard.string(forKey: "reserve_linked_cart_id") ?? ""
        let linkedOrderType = UserDefaults.standard.string(forKey: "reserve_linked_order_type") ?? ""
        let canCreateNewCart = UserDefaults.standard.object(
            forKey: "reserve_can_create_new_cart"
        ) as? Bool
        let linkedOrderTypesThatMustBePreserved = ["reserve", "repair", "repair_order"]
        let hasActiveLinkedCart =
            !linkedCartId.isEmpty &&
            linkedOrderTypesThatMustBePreserved.contains(linkedOrderType.lowercased()) &&
            canCreateNewCart == false

        // Do not clear an existing linked Reserve or Repair cart merely
        // because the More tab becomes visible. That would remove the cart
        // before PosCart can ask the user whether to quit the linked flow.
        if UserDefaults.standard.bool(forKey: "connected_order_restore_in_progress") {
            print("MoreController: defer clear cart while linked cart restore is pending")
        } else if hasActiveLinkedCart {
            print("MoreController: preserve active linked cart")
        } else {
            print("🔥 MoreController.swift mClearCart called")
            mGetData(url: mClearDataApi,headers: sGisHeaders,  params: ["":""]) { response , status in
                if status {
                    if let mCode =  response.value(forKey: "code") as? Int {
                        if mCode == 403 {
                            CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                            return
                        }
                    }
                }
            }
        }
        if UserDefaults.standard.bool(forKey: "isQuotation") == true {
            self.mQuotationView.isHidden = false
        }else{
            self.mQuotationView.isHidden = true
        }
        
        if UserDefaults.standard.bool(forKey: "isPartial") == true {
            self.mDepositImage.image = UIImage(named: "deposit_ic")
            self.mReceiveLABEL.text = "Receive".localizedString
        }else{
            self.mDepositImage.image = UIImage(named: "newDepositIcon")
            self.mReceiveLABEL.text = "Deposit".localizedString
        }
        
    }
    
    private func sCheckVouchers(){
        
        guard Reachability.isConnectedToNetwork() == true else {
            CommonClass.showSnackBar(message: "Check Internt connection and try again.")
            return
        }
        CommonClass.showFullLoader(view: self.view)
        AF.request(mVoucherStatus, method:.post,encoding: JSONEncoding.default,headers: sGisHeaders).responseJSON
        { response in
            CommonClass.stopLoader()
            
            guard response.error == nil else {

                return
            }
            
            guard let jsonData = response.data else {
                CommonClass.showSnackBar(message: "OOP's something went wrong!")
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? NSDictionary,
                let code = json["code"] as? Int else {
                    CommonClass.showSnackBar(message: "OOP's something went wrong!")
                    return
                }
                
                switch code {
                case 200:
                    if let data = json["data"] as? [String: Any] {
                        if let check = data["Repair_Order"] as? Int, check == 0 {
                            self.sRepairView.addSubview(DisabledOverlayView(on: self.sRepairView))
                        }
                        if let check = data["Exchange"] as? Int, check == 0 {
                            self.sExchangeView.addSubview(DisabledOverlayView(on: self.sExchangeView))
                        }
                        if let check = data["Refund"] as? Int, check == 0 {
                            self.sRefundView.addSubview(DisabledOverlayView(on: self.sRefundView))
                        }
                        if let check = data["Gift_Card"] as? Int, check == 0 {
                            self.sGiftCardView.addSubview(DisabledOverlayView(on: self.sGiftCardView))
                        }
                        if let check = data["Quotation"] as? Int, check == 0 {
                            self.mQuotationView.addSubview(DisabledOverlayView(on: self.mQuotationView))
                        }
                        if let check = data["Deposit"] as? Int, check == 0 {
                            self.disableDepositView = true
                        }
                        if let check = data["Custom_Order"] as? Int, check == 0 {
                            self.disableCustomOrderView = true
                        }
                        if let check = data["Mix_And_Match"] as? Int, check == 0 {
                            self.disableMixNmatchView = true
                        }
                    }
                    break
                case 403:
                    CommonClass.sessionExpired(isExpired: true, navigation: self.navigationController)
                    break
                default:
                    let errorMessage = json["message"] as? String ?? "An error occurred."
                    CommonClass.showSnackBar(message: "Error \(code): \(errorMessage)")
                    break
                }
            } catch {
                CommonClass.showSnackBar(message: "OOP's something went wrong!")
            }
        }

        
    }
    
    @IBAction func mExchange(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
        if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "ExchangeController") as? ExchangeController {
            self.navigationController?.pushViewController(mCustomCart, animated:true)
        }
    }
    
    @IBAction func mRefund(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
        if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "RefundController") as? RefundController {
            self.navigationController?.pushViewController(mCustomCart, animated:true)
        }
    }
    
    @IBAction func mCustomOrder(_ sender: Any) {

        if UserDefaults.standard.bool(forKey: "isMixMatch") == true {
            
            let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
            if let mOpenCustomAndMixMatch = storyBoard.instantiateViewController(withIdentifier: "OpenCustomAndMixMatch") as? OpenCustomAndMixMatch {
                mOpenCustomAndMixMatch.modalPresentationStyle = .overFullScreen
                mOpenCustomAndMixMatch.delegate = self
                print("MoreController AFTER SET =", mOpenCustomAndMixMatch.delegate as Any)
                mOpenCustomAndMixMatch.transitioningDelegate = self
                mOpenCustomAndMixMatch.disableCustomOrderView = disableCustomOrderView
                mOpenCustomAndMixMatch.disableMixNmatchView = disableMixNmatchView
                self.present(mOpenCustomAndMixMatch,animated: true)
            }
        }else{
            let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
            if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "CustomCart") as? CustomCart {
                self.navigationController?.pushViewController(mCustomCart, animated:true)
            }
        }
        
    }
    
    @IBAction func mRepairOrder(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
        if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "RepairOrderController") as? RepairOrderController {
            self.navigationController?.pushViewController(mCustomCart, animated:true)
        }
    }
    
    @IBAction func mReserve(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "reserveOrderBoard", bundle: nil)
        if let home = storyBoard.instantiateViewController(withIdentifier: "ReserveCart") as? ReserveCart {
            self.navigationController?.pushViewController(home, animated:true)
        }
    }
    
    @IBAction func mQuotation(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "quotation", bundle: nil)
        if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "Quotations") as? Quotations {
            self.navigationController?.pushViewController(mCustomCart, animated:true)
        }
    }
    
    @IBAction func mDeposit(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "isPartial") == true {
            let storyBoard: UIStoryboard = UIStoryboard(name: "common", bundle: nil)
            if let mOpenDepositReceive = storyBoard.instantiateViewController(withIdentifier: "OpenDepositReceive") as? OpenDepositReceive {
                mOpenDepositReceive.modalPresentationStyle = .overFullScreen
                mOpenDepositReceive.delegate = self
                mOpenDepositReceive.transitioningDelegate = self
                mOpenDepositReceive.disableDepositView = disableDepositView
                self.present(mOpenDepositReceive,animated: true)
            }
        }else{
            let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
            if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "DepositController") as? DepositController {
                UserDefaults.standard.set(NSMutableArray(), forKey: "TEMPDATA")
                self.navigationController?.pushViewController(mCustomCart, animated:true)
            }
        }
        
        
        
    }
    
    @IBAction func mGiftCard(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
        if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "POSCoupons") as? POSCoupons {
            self.navigationController?.pushViewController(mCustomCart, animated:true)
        }
    }
    @IBAction func mWishList(_ sender: Any) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "catalog", bundle: nil)
        if let mWishList  = storyBoard.instantiateViewController(withIdentifier: "WishlistSearchNew") as? WishlistSearch {
            self.navigationController?.pushViewController(mWishList, animated:true)
        }
    }
    
    func mOnClickItem(controller: String) {
        print("mOnClickItem =", controller)
        if controller == "custom" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "customOrder", bundle: nil)
            if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "CustomCart") as? CustomCart {
                self.navigationController?.pushViewController(mCustomCart, animated:true)
            }
        }else if controller == "deposit" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "moreBoard", bundle: nil)
            if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "DepositController") as? DepositController {
                UserDefaults.standard.set(NSMutableArray(), forKey: "TEMPDATA")
                self.navigationController?.pushViewController(mCustomCart, animated:true)
            }
        }else if controller == "receive" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "laybyInstallment", bundle: nil)
            if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "ReceivedLayByInstallments") as? ReceivedLayByInstallments {
                self.navigationController?.pushViewController(mCustomCart, animated:true)
            }
        }else if controller == "mixMatch" {
            let storyBoard: UIStoryboard = UIStoryboard(name: "mixNMatch", bundle: nil)
            if let mCustomCart = storyBoard.instantiateViewController(withIdentifier: "MixMatchCart") as? MixMatchCart {
                self.navigationController?.pushViewController(mCustomCart, animated:true)
            }
        }
    }

}
