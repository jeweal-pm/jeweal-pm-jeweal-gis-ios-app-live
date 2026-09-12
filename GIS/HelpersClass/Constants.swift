import UIKit
import Foundation
import Alamofire

//API Base URL

let mGoogleMapKey = ""
//let BaseUrl = "https://api2.gis247.net/api/v1/"

//let BaseUrl = "https://df21-103-15-253-94.ngrok-free.app/api/v1/"
//let BaseUrl = "https://api.gis247.net/api/v1/"
//let BaseUrl = "http://192.168.0.127:8890/api/v1/"

//let BaseUrl = "https://snooze-directly-cogwheel.ngrok-free.dev/api/v1/"

let BaseUrl = "https://api2uat.gis247.net/api/v1/"

//let BaseUrl = "https://api2.gis247.net/api/v1/"
//let BaseUrl = "https://overturn-mobster-idiom.ngrok-free.dev/api/v1/"

//"https://api2uat.gis247.net/api/v1/"//"https://api2.gis247.net/api/v1/"
//let BaseUrl = "https://snooze-directly-cogwheel.ngrok-free.dev/api/v1/"//"https://api2.gis247.net/api/v1/"
let agent = "\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? "").\(Bundle.main.infoDictionary?["CFBundleVersion"] ?? "")"
var sGisHeaders: HTTPHeaders = [ "Authorization": UserDefaults.standard.string(forKey: "token") ?? "",
                                 "pos-authorization": UserDefaults.standard.string(forKey: "token_pos") ?? "",
                                 "agent" : agent,
                                 "platform" : mGetDeviceInfo(),
                                 "Content-Type": "application/json" ]
//Without Content Type
var sGisHeaders2: HTTPHeaders = [ "Authorization": UserDefaults.standard.string(forKey: "token") ?? "",
                                  "pos-authorization": UserDefaults.standard.string(forKey: "token_pos") ?? "",
                                  "agent" : agent,
                                  "platform" : mGetDeviceInfo() ]

/**GRAPHQL*/
let mGrapQlUrl = BaseUrl + "App/graphql"
let mInventoryGrapQlUrl = BaseUrl + "Inventory/graphql"

//API Endpoints
let mLoginUser = BaseUrl+"Auth/Mobile/login"
let mPOSAuthToken = BaseUrl+"Mobile/auth/generatePOSAuthToken"
let mResendOneTimeCode = BaseUrl+"Auth/Mobile/resendOtp"
let mVerifyOneTimeCode = BaseUrl+"Auth/Mobile/verification"

let mLogOutUser = BaseUrl+"Auth/Mobile/logoutquick"
let mLoginUserWithPin = BaseUrl+"Auth/Mobile/loginquick"
let mVerifyPin = BaseUrl+"pos/common/loginPINVerfy"
let mFetchStores = BaseUrl + "Mobile/getVoucherList"
let mFetchProfileDetails = BaseUrl+"Mobile/getProfile"

let mResetPassword = BaseUrl+"Auth/Mobile/forgotPassword"
let mResetPin = BaseUrl+"Auth/Mobile/forgotPin"
let mResendOTP = BaseUrl+"Webservice/resendtoken"
let mGetCustomerList = BaseUrl + "Customer/customer/getList"
let mGetCustomerById = BaseUrl + "App/customer/get"
let mGenerateImageUrlAPI = BaseUrl + "App/customer/uploadImage"
let mCreateCustomer = BaseUrl + "App/customer/create"
let mGetCustomerPaymentAndHistory = BaseUrl + "Customer/getCustomerPurchaseAndpaymentHistory"
let mProductInformation = BaseUrl + "Mobile/pos/customOrder/productDetail"
/**MixAndMatch */
let mGetItemType = BaseUrl + "Mobile/pos/common/getItemList"
let mGetMixAndMatchCatalog = BaseUrl + "Mobile/pos/mixAndMatch/getProductList"
let mGetMixAndMatchCatalogDetails = BaseUrl + "Mobile/pos/mixAndMatch/getProductDetailById"
let mGetMixAndMatchInventroy = BaseUrl + "Mobile/pos/mixAndMatch/getJewelryList"
let mGetMixMatchDetails = BaseUrl + "Mobile/pos/customOrders/getMixMatchItemDetail"
let mAddToCartMixAndMatch = BaseUrl + "Mobile/pos/customOrders/addMixMatchToCart"

