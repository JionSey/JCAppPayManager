
import UIKit
import StoreKit

class JCApplePurchaseBusiness: NSObject {
    
    // MARK: - Defined Attribute
    
    typealias GetProductListBlock = ([SKProduct]?) -> ()
    public var getProductListBlock : GetProductListBlock? = nil
    
    typealias ProductPaySucInfoBlock = (String, [String : Any]) -> ()
    public var productPaySucInfoBlock : ProductPaySucInfoBlock? = nil
    
    typealias  NormalBlock = () -> ()
    public var paySuccessedBlock : NormalBlock? = nil
    
    var products: [SKProduct]?
    var orderId = ""
    
    // MARK: - Init Method
    
    static let showJCApplePurchaseBusinessInstance = JCApplePurchaseBusiness()
    
    private override init() {
        
        super.init()
    }
    
    // MARK: - InitData
    
    func initData() {
        
        self.getProductListBlock = { [weak self] (products) in
            
            self?.products = products
        }
        
        self.productPaySucInfoBlock = { [weak self] (productIdentifier, dict) in
            
            if let receiptData = dict["receipt"] as? String, let orderId = self?.orderId {
                self?.requestAppstoreInfo(receiptData: receiptData, orderId: orderId)
            } else {
                print("AppStore的验签参数错误!")
            }
        }
    }
    
    // MARK: - Config Data
    
    // 获取价格列表
    func getApplePayGoodsList(ids:Set<String>) -> Bool {
        
        if !JCApplePurchaseTool.showJCApplePurchaseToolInstance.getGoodsList(ids: ids) {
            return false
        }
        return true
    }
    
    // MARK: - Event Response
    
    // MARK: - NSNotificationCenter Method
    
    // MARK: - other Method
    
    // 根据价格获取指定商品
    func filtrationProduct(price: Double) -> SKProduct? {
        
        guard let products = products else {
            return nil
        }
        
        for product in products {
            if product.price == NSDecimalNumber.init(value: price) {
                return product
            }
        }
        return nil
    }
    
    // 支付商品
    func payProduct(product: SKProduct) {
        
        JCApplePurchaseTool.showJCApplePurchaseToolInstance.payProduct(product: product)
    }
    
    // MARK: - Getters & Setters
    
    // MARK: - Deinit Method
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - System Delegate

// MARK: - Custom Delegate

// 将具体业务剥离...
extension JCApplePurchaseBusiness {
    
    // 根据服务的配置项 校验可购买的appStore项目 获取购买列表
    public func checkAppstoreBuyItem(canBuyList: Set<String>?) -> (canBuy: Bool, mesage: String) {
        
        if let payItemIds = canBuyList {
            // 校验支付功能并提交appstore获取可销售列表
            if !self.getApplePayGoodsList(ids: payItemIds) {
                return (canBuy: false, mesage: "未开启支付功能")
            }
        } else {
            return (canBuy: false, mesage: "可用内购项目项为空")
        }
        
        return (canBuy: true, mesage: "")
    }
    
    // 下单生成后 发起苹果支付
    public func checkOrderInfoPayProductForAppStore(orderId: String?, price: Double) -> (canBuy: Bool, mesage: String) {
        
        if let orderId = orderId {
            // 开始进行苹果支付流程
            self.orderId = orderId
            return self.payProductForAppStore(price: price)
        } else {
            return (canBuy: false, mesage: "数据错误, 下单失败!")
        }
    }
    
    // 校验价格并发起支付
    public func payProductForAppStore(price: Double) -> (canBuy: Bool, mesage: String) {
        
        if let _ = products {
            // 校验当前价格是否在可销售列表内
            if let product = self.filtrationProduct(price: price) {
                // 根据价格的订单发起苹果支付
                self.payProduct(product: product)
                return (canBuy: true, mesage: "")
            } else {
                return (canBuy: false, mesage: "当前的商品暂时不可销售")
            }
        } else {
            return (canBuy: false, mesage: "当前可销售的产品列表为空, 请稍后再试!")
        }
    }
    
    // 上传appstor信息
    public func requestAppstoreInfo(receiptData: String, orderId: String) {
        
        let payVerifyReceiptModel = JCPayVerifyReceiptModel.init(receiptData: receiptData, orderId: orderId, token: "token")
        self.requestAppstoreInfo(isLeakList: false, payVerifyReceiptModel: payVerifyReceiptModel)
    }
    
    // 保存苹果已扣款的订单
    func savePayOrder(applePayOrderItem: JCAppleOrderItemModel) {
        
        var appleOrderModel = JCUserDefaultsTool.getAppleOrderListModel()
        var appleOrderListModel = appleOrderModel.appleOrderList
        for appleOrderItemModel in appleOrderListModel {
            if appleOrderItemModel.orderId == applePayOrderItem.orderId {
                return
            }
        }
        appleOrderListModel.append(applePayOrderItem)
        appleOrderModel.appleOrderList = appleOrderListModel
        JCUserDefaultsTool.saveAppleOrderListModel(model: appleOrderModel)
    }
    
    // 删除苹果已扣款的订单
    func delectPayOrder(payVerifyReceiptModel: JCPayVerifyReceiptModel) {
        
        var appleOrderModel = JCUserDefaultsTool.getAppleOrderListModel()
        var appleOrderListModel = appleOrderModel.appleOrderList
        for (index, appleOrderItemModel) in appleOrderListModel.enumerated() {
            if appleOrderItemModel.orderId == payVerifyReceiptModel.orderId {
                appleOrderListModel.remove(at: index)
                appleOrderModel.appleOrderList = appleOrderListModel
                JCUserDefaultsTool.saveAppleOrderListModel(model: appleOrderModel)
                return
            }
        }
    }
    
    // ApplePay 漏单处理
    func leakListDispose() {
        
        let appleOrderListModel = JCUserDefaultsTool.getAppleOrderListModel().appleOrderList
        for appleOrderItemModel in appleOrderListModel {
            let payVerifyReceiptModel = JCPayVerifyReceiptModel.init(receiptData: appleOrderItemModel.receipt, orderId: appleOrderItemModel.orderId, token: appleOrderItemModel.token)
            self.requestAppstoreInfo(isLeakList: true, payVerifyReceiptModel: payVerifyReceiptModel)
        }
    }
    
    // 上传appstor信息
    func requestAppstoreInfo(isLeakList: Bool, payVerifyReceiptModel: JCPayVerifyReceiptModel) {
        
        // 当不为漏单处理时，将订单加入漏单列表缓存
        if !isLeakList {
            let appleOrderItemModel = JCAppleOrderItemModel.init(orderId: payVerifyReceiptModel.orderId, receipt: payVerifyReceiptModel.receiptData, token: "token")
            JCApplePurchaseBusiness.showJCApplePurchaseBusinessInstance.savePayOrder(applePayOrderItem: appleOrderItemModel)
        }

        //////////////////////////////网络请求 <校验appstore信息>/////////////////////////
        
        // 此处发起网络请求，校验Appstore信息，通过校验后给用户提供具体的服务
        // 若不为漏单处理可将回调拿出进行其他业务操作
        if (!isLeakList) {
            if let _ = self.paySuccessedBlock {
                self.paySuccessedBlock!()
            }
        }
        // 移除待漏单处理的列表信息
        JCApplePurchaseBusiness.showJCApplePurchaseBusinessInstance.delectPayOrder(payVerifyReceiptModel: payVerifyReceiptModel)
        
        /////////////////////////////////////////////////////////////////////////////

    }
}





