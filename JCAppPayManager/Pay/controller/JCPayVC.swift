
import UIKit
import StoreKit

class JCPayVC: UIViewController {
    
    // MARK: - Defined Attribute
    
    typealias  NormalBlock = () -> ()
    public var paySuccessedBlock : NormalBlock? = nil
    
    // MARK: - Life Circle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        initData()
        lazyCreateUI()
        layoutSubview()
        configApplePayTool()
        configBuyItem()
        
        //        1.appstore后台配置购买项
        //        2.后台书写购买项接口
        //        3.app获取后台购买项接口，请求苹果服务器拿到可销售的商品列表
        //        4.用户点击发起苹果支付，app根据业务生成订单，并校验是否在可销售列表内
        //        5.苹果发起扣款，转发回调，若成功将订单号及recide发送到服务器进行校验
        //        6.校验通过后，给用户提供可需的服务
        //        7.漏单处理逻辑
    }
    
    // MARK: - InitData
    
    func initData() {
        
        self.view.backgroundColor = UIColor.white
        self.title = "订单确认"
    }
    
    // MARK: - LazyCreateUI
    
    func lazyCreateUI() {

    }
    
    // MARK: - LayoutSubview
    
    func layoutSubview() {

    }
    
    func configBuyItem() {
        
        //////////////////////////////网络请求 <服务器购置项目>/////////////////////////

        // 首先网络请求服务器购置项目 canBuyList 然后请求校验appstore可销售项
        let canBuyResult = JCApplePurchaseBusiness.showJCApplePurchaseBusinessInstance.checkAppstoreBuyItem(canBuyList: nil)
        if !canBuyResult.canBuy {
            print(canBuyResult.mesage)
        }
    }
    
    func chooseShopToBuy() {
        
        
        //////////////////////////////网络请求 <获取业务订单>/////////////////////////

        // 用户点击发起苹果支付，app根据业务生成订单orderId，校验是否在可销售列表内,在的话发起苹果支付
        let orderId = "orderId"
        let price: Double = 998
        
        let canBuyResult = JCApplePurchaseBusiness.showJCApplePurchaseBusinessInstance.checkOrderInfoPayProductForAppStore(orderId: orderId, price: price)
        if !canBuyResult.canBuy {
            print(canBuyResult.mesage)
        }
    }
    
    // MARK: - Config Data
    
    // MARK: - Event Response
    
    // MARK: - NSNotificationCenter Method
    
    // MARK: - other Method
    
    public func configApplePayTool() {
        
        JCApplePurchaseBusiness.showJCApplePurchaseBusinessInstance.initData()
    }

    // MARK: - Getters & Setters
    
    // MARK: - Deinit Method
    
    deinit {
        
        print("JCPayVC deinit ~~~~")
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - MemoryWarning
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
}

// MARK: - System Delegate

// MARK: - Custom Delegate

//extension JCPayVC: CustomDelegateName {
//    
//}