/**Diamond Reserve*/
let mDiamondDetailsAPI = BaseUrl + "Inventory/diamond/getDetails"
let mDiamondListAPI = BaseUrl + "Mobile/diamond/getList" //Inventory/diamond/getList"
let mDiamondFiltersAPI = BaseUrl + "Inventory/diamond/getFilters"
let mDiamondCreateReserveAPI = BaseUrl + "Inventory/diamond/createReserve"
let mDiamondRemoveReserveAPI = BaseUrl + "Inventory/diamond/removeReserve"
let mDiamondReservedListAPI = BaseUrl + "Inventory/diamond/getReserveList"

/**Sales Person**/
let mGetSalesPersonList = BaseUrl + "Customer/GetSalesperson"
let mSearchCustomerByKey = BaseUrl + "Customer/Search_Customer_by_Key"
let mGetSalesReports = BaseUrl + "pos/salesPersonTransactions_month"

/**SEARCH**/
let mCommonSearchAPI = BaseUrl+"Mobile/pos/customOrders/skuNameBySearch"
//----------------------

let mGetProductDetails = BaseUrl + "Customer/productsDetail"

/**Catalogue*/
let mAddToFav = BaseUrl + "Mobile/Catalog/updateWishlist"
let mGetCatalogue = BaseUrl + "Mobile/catalog/getCatalogList"
let mGetCatalogDetails = BaseUrl + "Mobile/catalog/getCatalogDetail"
let mGetCatalogVariantsDetails = BaseUrl + "POS/customOrder/getProductDetail_Variants"
let mGetWishList = BaseUrl + "Mobile/catalog/getCustomerWishList"
let mGetCustomerWishList = BaseUrl + "Mobile/catalog/getProductWishList"
let mGetVariantData = BaseUrl + "Catalog/getCatelogData_usingVariant"
let mEnquiry = BaseUrl + "Inventory/addfavourite_Enquiery"
let mGetFilters = BaseUrl + "Customer/product_filter_data"
/**ItemSearch*/
let mSearchItems = BaseUrl + "Mobile/itemsearch/itemSearchData"
let mGetItemSearchReserveOrderData  = BaseUrl + "Mobile/itemsearch/itemSearchList"
let mReserveSoldAPI = BaseUrl + "Mobile/my/itemSearchTransection"
let mSoldAPI = BaseUrl + "Mobile/my/itemSearchSoldTransection"

let mTempReserve = BaseUrl+"Inventory/reserveAddTempListItemSearch"
let mGetTempReserve = BaseUrl+"Inventory/getMyReserveTempList"

let mItemKeySearch = BaseUrl+"Mobile/my/itemKeySearch"

/**QuickView*/
let mQuickViewSearch = BaseUrl+"Mobile/quickView/getQuickViewSearch"
let mQuickViewFilterData = BaseUrl+"QuickView/getMasterProductImage"
let mGetQuickViewData = BaseUrl+"Inventory/quickview/result"
let mGetQuickViewCatalogDataOLD = BaseUrl+"Mobile/quickview/result" // Not In Use
let mGetQuickViewCatalogData = BaseUrl+"Inventory/quickview/result-catalog"
let mAllGetCatalogItems = BaseUrl+"Mobile/quickView/orderList"

let mGetQuickViewOrderReserveData = BaseUrl+"Mobile/quickView/getQuickViewList"

