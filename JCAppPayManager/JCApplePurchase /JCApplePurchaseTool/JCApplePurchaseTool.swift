
import UIKit
import StoreKit

class JCApplePurchaseTool: NSObject {
    
    // MARK: - Defined Attribute
    
    typealias GetProductListBlock = ([SKProduct]?) -> ()
    public var getProductListBlock : GetProductListBlock? = nil
    
    typealias ProductPaySucInfoBlock = (String, [String : Any]) -> ()
    public var productPaySucInfoBlock : ProductPaySucInfoBlock? = nil
    
    // MARK: - Init Method
    
    static let showJCApplePurchaseToolInstance = JCApplePurchaseTool()
    
    private override init() {
        
        super.init()
    }
    
    // MARK: - InitData
    
    func initData() {
    
    }
    
    // MARK: - Config Data
    
    func configSelf() {
        
    }
    
    func getGoodsList(ids:Set<String>) -> Bool {
        
        if gotoApplePay() {
            let request :SKProductsRequest = SKProductsRequest(productIdentifiers: ids) // 验证支付项目
            request.delegate = self
            request.start()
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Event Response
    
    // MARK: - NSNotificationCenter Method
    
    // MARK: - other Method
    
    //验证是否允许应用内支付
    func gotoApplePay() -> Bool {
        
        return SKPaymentQueue.canMakePayments()
    }
    
    // 恢复购买
    func retortBuyClick() {
        
        SKPaymentQueue.default().restoreCompletedTransactions()
        SKPaymentQueue.default().add(self)
    }
    
    // 根据商品id购买
    func payProduct(product: SKProduct) {
        
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
        SKPaymentQueue.default().add(self)
    }
    
    func completeTransaction(transaction: SKPaymentTransaction) {
        
        var sandBox = 0
        #if TEST_ENV
        #else
            sandBox = 1
        #endif
        
        let productIdentifier = transaction.payment.productIdentifier
        let url = Bundle.main.appStoreReceiptURL
        let appstoreRequest = URLRequest.init(url: url!)
        do {
            let reciptaData = try NSURLConnection.sendSynchronousRequest(appstoreRequest, returning: nil)
            let transactionRecipsting: String = reciptaData.base64EncodedString(options: .endLineWithLineFeed)
            let str = transactionRecipsting.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let dict = ["sandbox":sandBox,"receipt":str] as [String : Any]
            if let _ = self.productPaySucInfoBlock {
                self.productPaySucInfoBlock!(productIdentifier, dict)
            }
        } catch let error as NSError {
            print(error)
        }
    }
    
    // 获取商品信息
    func logProductInfo(product : SKProduct) {
        
        let title = product.localizedTitle
        let description = product.description
        let localizedDescription = product.localizedDescription
        let price = product.price
        let productIdentifier = product.productIdentifier
        
        print("产品标题: \(title)")
        print("描述信息: \(description)")
        print("产品描述信息: \(localizedDescription)")
        print("价格: \(price)")
        print("productIdentifier: \(productIdentifier)")
    }
    
    // MARK: - Getters & Setters
    
    // MARK: - Deinit Method
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
        SKPaymentQueue.default().remove(self)
    }
}

// MARK: - System Delegate

// MARK: - Custom Delegate

extension JCApplePurchaseTool: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if let _ = self.getProductListBlock {
            self.getProductListBlock!(response.products)
        }
    }
}

//MARK:交易队列的监听者
extension JCApplePurchaseTool : SKPaymentTransactionObserver {
    
    //当交易队列列名添加的每一笔交易状态发生变化的时候调用
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .deferred:
                print("延时处理")
            case .failed:
                print("支付失败")
                //应该移除交易队列
                queue.finishTransaction(transaction)
            case .purchased:
                print("支付成功")
                self.completeTransaction(transaction: transaction)
                //应该移除交易队列
                queue.finishTransaction(transaction)
            case .purchasing:
                print("正在支付")
            case .restored:
                print("恢复购买")
                //应该移除交易队列
                self.retortBuyClick()
                queue.finishTransaction(transaction)
            }
        }
    }
    
}
