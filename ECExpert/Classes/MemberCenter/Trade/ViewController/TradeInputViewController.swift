//
//  TradeInputViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/26.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

class TradeInputViewController: BasicViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let CellIdentifier = "cellIdentifier"
    static let DeleteButtonTag = 101
    
    private var tableView: UITableView!
    
    private var manager = AFNetworkingFactory.networkingManager()
    
    private var customerArray = NSMutableArray()
    private var productArray = NSMutableArray()
    private var giftArray = NSMutableArray()
    
    private var dateTypeString = "yyyy-MM-dd"
    private var dateFormatter = NSDateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.needLogin = true
        dateFormatter.dateFormat = dateTypeString
        
        self.title = i18n("Input transactions")
        
        setUpView()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Save, target: self, action: "saveRecord:")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func saveRecord(sender: AnyObject!){
        if productArray.count > 0 && customerArray.count > 0{
            let alertView = UIAlertView(title: "", message: i18n("Determine the input information?"), delegate: nil, cancelButtonTitle: i18n("Cancel"), otherButtonTitles: i18n("Sure"))
            alertView.showAlertViewWithCompleteBlock({ (buttonIndex) -> Void in
                if buttonIndex == 1{
                    self.commitAddRecord()
                }
            })
        }else{
            let alertView = UIAlertView(title: nil, message: i18n("The input information is insufficient, unable to complete the transaction."), delegate: nil, cancelButtonTitle: i18n("Cancel"))
            alertView.show()
        }
    }
    
    func commitAddRecord(){
        let params = NSMutableDictionary()
        params.setObject((customerArray.firstObject as! NSDictionary).objectForKey("customer_id")!, forKey: "customer_id")
        params.setObject(currentAppDelegate().loginUserInfo!["dealer_id"]!, forKey: "dealer_id")
        
        let tradeProducts = NSMutableArray()
        for item in productArray{
            let product = item as! ProductModel
            let dic = NSMutableDictionary()
            dic["scanCode"] = product.scanCode
            dic["totalCount"] = product.totalCount
            tradeProducts.addObject(dic)
        }
        let productJsonData = NSJSONSerialization.dataWithJSONObject(tradeProducts, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        if productJsonData != nil{
            let productJson = NSString(data: productJsonData!, encoding: NSUTF8StringEncoding)
            params["main_products"] = productJson
        }
        
        let tradeGifts = NSMutableArray()
        for item in giftArray{
            let gift = item as! ProductModel
            let dic = NSMutableDictionary()
            dic["scanCode"] = gift.scanCode
            dic["totalCount"] = gift.totalCount
            tradeGifts.addObject(dic)
        }
        let giftJsonData = NSJSONSerialization.dataWithJSONObject(tradeGifts, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        if giftJsonData != nil{
            let giftJson = NSString(data: giftJsonData!, encoding: NSUTF8StringEncoding)
            params["gift_products"] = giftJson
        }
        
        self.progressHUD?.mode = MBProgressHUDMode.Indeterminate
        self.progressHUD?.labelText = ""
        self.progressHUD?.detailsLabelText = ""
        self.progressHUD?.show(true)
        manager.POST(APP_URL_TRADE_INPUT, parameters: params, success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let dic = responseObj as? NSDictionary
            let code = dic?["code"] as? NSInteger
            if code != nil && code == 1{
                self.progressHUD?.mode = MBProgressHUDMode.Text
                self.progressHUD?.detailsLabelText = dic!["data"] as! String
                self.progressHUD?.minShowTime = 2
                self.progressHUD?.showAnimated(true, whileExecutingBlock: { () -> Void in
                    
                }, completionBlock: { () -> Void in
                    self.navigationController?.popViewControllerAnimated(true)
                })
                
            }else if code != nil && code == 0{
                self.progressHUD?.mode = MBProgressHUDMode.Text
                self.progressHUD?.detailsLabelText = dic!["data"] as! String
                self.hideProgressHUD(2)
            }else{
                KMLog("\(dic)")
                self.hideProgressHUD()
            }
            
            }) { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                self.progressHUD?.mode = MBProgressHUDMode.Text
                self.progressHUD?.labelText = i18n("Failed to connect link to server!")
                self.progressHUD?.detailsLabelText = error.localizedDescription
                self.hideProgressHUD(2)
        }
    }
    
    func setUpView(){
        tableView = UITableView(frame: getVisibleFrame())
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = RGBA(0, 0, 0, 0.3)
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.view.addSubview(tableView)
    }
    
    override func goback() {
        let alertView = UIAlertView(title: i18n("Give up the change?"), message: i18n("Give up modifying data?"), delegate: nil, cancelButtonTitle: i18n("Sure"), otherButtonTitles: i18n("Cancel"))
        alertView.showAlertViewWithCompleteBlock {(buttonIndex) -> Void in
            if buttonIndex == 0{
                super.goback()
            }
        }
        
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 1{
            let detailVC = ProductDetailViewController(product: productArray.objectAtIndex(row) as! ProductModel, productArray: productArray, fromTableView: tableView, pageDataType: ProductDetailPageDataType.Main, pageEditType: ProductDetailPageEditType.All)
            self.navigationController?.pushViewController(detailVC, animated: true)
            
        }else if section == 2{
            let detailVC = ProductDetailViewController(product: giftArray.objectAtIndex(row) as! ProductModel, productArray: giftArray, fromTableView: tableView, pageDataType: ProductDetailPageDataType.Gift, pageEditType: ProductDetailPageEditType.All)
            self.navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor.lightGrayColor()
        
        let height = self.tableView(tableView, heightForHeaderInSection: section)
        let padding: CGFloat = 10
        let labelH: CGFloat = 20
        let titleLabel = UILabel(frame: CGRectZero)
        titleLabel.numberOfLines = 1
        titleLabel.textColor = UIColor.whiteColor()
        
        let buttonW: CGFloat = 30
        let buttonH: CGFloat = 30
        let buttonFrame = CGRectMake( KM_FRAME_SCREEN_WIDTH - buttonW - padding , (height - buttonH) / 2.0 , buttonW, buttonH)
        let addButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
        addButton.frame = buttonFrame
        addButton.tintColor = UIColor.whiteColor()
        
        view.addSubview(titleLabel)
        view.addSubview(addButton)
        
        
        if section == 0{
            titleLabel.text = i18n("Buyer")
            addButton.addTarget(self, action: "addBuyerAction", forControlEvents: UIControlEvents.TouchUpInside)
        }else if section == 1{
            titleLabel.text = i18n("Goods List")
            addButton.addTarget(self, action: "addProductAction", forControlEvents: UIControlEvents.TouchUpInside)
        }else{
            titleLabel.text = i18n("Gift List")
            addButton.addTarget(self, action: "addGiftAction", forControlEvents: UIControlEvents.TouchUpInside)
        }
        
        let labelSize = titleLabel.sizeThatFits(CGSizeZero)
        let labelFrame = CGRectMake(padding, (height - labelH) / 2.0, labelSize.width, labelH)
        titleLabel.frame = labelFrame
        
        return view
    }
    
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRectZero)
        view.backgroundColor = UIColor.clearColor()
        return view
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    
    // MARK: - section header view button action
    func addBuyerAction(){
        let scanVC = ScanViewController(scanType: ScanType.QRCode) { (scanViewControlelr: ScanViewController, scanResult: String) -> Void in
            scanViewControlelr.goback()
            
            let jsonData = scanResult.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            var error: NSError?
            let jsonDic = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableLeaves, error: &error) as? NSDictionary
            
            self.progressHUD?.mode = MBProgressHUDMode.Indeterminate
            self.progressHUD?.labelText = ""
            self.progressHUD?.detailsLabelText = ""
            self.progressHUD?.show(true)
            if error == nil{
                self.manager.POST(APP_URL_CHECKVIP, parameters: jsonDic, success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
                    let dic = responseObj as? NSDictionary
                    let code = dic?["code"] as? NSInteger
                    if code != nil && code == 1{
                        let customerDic = dic!["data"] as! NSDictionary
                        self.customerArray.removeAllObjects()
                        self.customerArray.addObject(customerDic)
                        
                        self.tableView.reloadData()
                        self.hideProgressHUD()
                    }else if code != nil && code == 0{
                        self.progressHUD?.mode = MBProgressHUDMode.Text
                        self.progressHUD?.detailsLabelText = dic!["data"] as! String
                        self.hideProgressHUD(2)
                    }else{
                        KMLog("\(dic)")
                        self.hideProgressHUD()
                    }
                    
                    }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        self.progressHUD?.mode = MBProgressHUDMode.Text
                        self.progressHUD?.labelText = i18n("Failed to connect link to server!")
                        self.progressHUD?.detailsLabelText = error.localizedDescription
                        self.hideProgressHUD(2)
                })
            }else{
                self.progressHUD?.mode = MBProgressHUDMode.Text
                self.progressHUD?.detailsLabelText = i18n("Invalid two-dimensional code")
                self.hideProgressHUD(2)
            }
            
        }
        scanVC.title = i18n("Scan customer VIP card")
        self.navigationController?.pushViewController(scanVC, animated: true)
    }
    
    func addProductAction(){
        let scanVC = ScanViewController(scanType: ScanType.BarCode) { (scanViewControlelr: ScanViewController, scanResult: String) -> Void in
            scanViewControlelr.goback()
            
            var product: ProductModel?
            for item in self.productArray{
                let p = item as! ProductModel
                if p.scanCode == scanResult{
                    product = p
                    break
                }
            }
            
            if product != nil{
                product?.totalCount++
                self.productArray.removeObject(product!)
                self.productArray.insertObject(product!, atIndex: 0)
                self.tableView.reloadData()
                
            }else{
                let params = ["scancode": scanResult]
                
                self.progressHUD?.mode = MBProgressHUDMode.Indeterminate
                self.progressHUD?.labelText = ""
                self.progressHUD?.detailsLabelText = ""
                self.progressHUD?.show(true)
                self.manager.POST(APP_URL_SCAN_BAR_CODE, parameters: params, success: { (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
                    let dic = responseObj as? NSDictionary
                    let code = dic?["code"] as? NSInteger
                    if code != nil && code == 1{
                        let product = ProductModel.productWithKeyValues(dic!["data"] as! [NSObject : AnyObject]!)
                        product.scanCode = scanResult
                        product.totalCount = 1
                        
                        self.productArray.insertObject(product, atIndex: 0)
                        self.tableView.reloadData()
                        self.hideProgressHUD()
                        
                    }else if code != nil && code == 0{
                        self.progressHUD?.mode = MBProgressHUDMode.Text
                        self.progressHUD?.detailsLabelText = dic!["data"] as! String
                        self.hideProgressHUD(2)
                    }else{
                        KMLog("\(dic)")
                        self.hideProgressHUD()
                    }
                    }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        self.progressHUD?.mode = MBProgressHUDMode.Text
                        self.progressHUD?.labelText = i18n("Failed to connect link to server!")
                        self.progressHUD?.detailsLabelText = error.localizedDescription
                        self.hideProgressHUD(2)
                })
            }
        }
        scanVC.title = i18n("Scan product bar code")
        self.navigationController?.pushViewController(scanVC, animated: true)
    }
    
    func addGiftAction(){
        let scanVC = ScanViewController(scanType: ScanType.BarCode) {  (scanViewControlelr: ScanViewController, scanResult: String) -> Void in
            scanViewControlelr.goback()
            
            var product: ProductModel?
            for item in self.giftArray{
                let p = item as! ProductModel
                if p.scanCode == scanResult{
                    product = p
                    break
                }
            }
            
            if product != nil{
                product?.totalCount++
                self.giftArray.removeObject(product!)
                self.giftArray.insertObject(product!, atIndex: 0)
                self.tableView.reloadData()
                
            }else{
                let params = ["scancode": scanResult]
                
                self.progressHUD?.mode = MBProgressHUDMode.Indeterminate
                self.progressHUD?.labelText = ""
                self.progressHUD?.detailsLabelText = ""
                self.progressHUD?.show(true)
                self.manager.POST(APP_URL_SCAN_BAR_CODE, parameters: params, success: {  (operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
                    let dic = responseObj as? NSDictionary
                    let code = dic?["code"] as? NSInteger
                    if code != nil && code == 1{
                        let product = ProductModel.productWithKeyValues(dic!["data"] as! [NSObject : AnyObject]!)
                        product.scanCode = scanResult
                        product.totalCount = 1
                        
                        self.giftArray.insertObject(product, atIndex: 0)
                        self.tableView.reloadData()
                        self.hideProgressHUD()
                        
                    }else if code != nil && code == 0{
                        self.progressHUD?.mode = MBProgressHUDMode.Text
                        self.progressHUD?.detailsLabelText = dic!["data"] as! String
                        self.hideProgressHUD(2)
                    }else{
                        KMLog("\(dic)")
                        self.hideProgressHUD()
                    }
                    }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        self.progressHUD?.mode = MBProgressHUDMode.Text
                        self.progressHUD?.labelText = i18n("Failed to connect link to server!")
                        self.progressHUD?.detailsLabelText = error.localizedDescription
                        self.hideProgressHUD(2)
                })
            }
        }
        scanVC.title = i18n("Scan gift bar code")
        self.navigationController?.pushViewController(scanVC, animated: true)
    }
    
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1 {
            if productArray.count > 0{
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
        var cell = UIFactory.tableViewCellForTableView(tableView, cellIdentifier: TradeInputViewController.CellIdentifier, cellType: UITableViewCellStyle.Subtitle, cleanCellContentView: false) {  (tableViewCell: UITableViewCell!) -> Void in
            
            tableViewCell?.backgroundColor = UIColor.clearColor()
            tableViewCell?.textLabel?.textColor = UIColor.whiteColor()
            tableViewCell?.detailTextLabel?.textColor = UIColor.whiteColor()
            
            let buttonW: CGFloat = 22
            let buttonH: CGFloat = 22
            let cellHeight = self.tableView(tableView, heightForRowAtIndexPath: indexPath)
            let deleteButton = UIButton.buttonWithType(UIButtonType.Custom) as? UIButton
            deleteButton!.frame = CGRectMake(KM_FRAME_SCREEN_WIDTH - 10 - buttonW - 30, (cellHeight - buttonH) / 2.0, buttonW, buttonH)
            deleteButton!.tag = TradeInputViewController.DeleteButtonTag
            deleteButton!.backgroundColor = UIColor.clearColor()
            deleteButton!.setImage(UIImage(named: "button_minus"), forState: UIControlState.Normal)
            deleteButton!.addTarget(self, action: "deleteSelectCellDataAction:", forControlEvents: UIControlEvents.TouchUpInside)
            tableViewCell?.contentView.addSubview(deleteButton!)
            
            tableViewCell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        var deleteButton = cell?.contentView.viewWithTag(TradeInputViewController.DeleteButtonTag) as? UIButton
        deleteButton?.hidden = false
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0{
            if customerArray.count > 0{
                cell!.accessoryType = UITableViewCellAccessoryType.None
                let customer = customerArray.firstObject as! NSDictionary
                var customerName = customer["customer_nickname"] as? String
                if customerName == nil || customerName!.isEmpty{
                    customerName = customer["customer_name"] as? String
                }
                let customerVip = customer["customer_vip"] as? String
                var contact = customer["customer_phone"] as? String
                
                let connect = i18n("Connection way")
                cell?.textLabel?.text = "\(customerName!)(\(connect):\(contact!))"
                let vip = i18n("VIP")
                cell?.detailTextLabel?.text = "\(vip):\(customerVip!)"
            }else{
                emptyCell(cell!, text: i18n("Please select the buyer"), deleteButton: deleteButton!)
            }
            
        }else if section == 1{
            if productArray.count > 0{
                let product: ProductModel! = productArray.objectAtIndex(row) as! ProductModel
                let productName = product.productNameZH.isEmpty ? product.productNameEN : product.productNameZH
                let totalCount = product.totalCount
                let tc = i18n("Total count")
                
                cell?.textLabel?.text = productName
                cell?.detailTextLabel?.text = "\(tc):\(totalCount)"
                
            }else{
                emptyCell(cell!, text: i18n("Please select the goods"), deleteButton: deleteButton!)
            }
        
        }else{
            if giftArray.count > 0 {
                let product: ProductModel! = giftArray.objectAtIndex(row) as! ProductModel
                let productName = product.productNameZH.isEmpty ? product.productNameEN : product.productNameZH
                let totalCount = product.totalCount
                let tc = i18n("Total count")
                
                cell?.textLabel?.text = productName
                cell?.detailTextLabel?.text = "\(tc):\(totalCount)"
                
            }else{
                emptyCell(cell!, text: i18n("Please select the gift"), deleteButton: deleteButton!)
            }
            
        }
        
        return cell!
    }
    
    func emptyCell(cell: UITableViewCell,text: String, deleteButton: UIButton){
        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = ""
        cell.imageView?.image = nil
        
        deleteButton.hidden = true
    }
    
    func deleteSelectCellDataAction(sender: AnyObject!){
        let cell = (sender as! UIButton).superview?.superview as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)
        
        let alertView = UIAlertView(title: i18n("Hint"), message: i18n("Remove the selected data?"), delegate: nil, cancelButtonTitle: i18n("Cancel"), otherButtonTitles: i18n("Sure"))
        alertView.showAlertViewWithCompleteBlock {[unowned self, indexPath] (buttonIndex) -> Void in
            if buttonIndex == 1{
                let section = indexPath?.section
                let row = indexPath?.row
                if section == 0{
                    self.customerArray.removeObjectAtIndex(row!)
                }else if section == 1{
                    self.productArray.removeObjectAtIndex(row!)
                }else{
                    self.giftArray.removeObjectAtIndex(row!)
                }
                self.tableView.reloadData()
            }
        }
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