/** Custom Order*/
let mSearchProductByKey = BaseUrl + "Customer/Search_Product_by_Key"
let mGetShapes = BaseUrl + "Mobile/pos/customOrder/getShape"
let mAddCustomProduct = BaseUrl + "Mobile/pos/customOrder/addItemToCart"
let mReserveToCart = BaseUrl + "POS/reserve/reserveToCart"
let mAddReserveProduct = BaseUrl + "Mobile/pos/reserve/addItemsToCart"

let mAddDiamondProduct = BaseUrl + "Mobile/pos/customOrders/addDiamondToCart"
let mAddRepairProduct = BaseUrl + "Mobile/pos/customOrders/addrepairItemsToCart"
let mRemoveCustomProduct = BaseUrl + "Customorder/removeCustom"
let mFetchCustomProduct = BaseUrl + "Mobile/pos/customOrders/getCartItems"
let mFinalCheckoutCustomOrder = BaseUrl + "Mobile/pos/customOrder/saveCustomOrder"
let mFetchProductStoneDetails = BaseUrl + "Mobile/pos/customOrder/getCartItemDetails"
let mGetMetalsSizeColor = BaseUrl + "Mobile/pos/customOrder/motherProductDetailById"
let mGetItemSize = BaseUrl + "APP/product/getsizes"
let mDeleteCartItem = BaseUrl + "Mobile/pos/customOrder/deleteCartItem"
let mUpdateProductStoneDetails = BaseUrl + "Mobile/pos/customOrder/editCartItemDetails"
let mUpdateCustomOrderProduct = BaseUrl + "Mobile/pos/customOrder/editCustomOrderCart"
let mRestoreLinkedCartStatus = BaseUrl + "Mobile/pos/customOrder/restoreLinkedCartStatus"

/// Values returned by `getInventoryList` that identify an existing linked cart.
/// They are kept outside the cart-item payload because the cart APIs do not
/// guarantee that these inventory-only fields are echoed back in their response.
struct LinkedCartContext {
    let linkedCartId: String
    let linkedOrderId: String
    let existingCartStatus: String
    let canCreateNewCart: Bool
    let linkedOrderType: String

    init(inventoryItem: NSDictionary) {
        linkedCartId = Self.string(inventoryItem["linked_cart_id"])
        linkedOrderId = Self.string(inventoryItem["linked_order_id"])
        existingCartStatus = Self.string(inventoryItem["existing_cart_status"])
        linkedOrderType = Self.string(inventoryItem["linked_order_type"])

        let value = inventoryItem["can_create_new_cart"]
        if let bool = value as? Bool {
            canCreateNewCart = bool
        } else if let number = value as? NSNumber {
            canCreateNewCart = number.boolValue
        } else {
            switch Self.string(value).lowercased() {
            case "false", "0", "no":
                canCreateNewCart = false
            default:
                // An absent or malformed value must never trigger a restore.
                canCreateNewCart = true
            }
        }
    }

