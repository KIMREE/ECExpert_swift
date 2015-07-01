//
//  TradeRecordViewController.swift
//  ECExpert
//
//  Created by Fran on 15/6/25.
//  Copyright (c) 2015年 Fran. All rights reserved.
//

import UIKit

enum TradeRecordType: Int{
    case Customer = 0
    case Dealer, Gift
}

class TradeRecordViewController: BasicViewController, UITableViewDelegate, UITableViewDataSource {
    
    static let CellIdentifier = "CellIdentifier"
    private let tradeRecordType: TradeRecordType
    
    private var customerInfo: NSDictionary!
    private var dealerInfo: NSDictionary!
    
    private let manager = AFNetworkingFactory.networkingManager()
    
    private var tableView: UITableView!
    
    // 查询出来的数据
    private var recordArray: NSMutableArray = NSMutableArray()
    
    // 组装后显示到界面的数据
    // section header title
    private var sectionArray: NSMutableArray = NSMutableArray()
    // section row data
    private var sectionCellDic: NSMutableDictionary = NSMutableDictionary()
    
    private var pageNo = 1
    private var pageSize = 15
    private var recordOwnerId = ""
    private var usertype: Int!
    
    private var params: NSMutableDictionary = NSMutableDictionary()
    
    init(tradeRecordType: TradeRecordType){
        self.tradeRecordType = tradeRecordType
        super.init(nibName: nil, bundle: nil)
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        self.init(tradeRecordType: TradeRecordType.Customer)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.needLogin = true
        
        switch tradeRecordType{
        case .Customer:
            self.title = i18n("My spending record")
        case .Dealer:
            self.title = i18n("Transaction records")
        case .Gift:
            self.title = i18n("Distributed gifts record")
        }
        
        setUpNeedData()
        setUpView()
        
        // refresh
        tableView.footer = MJRefreshAutoNormalFooter(refreshingTarget: self, refreshingAction: "refresh")
        tableView.footer.beginRefreshing()
        let footer = tableView.footer as! MJRefreshAutoNormalFooter
        footer.stateLabel.textColor = UIColor.whiteColor()
    }
    
    func refresh(){
        self.progressHUD?.mode = MBProgressHUDMode.Indeterminate
        self.progressHUD?.labelText = ""
        self.progressHUD?.detailsLabelText = ""
        self.progressHUD?.show(true)
        
        manager.POST(APP_URL_TRADE_RECORD, parameters: params, success: { [unowned self](operation: AFHTTPRequestOperation!, responseObj: AnyObject!) -> Void in
            let dic = responseObj as? NSDictionary
            let code = dic?["code"] as? NSInteger
            if code != nil && code == 1{
                let datas = dic!["data"] as! NSArray
                self.recordArray.addObjectsFromArray(datas as [AnyObject])
                
                self.params.setValue(++self.pageNo, forKeyPath: "pageNo")
                self.changeArryToShowType()
                
            }else{
                KMLog("\(responseObj)")
            }
            self.tableView.footer.endRefreshing()
            self.progressHUD?.hide(true)
            
            }) { [unowned self](operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
            self.progressHUD?.hide(true)
            self.tableView.footer.endRefreshing()
        }
    }
    
    func changeArryToShowType(){
        sectionArray.removeAllObjects()
        sectionCellDic.removeAllObjects()
        
        for item in recordArray{
            let dic = item as! NSDictionary
            let sectionTitle = (dic["trade_time"] as! NSString).substringWithRange(NSMakeRange(0, 10))
            if !self.sectionArray.containsObject(sectionTitle){
                sectionArray.addObject(sectionTitle)
            }
            
            var sectionData = sectionCellDic.objectForKey(sectionTitle) as? NSMutableArray
            if sectionData == nil{
                sectionData = NSMutableArray()
                sectionCellDic.setObject(sectionData!, forKey: sectionTitle)
            }
            sectionData?.addObject(dic)
        }
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpNeedData(){
        let loginUserInfo = currentAppDelegate().loginUserInfo
        switch tradeRecordType{
        case .Customer:
            self.customerInfo = loginUserInfo
            self.recordOwnerId = loginUserInfo!["customer_id"] as! String
            self.usertype = loginUserInfo!["usertype"] as! Int
        case .Dealer:
            self.dealerInfo = loginUserInfo
            self.recordOwnerId = loginUserInfo!["dealer_id"] as! String
            self.usertype = loginUserInfo!["usertype"] as! Int
        case .Gift:
            KMLog("Gift")
        }
        
        params.setValue(pageNo, forKey: "pageNo")
        params.setValue(pageSize, forKey: "pageSize")
        params.setValue(recordOwnerId, forKey: "id")
        params.setValue(usertype, forKey: "type")
    }
    
    func setUpView(){
        tableView = UITableView(frame: getVisibleFrame())
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = RGBA(0, 0, 0, 0.3)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        self.view.addSubview(tableView)
    }
    
    // MARK: - UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sectionArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionCellDic.objectForKey(self.sectionArray.objectAtIndex(section))!.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionArray.objectAtIndex(section) as? String
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier(TradeRecordViewController.CellIdentifier) as? UITableViewCell
        if cell == nil{
            cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: TradeRecordViewController.CellIdentifier)
            cell!.backgroundColor = UIColor.clearColor()
            cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
            
            cell!.textLabel!.textColor = UIColor.whiteColor()
            cell!.detailTextLabel!.textColor = UIColor.whiteColor()
            cell?.selectionStyle = UITableViewCellSelectionStyle.None
        }
        
        let cellDic = sectionCellDic.objectForKey(sectionArray.objectAtIndex(indexPath.section))?.objectAtIndex(indexPath.row) as! NSDictionary
        let tradeNo = cellDic.objectForKey("trade_no") as? String
        let tradeTime = cellDic.objectForKey("trade_time") as? String
        cell!.textLabel!.text = i18n("Order Number") + ":\(tradeNo!)"
        cell!.detailTextLabel!.text = i18n("Trade Time") + ":\(tradeTime!)"
        
        return cell!
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        
        let sectionKey = sectionArray.objectAtIndex(section) as! String
        let cellDic = (sectionCellDic.objectForKey(sectionKey) as! NSArray).objectAtIndex(row) as! NSDictionary
        KMLog("\(cellDic)")
        
        let itemVC = TradeItemViewController(tradeRecordItemInfo: cellDic, tradeRecordType: self.tradeRecordType)
        self.navigationController?.pushViewController(itemVC, animated: true)
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
