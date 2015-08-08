//
//  TradeItemViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/29.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class TradeItemViewController: BasicViewController , UITableViewDelegate, UITableViewDataSource{
    
    static let CellIdentifier = "CellIdentifier"
    
    var tradeRecordType: TradeRecordType
    var tradeRecordItemInfo: NSDictionary
    
    private var dealerArray = NSMutableArray()
    private var customerArray = NSMutableArray()
    private var productArray = NSMutableArray()
    private var giftArray = NSMutableArray()
    
    private var manager = AFNetworkingFactory.networkingManager()
    
    private var tableView: UITableView!
    
    init(tradeRecordItemInfo: NSDictionary, tradeRecordType: TradeRecordType){
        self.tradeRecordItemInfo = tradeRecordItemInfo
        self.tradeRecordType = tradeRecordType
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.needLogin = true
        self.title = i18n("Trade record detail")
        
        setUpData()
        setUpView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpData(){
        let params = ["tradeno": tradeRecordItemInfo.objectForKey("trade_no")!]
        self.progressHUD?.mode = MBProgressHUDMode.Indeterminate
        self.progressHUD?.labelText = ""
        self.progressHUD?.detailsLabelText = ""
        self.progressHUD?.show(true)
        manager.POST(APP_URL_TRADE_RECORD_DETAIL, parameters: params , success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let dic = responseObj as? NSDictionary
            let code = dic?["code"] as? NSInteger
            if code != nil && code == 1{
                let data = dic!["data"] as! NSDictionary
                
                let customerDic = NSMutableDictionary()
                customerDic.setObject(data["customer_id"]!, forKey: "customer_id")
                customerDic.setObject(data["customer_nickname"]!, forKey: "customer_nickname")
                customerDic.setObject(data["customer_vip"]!, forKey: "customer_vip")
                self.customerArray.addObject(customerDic)
                
                let dealerDic = NSMutableDictionary()
                dealerDic.setObject(data["dealer_id"]!, forKey: "dealer_id")
                dealerDic.setObject(data["dealer_company"]!, forKey: "dealer_company")
                self.dealerArray.addObject(dealerDic)
                
                let products = data["products"] as? NSArray
                if products != nil{
                    for item in products! {
                        let product = item as! NSDictionary
                        let model = ProductModel()
                        model.scanCode = product["productcode"] as! String
                        model.totalCount = (product["productnum"] as! NSString).integerValue
                        model.productNameZH = product["productname"] as! String
                        self.productArray.addObject(model)
                    }
                }
                
                let gifts = data["gifts"] as? NSArray
                if gifts != nil{
                    for item in gifts! {
                        let product = item as! NSDictionary
                        let model = ProductModel()
                        model.scanCode = product["giftcode"] as! String
                        model.totalCount = (product["giftnum"] as! NSString).integerValue
                        model.productNameZH = product["giftname"] as! String
                        self.giftArray.addObject(model)
                    }
                }
                
                if self.tableView != nil{
                    self.tableView.reloadData()
                }
                self.hideProgressHUD()
                
            }else if code != nil && code == 0{
                self.progressHUD?.mode = MBProgressHUDMode.Text
                self.progressHUD?.detailsLabelText = dic!["data"] as! String
                self.hideProgressHUD(2)
            }else{
                KMLog("\(dic)")
                self.hideProgressHUD()
            }
            
            }) {(operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                self.progressHUD?.mode = MBProgressHUDMode.Text
                self.progressHUD?.labelText = i18n("Failed to connect link to server!")
                self.progressHUD?.detailsLabelText = error.localizedDescription
                self.hideProgressHUD(2)
        }
    }
    
    func setUpView(){
        let visibleFrame = getVisibleFrame()
        
        let headerFrame = CGRectMake(visibleFrame.origin.x, visibleFrame.origin.y, visibleFrame.size.width, 80)
        let headerView = UIView(frame: headerFrame)
        
        let finishTime = self.tradeRecordItemInfo.objectForKey("trade_time") as! String
        let finish = i18n("Order completion time")
        let labelFrame = CGRectMake(10, 40, headerFrame.size.width - 2 * 10, 40)
        let labelText = "\(finish):\(finishTime)"
        let label = UIFactory.labelWithFrame(labelFrame, text: labelText, textColor: UIColor.whiteColor(), numberOfLines: 1, textAlignment: NSTextAlignment.Center)
        
        let tradeNoLabel = UIFactory.labelWithFrame(CGRectMake(10, 0, headerFrame.size.width - 2 * 10, 40), text: self.tradeRecordItemInfo.objectForKey("trade_no") as! String, textColor: UIColor.whiteColor(), numberOfLines: 1, textAlignment: NSTextAlignment.Center)
        
        headerView.addSubview(tradeNoLabel)
        headerView.addSubview(label)
        self.view.addSubview(headerView)
        
        let tableViewFrame = CGRectMake(visibleFrame.origin.x, visibleFrame.origin.y + headerFrame.size.height, visibleFrame.size.width, visibleFrame.size.height - headerFrame.size.height)
        tableView = UITableView(frame: tableViewFrame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView(frame: CGRectZero)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.backgroundColor = RGBA(0, 0, 0, 0.3)
        self.view.addSubview(tableView)
        
    }
    
    // MARK: - UITableViewDelegate
    func showRecordDetail(indexPath: NSIndexPath){
        let section = indexPath.section
        let row = indexPath.row
        var product: ProductModel!
        if section == 1{
            product = productArray.objectAtIndex(row) as! ProductModel
        }else if section == 2{
            product = giftArray.objectAtIndex(row) as! ProductModel
        }
        
        if product.barCodeImageUrl != nil && !product.barCodeImageUrl.isEmpty{
            if section == 1{
                let detailVC = ProductDetailViewController(product: product, productArray: productArray, fromTableView: tableView, pageDataType: ProductDetailPageDataType.Main, pageEditType: ProductDetailPageEditType.None)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }else if section == 2{
                let detailVC = ProductDetailViewController(product: product, productArray: giftArray, fromTableView: tableView, pageDataType: ProductDetailPageDataType.Gift, pageEditType: ProductDetailPageEditType.None)
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }else{
            
            let params = ["scancode": product.scanCode]
            self.progressHUD?.mode = MBProgressHUDMode.Indeterminate
            self.progressHUD?.labelText = ""
            self.progressHUD?.detailsLabelText = ""
            self.progressHUD?.show(true)
            manager.POST(APP_URL_SCAN_BAR_CODE, parameters: params, success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
                let dic = responseObj as? NSDictionary
                let code = dic?["code"] as? NSInteger
                if code != nil && code == 1{
                    let model = ProductModel.productWithKeyValues(dic!["data"] as! [NSObject : AnyObject]!)
                    model.totalCount = product.totalCount
                    model.scanCode = product.scanCode
                    
                    self.hideProgressHUD()
                    
                    if section == 1{
                        let index = self.productArray.indexOfObject(product)
                        self.productArray.insertObject(model, atIndex: index)
                        let detailVC = ProductDetailViewController(product: model, productArray: self.productArray, fromTableView: self.tableView, pageDataType: ProductDetailPageDataType.Main, pageEditType: ProductDetailPageEditType.None)
                        self.navigationController?.pushViewController(detailVC, animated: true)
                        
                    }else if section == 2{
                        let index = self.giftArray.indexOfObject(product)
                        self.giftArray.insertObject(model, atIndex: index)
                        let detailVC = ProductDetailViewController(product: model, productArray: self.giftArray, fromTableView: self.tableView, pageDataType: ProductDetailPageDataType.Gift, pageEditType: ProductDetailPageEditType.None)
                        self.navigationController?.pushViewController(detailVC, animated: true)
                    }
                    
                }else if code != nil && code == 0{
                    self.progressHUD?.mode = MBProgressHUDMode.Text
                    self.progressHUD?.detailsLabelText = dic!["data"] as! String
                    self.hideProgressHUD(2)
                }else{
                    KMLog("\(dic)")
                    self.hideProgressHUD()
                }
                
                }, failure: {(operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    self.progressHUD?.mode = MBProgressHUDMode.Text
                    self.progressHUD?.labelText = i18n("Failed to connect link to server!")
                    self.progressHUD?.detailsLabelText = error.localizedDescription
                    self.hideProgressHUD(2)
            })
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        if section == 1 && productArray.count > 0{
            showRecordDetail(indexPath)
        }else if section == 2 && giftArray.count > 0{
            showRecordDetail(indexPath)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor.lightGrayColor()
        
        let height = self.tableView(tableView, heightForHeaderInSection: section)
        let labelFrame = CGRectMake(10, (height - 21) / 2.0, KM_FRAME_SCREEN_WIDTH - 2 * 10, 21)
        var text = ""
        if section == 0{
            switch tradeRecordType{
            case .Customer:
                text = i18n("Purchase address")
            case .Dealer, .Gift:
                text = i18n("Buyer")
            }
        }else if section == 1{
            text = i18n("Goods List")
        }else{
            text = i18n("Gift List")
        }
        let label = UIFactory.labelWithFrame(labelFrame, text: text, textColor: UIColor.whiteColor(), numberOfLines: 1)
        view.addSubview(label)
        
        return view
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor.whiteColor()
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            if productArray.count > 0 {
                return productArray.count
            }else{
                return 1
            }
        }else{
            if giftArray.count > 0 {
                return giftArray.count
            }else{
                return 1
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UIFactory.tableViewCellForTableView(tableView, cellIdentifier: TradeItemViewController.CellIdentifier, cellType: UITableViewCellStyle.Subtitle) { (tableViewCell: UITableViewCell!) -> Void in
            
            tableViewCell!.backgroundColor = UIColor.clearColor()
            tableViewCell!.textLabel?.textColor = UIColor.whiteColor()
            tableViewCell!.detailTextLabel?.textColor = UIColor.whiteColor()
            tableViewCell!.selectionStyle = UITableViewCellSelectionStyle.None
        }

        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        let section = indexPath.section
        let row = indexPath.row
        let countUnit = i18n("Total count")
        
        if section == 0{
            cell?.accessoryType = UITableViewCellAccessoryType.None
            switch tradeRecordType{
            case .Customer:
                if dealerArray.count > 0{
                    let dealer = dealerArray.firstObject as! NSDictionary
                    cell?.textLabel?.text = dealer["dealer_company"] as? String
                }else{
                    cell?.textLabel?.text = i18n("No seller information")
                }
                
            case .Dealer, .Gift:
                if customerArray.count > 0{
                    let customer = customerArray.firstObject as! NSDictionary
                    let vipNo = i18n("VIP")
                    let vip = customer["customer_vip"] as! String
                    let nickName = customer["customer_nickname"] as! String
                    
                    cell?.textLabel?.text = nickName
                    cell?.detailTextLabel?.text = "\(vipNo):\(vip)"
                }else{
                    cell?.textLabel?.text = i18n("No user information")
                }
            }
            
        }else if section == 1{
            if productArray.count > 0{
                let product = productArray.objectAtIndex(row) as! ProductModel
                cell?.textLabel?.text = product.productNameZH
                cell?.detailTextLabel?.text = "\(countUnit):\(product.totalCount)"
                
            }else{
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell?.textLabel?.text = i18n("No commodity data")
            }
        }else{
            if giftArray.count > 0{
                let product = giftArray.objectAtIndex(row) as! ProductModel
                cell?.textLabel?.text = product.productNameZH
                cell?.detailTextLabel?.text = "\(countUnit):\(product.totalCount)"
                
            }else{
                cell?.accessoryType = UITableViewCellAccessoryType.None
                cell?.textLabel?.text = i18n("No gifts data")
            }
        }
        
        
        return cell!
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