    private static func string(_ value: Any?) -> String {
        guard let value, !(value is NSNull) else { return "" }
        return "\(value)".trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

final class LinkedCartContextStore {

    static let shared = LinkedCartContextStore()

    private var contexts = [String: LinkedCartContext]()

    private func key(orderType: String, customerId: String) -> String {
        "\(orderType)|\(customerId)"
    }

    func save(
        _ context: LinkedCartContext,
        orderType: String,
        customerId: String
    ) {
        contexts[key(orderType: orderType, customerId: customerId)] = context
    }

    func context(
        orderType: String,
        customerId: String
    ) -> LinkedCartContext? {

        contexts[key(orderType: orderType, customerId: customerId)]
    }

    // ============================
    // ADD THIS
    // ============================

    func clear(
        orderType: String,
        customerId: String
    ) {

        contexts.removeValue(
            forKey: key(
                orderType: orderType,
                customerId: customerId
            )
        )
    }
}

let mCustomDesignDetails = BaseUrl + "Mobile/pos/customOrder/getCartItemDetails"
let mAddConceptDesign = BaseUrl + "Mobile/pos/customOrder/updateCartItemDesign"
let mCustomProductUpdate = BaseUrl + "Customorder/customProductUpdate"
let mRegister = BaseUrl + "customer/Create"
let mFonts = BaseUrl + "Customorder/getFonts"
let mFetchCountries = BaseUrl +   "master/country"
let mFetchStates = BaseUrl +   "master/state/"
let mFetchCities = BaseUrl +   "master/city/"
/**StockTake*/

let mGetStockTake = BaseUrl+"Mobile/stocktake/stockTakeList"
let mUploadStocks = BaseUrl+"Mobile/stocktake/stockTakeCreate"
let sSkuDetail = BaseUrl + "Mobile/stocktake/skuDetail"

/**Print*/

let mGetDiamondPrint = BaseUrl+"Mobile/inventory/print/diamondSearch"

let mGetInventoryPrint = BaseUrl+"Mobile/inventory/print/myInventory"
let mGetInventorySummaryPrint = BaseUrl+"Inventory/getMyInventorySummary_print"

let mPrintPdf = BaseUrl+"Mobile/inventory/print/myInventory"
//let mGetCatalogPdf = BaseUrl + "POS/customOrder/getCatalogPdf"
let mGetCatalogPdf = BaseUrl + "POS/customOrder/getCatalogPdfMobile"


let mNewInventoryPrint = BaseUrl+"Inventory/inventory/print/myInventory"
let mNewDiamondPrint = BaseUrl+"Inventory/inventory/print/diamondSearch"

/**Inventory*/

let mGetInventory = BaseUrl+"Mobile/my/getInventoryList"
let mGetInventorySummary = BaseUrl+"Mobile/my/getSummery"
let mAddToReserve = BaseUrl+"Inventory/myInventoryToReserve"
let mGetReserveList = BaseUrl+"Mobile/my/getReserveList"
let mCreateReserve = BaseUrl+"Mobile/my/createReserve"
let mCreateReserveOrder = BaseUrl+"Mobile/my/createReserveOrder"
let mRemoveReserve = BaseUrl+"Mobile/my/removeReserve"
//Summary Details
let sSummerySkuDetails = BaseUrl+"Mobile/my/summerySkuDetails"

/**Filters*/

let mGetInventoryFilter = BaseUrl+"Mobile/my/getFilters"

let mGetCatalogFilter = BaseUrl+"Catalog/getMasterProductFilter"
let mGetCustomerFilter = BaseUrl+"App/customer/customerFilter"

/**POS*/

let mPOSCustomerTransactions = BaseUrl+"Mobile/pos/report/customer"
let mPOSSalesPerson = BaseUrl+"Mobile/pos/report/salesPerson"
let mPOSSettings = BaseUrl+"Mobile/common/getPOSSettings"
let mClearDataApi = BaseUrl+"Mobile/pos/customOrder/cartClear"
let mFetchStoreData = BaseUrl+"Pos/posDetails_get"
let mFetchPaymentMethod = BaseUrl+"pos/checkout/payment/getCashMethodList"
let mPOSSearch = BaseUrl+"pos/pos_searchByKey"
let mPOSpay = BaseUrl+"pos/SalesOrderCreate"
let mPOSCreditNote = BaseUrl+"Mobile/pos/checkout/creditnote/getCreditNote"
let mPOSReport = BaseUrl + "ReportApi/POS_InvoiceprintCustomerCopy"
let mCreditCardAdd = BaseUrl + "checkout/addCardDetail"
let mEmailReport = BaseUrl + "Mobile/pos/mail/invoiceMail"
let mApplyForGiftCard = BaseUrl+"Pos/posGiftcardApply"

let mStockIdManage = BaseUrl+"Mobile/pos/customOrder/stockIdManage"
let mVoucherStatus = BaseUrl+"Mobile/common/getVoucherStatus"

let mGeneratePaypalQRCode = BaseUrl + "pos/PaymentQRcode/generatePaypalQRcodeMobile"
let mGenerateCregisQRCode = BaseUrl + "POS/PaymentQRcode/generateQRcode"

/**Installments  & Layby*/
let mGetInstallmentPlans = BaseUrl+"Mobile/receive/calculateInstallments"

let mGetAllReceivedItems = BaseUrl+"Mobile/receive/LayByList"
let mGetPurchasedItems = BaseUrl+"Mobile/receive/getLayBySKUList"
let mGetPartialPaymentHistory = BaseUrl+"Mobile/customer/getpartialPaymentHistory"
let mGetPartialPaymentDetails = BaseUrl+"Mobile/customer/getpartialPaymentTransaction"


/**Quotations*/
let mGetAllQuotations = BaseUrl+"Mobile/quatation/getQuatationList"
let mRemoveQuotation = BaseUrl+"Mobile/quatation/removeQuatation"
let mGetQuotedItems = BaseUrl+"Mobile/quatation/getQuatationSubList"
let mSaveQuotation = BaseUrl+"Mobile/quatation/saveQuatation"

let mQuotationDesign = BaseUrl+"Mobile/quatation/quotationCartInfo"

/**PARKING**/
let mAddToPark = BaseUrl+"Mobile/pos/park/savepark"
let mGetPark = BaseUrl+"Mobile/pos/park/getParkList"
let mRemovePark = BaseUrl+"Mobile/pos/park/removePark"
/**SALES PERSON**/
let mGetSalesPersonTransactions = BaseUrl+"Mobile/pos/report/salesPerson"
let mGetCustomerTransactions = BaseUrl+"Mobile/pos/report/customer"
/**CUSTOMER TRANSACTIONS**/
let mGetCustomerPurchaseList = BaseUrl+"Mobile/pos/report/Transaction"
let mGetCustomerPaymentHistory = BaseUrl+"Mobile/pos/report/paymentHistory"

/**COUPONS*/

let mAddNewCoupons = BaseUrl + "Mobile/pos/giftCard/createGiftCard"
let mDeleteCoupons = BaseUrl + "Mobile/pos/giftCard/removeGiftCard"
let mFetchCoupons = BaseUrl + "Mobile/pos/giftCard/getGiftCard"
let mUpdateCoupons = BaseUrl + "Mobile/pos/giftCard/editGiftCard"
let mGiftPayment = BaseUrl + "pos/giftCardPayment"

/**DEPOSIT*/
let mDepositAdd = BaseUrl + "pos/deposit_paymentTypeAdd"
let mDepositRemove = BaseUrl + "pos/depositRowremove"
let mDepositGet = BaseUrl + "pos/get_depositpaymentType"
let mDepositSubmit = BaseUrl + "pos/depositSubmit"

/**MORE*/

let mPurchaseHistory = BaseUrl + "Pos/exchangeHistoryDataget"
let mExchangeItem = BaseUrl + "pos/exchangeFormsSubmit"

/**ServiceLabour*/

let mSaveServiceLabour = BaseUrl+"Mobile/pos/customOrder/saveServiceLabour"


/**Repair Order*/

let mGetOptions = BaseUrl + "pos/getRepairOptions"
let mGetSalesOrderHistory = BaseUrl + "Mobile/pos/customOrders/getSalesOrderListByCustomer"
let mAddRepairItems = BaseUrl+"Mobile/pos/customOrders/addrepairItemsToCart"
let mGetRepairItems = BaseUrl+"pos/purchaseHistorySaveDataget"
let mRemoveRepairItems = BaseUrl+"pos/repairHistoryDelete"
let mCustomRepair = BaseUrl + "pos/addRepairList"
let mSubmitRepairDesign = BaseUrl+"Mobile/pos/customOrders/editCartItemDetails"

/**CHECKOUT*/
let mGetCurrencies = BaseUrl+"Mobile/common/exchange-rates"
let mGetQRCode = BaseUrl+"POS/PaymentQRcode/generateQRcode"
let mCancelQR = BaseUrl+"POS/PaymentQRcode/cancelQRcode"
let mGetPaymentStatus = BaseUrl+"POS/PaymentQRcode/getPaymentStatus"
let mCregisQueryOrder = BaseUrl+"POS/PaymentQRcode/cregis/queryOrder"
let mGetStipData = BaseUrl+"pos/PaymentQRcode/getPayment-token"


/**TRACKING**/
let mTrackProductDetailsApi = BaseUrl+"ledger/get-product-info"
let mTrackProductHistoryApi = BaseUrl+"ledger/get-history"
/**INVENTORY DETAILS**
 */

let mInventorySearch =  "https://gis247.net/hcsdeveloper/api/Inventory/getInventoryDetails"

// MARK: Customer Address Module
let mGetCustomerAddressList = BaseUrl+"Customer/address/list"
let mEditAndSaveCustomerAddress = BaseUrl+"Customer/address/edit-address"
let mCheckAddress = BaseUrl+"App/customer/checkAddress"

//App Colors
let themeIndigoColor = UIColor.init(red: 0.21, green: 0.31, blue: 0.76, alpha: 1.0)
let themeOrangeColor = UIColor.init(red: 0.98, green: 0.68, blue: 0.16, alpha: 1.0)
let greenBack = UIColor.init(red: 0.91, green: 0.97, blue: 0.92, alpha: 1.0)
let greenText = UIColor.init(red: 0.35, green: 0.73, blue: 0.36, alpha: 1.0)
let redBack = UIColor.init(red: 0.96, green: 0.82, blue: 0.82, alpha: 1.0)
let redText = UIColor.init(red: 0.73, green: 0.35, blue: 0.35, alpha: 1.0)
let redish = UIColor.init(red: 0.91, green: 0.40, blue: 0.40, alpha: 1.0)
let green = UIColor.init(red: 47/255.0, green: 191/255.0, blue: 140/255.0, alpha: 1.0)


// MARK: Faro
let mGetFaroSearchAPI = BaseUrl + "POS/catalog/search"
let mGetFaroDiscoverAPI = BaseUrl + "POS/catalog/discover"

//Other Constants
//let mGetOrderPdf = BaseUrl + "api/v1/POS/customOrder/getOrderPdf"
//let mBaseURL = "https://api2.gis247.net/api/v1"
//let mBaseURL = "https://api2.gis247.net/api/v1/"
let mGetOrderPdf = "\(BaseUrl)/POS/customOrder/getOrderPdf"

var mUserLoginToken = UserDefaults.standard.string(forKey: "token")
var mUserLoginTokenPos = UserDefaults.standard.string(forKey: "token_pos")

var mUserLoginTokenR = UserDefaults.standard.string(forKey: "login_tokenR")
var mUserVehicleId = UserDefaults.standard.string(forKey: "mUserVehicleId")
var myDeviceToken = ""

var mDriverLatitude = ""
var mDriverLongitude = ""
let myDeviceUDID = UIDevice.current.identifierForVendor!.uuidString

let headers:
HTTPHeaders = [
    "Authorizations": mUserLoginToken!,
    "Content-Type": "application/x-www-form-urlencoded"
]
let headerss:
HTTPHeaders = [
    "Authorization": mUserLoginToken!,
    "pos-authorization": mUserLoginTokenPos!,
    "agent" : agent,
    "platform" : mGetDeviceInfo(),
    "Content-Type": "application/json"
]

let headersR:
HTTPHeaders = [
    "Authorizations": mUserLoginTokenR!,
    "Content-Type": "application/json"
]
